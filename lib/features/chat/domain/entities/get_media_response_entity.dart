class GetMediaResponse {
  final List<Datum> data;
  final Pagination pagination;

  GetMediaResponse({required this.data, required this.pagination});
}

class Datum {
  final String id;
  final String conversationId;
  final String senderId;
  final String type;
  final String content;
  final String mediaUrl;
  final String mediaType;
  final String? encryptionMetadata;
  final bool isForwarded;
  final bool isViewOnce;
  final DateTime? expireAt;
  final dynamic replyToId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Sender sender;
  final Conversation conversation;

  Datum({
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
    required this.conversation,
  });
}

class Conversation {
  final String encryptionKey;
  final String type;

  Conversation({required this.encryptionKey, required this.type});
}

class Sender {
  final String id;
  final String username;
  final String profileImage;

  Sender({
    required this.id,
    required this.username,
    required this.profileImage,
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
