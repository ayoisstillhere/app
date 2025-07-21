import 'package:app/features/chat/domain/entities/live_stream_comment_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/text_message_entity.dart';
import '../models/live_stream_comment_model.dart';
import '../models/text_message_model.dart';

abstract class FirebaseRemoteDataSource {
  Stream<List<TextMessageEntity>> getTextMessages();
  Stream<List<LiveStreamCommentEntity>> getLiveStreamComments();
}

class FirebaseRemoteDatasourceImpl implements FirebaseRemoteDataSource {
  final _messageCollection = FirebaseFirestore.instance.collection("messages");
  final _liveStreamCommentsCollection = FirebaseFirestore.instance.collection(
    "liveStreamComments",
  );
  @override
  Stream<List<TextMessageEntity>> getTextMessages() {
    return _messageCollection.snapshots().map(
      (querySnapshot) => querySnapshot.docs
          .map((docSnapshot) => TextMessageModel.fromSnapshot(docSnapshot))
          .toList(),
    );
  }

  @override
  Stream<List<LiveStreamCommentEntity>> getLiveStreamComments() {
    return _liveStreamCommentsCollection.snapshots().map(
      (querySnapshot) => querySnapshot.docs
          .map(
            (docSnapshot) => LiveStreamCommentModel.fromSnapshot(docSnapshot),
          )
          .toList(),
    );
  }
}
