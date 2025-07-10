import 'package:equatable/equatable.dart';

class PostResponseEntity extends Equatable {
  final List<Post> posts;
  final Pagination pagination;
  final User user;

  const PostResponseEntity(this.posts, this.pagination, this.user);

  @override
  List<Object?> get props => [posts, pagination, user];
}

class CommentsResponseEntity extends Equatable {
  final List<Comment> comments;
  final Pagination pagination;

  const CommentsResponseEntity(this.comments, this.pagination);

  @override
  List<Object?> get props => [comments, pagination];
}

class Comment extends Equatable {
  final Post post;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  const Comment({
    required this.post,
    required this.isLiked,
    required this.isReposted,
    required this.isSaved,
  });

  @override
  List<Object?> get props => [post, isLiked, isReposted, isSaved];
}

class Pagination extends Equatable {
  final int page;
  final int limit;
  final bool hasMore;

  const Pagination(this.page, this.limit, this.hasMore);

  @override
  List<Object?> get props => [page, limit, hasMore];
}

class Post extends Equatable {
  final String id;
  final String content;
  final List<String> media;
  final List<String> links;
  final String authorId;
  final bool isComment;
  final String? parentPostId; // Made nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author author;
  final ParentPost? parentPost; // Made nullable
  final Count count;
  final bool isLiked;
  final bool isReposted;
  final bool isSaved;

  const Post(
    this.id,
    this.content,
    this.media,
    this.links,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.count,
    this.isLiked,
    this.isReposted,
    this.isSaved,
    this.authorId,
    this.isComment,
    this.parentPostId,
    this.parentPost,
  );

  // Helper methods to check post type
  bool get isTopLevelPost => !isComment && parentPostId == null;
  bool get isReply => isComment && parentPostId != null;
  bool get hasParentPost => parentPost != null;

  @override
  List<Object?> get props => [
    id,
    content,
    media,
    links,
    createdAt,
    updatedAt,
    author,
    count,
    isLiked,
    isReposted,
    isSaved,
    authorId,
    isComment,
    parentPostId,
    parentPost,
  ];
}

class Author extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String profileImage;

  const Author(this.id, this.username, this.fullName, this.profileImage);

  @override
  List<Object?> get props => [id, username, fullName, profileImage];
}

class Count extends Equatable {
  final int likes;
  final int comments;
  final int reposts;
  final int saves;

  const Count(this.likes, this.comments, this.reposts, this.saves);

  @override
  List<Object?> get props => [likes, comments, reposts, saves];
}

class ParentPost extends Equatable {
  final String id;
  final String content;
  final List<String> media;
  final List<String> links;
  final String authorId;
  final bool isComment;
  final String? parentPostId; // Made nullable
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author author;

  const ParentPost(
    this.id,
    this.content,
    this.media,
    this.links,
    this.authorId,
    this.isComment,
    this.parentPostId,
    this.createdAt,
    this.updatedAt,
    this.author,
  );

  @override
  List<Object?> get props => [
    id,
    content,
    media,
    links,
    authorId,
    isComment,
    parentPostId,
    createdAt,
    updatedAt,
    author,
  ];
}

class User extends Equatable {
  final String id;
  final String username;
  final String fullName;
  final String profileImage;

  const User(this.id, this.username, this.fullName, this.profileImage);

  @override
  List<Object?> get props => [id, username, fullName, profileImage];
}
