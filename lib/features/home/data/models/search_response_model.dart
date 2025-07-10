import '../../domain/entities/search_response_entity.dart';

class SearchResponseModel extends SearchResponseEntity {
  const SearchResponseModel({
    required List<TopModel> top,
    required EverythingModel everything,
    required MediaModel media,
    required PeopleModel people,
    required MediaModel recent,
  }) : super(
         top: top,
         everything: everything,
         media: media,
         people: people,
         recent: recent,
       );

  const SearchResponseModel.empty()
    : super(
        top: const [],
        everything: const EverythingModel.empty(),
        media: const MediaModel.empty(),
        people: const PeopleModel.empty(),
        recent: const MediaModel.empty(),
      );

  factory SearchResponseModel.fromJson(Map<String, dynamic> json) {
    return SearchResponseModel(
      top:
          (json['top'] as List<dynamic>?)
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
      recent: json['recent'] != null
          ? MediaModel.fromJson(json['recent'])
          : const MediaModel.empty(),
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
  }) : super(
         users: users,
         posts: posts,
         keywords: keywords,
         pagination: pagination,
       );

  const EverythingModel.empty()
    : super(
        users: const [],
        posts: const [],
        keywords: const [],
        pagination: const PaginationModel(page: 0, limit: 0, hasMore: false),
      );

  factory EverythingModel.fromJson(Map<String, dynamic> json) {
    return EverythingModel(
      users:
          (json['users'] as List<dynamic>?)
              ?.map((user) => UserModel.fromJson(user))
              .toList() ??
          [],
      posts:
          (json['posts'] as List<dynamic>?)
              ?.map((post) => EverythingPostModel.fromJson(post))
              .toList() ??
          [],
      keywords:
          (json['keywords'] as List<dynamic>?)
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
      'posts': posts
          .map((post) => (post as EverythingPostModel).toJson())
          .toList(),
      'keywords': keywords
          .map((keyword) => (keyword as KeywordModel).toJson())
          .toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class KeywordModel extends Keyword {
  const KeywordModel({
    required super.keyword,
    required super.type,
    required super.postsCount,
    required super.objectId,
  });

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
    required super.page,
    required super.limit,
    required super.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] ?? 0,
      limit: json['limit'] ?? 10,
      hasMore: json['hasMore'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'hasMore': hasMore};
  }
}

class EverythingPostModel extends EverythingPost {
  const EverythingPostModel({
    required super.content,
    super.authorId,
    required super.authorUsername,
    required super.keywords,
    required super.media,
    required super.hasMedia,
    required super.likesCount,
    required super.commentsCount,
    required super.repostsCount,
    required super.createdAt,
    required super.objectId,
    required super.id,
    required super.isLiked,
    required super.isReposted,
    required super.isSaved,
  });

  factory EverythingPostModel.fromJson(Map<String, dynamic> json) {
    return EverythingPostModel(
      content: json['content'] ?? '',
      authorId: json['authorId'],
      authorUsername: json['authorUsername'] ?? '',
      keywords:
          (json['keywords'] as List<dynamic>?)
              ?.map((k) => k as String?)
              .toList() ??
          [],
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
      if (authorId != null) 'authorId': authorId,
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
    required super.username,
    required super.fullName,
    required super.bio,
    required super.profileImage,
    required super.followersCount,
    required super.postsCount,
    required super.objectId,
  });

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
  }) : super(posts: posts, pagination: pagination);

  const MediaModel.empty()
    : super(
        posts: const [],
        pagination: const PaginationModel(page: 0, limit: 0, hasMore: false),
      );

  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      posts:
          (json['posts'] as List<dynamic>?)
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
    required super.content,
    required super.authorUsername,
    required super.keywords,
    required super.media,
    required super.hasMedia,
    required super.likesCount,
    required super.commentsCount,
    required super.repostsCount,
    required super.createdAt,
    required super.objectId,
    required super.id,
    required super.isLiked,
    required super.isReposted,
    required super.isSaved,
    required super.fullName,
    required super.profileImage,
    required super.savesCount,
  });

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
      fullName: json['fullName'] ?? '',
      profileImage: json['profileImage'] ?? '',
      savesCount: json['savesCount'] ?? 0,
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
      'fullName': fullName,
      'profileImage': profileImage,
      'savesCount': savesCount,
    };
  }
}

class PeopleModel extends People {
  const PeopleModel({
    required List<UserModel> users,
    required PaginationModel pagination,
  }) : super(users: users, pagination: pagination);

  const PeopleModel.empty()
    : super(
        users: const [],
        pagination: const PaginationModel(page: 0, limit: 0, hasMore: false),
      );

  factory PeopleModel.fromJson(Map<String, dynamic> json) {
    return PeopleModel(
      users:
          (json['users'] as List<dynamic>?)
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
  const TopModel({required super.type, required DataModel super.data});

  factory TopModel.fromJson(Map<String, dynamic> json) {
    return TopModel(
      type: json['type'] ?? '',
      data: DataModel.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'type': type, 'data': (data as DataModel).toJson()};
  }
}

class DataModel extends Data {
  const DataModel({
    super.username,
    super.fullName,
    super.bio,
    super.profileImage,
    super.followersCount,
    super.postsCount,
    required super.objectId,
    super.content,
    super.authorId,
    super.authorUsername,
    super.keywords,
    super.media,
    super.hasMedia,
    super.likesCount,
    super.commentsCount,
    super.repostsCount,
    super.createdAt,
    super.id,
    super.isLiked,
    super.isReposted,
    super.isSaved,
    super.keyword,
    super.type,
    super.savesCount,
  });

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
      username: json['username'],
      fullName: json['fullName'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      followersCount: json['followersCount'],
      postsCount: json['postsCount'],
      objectId: json['objectId'] ?? '',
      content: json['content'],
      authorId: json['authorId'],
      authorUsername: json['authorUsername'],
      keywords: json['keywords'] != null
          ? List<String?>.from(json['keywords'])
          : null,
      media: json['media'] != null ? List<String>.from(json['media']) : null,
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
      savesCount: json['savesCount'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'objectId': objectId};

    if (username != null) data['username'] = username;
    if (fullName != null) data['fullName'] = fullName;
    if (bio != null) data['bio'] = bio;
    if (profileImage != null) data['profileImage'] = profileImage;
    if (followersCount != null) data['followersCount'] = followersCount;
    if (postsCount != null) data['postsCount'] = postsCount;
    if (content != null) data['content'] = content;
    if (authorId != null) data['authorId'] = authorId;
    if (authorUsername != null) data['authorUsername'] = authorUsername;
    if (keywords != null) data['keywords'] = keywords;
    if (media != null) data['media'] = media;
    if (hasMedia != null) data['hasMedia'] = hasMedia;
    if (likesCount != null) data['likesCount'] = likesCount;
    if (commentsCount != null) data['commentsCount'] = commentsCount;
    if (repostsCount != null) data['repostsCount'] = repostsCount;
    if (createdAt != null) data['createdAt'] = createdAt.toString();
    if (id != null) data['id'] = id;
    if (isLiked != null) data['isLiked'] = isLiked;
    if (isReposted != null) data['isReposted'] = isReposted;
    if (isSaved != null) data['isSaved'] = isSaved;
    if (keyword != null) data['keyword'] = keyword;
    if (type != null) data['type'] = type;
    if (savesCount != null) data['savesCount'] = savesCount;

    return data;
  }
}
