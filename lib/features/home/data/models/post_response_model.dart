import 'package:app/features/home/domain/entities/post_response_entity.dart';

class PostResponseModel extends PostResponseEntity {
  const PostResponseModel({
    required List<PostModel> posts,
    required PaginationModel pagination,
    required User user,
  }) : super(posts, pagination, user);

  factory PostResponseModel.fromJson(Map<String, dynamic> json) {
    return PostResponseModel(
      posts: (json['posts'] as List)
          .map((post) => PostModel.fromJson(post))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
      user: json['user'] == null
          ? const PostResponseUserModel.empty()
          : PostResponseUserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'posts': posts.map((post) => (post as PostModel).toJson()).toList(),
      'pagination': (pagination as PaginationModel).toJson(),
      'user': (user as PostResponseUserModel).toJson(),
    };
  }
}

class CommentsResponseModel extends CommentsResponseEntity {
  const CommentsResponseModel({
    required List<CommentModel> comments,
    required PaginationModel pagination,
  }) : super(comments, pagination);

  factory CommentsResponseModel.fromJson(Map<String, dynamic> json) {
    return CommentsResponseModel(
      comments: (json['comments'] as List)
          .map((comment) => CommentModel.fromJson(comment))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comments': comments
          .map((comment) => (comment as CommentModel).toJson())
          .toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class CommentModel extends Comment {
  const CommentModel({
    required PostModel super.post,
    required super.isLiked,
    required super.isReposted,
    required super.isSaved,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      post: PostModel.fromJson(json),
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isSaved: json['isSaved'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'post': (post as PostModel).toJson(),
      'isLiked': isLiked,
      'isReposted': isReposted,
      'isSaved': isSaved,
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
    required String authorId,
    required bool isComment,
    required String? parentPostId,
    required ParentPost? parentPost,
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
         authorId,
         isComment,
         parentPostId,
         parentPost,
       );

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      links: List<String>.from(json['links'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      author: AuthorModel.fromJson(json['author'] ?? {}),
      count: CountModel.fromJson(json['_count'] ?? {}),
      isLiked: json['isLiked'] ?? false,
      isReposted: json['isReposted'] ?? false,
      isSaved: json['isSaved'] ?? false,
      authorId: json['authorId'] ?? '',
      isComment: json['isComment'] ?? false,
      parentPostId: json['parentPostId'], // Can be null
      parentPost: json['parentPost'] != null
          ? ParentPostModel.fromJson(json['parentPost'])
          : null,
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
      'authorId': authorId,
      'isComment': isComment,
      if (parentPostId != null) 'parentPostId': parentPostId,
      if (parentPost != null)
        'parentPost': (parentPost as ParentPostModel).toJson(),
    };
  }
}

class AuthorModel extends Author {
  const AuthorModel({
    required String id,
    required String username,
    required String fullName,
    required String profileImage,
  }) : super(id, username, fullName, profileImage);

  // Empty constructor for null handling
  const AuthorModel.empty() : super('', '', '', '');

  factory AuthorModel.fromJson(Map<String, dynamic> json) {
    return AuthorModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
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

class PostResponseUserModel extends User {
  const PostResponseUserModel({
    required String id,
    required String username,
    required String fullName,
    required String profileImage,
  }) : super(id, username, fullName, profileImage);

  // Empty constructor for null handling
  const PostResponseUserModel.empty() : super('', '', '', '');

  factory PostResponseUserModel.fromJson(Map<String, dynamic> json) {
    return PostResponseUserModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      profileImage: json['profileImage'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'profileImage': profileImage,
    };
  }
}

class ParentPostModel extends ParentPost {
  const ParentPostModel({
    required String id,
    required String content,
    required List<String> media,
    required List<String> links,
    required DateTime createdAt,
    required DateTime updatedAt,
    required AuthorModel author,
    required String authorId,
    required bool isComment,
    required String? parentPostId,
  }) : super(
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
       );

  factory ParentPostModel.fromJson(Map<String, dynamic> json) {
    return ParentPostModel(
      id: json['id'] ?? '',
      content: json['content'] ?? '',
      media: List<String>.from(json['media'] ?? []),
      links: List<String>.from(json['links'] ?? []),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      author: AuthorModel.fromJson(json['author'] ?? {}),
      authorId: json['authorId'] ?? '',
      isComment: json['isComment'] ?? false,
      parentPostId: json['parentPostId'], // Can be null
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
      'authorId': authorId,
      'isComment': isComment,
      if (parentPostId != null) 'parentPostId': parentPostId,
    };
  }
}
