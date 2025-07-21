import 'package:app/features/chat/data/datasources/firebase_remote_datasource.dart';
import 'package:app/features/chat/domain/entities/text_message_entity.dart';

import '../../domain/entities/live_stream_comment_entity.dart';
import '../../domain/repositories/firebase_repository.dart';

class FirebaseRepositoryImpl implements FirebaseRepository {
  final FirebaseRemoteDataSource firebaseRemoteDatasource;
  FirebaseRepositoryImpl({required this.firebaseRemoteDatasource});
  @override
  Stream<List<TextMessageEntity>> getTextMessages() {
    return firebaseRemoteDatasource.getTextMessages();
  }

  @override
  Stream<List<LiveStreamCommentEntity>> getLiveStreamComments() {
    return firebaseRemoteDatasource.getLiveStreamComments();
  }
}
