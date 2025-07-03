import 'package:equatable/equatable.dart';

class SearchResponseEntity extends Equatable {
  final List<Top> top;
  final Everything everything;
  final Media media;
  final People people;

  const SearchResponseEntity(this.top, this.everything, this.media, this.people);

  @override
  List<Object?> get props => [top, everything, media, people];
}

class Everything extends Equatable {
  final List<User> users;
  final List<EverythingPost> posts;
  final List<Keyword> keywords;
  final Pagination pagination;

  const Everything(this.users, this.posts, this.keywords, this.pagination);

  @override
  List<Object?> get props => [users, posts, keywords, pagination];
}

class Keyword extends Equatable {
  final String keyword;
  final String type;
  final int postsCount;
  final String objectId;

  const Keyword(this.keyword, this.type, this.postsCount, this.objectId);

  @override
  List<Object?> get props => [keyword, type, postsCount, objectId];
}

class Pagination extends Equatable {
  final int page;
  final int limit;
  final bool hasMore;

  const Pagination(this.page, this.limit, this.hasMore);

  @override
  List<Object?> get props => [page, limit, hasMore];
}

class EverythingPost extends Equatable {
  final String content;
  final String authorId;
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

  const EverythingPost(
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
    this.objectId,
    this.id,
    this.isLiked,
    this.isReposted,
    this.isSaved,
  );

  @override
  List<Object?> get props => [
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
  ];
}

class User extends Equatable {
  final String username;
  final String fullName;
  final String bio;
  final String profileImage;
  final int followersCount;
  final int postsCount;
  final String objectId;

  const User(
    this.username,
    this.fullName,
    this.bio,
    this.profileImage,
    this.followersCount,
    this.postsCount,
    this.objectId,
  );

  @override
  List<Object?> get props => [
    username,
    fullName,
    bio,
    profileImage,
    followersCount,
    postsCount,
    objectId,
  ];
}

class Media extends Equatable {
  final List<MediaPost> posts;
  final Pagination pagination;

  const Media(this.posts, this.pagination);

  @override
  List<Object?> get props => [posts, pagination];
}

class MediaPost extends Equatable {
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

  const MediaPost(
    this.content,
    this.authorUsername,
    this.keywords,
    this.media,
    this.hasMedia,
    this.likesCount,
    this.commentsCount,
    this.repostsCount,
    this.createdAt,
    this.objectId,
    this.id,
    this.isLiked,
    this.isReposted,
    this.isSaved,
  );

  @override
  List<Object?> get props => [
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
  ];
}

class People extends Equatable {
  final List<User> users;
  final Pagination pagination;

  const People(this.users, this.pagination);

  @override
  List<Object?> get props => [users, pagination];
}

class Top extends Equatable {
  final String type;
  final Data data;

  const Top(this.type, this.data);

  @override
  List<Object?> get props => [type, data];
}

class Data extends Equatable {
  final String? username;
  final String? fullName;
  final String? bio;
  final String? profileImage;
  final int? followersCount;
  final int? postsCount;
  final String? objectId;
  final String? content;
  final String? authorId;
  final String? authorUsername;
  final List<String>? keywords;
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

  const Data(
    this.username,
    this.fullName,
    this.bio,
    this.profileImage,
    this.followersCount,
    this.postsCount,
    this.objectId,
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
  );

  // Helper methods to determine data type
  bool get isUser => username != null && fullName != null;
  bool get isPost => content != null && authorUsername != null;
  bool get isKeyword => keyword != null && type != null;

  @override
  List<Object?> get props => [
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
  ];
}