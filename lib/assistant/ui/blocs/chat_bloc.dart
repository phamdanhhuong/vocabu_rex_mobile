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

class ResetChatEvent extends ChatEvent {}

//State
abstract class ChatState {
  final List<ConversationEntity> conversations;
  final bool isLoadingConversations;
  
  ChatState({
    this.conversations = const [],
    this.isLoadingConversations = false,
  });
}

class ChatInit extends ChatState {
  ChatInit({super.conversations, super.isLoadingConversations});
}

class ChatLoading extends ChatState {
  ChatLoading({super.conversations, super.isLoadingConversations});
}

class ChatLoaded extends ChatState {
  String conversationId;
  List<MessageEntity> messages;
  bool isLoadingMessage;

  ChatLoaded({
    required this.conversationId,
    required this.messages,
    this.isLoadingMessage = false,
    super.conversations,
    super.isLoadingConversations,
  });

  ChatLoaded copyWith({
    List<MessageEntity>? messages,
    String? conversationId,
    bool? isLoadingMessage,
    List<ConversationEntity>? conversations,
    bool? isLoadingConversations,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      conversationId: conversationId ?? this.conversationId,
      isLoadingMessage: isLoadingMessage ?? this.isLoadingMessage,
      conversations: conversations ?? this.conversations,
      isLoadingConversations: isLoadingConversations ?? this.isLoadingConversations,
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
      emit(ChatLoading(
        conversations: state.conversations,
      ));
      final id = await startChatUsecase();
      final aiGreeting = MessageEntity(
        messageId: DateTime.now().millisecondsSinceEpoch.toString(),
        conversationId: id,
        role: "assistant",
        content: "Xin chào! Bạn muốn luyện tập nội dung gì hôm nay?",
        timestamp: DateTime.now(),
        metadata: const {},
      );
      
      emit(ChatLoaded(
        conversationId: id,
        messages: [aiGreeting],
        conversations: state.conversations,
      ));
    });

    on<LoadConversationsEvent>((event, emit) async {
      if (state is ChatLoaded) {
        emit((state as ChatLoaded).copyWith(isLoadingConversations: true));
      } else {
        emit(ChatInit(
          conversations: state.conversations,
          isLoadingConversations: true,
        ));
      }
      
      try {
        final conversations = await getUserConversationsUsecase();
        if (state is ChatLoaded) {
          emit((state as ChatLoaded).copyWith(
            conversations: conversations,
            isLoadingConversations: false,
          ));
        } else {
          emit(ChatInit(
            conversations: conversations,
            isLoadingConversations: false,
          ));
        }
      } catch (e) {
        if (state is ChatLoaded) {
          emit((state as ChatLoaded).copyWith(isLoadingConversations: false));
        } else {
          emit(ChatInit(
            conversations: state.conversations,
            isLoadingConversations: false,
          ));
        }
      }
    });

    on<ResetChatEvent>((event, emit) {
      emit(ChatInit(
        conversations: state.conversations,
        isLoadingConversations: state.isLoadingConversations,
      ));
    });

    on<LoadConversationHistoryEvent>((event, emit) async {
      emit(ChatLoading(
        conversations: state.conversations,
      ));
      try {
        final messages = await getConversationMessagesUsecase(
          event.conversationId,
        );
        
        if (messages.isEmpty) {
          messages.add(
            MessageEntity(
              messageId: DateTime.now().millisecondsSinceEpoch.toString(),
              conversationId: event.conversationId,
              role: "assistant",
              content: "Xin chào! Bạn muốn luyện tập nội dung gì hôm nay?",
              timestamp: DateTime.now(),
              metadata: const {},
            ),
          );
        }

        emit(
          ChatLoaded(
            conversationId: event.conversationId,
            messages: messages,
            conversations: state.conversations,
          ),
        );
      } catch (e) {
        emit(ChatInit(
          conversations: state.conversations,
        ));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      var currentState = state;

      // If no conversation exists, start one first
      if (currentState is! ChatLoaded) {
        emit(ChatLoading(
          conversations: state.conversations,
        ));
        try {
          final id = await startChatUsecase();
          currentState = ChatLoaded(
            conversationId: id,
            messages: [],
            conversations: state.conversations,
          );
        } catch (e) {
          emit(ChatInit(
            conversations: state.conversations,
          ));
          return;
        }
      }

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
                content:
                    "Sorry, I encountered an error: ${e.toString()}. Please try again.",
                timestamp: DateTime.now(),
                metadata: {"error": true},
              ),
            ],
            isLoadingMessage: false,
          ),
        );
      }
    });
  }
}
