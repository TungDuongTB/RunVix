import 'package:cloud_firestore/cloud_firestore.dart';

class GroupModel {
  final String? id;
  final String name;
  final String description;
  final String location;
  final String coverImageUrl;
  final String logoImageUrl;
  final bool isPublic;
  final bool hasRequirements;
  final String minPace;
  final String minKm;
  final String minSessions;
  final String creatorId;
  final List<String> memberIds;
  final DateTime? createdAt;

  const GroupModel({
    this.id,
    required this.name,
    this.description = '',
    this.location = '',
    this.coverImageUrl = '',
    this.logoImageUrl = '',
    this.isPublic = true,
    this.hasRequirements = false,
    this.minPace = '',
    this.minKm = '',
    this.minSessions = '',
    required this.creatorId,
    this.memberIds = const [],
    this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Description': description,
      'Location': location,
      'CoverImageUrl': coverImageUrl,
      'LogoImageUrl': logoImageUrl,
      'IsPublic': isPublic,
      'HasRequirements': hasRequirements,
      'MinPace': minPace,
      'MinKm': minKm,
      'MinSessions': minSessions,
      'CreatorId': creatorId,
      'MemberIds': memberIds,
      'CreatedAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }

  factory GroupModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    if (data == null) {
      throw Exception('Dữ liệu nhóm trống');
    }

    // Helper function để chuyển đổi giá trị thành string
    String toStringValue(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is int || value is double) return value.toString();
      return value.toString();
    }

    return GroupModel(
      id: doc.id,
      name: data['Name'] ?? '',
      description: data['Description'] ?? '',
      location: data['Location'] ?? '',
      coverImageUrl: data['CoverImageUrl'] ?? '',
      logoImageUrl: data['LogoImageUrl'] ?? '',
      isPublic: data['IsPublic'] ?? true,
      hasRequirements: data['HasRequirements'] ?? false,
      minPace: toStringValue(data['MinPace']),
      minKm: toStringValue(data['MinKm']),
      minSessions: toStringValue(data['MinSessions']),
      creatorId: toStringValue(data['CreatorId']),
      memberIds: List<String>.from(
        (data['MemberIds'] ?? []).map((e) => e.toString())
      ),
      createdAt: data['CreatedAt'] != null
          ? (data['CreatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  GroupModel copyWith({
    String? id,
    String? name,
    String? description,
    String? location,
    String? coverImageUrl,
    String? logoImageUrl,
    bool? isPublic,
    bool? hasRequirements,
    String? minPace,
    String? minKm,
    String? minSessions,
    String? creatorId,
    List<String>? memberIds,
    DateTime? createdAt,
  }) {
    return GroupModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      location: location ?? this.location,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      logoImageUrl: logoImageUrl ?? this.logoImageUrl,
      isPublic: isPublic ?? this.isPublic,
      hasRequirements: hasRequirements ?? this.hasRequirements,
      minPace: minPace ?? this.minPace,
      minKm: minKm ?? this.minKm,
      minSessions: minSessions ?? this.minSessions,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
