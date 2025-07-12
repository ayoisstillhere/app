class FollowersResponseEntity {
    List<FollowerEntity> followers;
    Pagination pagination;

    FollowersResponseEntity({
        required this.followers,
        required this.pagination,
    });

}

class FollowerEntity {
    String id;
    String username;
    String fullName;
    String profileImage;
    String? bio;
    int followerCount;
    int followingCount;
    DateTime followedAt;

    FollowerEntity({
        required this.id,
        required this.username,
        required this.fullName,
        required this.profileImage,
        required this.bio,
        required this.followerCount,
        required this.followingCount,
        required this.followedAt,
    });

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

}
