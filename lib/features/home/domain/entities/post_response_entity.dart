import 'package:equatable/equatable.dart';

class PostResponseEntity extends Equatable {
  final List<Post> posts;
  final Pagination pagination;

  const PostResponseEntity(this.posts, this.pagination);

  @override
  List<Object?> get props => [posts, pagination];
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final Author author;
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
  );

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
  ];
}

class Author extends Equatable {
  final String username;
  final String fullName;
  final String profileImage;

  const Author(this.username, this.fullName, this.profileImage);

  @override
  List<Object?> get props => [username, fullName, profileImage];
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
