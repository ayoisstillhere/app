class GetMessageResponse {
  final List<Conversation> conversations;
  final Pagination pagination;

  GetMessageResponse({required this.conversations, required this.pagination});
}

class Conversation {
  final String id;
  final String? name;
  final String type;
  final bool isSecret;
  final bool hasDisappearingMessages;
  final String? encryptionKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Participant> participants;
  final bool isConversationMutedForMe;
  final bool isConversationArchivedForMe;
  final bool isConversationRequestForMe;
  final bool isConversationBlockedForMe;
  final Message? lastMessage;
  final int? unreadCount;
  final String? groupImage;

  Conversation({
    required this.id,
    required this.name,
    required this.type,
    required this.isSecret,
    required this.hasDisappearingMessages,
    required this.encryptionKey,
    required this.createdAt,
    required this.updatedAt,
    required this.participants,
    required this.isConversationMutedForMe,
    required this.isConversationArchivedForMe,
    required this.isConversationRequestForMe,
    required this.lastMessage,
    required this.unreadCount,
    required this.isConversationBlockedForMe,
    required this.groupImage,
  });
}

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String content;
  final dynamic mediaUrl;
  final dynamic mediaType;
  final dynamic encryptionMetadata;
  final bool isForwarded;
  final bool isViewOnce;
  final dynamic expireAt;
  final dynamic replyToId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Sender sender;
  final List<dynamic> reactions;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.type,
    required this.content,
    required this.mediaUrl,
    required this.mediaType,
    required this.encryptionMetadata,
    required this.isForwarded,
    required this.isViewOnce,
    required this.expireAt,
    required this.replyToId,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.reactions,
  });
}

class Sender {
  final String username;
  final String profileImage;

  Sender({required this.username, required this.profileImage});
}

class Participant {
  final String id;
  final String userId;
  final bool isAdmin;
  final DateTime joinedAt;
  final DateTime lastReadAt;
  final String? conversationId;
  final bool? isConversationMutedForMe;
  final bool? isConversationArchivedForMe;
  final bool? isConversationRequestForMe;
  final User user;
  final String? mySecretConversationKey;

  Participant({
    required this.id,
    required this.userId,
    required this.isAdmin,
    required this.joinedAt,
    required this.lastReadAt,
    required this.conversationId,
    required this.isConversationMutedForMe,
    required this.isConversationArchivedForMe,
    required this.isConversationRequestForMe,
    required this.user,
    required this.mySecretConversationKey,
  });
}

class User {
  final String username;
  final String? profileImage;
  final String? fullName;
  final String? publicKey;

  User({
    required this.username,
    required this.profileImage,
    required this.fullName,
    required this.publicKey,
  });
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
}
