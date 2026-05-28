import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:runvix/export.dart';

class PostRepository extends GetxController {
  static PostRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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
      final ref = _storage.ref().child('Posts/${DateTime.now().millisecondsSinceEpoch}.jpg');
      
      if (kIsWeb) {
        await ref.putData(await image.readAsBytes(), SettableMetadata(contentType: 'image/jpeg'));
      } else {
        await ref.putFile(File(image.path));
      }
      
      return await ref.getDownloadURL();
    } catch (e) {
      throw "Lỗi khi tải ảnh lên.";
    }
  }

  Future<List<PostModel>> getAllPosts() async {
    try {
      final snapshot = await _db.collection("Posts").orderBy("CreatedAt", descending: true).get();
      return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
    } catch (e) {
      throw "Không thể tải bài viết.";
    }
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
}
