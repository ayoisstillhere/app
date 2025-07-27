import 'package:app/features/chat/domain/entities/live_stream_reaction_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStreamReactionModel extends LiveStreamReactionEntity {
  const LiveStreamReactionModel({
    required String reaction,
    required String liveStreamId,
    required Timestamp createdAt,
  }) : super(reaction, liveStreamId, createdAt);

  factory LiveStreamReactionModel.fromJson(Map<String, dynamic> json) =>
      LiveStreamReactionModel(
        reaction: json['reaction'],
        liveStreamId: json['liveStreamId'],
        createdAt: json['createdAt'],
      );

  factory LiveStreamReactionModel.fromSnapshot(
    DocumentSnapshot documentSnapshot,
  ) => LiveStreamReactionModel(
    reaction: (documentSnapshot.data()! as dynamic)['reaction'],
    liveStreamId: (documentSnapshot.data()! as dynamic)['liveStreamId'],
    createdAt: (documentSnapshot.data()! as dynamic)['createdAt'],
  );

  Map<String, dynamic> toDocument() => {
    'reaction': reaction,
    'liveStreamId': liveStreamId,
    'createdAt': createdAt,
  };
}
