import 'package:app/features/chat/domain/entities/live_stream_comment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LiveStreamCommentModel extends LiveStreamCommentEntity {
  const LiveStreamCommentModel({
    required String id,
    required String username,
    required String comment,
    required Timestamp createdAt,
    required String liveStreamId,
  }) : super(id, username, comment, createdAt, liveStreamId);

  factory LiveStreamCommentModel.fromJson(Map<String, dynamic> json) {
    return LiveStreamCommentModel(
      id: json['id'],
      username: json['username'],
      comment: json['comment'],
      createdAt: json['createdAt'],
      liveStreamId: json['liveStreamId'],
    );
  }

  factory LiveStreamCommentModel.fromSnapshot(
    DocumentSnapshot documentSnapshot,
  ) {
    return LiveStreamCommentModel(
      id: (documentSnapshot.data()! as dynamic)['id'],
      username: (documentSnapshot.data()! as dynamic)['username'],
      comment: (documentSnapshot.data()! as dynamic)['comment'],
      createdAt: (documentSnapshot.data()! as dynamic)['createdAt'],
      liveStreamId: (documentSnapshot.data()! as dynamic)['liveStreamId'],
    );
  }

  Map<String, dynamic> toDocument() => {
    'id': id,
    'username': username,
    'comment': comment,
    'createdAt': createdAt,
    'liveStreamId': liveStreamId,
  };
}
