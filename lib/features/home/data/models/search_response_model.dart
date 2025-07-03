import '../../domain/entities/search_response_entity.dart';

class SearchResponseModel extends SearchResponseEntity {
  const SearchResponseModel({
    required List<TopModel> top,
    required EverythingModel everything,
    required MediaModel media,
    required PeopleModel people,
  }) : super(top, everything, media, people);

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      top: (json['top'] as List<dynamic>?)
              ?.map((item) => TopModel.fromJson(item))
              .toList() ??
          [],
      everything: json['everything'] != null
          ? EverythingModel.fromJson(json['everything'])
          : const EverythingModel.empty(),
      media: json['media'] != null
          ? MediaModel.fromJson(json['media'])
          : const MediaModel.empty(),
      people: json['people'] != null
          ? PeopleModel.fromJson(json['people'])
          : const PeopleModel.empty(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'top': top.map((item) => (item as TopModel).toJson()).toList(),
      'everything': (everything as EverythingModel).toJson(),
      'media': (media as MediaModel).toJson(),
      'people': (people as PeopleModel).toJson(),
    };
  }
}

class EverythingModel extends Everything {
  const EverythingModel({
    required List<UserModel> users,
    required List<EverythingPostModel> posts,
    required List<KeywordModel> keywords,
    required PaginationModel pagination,
  }) : super(users, posts, keywords, pagination);

  const EverythingModel.empty()
      : super(
          const [],
          const [],
          const [],
          const PaginationModel(page: 0, limit: 0, hasMore: false),
        );

