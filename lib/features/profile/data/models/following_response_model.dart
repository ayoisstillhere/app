import 'dart:convert';

FollowingResponse followingResponseFromJson(String str) =>
    FollowingResponse.fromJson(json.decode(str));

String followingResponseToJson(FollowingResponse data) =>
    json.encode(data.toJson());

class FollowingResponse {
  List<Following> following;
  Pagination pagination;

  FollowingResponse({required this.following, required this.pagination});

  factory FollowingResponse.fromJson(Map<String, dynamic> json) =>
      FollowingResponse(
        following: List<Following>.from(
          json["following"].map((x) => Following.fromJson(x)),
        ),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "following": List<dynamic>.from(following.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Following {
  String id;
  String username;
  String? fullName;
  String? profileImage;
  String? bio;
  int followerCount;
  int followingCount;
  DateTime followedAt;
  bool followsYou;
  bool youFollow;

  Following({
    required this.id,
    required this.username,
    required this.fullName,
    required this.profileImage,
    required this.bio,
    required this.followerCount,
    required this.followingCount,
    required this.followedAt,
    required this.followsYou,
    required this.youFollow,
  });

  factory Following.fromJson(Map<String, dynamic> json) => Following(
    id: json["id"],
    username: json["username"],
    fullName: json["fullName"] ?? "",
    profileImage: json["profileImage"] ?? "",
    bio: json["bio"] ?? "",
    followerCount: json["followerCount"],
    followingCount: json["followingCount"],
    followedAt: DateTime.parse(json["followedAt"]),
    followsYou: json["follow_you"],
    youFollow: json["you_follow"],
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
    "follow_you": followsYou,
    "you_follow": youFollow,
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
