import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LiveStreamCommentEntity extends Equatable {
  final String id;
  final String username;
  final String comment;
  final Timestamp createdAt;
  final String liveStreamId;
  const LiveStreamCommentEntity(
    this.id,
    this.username,
    this.comment,
    this.createdAt,
    this.liveStreamId,
  );
  @override
  List<Object?> get props => [id, username, comment, createdAt, liveStreamId];
}
