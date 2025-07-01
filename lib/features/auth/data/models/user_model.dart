import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required String id,
    required String email,
    required String username,
    required String fullName,
    required String bio,
    required String location,
    required String profileImage,
    required dynamic bannerImage,
    required bool isEmailVerified,
    required int followerCount,
    required int followingCount,
    required int friendCount,
    required DateTime dateJoined,
    required String relationshipStatus,
    required bool isFollowing,
    required bool followsYou,
    required bool isOwnProfile,
    required DateTime updatedAt,
  }) : super(
          id,
          email,
          username,
          fullName,
          bio,
          location,
          profileImage,
          bannerImage,
          isEmailVerified,
          followerCount,
          followingCount,
          friendCount,
          dateJoined,
          relationshipStatus,
          isFollowing,
          followsYou,
          isOwnProfile,
          updatedAt,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      bio: json['bio'] ?? '',
      location: json['location'] ?? '',
      profileImage: json['profileImage'] ?? '',
      bannerImage: json['bannerImage'],
      isEmailVerified: json['isEmailVerified'] ?? false,
      followerCount: json['followerCount'] ?? 0,
      followingCount: json['followingCount'] ?? 0,
      friendCount: json['friendCount'] ?? 0,
      dateJoined: json['dateJoined'] != null 
          ? DateTime.parse(json['dateJoined']) 
          : DateTime.now(),
      relationshipStatus: json['relationshipStatus'] ?? '',
      isFollowing: json['isFollowing'] ?? false,
      followsYou: json['followsYou'] ?? false,
      isOwnProfile: json['isOwnProfile'] ?? false,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'location': location,
      'profileImage': profileImage,
      'bannerImage': bannerImage,
      'isEmailVerified': isEmailVerified,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'friendCount': friendCount,
      'dateJoined': dateJoined.toIso8601String(),
      'relationshipStatus': relationshipStatus,
      'isFollowing': isFollowing,
      'followsYou': followsYou,
      'isOwnProfile': isOwnProfile,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}