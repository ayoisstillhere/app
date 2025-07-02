import '../../domain/entities/explore_response_entity.dart';

class ExploreResponseModel extends ExploreResponseEntity {
  const ExploreResponseModel({
    required List<SuggestedAccountModel> suggestedAccounts,
    required List<TrendingModel> trending,
    required List<PopularKeywordModel> popularKeywords,
  }) : super(suggestedAccounts, trending, popularKeywords);

  factory ExploreResponseModel.fromJson(Map<String, dynamic> json) {
    return ExploreResponseModel(
      suggestedAccounts: (json['suggestedAccounts'] as List)
          .map((e) => SuggestedAccountModel.fromJson(e))
          .toList(),
      trending: (json['trending'] as List)
          .map((e) => TrendingModel.fromJson(e))
          .toList(),
      popularKeywords: (json['popularKeywords'] as List)
          .map((e) => PopularKeywordModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suggestedAccounts':
          suggestedAccounts.map((e) => (e as SuggestedAccountModel).toJson()).toList(),
      'trending': trending.map((e) => (e as TrendingModel).toJson()).toList(),
      'popularKeywords':
          popularKeywords.map((e) => (e as PopularKeywordModel).toJson()).toList(),
    };
  }
}

class SuggestedAccountModel extends SuggestedAccount {
  const SuggestedAccountModel({
    required String username,
    required String fullName,
    required String bio,
    required String profileImage,
    required int followersCount,
  }) : super(username, fullName, bio, profileImage, followersCount);

  factory SuggestedAccountModel.fromJson(Map<String, dynamic> json) {
    return SuggestedAccountModel(
      username: json['username'],
      fullName: json['fullName'],
      bio: json['bio'],
      profileImage: json['profileImage'],
      followersCount: json['followersCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'fullName': fullName,
      'bio': bio,
      'profileImage': profileImage,
      'followersCount': followersCount,
    };
  }
}

class PopularKeywordModel extends PopularKeyword {
  const PopularKeywordModel({
    required String keyword,
    required String type,
    required int postsCount,
  }) : super(keyword, type, postsCount);

  factory PopularKeywordModel.fromJson(Map<String, dynamic> json) {
    return PopularKeywordModel(
      keyword: json['keyword'],
      type: json['type'],
      postsCount: json['postsCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'keyword': keyword,
      'type': type,
      'postsCount': postsCount,
    };
  }
}

class TrendingModel extends Trending {
  const TrendingModel({
    required String id,
    required String content,
    required List<String> media,
    required AuthorModel author,
    required DateTime createdAt,
    required CountModel count,
  }) : super(id, content, media, author, createdAt, count);

  factory TrendingModel.fromJson(Map<String, dynamic> json) {
    return TrendingModel(
      id: json['id'],
      content: json['content'],
      media: List<String>.from(json['media'] ?? []),
      author: AuthorModel.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
      count: CountModel.fromJson(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'media': media,
      'author': (author as AuthorModel).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'count': (count as CountModel).toJson(),
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
