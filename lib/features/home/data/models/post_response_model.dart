import 'package:app/features/home/domain/entities/post_response_entity.dart';

class PostResponseModel extends PostResponseEntity {
  const PostResponseModel({
    required List<PostModel> posts,
    required PaginationModel pagination,
  }) : super(posts, pagination);

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    return PostResponseModel(
      posts: (json['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => (post as PostModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
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
      page: json['page'],
      limit: json['limit'],
      hasMore: json['hasMore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'page': page, 'limit': limit, 'hasMore': hasMore};
  }
}

class PostModel extends Post {
  const PostModel({
    required String id,
    required String content,
    required List<String> media,
    required List<String> links,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AuthorModel author,
    required CountModel count,
    required bool isLiked,
    required bool isReposted,
    required bool isSaved,
  }) : super(
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
       );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      content: json['content'],
      media: List<String>.from(json['media'] ?? []),
      links: List<String>.from(json['links'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      author: AuthorModel.fromJson(json['author']),
      count: CountModel.fromJson(json['_count']),
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'media': media,
      'links': links,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'author': (author as AuthorModel).toJson(),
      '_count': (count as CountModel).toJson(),
      'isLiked': isLiked,
      'isReposted': isReposted,
      'isSaved': isSaved,
    };
  }
}

class AuthorModel extends Author {
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

class CountModel extends Count {
  const CountModel({
    required int likes,
    required int comments,
    required int reposts,
    required int saves,
  }) : super(likes, comments, reposts, saves);

  factory CountModel.fromJson(Map<String, dynamic> json) {
    return CountModel(
      likes: json['likes'] ?? 0,
      comments: json['comments'] ?? 0,
      reposts: json['reposts'] ?? 0,
      saves: json['saves'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'comments': comments,
      'reposts': reposts,
      'saves': saves,
    };
  }
}
