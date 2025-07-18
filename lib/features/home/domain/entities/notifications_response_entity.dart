// To parse this JSON data, do
//
//     final notificationsResponseEntity = notificationsResponseEntityFromJson(jsonString);

import 'dart:convert';

NotificationsResponseEntity notificationsResponseEntityFromJson(String str) =>
    NotificationsResponseEntity.fromJson(json.decode(str));

String notificationsResponseEntityToJson(NotificationsResponseEntity data) =>
    json.encode(data.toJson());

class NotificationsResponseEntity {
  final List<Notification> notifications;
  final Pagination pagination;

  NotificationsResponseEntity({
    required this.notifications,
    required this.pagination,
  });

  factory NotificationsResponseEntity.fromJson(Map<String, dynamic> json) =>
      NotificationsResponseEntity(
        notifications: List<Notification>.from(
          json["notifications"].map((x) => Notification.fromJson(x)),
        ),
        pagination: Pagination.fromJson(json["pagination"]),
      );

  Map<String, dynamic> toJson() => {
    "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
    "pagination": pagination.toJson(),
  };
}

class Notification {
  final String id;
  final String type;
  final String message;
  final bool isRead;
  final Sender? sender;
  final Post? post;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.sender,
    required this.post,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
    id: json["id"],
    type: json["type"],
    message: json["message"],
    isRead: json["isRead"],
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    post: json["post"] == null ? null : Post.fromJson(json["post"]),
    createdAt: DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "type": type,
    "message": message,
    "isRead": isRead,
    "sender": sender?.toJson(),
    "post": post?.toJson(),
    "createdAt": createdAt.toIso8601String(),
  };
}

class Post {
  final String id;
  final String content;
  final List<String> media;

  Post({required this.id, required this.content, required this.media});

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["id"],
    content: json["content"],
    media: List<String>.from(json["media"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "content": content,
    "media": List<dynamic>.from(media.map((x) => x)),
  };
}

class Sender {
  final String username;
  final String fullName;
  final String profileImage;

  Sender({
    required this.username,
    required this.fullName,
    required this.profileImage,
  });

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    username: json["username"],
    fullName: json["fullName"],
    profileImage: json["profileImage"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "fullName": fullName,
    "profileImage": profileImage,
  };
}

class Pagination {
  final int page;
  final int limit;
  final int totalCount;
  final int totalPages;
  final bool hasMore;

  Pagination({
    required this.page,
    required this.limit,
    required this.totalCount,
    required this.totalPages,
    required this.hasMore,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    page: json["page"],
    limit: json["limit"],
    totalCount: json["totalCount"],
    totalPages: json["totalPages"],
    hasMore: json["hasMore"],
  );

  Map<String, dynamic> toJson() => {
    "page": page,
    "limit": limit,
    "totalCount": totalCount,
    "totalPages": totalPages,
    "hasMore": hasMore,
  };
}
