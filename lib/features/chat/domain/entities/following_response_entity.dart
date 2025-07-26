class FollowingResponse {
    final List<Following> following;
    final Pagination pagination;

    FollowingResponse({
        required this.following,
        required this.pagination,
    });

}

class Following {
    final String id;
    final String username;
    final String? fullName;
    final String? profileImage;
    final String? bio;
    final int followerCount;
    final int followingCount;
    final DateTime followedAt;

    Following({
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
    final int page;
    final int limit;
    final int totalCount;
    final int totalPages;
    final bool hasMore;

    Pagination({
        required this.page,
        required this.limit,
        required this.totalCount,
        required this.totalPages,
        required this.hasMore,
    });

}
