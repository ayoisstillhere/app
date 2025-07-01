import 'package:equatable/equatable.dart';

abstract class CommentResponseEntity extends Equatable {
  final List<CommentEntity> comments;
  final PaginationEntity pagination;

  const CommentResponseEntity(this.comments, this.pagination);

  @override
  List<Object> get props => [comments, pagination];
}

abstract class CommentEntity extends Equatable {
  final String id;
  final String content;
  final String postId;
  final dynamic parentId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final AuthorEntity author;
  final CountEntity count;
  final bool isLiked;
  final List<dynamic> replies;

  const CommentEntity(
    this.id,
    this.content,
    this.postId,
    this.parentId,
    this.createdAt,
    this.updatedAt,
    this.author,
    this.count,
    this.isLiked,
    this.replies,
  );

  @override
  List<Object> get props => [
    id,
    content,
    postId,
    parentId,
    createdAt,
    updatedAt,
    author,
    count,
    isLiked,
    replies,
  ];
}

abstract class AuthorEntity extends Equatable {
  final String username;
  final String fullName;
  final String profileImage;

  const AuthorEntity(this.username, this.fullName, this.profileImage);

  @override
  List<Object> get props => [username, fullName, profileImage];
}

abstract class CountEntity extends Equatable {
  final int likes;
  final int replies;

  const CountEntity(this.likes, this.replies);

  @override
  List<Object> get props => [likes, replies];
}

abstract class PaginationEntity extends Equatable {
  final int page;
  final int limit;
  final bool hasMore;

  const PaginationEntity(this.page, this.limit, this.hasMore);

  @override
  List<Object> get props => [page, limit, hasMore];
}
