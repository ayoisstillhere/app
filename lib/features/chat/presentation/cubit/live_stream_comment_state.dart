part of 'live_stream_comment_cubit.dart';

abstract class LiveStreamCommentState extends Equatable {
  const LiveStreamCommentState();
}

class LiveStreamCommentInitial extends LiveStreamCommentState {
  @override
  List<Object> get props => [];
}

class LiveStreamCommentLoading extends LiveStreamCommentState {
  @override
  List<Object> get props => [];
}

class LiveStreamCommentLoaded extends LiveStreamCommentState {
  final List<LiveStreamCommentEntity> comments;
  const LiveStreamCommentLoaded({required this.comments});
  @override
  List<Object> get props => [comments];
}