import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TextMessageEntity extends Equatable {
  final String content;
  final String conversationId;
  final Timestamp createdAt;
  final Timestamp? expiredAt;
  final String id;
  final bool isForwarded;
  final bool? isViewOnce;
  final String? mediaUrl;
  final Map<String, dynamic> reactions;
  final String senderId;
  final String type;
  final String? encryptionMetadata;
  const TextMessageEntity(
    this.content,
    this.conversationId,
    this.createdAt,
    this.expiredAt,
    this.id,
    this.isForwarded,
    this.isViewOnce,
    this.mediaUrl,
    this.reactions,
    this.senderId,
    this.type,
    this.encryptionMetadata,
  );

  @override
  List<Object?> get props => [
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
    encryptionMetadata
  ];
}
