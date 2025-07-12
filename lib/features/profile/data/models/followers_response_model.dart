import 'dart:convert';

FollowersResponse followersResponseFromJson(String str) =>
    FollowersResponse.fromJson(json.decode(str));

String followersResponseToJson(FollowersResponse data) =>
    json.encode(data.toJson());

class FollowersResponse {
  List<Follower> followers;
  Pagination pagination;

  FollowersResponse({required this.followers, required this.pagination});

  factory FollowersResponse.fromJson(Map<String, dynamic> json) =>
      FollowersResponse(
        followers: List<Follower>.from(
          json["followers"].map((x) => Follower.fromJson(x)),
        ),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "followers": List<dynamic>.from(followers.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Follower {
  String id;
  String username;
  String fullName;
  String profileImage;
  String? bio;
  int followerCount;
  int followingCount;
  DateTime followedAt;

  Follower({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profileImage,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.followedAt,
  });

  factory Follower.fromJson(Map<String, dynamic> json) => Follower(
    id: json["id"],
    username: json["username"],
    fullName: json["fullName"],
    profileImage: json["profileImage"],
    bio: json["bio"],
    followerCount: json["followerCount"],
    followingCount: json["followingCount"],
    followedAt: DateTime.parse(json["followedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "username": username,
    "fullName": fullName,
    "profileImage": profileImage,
    "bio": bio,
    "followerCount": followerCount,
    "followingCount": followingCount,
    "followedAt": followedAt.toIso8601String(),
  };
}

class Pagination {
  int page;
  int limit;
  int totalCount;
  int totalPages;
  bool hasMore;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    totalCount: json["totalCount"],
    totalPages: json["totalPages"],
    hasMore: json["hasMore"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "totalCount": totalCount,
    "totalPages": totalPages,
    "hasMore": hasMore,
  };
}
