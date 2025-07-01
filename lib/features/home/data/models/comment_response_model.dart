import 'package:app/features/home/domain/entities/comment_response_entity.dart';

class CommentResponseModel extends CommentResponseEntity {
  const CommentResponseModel({
    required List<CommentEntity> comments,
    required PaginationEntity pagination,
  }) : super(comments, pagination);

  factory CommentResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentResponseModel(
      comments: (json['comments'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comments': comments.map((comment) => (comment as CommentModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class CommentModel extends CommentEntity {
  const CommentModel({
    required String id,
    required String content,
    required String postId,
    required dynamic parentId,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AuthorEntity author,
    required CountEntity count,
    required bool isLiked,
    required List<dynamic> replies,
  }) : super(
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
        );

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      content: json['content'],
      postId: json['postId'],
      parentId: json['parentId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: AuthorModel.fromJson(json['author']),
      count: CountModel.fromJson(json['_count']),
      isLiked: json['isLiked'] ?? false,
      replies: json['replies'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'postId': postId,
      'parentId': parentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': (author as AuthorModel).toJson(),
      '_count': (count as CountModel).toJson(),
      'isLiked': isLiked,
      'replies': replies,
    };
  }
}

class AuthorModel extends AuthorEntity {
  const AuthorModel({
    required String username,
    required String fullName,
    required String profileImage,
  }) : super(username, fullName, profileImage);

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      username: json['username'],
      fullName: json['fullName'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'profileImage': profileImage,
    };
  }
}

class CountModel extends CountEntity {
  const CountModel({
    required int likes,
    required int replies,
  }) : super(likes, replies);

  factory CountModel.fromJson(Map<String, dynamic> json) {
    return CountModel(
      likes: json['likes'] ?? 0,
      replies: json['replies'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'replies': replies,
    };
  }
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required int page,
    required int limit,
    required bool hasMore,
  }) : super(page, limit, hasMore);

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'],
      limit: json['limit'],
      hasMore: json['hasMore'],
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