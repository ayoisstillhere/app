import '../../domain/entities/get_messages_response_entity.dart';

class GetMessagesResponseModel extends GetMessagesResponse {
  GetMessagesResponseModel({
    required List<ConversationModel> conversations,
    required PaginationModel pagination,
  }) : super(conversations: conversations, pagination: pagination);

  factory GetMessagesResponseModel.fromJson(Map<String, dynamic> json) {
    return GetMessagesResponseModel(
      conversations: (json['conversations'] as List)
          .map((conv) => ConversationModel.fromJson(conv))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversations': (conversations as List<ConversationModel>)
          .map((conv) => conv.toJson())
          .toList(),
      'pagination': (pagination as PaginationModel).toJson(),
    };
  }
}

class ConversationModel extends Conversation {
  ConversationModel({
    required super.id,
    super.name,
    required super.type,
    required super.isSecret,
    required super.hasDisappearingMessages,
    super.encryptionKey,
    required super.createdAt,
    required super.updatedAt,
    required List<ParticipantModel> super.participants,
    required List<MessageModel> super.messages,
    MessageModel? super.lastMessage,
    required super.unreadCount,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      isSecret: json['isSecret'],
      hasDisappearingMessages: json['hasDisappearingMessages'],
      encryptionKey: json['encryptionKey'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      participants: (json['participants'] as List)
          .map((p) => ParticipantModel.fromJson(p))
          .toList(),
      messages: (json['messages'] as List)
          .map((m) => MessageModel.fromJson(m))
          .toList(),
      lastMessage: json['lastMessage'] != null
          ? MessageModel.fromJson(json['lastMessage'])
          : null,
      unreadCount: json['unreadCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'isSecret': isSecret,
      'hasDisappearingMessages': hasDisappearingMessages,
      'encryptionKey': encryptionKey,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'participants': (participants as List<ParticipantModel>)
          .map((p) => p.toJson())
          .toList(),
      'messages': (messages as List<MessageModel>)
          .map((m) => m.toJson())
          .toList(),
      'lastMessage': lastMessage != null
          ? (lastMessage as MessageModel).toJson()
          : null,
      'unreadCount': unreadCount,
    };
  }
}

class MessageModel extends Message {
  MessageModel({
    required super.id,
    required super.conversationId,
    required super.senderId,
    required super.type,
    required super.content,
    required super.mediaUrl,
    required super.mediaType,
    required super.encryptionMetadata,
    required super.isForwarded,
    required super.isViewOnce,
    required super.expireAt,
    required super.replyToId,
    required super.createdAt,
    required super.updatedAt,
    required SenderModel super.sender,
    required super.reactions,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'],
      conversationId: json['conversationId'],
      senderId: json['senderId'],
      type: json['type'],
      content: json['content'],
      mediaUrl: json['mediaUrl'],
      mediaType: json['mediaType'],
      encryptionMetadata: json['encryptionMetadata'],
      isForwarded: json['isForwarded'],
      isViewOnce: json['isViewOnce'],
      expireAt: DateTime.parse(json['expireAt']),
      replyToId: json['replyToId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sender: SenderModel.fromJson(json['sender']),
      reactions: json['reactions'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversationId': conversationId,
      'senderId': senderId,
      'type': type,
      'content': content,
      'mediaUrl': mediaUrl,
      'mediaType': mediaType,
      'encryptionMetadata': encryptionMetadata,
      'isForwarded': isForwarded,
      'isViewOnce': isViewOnce,
      'expireAt': expireAt.toIso8601String(),
      'replyToId': replyToId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'sender': (sender as SenderModel).toJson(),
      'reactions': reactions,
    };
  }
}

class SenderModel extends Sender {
  SenderModel({required super.username, required super.profileImage});

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      username: json['username'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'profileImage': profileImage};
  }
}

class ParticipantModel extends Participant {
  ParticipantModel({
    required super.id,
    required super.userId,
    required super.isAdmin,
    required super.joinedAt,
    required super.lastReadAt,
    required super.conversationId,
    required UserModel super.user,
  });

  factory ParticipantModel.fromJson(Map<String, dynamic> json) {
    return ParticipantModel(
      id: json['id'],
      userId: json['userId'],
      isAdmin: json['isAdmin'],
      joinedAt: DateTime.parse(json['joinedAt']),
      lastReadAt: DateTime.parse(json['lastReadAt']),
      conversationId: json['conversationId'],
      user: UserModel.fromJson(json['user']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'isAdmin': isAdmin,
      'joinedAt': joinedAt.toIso8601String(),
      'lastReadAt': lastReadAt.toIso8601String(),
      'conversationId': conversationId,
      'user': (user as UserModel).toJson(),
    };
  }
}

class UserModel extends User {
  UserModel({
    required super.username,
    required super.profileImage,
    required super.fullName,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      profileImage: json['profileImage'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'profileImage': profileImage,
      'fullName': fullName,
    };
  }
}

class PaginationModel extends Pagination {
  PaginationModel({
    required super.page,
    required super.limit,
    required super.totalCount,
    required super.totalPages,
    required super.hasMore,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'],
      limit: json['limit'],
      totalCount: json['totalCount'],
      totalPages: json['totalPages'],
      hasMore: json['hasMore'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      'totalCount': totalCount,
      'totalPages': totalPages,
      'hasMore': hasMore,
    };
  }
}
