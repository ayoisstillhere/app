import '../entities/text_message_entity.dart';

abstract class FirebaseRepository {
  Stream<List<TextMessageEntity>> getTextMessages();
}
