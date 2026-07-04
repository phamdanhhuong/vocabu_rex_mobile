import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/domain/usecases/start_chat_usecase.dart';
import 'package:vocabu_rex_mobile/assistant/ui/widgets/typewriter_text.dart';
import 'dart:convert';

class ChatMessage {
  final String text;
  final bool isUser;
  final List<String>? quickReplies;
  final int? progress;
  final String? step;

  ChatMessage(
    this.text,
    this.isUser, {
    this.quickReplies,
    this.progress,
    this.step,
  });
}

class AIRoadmapGeneratorPanel extends StatefulWidget {
  const AIRoadmapGeneratorPanel({super.key});

  @override
  State<AIRoadmapGeneratorPanel> createState() => _AIRoadmapGeneratorPanelState();
}

class _AIRoadmapGeneratorPanelState extends State<AIRoadmapGeneratorPanel>
    with TickerProviderStateMixin {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  bool _isLoading = false;
  String? _conversationId;
  
  // Progress tracking
  double _currentProgress = 0;
  String _currentStep = 'start';
  late AnimationController _progressAnimController;
  late Animation<double> _progressAnimation;

  // Quick reply chip animation
  late AnimationController _chipAnimController;

  // Track which message index has active (clickable) chips
  int? _activeChipMessageIndex;

  static const Map<String, String> _stepLabels = {
    'start': 'Bắt đầu',
    'goal': 'Bước 1/4: Mục tiêu',
    'level': 'Bước 2/4: Trình độ',
    'interests': 'Bước 3/4: Sở thích',
    'confirm': 'Bước 4/4: Xác nhận',
  };

  @override
  void initState() {
    super.initState();

    _progressAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _progressAnimController, curve: Curves.easeInOut),
    );

    _chipAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startConversation();
  }

  @override
  void dispose() {
    _progressAnimController.dispose();
    _chipAnimController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _animateProgressTo(double target) {
    final oldValue = _progressAnimation.value;
    _progressAnimation = Tween<double>(
      begin: oldValue,
      end: target.clamp(0, 100) / 100,
    ).animate(
      CurvedAnimation(parent: _progressAnimController, curve: Curves.easeInOut),
    );
    _progressAnimController.forward(from: 0);
  }

  Future<void> _startConversation() async {
    setState(() => _isLoading = true);
    try {
      final startUseCase = sl<StartChatUsecase>();
      _conversationId = await startUseCase();
      
      // Hardcoded welcome message with initial quick replies (Option A - no extra API call)
      _addBotMessage(
        "Xin chào Chỉ huy! 🚀 Tôi là VocabuRex AI, chuyên tư vấn lộ trình học tiếng Anh. Để tạo lộ trình phù hợp nhất, cho tôi biết bạn muốn học tiếng Anh để làm gì nhé?",
        quickReplies: ["Du lịch", "Công việc/Career", "Xem phim/nhạc", "Thi IELTS/TOEIC", "Giao tiếp"],
        progress: 0,
        step: 'goal',
      );
    } catch (e) {
      _addBotMessage("Lỗi kết nối tới Lõi AI: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addBotMessage(
    String text, {
    List<String>? quickReplies,
    int? progress,
    String? step,
  }) {
    setState(() {
      _messages.add(ChatMessage(
        text,
        false,
        quickReplies: quickReplies,
        progress: progress,
        step: step,
      ));
      _activeChipMessageIndex = _messages.length - 1;
    });

    // Update progress if provided
    if (progress != null) {
      _currentProgress = progress.toDouble();
      _animateProgressTo(_currentProgress);
    }
    if (step != null) {
      _currentStep = step;
    }

    // Animate chips in
    if (quickReplies != null && quickReplies.isNotEmpty) {
      _chipAnimController.forward(from: 0);
    }

    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      // Disable chips from previous bot messages
      _activeChipMessageIndex = null;
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
      List<String>? quickReplies = aiMessage.quickReplies;
      int? progress = aiMessage.progress;
      String? step = aiMessage.step;

      // Fallback: parse METADATA from content if not in structured fields
      if (quickReplies == null && progress == null) {
        final metadataRegex = RegExp(r'METADATA:\s*({.*?})\s*$', dotAll: true, multiLine: true);
        final metaMatch = metadataRegex.firstMatch(aiResponseText);
        if (metaMatch != null) {
          try {
            final meta = jsonDecode(metaMatch.group(1)!);
            quickReplies = (meta['quick_replies'] as List<dynamic>?)?.cast<String>();
            progress = meta['progress'] as int?;
            step = meta['step'] as String?;
          } catch (e) {
            debugPrint('Failed to parse METADATA JSON: $e');
          }
          aiResponseText = aiResponseText.replaceAll(metaMatch.group(0)!, '').trim();
        }
      }

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
        _addBotMessage(
          aiResponseText,
          quickReplies: quickReplies,
          progress: progress,
          step: step,
        );
      }

      if (rawContext != null) {
        _addBotMessage(
          "Hoàn hảo! 🎯 Dữ liệu đã được nạp. Đang kích hoạt Lõi AI để tạo Ngân Hà mới cho bạn...",
        );
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
      height: 550,
      decoration: BoxDecoration(
        color: const Color(0xFF0D1117), // Deep space color
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.macaw.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
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

          // Progress Bar
          _buildProgressBar(),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildMessageItem(msg, index);
              },
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.macaw.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Đang suy nghĩ...',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return AnimatedBuilder(
      animation: _progressAnimController,
      builder: (context, child) {
        final value = _progressAnimation.value;
        final stepLabel = _stepLabels[_currentStep] ?? _currentStep;
        final percent = (value * 100).round();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    stepLabel,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '$percent%',
                    style: TextStyle(
                      color: AppColors.macaw.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(3),
                  color: Colors.white.withOpacity(0.08),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.macaw.withOpacity(0.7),
                          AppColors.macaw,
                          const Color(0xFF6C63FF),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.macaw.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 0),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMessageItem(ChatMessage msg, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Chat bubble
        _buildChatBubble(msg.text, msg.isUser, index == _messages.length - 1),
        // Quick reply chips (only for bot messages with quick replies)
        if (!msg.isUser &&
            msg.quickReplies != null &&
            msg.quickReplies!.isNotEmpty)
          _buildQuickReplyChips(msg.quickReplies!, index),
      ],
    );
  }

  Widget _buildChatBubble(String text, bool isUser, bool isLast) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.macaw.withOpacity(0.2) : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: Border.all(
            color: isUser ? AppColors.macaw.withOpacity(0.5) : Colors.white12,
          )
        ),
        child: TypewriterText(
          text: text,
          animate: !isUser && isLast,
          builder: (context, animatedText) => Text(
            animatedText,
            style: const TextStyle(color: Colors.white, height: 1.4),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplyChips(List<String> replies, int messageIndex) {
    final isActive = _activeChipMessageIndex == messageIndex;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 300),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: replies.map((reply) {
            return _buildChip(reply, isActive);
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isActive) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isActive && !_isLoading ? () => _handleSubmitted(label) : null,
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.macaw.withOpacity(0.3),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? AppColors.macaw.withOpacity(0.7)
                  : Colors.white.withOpacity(0.15),
              width: 1.2,
            ),
            color: isActive
                ? AppColors.macaw.withOpacity(0.1)
                : Colors.transparent,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 14,
                    color: AppColors.macaw.withOpacity(0.8),
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  color: isActive
                      ? Colors.white
                      : Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.06)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Hoặc gõ câu trả lời...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.35)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
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
            onPressed: _isLoading ? null : () => _handleSubmitted(_textController.text),
            icon: const Icon(Icons.send_rounded, color: AppColors.macaw),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.macaw.withOpacity(0.2),
              padding: const EdgeInsets.all(12),
              disabledForegroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
