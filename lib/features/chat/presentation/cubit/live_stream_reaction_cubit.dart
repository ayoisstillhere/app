import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/live_stream_reaction_entity.dart';
import '../../domain/usecases/get_live_stream_reactions_usecase.dart';

part 'live_stream_reaction_state.dart';

class LiveStreamReactionCubit extends Cubit<LiveStreamReactionState>{
  final GetLiveStreamReactionsUsecase getLiveStreamReactionsUsecase;

  LiveStreamReactionCubit({required this.getLiveStreamReactionsUsecase}) : super(LiveStreamReactionInitial());

  Future<void> getLiveStreamReactions() async {
    try {
      final reactions = getLiveStreamReactionsUsecase.call();
      reactions.listen((reaction) {
        emit(LiveStreamReactionLoaded(reactions: reaction));
      });
    } on SocketException catch (_) {}
  }
}