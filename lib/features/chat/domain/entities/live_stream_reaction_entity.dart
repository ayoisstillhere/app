import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class LiveStreamReactionEntity extends Equatable {
  final String reaction;
  final String liveStreamId;
  final Timestamp createdAt;
  const LiveStreamReactionEntity(this.reaction, this.liveStreamId, this.createdAt);

  @override
  List<Object?> get props => [reaction, liveStreamId, createdAt];
}
