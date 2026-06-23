import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage(this.text, this.isUser);
}

class AIRoadmapGeneratorPanel extends StatefulWidget {
  const AIRoadmapGeneratorPanel({super.key});

  @override
  State<AIRoadmapGeneratorPanel> createState() => _AIRoadmapGeneratorPanelState();
}

class _AIRoadmapGeneratorPanelState extends State<AIRoadmapGeneratorPanel> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _conversationId;

  @override
  void initState() {
    super.initState();
    _startConversation();
  }

  Future<void> _startConversation() async {
    setState(() => _isLoading = true);
    try {
      final startUseCase = sl<StartChatUsecase>();
      _conversationId = await startUseCase();
      _addBotMessage("Xin chào Chỉ huy! Tôi là VocabuRex AI chuyên tư vấn lộ trình. Bạn muốn học tiếng Anh để làm gì? Trình độ hiện tại và thời gian bạn có thể dành ra mỗi ngày?");
    } catch (e) {
      _addBotMessage("Lỗi kết nối tới Lõi AI: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text, false));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(text, true));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _conversationId == null) return;
    _textController.clear();
    _addUserMessage(text);
    
    setState(() => _isLoading = true);
    try {
      final chatUseCase = sl<ChatUsecase>();
      final aiMessage = await chatUseCase(
        _conversationId!,
        text,
        role: 'roadmap_planner',
      );
      
      String aiResponseText = aiMessage.content;
      String? rawContext;

      // Extract ACTION: {...} if present
      final actionRegex = RegExp(r'ACTION:\s*({.*})', dotAll: true);
      final match = actionRegex.firstMatch(aiResponseText);
      if (match != null) {
        final jsonStr = match.group(1);
        try {
          final actionObj = jsonDecode(jsonStr!);
          if (actionObj['type'] == 'GENERATE_ROADMAP') {
            rawContext = actionObj['data']['raw_context'];
          }
        } catch (e) {
          debugPrint('Failed to parse ACTION JSON: $e');
        }
        // Remove ACTION from displayed text
        aiResponseText = aiResponseText.replaceAll(match.group(0)!, '').trim();
      }

      if (aiResponseText.isNotEmpty) {
        _addBotMessage(aiResponseText);
      }

      if (rawContext != null) {
        _addBotMessage("Hoàn hảo! Dữ liệu đã được nạp. Đang kích hoạt Lõi AI để tạo Ngân Hà mới cho bạn...");
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          context.read<HomeBloc>().add(
            GenerateRoadmapEvent(
              customPrompt: rawContext,
            )
          );
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      _addBotMessage("Rất tiếc, đường truyền không gian gặp sự cố: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Deep space color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.macaw.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.macaw),
                const SizedBox(width: 8),
                const Text(
                  'AI Commander',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Navigator.of(context).pop(),
                )
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg.text, msg.isUser);
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(color: AppColors.macaw),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập câu trả lời...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _handleSubmitted(_textController.text),
                  icon: const Icon(Icons.send, color: AppColors.macaw),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.macaw.withOpacity(0.2),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppColors.macaw.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUser ? AppColors.macaw.withOpacity(0.5) : Colors.white12,
          )
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
