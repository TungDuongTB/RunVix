import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String fullName;
  final String email;
  final String address;
  final String profilePicture;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.address,
    required this.profilePicture,
  });

  toJson() {
    return {
      "Username": username,
      "FullName": fullName,
      "Email": email,
      "Address": address,
      "ProfilePicture": profilePicture,
    };
  }

  factory UserModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> document) {
    if (document.data() == null) return UserModel.empty();
    final data = document.data()!;
    return UserModel(
      id: document.id,
      username: data["Username"] ?? "",
      email: data["Email"] ?? "",
      fullName: data["FullName"] ?? "",
      address: data["Address"] ?? "",
      profilePicture: data["ProfilePicture"] ?? "https://picsum.photos/200",
    );
  }

  static UserModel empty() => const UserModel(id: "", username: "", email: "", fullName: "", address: "", profilePicture: "https://picsum.photos/200");
}
