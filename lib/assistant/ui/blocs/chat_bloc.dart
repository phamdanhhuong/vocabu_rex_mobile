import 'package:bloc/bloc.dart';
import 'package:vocabu_rex_mobile/assistant/domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/get_user_conversations_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/get_conversation_messages_usecase.dart';

//Event
abstract class ChatEvent {}

class StartEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;
  final String? role;

  SendMessageEvent({required this.message, this.role});
}

class LoadConversationsEvent extends ChatEvent {}

class LoadConversationHistoryEvent extends ChatEvent {
  final String conversationId;

  LoadConversationHistoryEvent({required this.conversationId});
}

//State
abstract class ChatState {}

class ChatInit extends ChatState {}

class ChatLoading extends ChatState {}

class ConversationsLoading extends ChatState {}

class ConversationsLoaded extends ChatState {
  final List<ConversationEntity> conversations;

  ConversationsLoaded({required this.conversations});
}

class ChatLoaded extends ChatState {
  String conversationId;
  List<MessageEntity> messages;
  bool isLoadingMessage; // Flag to indicate message is being sent

  ChatLoaded({
    required this.conversationId,
    required this.messages,
    this.isLoadingMessage = false,
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    String? conversationId,
    bool? isLoadingMessage,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      isLoadingMessage: isLoadingMessage ?? this.isLoadingMessage,
    );
  }
}

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final ChatUsecase chatUsecase;
  final StartChatUsecase startChatUsecase;
  final GetUserConversationsUsecase getUserConversationsUsecase;
  final GetConversationMessagesUsecase getConversationMessagesUsecase;

  ChatBloc({
    required this.chatUsecase,
    required this.startChatUsecase,
    required this.getUserConversationsUsecase,
    required this.getConversationMessagesUsecase,
  }) : super(ChatInit()) {
    on<StartEvent>((event, emit) async {
      emit(ChatLoading());
      final id = await startChatUsecase();
      emit(ChatLoaded(conversationId: id, messages: []));
    });

    on<LoadConversationsEvent>((event, emit) async {
      emit(ConversationsLoading());
      try {
        final conversations = await getUserConversationsUsecase();
        emit(ConversationsLoaded(conversations: conversations));
      } catch (e) {
        emit(ChatInit());
      }
    });

    on<LoadConversationHistoryEvent>((event, emit) async {
      emit(ChatLoading());
      try {
        final messages = await getConversationMessagesUsecase(event.conversationId);
        emit(ChatLoaded(conversationId: event.conversationId, messages: messages));
      } catch (e) {
        emit(ChatInit());
      }
    });

    on<SendMessageEvent>((event, emit) async {
      var currentState = state;
      
      // If no conversation exists, start one first
      if (currentState is! ChatLoaded) {
        emit(ChatLoading());
        try {
          final id = await startChatUsecase();
          currentState = ChatLoaded(conversationId: id, messages: []);
        } catch (e) {
          // If failed to start, return to init state
          emit(ChatInit());
          return;
        }
      }
      
      if (currentState is ChatLoaded) {
        final userMessage = MessageEntity(
          messageId: DateTime.now().millisecondsSinceEpoch.toString(),
          conversationId: currentState.conversationId,
          role: "user",
          content: event.message,
          timestamp: DateTime.now(),
          metadata: {},
        );

        // Add user message and set loading flag
        emit(
          currentState.copyWith(
            messages: [...currentState.messages, userMessage],
            isLoadingMessage: true,
          ),
        );

        try {
          // Get AI response
          final aiMessage = await chatUsecase(
            currentState.conversationId,
            event.message,
            role: event.role,
          );

          // Add AI message to the list and clear loading flag
          emit(
            currentState.copyWith(
              messages: [...currentState.messages, userMessage, aiMessage],
              isLoadingMessage: false,
            ),
          );
        } catch (e) {
          // On error, still show user message but add error message
          emit(
            currentState.copyWith(
              messages: [
                ...currentState.messages,
                userMessage,
                MessageEntity(
                  messageId: DateTime.now().millisecondsSinceEpoch.toString(),
                  conversationId: currentState.conversationId,
                  role: "assistant",
                  content: "Sorry, I encountered an error: ${e.toString()}. Please try again.",
                  timestamp: DateTime.now(),
                  metadata: {"error": true},
                ),
              ],
              isLoadingMessage: false,
            ),
          );
        }
      }
    });
  }
}
