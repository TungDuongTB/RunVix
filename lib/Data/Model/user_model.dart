import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String fullName;
  final String email;
  final String address;
  final String profilePicture;
  final String role; // 'admin', 'coordinator', 'user'
  final String status; // 'active', 'blocked'

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.address,
    required this.profilePicture,
    this.role = 'user',
    this.status = 'active',
  });

  toJson() {
    return {
      "Username": username,
      "FullName": fullName,
      "Email": email,
      "Address": address,
      "ProfilePicture": profilePicture,
      "Role": role,
      "Status": status,
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
      role: data["Role"] ?? "user",
      status: data["Status"] ?? "active",
    );
  }

  static UserModel empty() => const UserModel(
        id: "",
        username: "",
        email: "",
        fullName: "",
        address: "",
        profilePicture: "https://picsum.photos/200",
        role: "user",
        status: "active",
      );

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? email,
    String? address,
    String? profilePicture,
    String? role,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      address: address ?? this.address,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      status: status ?? this.status,
    );
  }
}
