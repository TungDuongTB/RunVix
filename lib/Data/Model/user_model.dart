import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String? id;
  final String username;
  final String fullName;
  final String firstName;
  final String lastName;
  final String email;
  final String address;
  final String city;
  final String bio;
  final String profilePicture;
  final String mainSport;
  final DateTime? dob;
  final String gender;
  final double weight;
  final double height;
  final Map<String, bool> roles;
  final String status;

  const UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    this.firstName = "",
    this.lastName = "",
    required this.address,
    this.city = "",
    this.bio = "",
    required this.profilePicture,
    this.mainSport = "Chạy bộ",
    this.dob,
    this.gender = "Nam",
    this.weight = 0.0,
    this.height = 0.0,
    this.roles = const {'user': true},
    this.status = 'active',
  });

  bool get isAdmin => roles['admin'] ?? false;
  bool get isCoordinator => roles['coordinator'] ?? false;
  bool get isUser => roles['user'] ?? false;

  toJson() {
    return {
      "Username": username,
      "FullName": fullName,
      "FirstName": firstName,
      "LastName": lastName,
      "Email": email,
      "Address": address,
      "City": city,
      "Bio": bio,
      "ProfilePicture": profilePicture,
      "MainSport": mainSport,
      "DOB": dob != null ? Timestamp.fromDate(dob!) : null,
      "Gender": gender,
      "Weight": weight,
      "Height": height,
      "Roles": roles,
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
      firstName: data["FirstName"] ?? "",
      lastName: data["LastName"] ?? "",
      address: data["Address"] ?? "",
      city: data["City"] ?? "",
      bio: data["Bio"] ?? "",
      profilePicture: data["ProfilePicture"] ?? "https://picsum.photos/200",
      mainSport: data["MainSport"] ?? "Chạy bộ",
      dob: data["DOB"] != null ? (data["DOB"] as Timestamp).toDate() : null,
      gender: data["Gender"] ?? "Nam",
      weight: (data["Weight"] ?? 0.0).toDouble(),
      height: (data["Height"] ?? 0.0).toDouble(),
      roles: Map<String, bool>.from(data["Roles"] ?? {'user': true}),
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
        roles: {'user': true},
        status: "active",
      );

  UserModel copyWith({
    String? id,
    String? username,
    String? fullName,
    String? firstName,
    String? lastName,
    String? email,
    String? address,
    String? city,
    String? bio,
    String? profilePicture,
    String? mainSport,
    DateTime? dob,
    String? gender,
    double? weight,
    double? height,
    Map<String, bool>? roles,
    String? status,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      address: address ?? this.address,
      city: city ?? this.city,
      bio: bio ?? this.bio,
      profilePicture: profilePicture ?? this.profilePicture,
      mainSport: mainSport ?? this.mainSport,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      roles: roles ?? this.roles,
      status: status ?? this.status,
    );
  }
}
