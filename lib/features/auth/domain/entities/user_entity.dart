import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String bio;
  final String location;
  final String? profileImage;
  final String? bannerImage;
  final bool isEmailVerified;
  final int followerCount;
  final int followingCount;
  final int friendCount;
  final DateTime dateJoined;
  final String relationshipStatus;
  final bool isFollowing;
  final bool followsYou;
  final bool isOwnProfile;
  final DateTime updatedAt;

  const UserEntity(
    this.id,
    this.email,
    this.username,
    this.fullName,
    this.bio,
    this.location,
    this.profileImage,
    this.bannerImage,
    this.isEmailVerified,
    this.followerCount,
    this.followingCount,
    this.friendCount,
    this.dateJoined,
    this.relationshipStatus,
    this.isFollowing,
    this.followsYou,
    this.isOwnProfile,
    this.updatedAt,
  );

  @override
  List<Object?> get props => [
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
  ];
}
