import '../entities/live_stream_comment_entity.dart';
import '../repositories/firebase_repository.dart';

class GetLiveStreamComnmentsUsecase {
  final FirebaseRepository repository;

  GetLiveStreamComnmentsUsecase({required this.repository});

  Stream<List<LiveStreamCommentEntity>> call() =>
      repository.getLiveStreamComments();
}
