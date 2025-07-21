import '../entities/live_stream_comment_entity.dart';
import '../entities/text_message_entity.dart';

abstract class FirebaseRepository {
  Stream<List<TextMessageEntity>> getTextMessages();
  Stream<List<LiveStreamCommentEntity>> getLiveStreamComments();
}
