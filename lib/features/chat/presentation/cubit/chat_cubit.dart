import 'dart:io';

import 'package:equatable/equatable.dart';

import 'package:app/features/chat/domain/usecases/get_messages_usecase.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/text_message_entity.dart';

part 'chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final GetMessagesUsecase getMessagesUsecase;
  ChatCubit({required this.getMessagesUsecase}) : super(ChatInitial());

  Future<void> getTextMessages() async {
    try {
      final messages = getMessagesUsecase.call();
      messages.listen((msg) {
        emit(ChatLoaded(messages: msg));
      });
    } on SocketException catch (_) {}
  }
}
