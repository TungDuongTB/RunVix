import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:runvix/export.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;

  Future<void> createPost(PostModel post, XFile? imageFile) async {
    try {
      String imageUrl = post.imageUrl; // Giữ lại URL nếu đã có (từ manual activity)
      if (imageFile != null) {
        imageUrl = await uploadImage(imageFile);
      }

      final postWithImage = post.copyWith(
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
        final likesSnapshot = await _db.collection("Likes")
            .where("UserId", isEqualTo: currentUserId)
            .get();
        likedPostIds = likesSnapshot.docs.map((doc) {
          final likeData = doc.data();
          final likeUserId = likeData["UserId"];
          final likePostId = likeData["PostId"];
          return likePostId as String;
        }).toSet();
      }

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final userId = data["UserId"] ?? "";
        
        final userData = userCache[userId];
        String userName = userData?["FullName"] ?? "Người dùng RunVix";
        String userProfilePicture = userData?["ProfilePicture"] ?? "";
        bool isLiked = likedPostIds.contains(doc.id);
        posts.add(PostModel.fromSnapshot(doc as DocumentSnapshot<Map<String, dynamic>>, 
          userName: userName, 
          userProfilePicture: userProfilePicture
        ).copyWith(isLiked: isLiked));
      }
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

      final postDoc = await _db.collection("Posts").doc(postId).get();
      final postAuthorId = postDoc.exists ? (postDoc.data()?["UserId"] ?? "") as String : "";

      if (likeQuery.docs.isEmpty) {
        final newLike = LikeModel(postId: postId, userId: userId);
        await _db.collection("Likes").add(newLike.toJson());
        
        await _db.collection("Posts").doc(postId).update({
          "Likes": FieldValue.increment(1)
        });

        // Trigger notification
        if (postAuthorId.isNotEmpty && postAuthorId != userId) {
          await NotificationRepository.instance.createOrUpdateLikeNotification(
            postAuthorId, userId, postId);
        }
      } else {
        await _db.collection("Likes").doc(likeQuery.docs.first.id).delete();
        await _db.collection("Posts").doc(postId).update({
          "Likes": FieldValue.increment(-1)
        });

        // Remove like from notification
        if (postAuthorId.isNotEmpty && postAuthorId != userId) {
          await NotificationRepository.instance.removeLikeNotification(
            postAuthorId, userId, postId);
        }
      }
    } catch (e) {
      throw "Lỗi khi thực hiện Like";
    }
  }

  // --- Comment Methods ---
  Future<void> addComment(CommentModel comment) async {
    try {
      final ref = await _db.collection("Comments").add(comment.toJson());
      await _db.collection("Posts").doc(comment.postId).update({
        "Comments": FieldValue.increment(1)
      });

      // Trigger comment notification
      final postDoc = await _db.collection("Posts").doc(comment.postId).get();
      final postAuthorId = postDoc.exists ? (postDoc.data()?["UserId"] ?? "") as String : "";
      if (postAuthorId.isNotEmpty && postAuthorId != comment.userId) {
        await NotificationRepository.instance.createOrUpdateCommentNotification(
          postAuthorId, comment.userId, comment.postId, ref.id);
      }
    } catch (e) {
      throw "Lỗi khi gửi bình luận";
    }
  }
  Future<List<CommentModel>> getComments(String postId) async {
    try {
      // Bỏ orderBy ở đây để tránh lỗi thiếu Index trong Firestore (Composite Index)
      // Khi dùng cả where và orderBy trên 2 trường khác nhau, Firestore yêu cầu tạo Index thủ công.
      // Sắp xếp local để tránh lỗi này.
      final snapshot = await _db.collection("Comments")
          .where("PostId", isEqualTo: postId)
          .get();
      
      final comments = snapshot.docs.map((doc) => CommentModel.fromSnapshot(doc)).toList();
      
      // Sắp xếp thủ công tại local (giảm dần theo thời gian)
      comments.sort((a, b) {
        if (a.createdAt == null) return -1;
        if (b.createdAt == null) return 1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      
      return comments;
    } catch (e) {
      print("Error getComments: $e");
      throw "Không thể tải bình luận: $e";
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