  factory EverythingModel.fromJson(Map<String, dynamic> json) {
    return EverythingModel(
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => UserModel.fromJson(user))
              .toList() ??
          [],
      posts: (json['posts'] as List<dynamic>?)
              ?.map((post) => EverythingPostModel.fromJson(post))
              .toList() ??
          [],
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((keyword) => KeywordModel.fromJson(keyword))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : const PaginationModel(page: 0, limit: 0, hasMore: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => (user as UserModel).toJson()).toList(),
      'posts': posts.map((post) => (post as EverythingPostModel).toJson()).toList(),
      'keywords': keywords.map((keyword) => (keyword as KeywordModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class KeywordModel extends Keyword {
  const KeywordModel({
    required String keyword,
    required String type,
    required int postsCount,
    required String objectId,
  }) : super(keyword, type, postsCount, objectId);

  factory KeywordModel.fromJson(Map<String, dynamic> json) {
    return KeywordModel(
      keyword: json['keyword'] ?? '',
      type: json['type'] ?? '',
      postsCount: json['postsCount'] ?? 0,
      objectId: json['objectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'type': type,
      'postsCount': postsCount,
      'objectId': objectId,
    };
  }
}

class PaginationModel extends Pagination {
  const PaginationModel({
    required int page,
    required int limit,
    required bool hasMore,
  }) : super(page, limit, hasMore);

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 10,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'hasMore': hasMore,
    };
  }
}

class EverythingPostModel extends EverythingPost {
  const EverythingPostModel({
    required String content,
    required String authorId,
    required String authorUsername,
    required List<String> keywords,
    required List<String> media,
    required bool hasMedia,
    required int likesCount,
    required int commentsCount,
    required int repostsCount,
    required DateTime createdAt,
    required String objectId,
    required String id,
    required bool isLiked,
    required bool isReposted,
    required bool isSaved,
  }) : super(
          content,
          authorId,
          authorUsername,
          keywords,
          media,
          hasMedia,
          likesCount,
          commentsCount,
          repostsCount,
          createdAt,
          objectId,
          id,
          isLiked,
          isReposted,
          isSaved,
        );

  factory EverythingPostModel.fromJson(Map<String, dynamic> json) {
    return EverythingPostModel(
      content: json['content'] ?? '',
      authorId: json['authorId'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      media: List<String>.from(json['media'] ?? []),
      hasMedia: json['hasMedia'] ?? false,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      repostsCount: json['repostsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      objectId: json['objectId'] ?? '',
      id: json['id'] ?? '',
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'authorId': authorId,
      'authorUsername': authorUsername,
      'keywords': keywords,
      'media': media,
      'hasMedia': hasMedia,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'createdAt': createdAt.toIso8601String(),
      'objectId': objectId,
      'id': id,
      'isLiked': isLiked,
      'isReposted': isReposted,
      'isSaved': isSaved,
    };
  }
}

class UserModel extends User {
  const UserModel({
    required String username,
    required String fullName,
    required String bio,
    required String profileImage,
    required int followersCount,
    required int postsCount,
    required String objectId,
  }) : super(username, fullName, bio, profileImage, followersCount, postsCount, objectId);

  const UserModel.empty() : super('', '', '', '', 0, 0, '');

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      bio: json['bio'] ?? '',
      profileImage: json['profileImage'] ?? '',
      followersCount: json['followersCount'] ?? 0,
      postsCount: json['postsCount'] ?? 0,
      objectId: json['objectId'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'profileImage': profileImage,
      'followersCount': followersCount,
      'postsCount': postsCount,
      'objectId': objectId,
    };
  }
}

class MediaModel extends Media {
  const MediaModel({
    required List<MediaPostModel> posts,
    required PaginationModel pagination,
  }) : super(posts, pagination);

  const MediaModel.empty()
      : super(const [], const PaginationModel(page: 0, limit: 0, hasMore: false));

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      posts: (json['posts'] as List<dynamic>?)
              ?.map((post) => MediaPostModel.fromJson(post))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : const PaginationModel(page: 0, limit: 0, hasMore: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => (post as MediaPostModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class MediaPostModel extends MediaPost {
  const MediaPostModel({
    required String content,
    required String authorUsername,
    required List<String> keywords,
    required List<String> media,
    required bool hasMedia,
    required int likesCount,
    required int commentsCount,
    required int repostsCount,
    required DateTime createdAt,
    required String objectId,
    required String id,
    required bool isLiked,
    required bool isReposted,
    required bool isSaved,
  }) : super(
          content,
          authorUsername,
          keywords,
          media,
          hasMedia,
          likesCount,
          commentsCount,
          repostsCount,
          createdAt,
          objectId,
          id,
          isLiked,
          isReposted,
          isSaved,
        );

  factory MediaPostModel.fromJson(Map<String, dynamic> json) {
    return MediaPostModel(
      content: json['content'] ?? '',
      authorUsername: json['authorUsername'] ?? '',
      keywords: List<String>.from(json['keywords'] ?? []),
      media: List<String>.from(json['media'] ?? []),
      hasMedia: json['hasMedia'] ?? false,
      likesCount: json['likesCount'] ?? 0,
      commentsCount: json['commentsCount'] ?? 0,
      repostsCount: json['repostsCount'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      objectId: json['objectId'] ?? '',
      id: json['id'] ?? '',
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'authorUsername': authorUsername,
      'keywords': keywords,
      'media': media,
      'hasMedia': hasMedia,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'repostsCount': repostsCount,
      'createdAt': createdAt.toIso8601String(),
      'objectId': objectId,
      'id': id,
      'isLiked': isLiked,
      'isReposted': isReposted,
      'isSaved': isSaved,
    };
  }
}

class PeopleModel extends People {
  const PeopleModel({
    required List<UserModel> users,
    required PaginationModel pagination,
  }) : super(users, pagination);

  const PeopleModel.empty()
      : super(const [], const PaginationModel(page: 0, limit: 0, hasMore: false));

  factory PeopleModel.fromJson(Map<String, dynamic> json) {
    return PeopleModel(
      users: (json['users'] as List<dynamic>?)
              ?.map((user) => UserModel.fromJson(user))
              .toList() ??
          [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : const PaginationModel(page: 0, limit: 0, hasMore: false),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => (user as UserModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class TopModel extends Top {
  const TopModel({
    required String type,
    required DataModel data,
  }) : super(type, data);

  factory TopModel.fromJson(Map<String, dynamic> json) {
    return TopModel(
      type: json['type'] ?? '',
      data: DataModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': (data as DataModel).toJson(),
    };
  }
}

class DataModel extends Data {
  const DataModel({
    required String? username,
    required String? fullName,
    required String? bio,
    required String? profileImage,
    required int? followersCount,
    required int? postsCount,
    required String? objectId,
    required String? content,
    required String? authorId,
    required String? authorUsername,
    required List<String>? keywords,
    required List<String>? media,
    required bool? hasMedia,
    required int? likesCount,
    required int? commentsCount,
    required int? repostsCount,
    required DateTime? createdAt,
    required String? id,
    required bool? isLiked,
    required bool? isReposted,
    required bool? isSaved,
    required String? keyword,
    required String? type,
  }) : super(
          username,
          fullName,
          bio,
          profileImage,
          followersCount,
          postsCount,
          objectId,
          content,
          authorId,
          authorUsername,
          keywords,
          media,
          hasMedia,
          likesCount,
          commentsCount,
          repostsCount,
          createdAt,
          id,
          isLiked,
          isReposted,
          isSaved,
          keyword,
          type,
        );

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      username: json['username'],
      fullName: json['fullName'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      followersCount: json['followersCount'],
      postsCount: json['postsCount'],
      objectId: json['objectId'],
      content: json['content'],
      authorId: json['authorId'],
      authorUsername: json['authorUsername'],
      keywords: json['keywords'] != null
          ? List<String>.from(json['keywords'])
          : null,
      media: json['media'] != null
          ? List<String>.from(json['media'])
          : null,
      hasMedia: json['hasMedia'],
      likesCount: json['likesCount'],
      commentsCount: json['commentsCount'],
      repostsCount: json['repostsCount'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      id: json['id'],
      isLiked: json['isLiked'],
      isReposted: json['isReposted'],
      isSaved: json['isSaved'],
      keyword: json['keyword'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (username != null) 'username': username,
      if (fullName != null) 'fullName': fullName,
      if (bio != null) 'bio': bio,
      if (profileImage != null) 'profileImage': profileImage,
      if (followersCount != null) 'followersCount': followersCount,
      if (postsCount != null) 'postsCount': postsCount,
      if (objectId != null) 'objectId': objectId,
      if (content != null) 'content': content,
      if (authorId != null) 'authorId': authorId,
      if (authorUsername != null) 'authorUsername': authorUsername,
      if (keywords != null) 'keywords': keywords,
      if (media != null) 'media': media,
      if (hasMedia != null) 'hasMedia': hasMedia,
      if (likesCount != null) 'likesCount': likesCount,
      if (commentsCount != null) 'commentsCount': commentsCount,
      if (repostsCount != null) 'repostsCount': repostsCount,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (id != null) 'id': id,
      if (isLiked != null) 'isLiked': isLiked,
      if (isReposted != null) 'isReposted': isReposted,
      if (isSaved != null) 'isSaved': isSaved,
      if (keyword != null) 'keyword': keyword,
      if (type != null) 'type': type,
    };
  }
}