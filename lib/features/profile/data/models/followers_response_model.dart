
import 'dart:convert';

FollowersResponseModel followersResponseFromJson(String str) => FollowersResponseModel.fromJson(json.decode(str));

String followersResponseToJson(FollowersResponseModel data) => json.encode(data.toJson());

class FollowersResponseModel {
    List<FollowerModel> followers;
    Pagination pagination;

    FollowersResponseModel({
        required this.followers,
        required this.pagination,
    });

    factory FollowersResponseModel.fromJson(Map<String, dynamic> json) => FollowersResponseModel(
        followers: List<FollowerModel>.from(json["followers"].map((x) => FollowerModel.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "followers": List<dynamic>.from(followers.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
    };
}

class FollowerModel {
    String id;
    String username;
    String fullName;
    String profileImage;
    String? bio;
    int followerCount;
    int followingCount;
    DateTime followedAt;

    FollowerModel({
        required this.id,
        required this.username,
        required this.fullName,
        required this.profileImage,
        required this.bio,
        required this.followerCount,
        required this.followingCount,
        required this.followedAt,
    });

    factory FollowerModel.fromJson(Map<String, dynamic> json) => FollowerModel(
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
