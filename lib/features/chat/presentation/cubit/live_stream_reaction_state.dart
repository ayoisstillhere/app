part of 'live_stream_reaction_cubit.dart';

abstract class LiveStreamReactionState extends Equatable {
  const LiveStreamReactionState();
}

class LiveStreamReactionInitial extends LiveStreamReactionState {
  @override
  List<Object> get props => [];
}

class LiveStreamReactionLoading extends LiveStreamReactionState {
  @override
  List<Object> get props => [];
}

class LiveStreamReactionLoaded extends LiveStreamReactionState {
  final List<LiveStreamReactionEntity> reactions;
  const LiveStreamReactionLoaded({required this.reactions});
  @override
  List<Object> get props => [reactions];
}