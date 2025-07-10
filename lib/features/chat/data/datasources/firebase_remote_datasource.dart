import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/text_message_entity.dart';
import '../models/text_message_model.dart';

abstract class FirebaseRemoteDataSource {
  Stream<List<TextMessageEntity>> getTextMessages();
}

class FirebaseRemoteDatasourceImpl implements FirebaseRemoteDataSource {
  final _messageCollection = FirebaseFirestore.instance.collection("messages");
  @override
  Stream<List<TextMessageEntity>> getTextMessages() {
    return _messageCollection.snapshots().map(
      (querySnapshot) => querySnapshot.docs
          .map((docSnapshot) => TextMessageModel.fromSnapshot(docSnapshot))
          .toList(),
    );
  }
}
