import '../../domain/entities/get_media_response_entity.dart';

class GetMediaResponseModel extends GetMediaResponse {
  GetMediaResponseModel({
    required List<DatumModel> data,
    required PaginationModel pagination,
  }) : super(data: data, pagination: pagination);

  factory GetMediaResponseModel.fromJson(Map<String, dynamic> json) {
    return GetMediaResponseModel(
      data: (json['data'] as List).map((e) => DatumModel.fromJson(e)).toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }

  Map<String, dynamic> toJson() => {
    'data': (data as List<DatumModel>).map((e) => e.toJson()).toList(),
    'pagination': (pagination as PaginationModel).toJson(),
  };
}

class DatumModel extends Datum {
  DatumModel({
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
    required ConversationModel super.conversation,
  });

  factory DatumModel.fromJson(Map<String, dynamic> json) {
    return DatumModel(
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
      expireAt: json['expireAt'] != null
          ? DateTime.parse(json['expireAt'])
          : null,
      replyToId: json['replyToId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      sender: SenderModel.fromJson(json['sender']),
      conversation: ConversationModel.fromJson(json['conversation']),
    );
  }

  Map<String, dynamic> toJson() => {
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
    'expireAt': expireAt?.toIso8601String(),
    'replyToId': replyToId,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'sender': (sender as SenderModel).toJson(),
    'conversation': (conversation as ConversationModel).toJson(),
  };
}

class ConversationModel extends Conversation {
  ConversationModel({required super.encryptionKey, required super.type});

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      encryptionKey: json['encryptionKey'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'encryptionKey': encryptionKey,
    'type': type,
  };
}

class SenderModel extends Sender {
  SenderModel({
    required super.id,
    required super.username,
    required super.profileImage,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'],
      username: json['username'],
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'profileImage': profileImage,
  };
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

  Map<String, dynamic> toJson() => {
    'page': page,
    'limit': limit,
    'totalCount': totalCount,
    'totalPages': totalPages,
    'hasMore': hasMore,
  };
}
