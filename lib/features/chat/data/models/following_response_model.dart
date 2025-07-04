import '../../domain/entities/following_response_entity.dart';

class FollowingResponseModel extends FollowingResponse {
  FollowingResponseModel({
    required List<FollowingModel> following,
    required PaginationModel pagination,
  }) : super(following: following, pagination: pagination);

  factory FollowingResponseModel.fromJson(Map<String, dynamic> json) {
    return FollowingResponseModel(
      following: (json['following'] as List)
          .map((f) => FollowingModel.fromJson(f))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'following': (following as List<FollowingModel>)
          .map((f) => f.toJson())
          .toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class FollowingModel extends Following {
  FollowingModel({
    required super.id,
    required super.username,
    required super.fullName,
    required super.profileImage,
    required super.bio,
    required super.followerCount,
    required super.followingCount,
    required super.followedAt,
  });

  factory FollowingModel.fromJson(Map<String, dynamic> json) {
    return FollowingModel(
      id: json['id'],
      username: json['username'],
      fullName: json['fullName'],
      profileImage: json['profileImage'],
      bio: json['bio'],
      followerCount: json['followerCount'],
      followingCount: json['followingCount'],
      followedAt: DateTime.parse(json['followedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'profileImage': profileImage,
      'bio': bio,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'followedAt': followedAt.toIso8601String(),
    };
  }
}

// Note: If you already have a PaginationModel implementation elsewhere,
// you might want to reuse it instead of defining it again here.
class PaginationModel extends Pagination {
  PaginationModel({
    required super.page,
    required super.limit,
    required super.totalCount,
    required super.totalPages,
    required super.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      hasMore: json['hasMore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasMore': hasMore,
    };
  }
}
