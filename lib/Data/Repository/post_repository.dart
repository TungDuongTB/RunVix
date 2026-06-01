import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:runvix/export.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> createPost(PostModel post, XFile? imageFile) async {
    try {
      String imageUrl = "";
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final postWithImage = PostModel(
        userId: post.userId,
        userName: post.userName,
        userProfilePicture: post.userProfilePicture,
        title: post.title,
        content: post.content,
        imageUrl: imageUrl,
        createdAt: DateTime.now(),
      );

      await _db.collection("Posts").add(postWithImage.toJson());
    } catch (e) {
      throw "Đã xảy ra lỗi khi đăng bài. Vui lòng thử lại!";
    }
  }

  Future<String> uploadImage(XFile image) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('https://api.cloudinary.com/v1_1/dz1z232l7/image/upload'),
      );
      request.fields['upload_preset'] = 'RunVix';
      final bytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: image.name,
      ));
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'];
      } else {
        print("Cloudinary Error: ${response.body}");
        final errorData = jsonDecode(response.body);
        throw errorData['error']['message'];
      }
    } catch (e) {
      print("Upload Error: $e");
      throw "Lỗi khi tải ảnh lên: $e";
    }
  }


  Future<Map<String, dynamic>> getPaginatedPosts(DocumentSnapshot? lastDocument, int limit, {String? currentUserId}) async {
    try {
      Query query = _db.collection("Posts")
          .orderBy("CreatedAt", descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(limit);
      
      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }
      
      final snapshot = await query.get();
      List<PostModel> posts = [];
      
      // Lấy danh sách UserId duy nhất và tải thông tin người dùng song song
      final userIds = snapshot.docs
          .map((doc) => (doc.data() as Map<String, dynamic>)["UserId"] as String)
          .where((id) => id.isNotEmpty)
          .toSet();
      
      Map<String, Map<String, dynamic>> userCache = {};
      if (userIds.isNotEmpty) {
        final userDocs = await Future.wait(userIds.map((id) => _db.collection("Users").doc(id).get()));
        for (var userDoc in userDocs) {
          if (userDoc.exists) {
            userCache[userDoc.id] = userDoc.data()!;
          }
        }
      }

      Set<String> likedPostIds = {};
      if (currentUserId != null && currentUserId.isNotEmpty && snapshot.docs.isNotEmpty) {
        print("==================================================");
        print("[DEBUG_LIKE] BẮT ĐẦU QUÁ TRÌNH KIỂM TRA");
        print("[DEBUG_LIKE] UID NGƯỜI DÙNG HIỆN TẠI: $currentUserId");

        // Truy vấn các bản ghi Like của User này
        final likesSnapshot = await _db.collection("Likes")
            .where("UserId", isEqualTo: currentUserId)
            .get();
        print("[DEBUG_LIKE] Tìm thấy ${likesSnapshot.docs.length} bản ghi Like của User này trong DB.");
        likedPostIds = likesSnapshot.docs.map((doc) {
          final likeData = doc.data();
          final likeUserId = likeData["UserId"];
          final likePostId = likeData["PostId"];
          
          // In chi tiết từng bản ghi Like để đối chiếu
          print("[DEBUG_LIKE] Đang xem bản ghi Like ID: ${doc.id}");
          print("[DEBUG_LIKE]   -> UID trong bản ghi Like: $likeUserId");
          print("[DEBUG_LIKE]   -> So sánh (Hiện tại == LikeUID): ${currentUserId == likeUserId}");
          print("[DEBUG_LIKE]   -> Dành cho Post ID: $likePostId");
          
          return likePostId as String;
        }).toSet();
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data["UserId"] ?? "";
        
        final userData = userCache[userId];
        String userName = userData?["FullName"] ?? "Người dùng RunVix";
        String userProfilePicture = userData?["ProfilePicture"] ?? "";
        
        // --- CHỖ SO SÁNH QUAN TRỌNG ---
        bool isLiked = likedPostIds.contains(doc.id);
        print("[DEBUG_LIKE] KIỂM TRA BÀI VIẾT ID: ${doc.id}");
        print("[DEBUG_LIKE]   -> Kết quả so sánh (Có trong Set LikedPostIds?): $isLiked");

        posts.add(PostModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>, 
          userName: userName, 
          userProfilePicture: userProfilePicture
        ).copyWith(isLiked: isLiked));
      }
      print("==================================================");
      return {
        "posts": posts,
        "lastDocument": snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      };
    } catch (e) {
      print("Error fetching posts: $e");
      throw "Không thể tải bài viết.";
    }
  }

  Future<List<PostModel>> getAllPosts() async {
    final result = await getPaginatedPosts(null, 10);
    return result["posts"] as List<PostModel>;
  }

  // --- Like Methods ---
  Future<void> likePost(String postId, String userId) async {
    try {
      final likeQuery = await _db.collection("Likes")
          .where("PostId", isEqualTo: postId)
          .where("UserId", isEqualTo: userId)
          .get();

      if (likeQuery.docs.isEmpty) {
        final newLike = LikeModel(postId: postId, userId: userId);
        await _db.collection("Likes").add(newLike.toJson());
        
        await _db.collection("Posts").doc(postId).update({
          "Likes": FieldValue.increment(1)
        });
      } else {
        await _db.collection("Likes").doc(likeQuery.docs.first.id).delete();
        await _db.collection("Posts").doc(postId).update({
          "Likes": FieldValue.increment(-1)
        });
      }
    } catch (e) {
      throw "Lỗi khi thực hiện Like";
    }
  }

  // --- Comment Methods ---
  Future<void> addComment(CommentModel comment) async {
    try {
      await _db.collection("Comments").add(comment.toJson());
      await _db.collection("Posts").doc(comment.postId).update({
        "Comments": FieldValue.increment(1)
      });
    } catch (e) {
      throw "Lỗi khi gửi bình luận";
    }
  }

  Future<List<CommentModel>> getComments(String postId) async {
    try {
      final snapshot = await _db.collection("Comments")
          .where("PostId", isEqualTo: postId)
          .orderBy("CreatedAt", descending: true)
          .get();
      return snapshot.docs.map((doc) => CommentModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw "Không thể tải bình luận";
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _db.collection("Posts").doc(postId).delete();
      // Có thể xóa thêm Likes và Comments liên quan ở đây nếu cần
    } catch (e) {
      throw "Lỗi khi xóa bài viết";
    }
  }

  Future<void> updatePost(PostModel post) async {
    try {
      await _db.collection("Posts").doc(post.id).update(post.toJson());
    } catch (e) {
      throw "Lỗi khi cập nhật bài viết";
    }
  }
}
