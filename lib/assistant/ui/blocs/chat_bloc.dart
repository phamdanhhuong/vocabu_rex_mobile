import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/assistant/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';

//Event
abstract class ChatEvent {}

class StartEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;

  SendMessageEvent({required this.message});
}

//State
abstract class ChatState {}

class ChatInit extends ChatState {}

class ChatLoading extends ChatState {}

class MessageLoading extends ChatState {}

class ChatLoaded extends ChatState {
  String conversationId;
  List<MessageEntity> messages;
  ChatLoaded({required this.conversationId, required this.messages});

  ChatLoaded copyWith({List<MessageEntity>? messages, String? conversationId}) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
    );
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUsecase chatUsecase;
  final StartChatUsecase startChatUsecase;
  ChatBloc({required this.chatUsecase, required this.startChatUsecase})
    : super(ChatInit()) {
    on<StartEvent>((event, emit) async {
      emit(ChatLoading());
      final id = await startChatUsecase();
      emit(ChatLoaded(conversationId: id, messages: []));
    });

    on<SendMessageEvent>((event, emit) async {
      var currentState = state;
      if (currentState is ChatLoaded) {
        final userMessage = MessageEntity(
          messageId: "",
          conversationId: "",
          role: "user",
          content: event.message,
          timestamp: DateTime.now(),
          metadata: {},
        );

        currentState.messages.add(userMessage);

        // emit(MessageLoading());
        final message = await chatUsecase(
          currentState.conversationId,
          event.message,
        );
        emit(
          currentState.copyWith(messages: [...currentState.messages, message]),
        );
      }
    });
  }
}
