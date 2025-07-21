import 'dart:io';

import 'package:app/features/chat/domain/usecases/get_live_stream_comnments_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/live_stream_comment_entity.dart';

part 'live_stream_comment_state.dart';

class LiveStreamCommentCubit extends Cubit<LiveStreamCommentState>{
  final GetLiveStreamComnmentsUsecase getLiveStreamComnmentsUsecase;

  LiveStreamCommentCubit({required this.getLiveStreamComnmentsUsecase}) : super(LiveStreamCommentInitial());

  Future<void> getLiveStreamComments() async {
    try {
      final comments = getLiveStreamComnmentsUsecase.call();
      comments.listen((comment) {
        emit(LiveStreamCommentLoaded(comments: comment));
      });
    } on SocketException catch (_) {}
  }
}