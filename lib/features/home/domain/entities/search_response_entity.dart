class SearchResponseEntity {
  final List<Top> top;
  final Everything everything;
  final Media media;
  final People people;

  const SearchResponseEntity({
    required this.top,
    required this.everything,
    required this.media,
    required this.people,
  });
}

class Everything {
  final List<User> users;
  final List<EverythingPost> posts;
  final List<Keyword> keywords;
  final Pagination pagination;

  const Everything({
    required this.users,
    required this.posts,
    required this.keywords,
    required this.pagination,
  });
}

class Keyword {
  final String keyword;
  final String type;
  final int postsCount;
  final String objectId;

  const Keyword({
    required this.keyword,
    required this.type,
    required this.postsCount,
    required this.objectId,
  });
}

class Pagination {
  final int page;
  final int limit;
  final bool hasMore;

  const Pagination({
    required this.page,
    required this.limit,
    required this.hasMore,
  });
}

class EverythingPost {
  final String content;
  final String? authorId;
  final String authorUsername;
  final List<String?> keywords;
  final List<String> media;
  final bool hasMedia;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final DateTime createdAt;
  final String objectId;
  final String id;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  const EverythingPost({
    required this.content,
    this.authorId,
    required this.authorUsername,
    required this.keywords,
    required this.media,
    required this.hasMedia,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    required this.createdAt,
    required this.objectId,
    required this.id,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
  });
}

class User {
  final String username;
  final String fullName;
  final String bio;
  final String profileImage;
  final int followersCount;
  final int postsCount;
  final String objectId;

  const User({
    required this.username,
    required this.fullName,
    required this.bio,
    required this.profileImage,
    required this.followersCount,
    required this.postsCount,
    required this.objectId,
  });
}

class Media {
  final List<MediaPost> posts;
  final Pagination pagination;

  const Media({required this.posts, required this.pagination});
}

class MediaPost {
  final String content;
  final String authorUsername;
  final List<String> keywords;
  final List<String> media;
  final bool hasMedia;
  final int likesCount;
  final int commentsCount;
  final int repostsCount;
  final DateTime createdAt;
  final String objectId;
  final String id;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  const MediaPost({
    required this.content,
    required this.authorUsername,
    required this.keywords,
    required this.media,
    required this.hasMedia,
    required this.likesCount,
    required this.commentsCount,
    required this.repostsCount,
    required this.createdAt,
    required this.objectId,
    required this.id,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
  });
}

class People {
  final List<User> users;
  final Pagination pagination;

  const People({required this.users, required this.pagination});
}

class Top {
  final String type;
  final Data data;

  const Top({required this.type, required this.data});
}

class Data {
  final String? username;
  final String? fullName;
  final String? bio;
  final String? profileImage;
  final int? followersCount;
  final int? postsCount;
  final String objectId;
  final String? content;
  final String? authorId;
  final String? authorUsername;
  final List<String?>? keywords;
  final List<String>? media;
  final bool? hasMedia;
  final int? likesCount;
  final int? commentsCount;
  final int? repostsCount;
  final DateTime? createdAt;
  final String? id;
  final bool? isLiked;
  final bool? isReposted;
  final bool? isSaved;
  final String? keyword;
  final String? type;

  const Data({
    this.username,
    this.fullName,
    this.bio,
    this.profileImage,
    this.followersCount,
    this.postsCount,
    required this.objectId,
    this.content,
    this.authorId,
    this.authorUsername,
    this.keywords,
    this.media,
    this.hasMedia,
    this.likesCount,
    this.commentsCount,
    this.repostsCount,
    this.createdAt,
    this.id,
    this.isLiked,
    this.isReposted,
    this.isSaved,
    this.keyword,
    this.type,
  });
}
