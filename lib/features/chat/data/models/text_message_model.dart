import 'package:app/features/chat/domain/entities/text_message_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TextMessageModel extends TextMessageEntity {
  const TextMessageModel({
    required String content,
    required String conversationId,
    required Timestamp createdAt,
    required Timestamp? expiredAt,
    required String id,
    required bool isForwarded,
    required bool? isViewOnce,
    required String? mediaUrl,
    required Map<String, dynamic> reactions,
    required String senderId,
    required String type,
    final String? encryptionMetadata,
  }) : super(
         content,
         conversationId,
         createdAt,
         expiredAt,
         id,
         isForwarded,
         isViewOnce,
         mediaUrl,
         reactions,
         senderId,
         type,
         encryptionMetadata,
       );

  factory TextMessageModel.fromJson(Map<String, dynamic> json) {
    return TextMessageModel(
      content: json['content'],
      conversationId: json['conversationId'],
      createdAt: json['createdAt'],
      expiredAt: json['expiredAt'],
      id: json['id'],
      isForwarded: json['isForwarded'],
      isViewOnce: json['isViewOnce'],
      mediaUrl: json['mediaUrl'],
      reactions: json['reactions'],
      senderId: json['senderId'],
      type: json['type'],
      encryptionMetadata: json['encryptionMetadata'],
    );
  }

  factory TextMessageModel.fromSnapshot(DocumentSnapshot documentSnapshot) {
    return TextMessageModel(
      content: (documentSnapshot.data()! as dynamic)['content'],
      conversationId: (documentSnapshot.data()! as dynamic)['conversationId'],
      createdAt: (documentSnapshot.data()! as dynamic)['createdAt'],
      expiredAt: (documentSnapshot.data()! as dynamic)['expiredAt'],
      id: (documentSnapshot.data()! as dynamic)['id'],
      isForwarded: (documentSnapshot.data()! as dynamic)['isForwarded'],
      isViewOnce: (documentSnapshot.data()! as dynamic)['isViewOnce'],
      mediaUrl: (documentSnapshot.data()! as dynamic)['mediaUrl'],
      reactions: (documentSnapshot.data()! as dynamic)['reactions'],
      senderId: (documentSnapshot.data()! as dynamic)['senderId'],
      type: (documentSnapshot.data()! as dynamic)['type'],
      encryptionMetadata:
          (documentSnapshot.data()! as dynamic)['encryptionMetadata'],
    );
  }

  Map<String, dynamic> toDocument() => {
    'content': content,
    'conversationId': conversationId,
    'createdAt': createdAt,
    'expiredAt': expiredAt,
    'id': id,
    'isForwarded': isForwarded,
    'isViewOnce': isViewOnce,
    'mediaUrl': mediaUrl,
    'reactions': reactions,
    'senderId': senderId,
    'type': type,
    'encryptionMetadata': encryptionMetadata,
  };
}
