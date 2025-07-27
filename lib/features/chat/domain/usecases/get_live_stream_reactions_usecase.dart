import '../entities/live_stream_reaction_entity.dart';
import '../repositories/firebase_repository.dart';

class GetLiveStreamReactionsUsecase {
  final FirebaseRepository repository;

  GetLiveStreamReactionsUsecase({required this.repository});

  Stream<List<LiveStreamReactionEntity>> call() =>
      repository.getLiveStreamReactions();
}
