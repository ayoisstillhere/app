import 'package:equatable/equatable.dart';

class ExploreResponseEntity extends Equatable {
  final List<SuggestedAccount> suggestedAccounts;
  final List<Trending> trending;
  final List<PopularKeyword> popularKeywords;

  const ExploreResponseEntity(
    this.suggestedAccounts,
    this.trending,
    this.popularKeywords,
  );

  @override
  List<Object?> get props => [suggestedAccounts, trending, popularKeywords];
}

class PopularKeyword extends Equatable {
  final String keyword;
  final String type;
  final int postsCount;

  const PopularKeyword(this.keyword, this.type, this.postsCount);

  @override
  List<Object?> get props => [keyword, type, postsCount];
}

class SuggestedAccount extends Equatable {
  final String username;
  final String fullName;
  final String bio;
  final String profileImage;
  final int followersCount;

  const SuggestedAccount(
    this.username,
    this.fullName,
    this.bio,
    this.profileImage,
    this.followersCount,
  );

  @override
  List<Object?> get props => [
    username,
    fullName,
    bio,
    profileImage,
    followersCount,
  ];
}

class Trending extends Equatable {
  final String id;
  final String content;
  final List<String> media;
  final Author author;
  final DateTime createdAt;
  final Count count;

  const Trending(
    this.id,
    this.content,
    this.media,
    this.author,
    this.createdAt,
    this.count,
  );

  @override
  List<Object?> get props => [id, content, media, author, createdAt, count];
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
