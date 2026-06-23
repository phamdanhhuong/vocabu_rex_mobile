import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

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
  
  int _step = 0;
  String _targetLanguage = 'English';
  String _proficiencyLevel = 'BEGINNER';
  List<String> _learningGoals = ['CONNECT'];
  int _dailyGoalMinutes = 15;

  @override
  void initState() {
    super.initState();
    _addBotMessage("Xin chào Chỉ huy! Tôi là VocabuRex AI. Bạn muốn tôi kiến tạo một Lộ trình ngôn ngữ mới nào? (Ví dụ: Tiếng Anh, Tiếng Nhật...)");
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

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    _addUserMessage(text);

    // Xử lý luồng trò chuyện dựa trên Step
    Future.delayed(const Duration(milliseconds: 500), () {
      final input = text.toLowerCase();
      
      if (_step == 0) {
        _targetLanguage = text;
        _addBotMessage("Tuyệt vời! Ngôn ngữ mục tiêu là $_targetLanguage. Bạn tự đánh giá trình độ hiện tại của mình như thế nào? (Mới bắt đầu, Trung bình, Khá...)");
        _step++;
      } else if (_step == 1) {
        if (input.contains('khá') || input.contains('tốt') || input.contains('advanced')) {
          _proficiencyLevel = 'ADVANCED';
        } else if (input.contains('trung bình') || input.contains('intermediate')) {
          _proficiencyLevel = 'INTERMEDIATE';
        } else {
          _proficiencyLevel = 'BEGINNER';
        }
        _addBotMessage("Đã lưu dữ liệu trình độ. Mục tiêu lớn nhất của bạn là gì? (Du lịch, Công việc, Giao tiếp...)");
        _step++;
      } else if (_step == 2) {
        if (input.contains('công việc') || input.contains('làm') || input.contains('career')) {
          _learningGoals = ['CAREER'];
        } else if (input.contains('du lịch') || input.contains('travel')) {
          _learningGoals = ['TRAVEL'];
        } else if (input.contains('học') || input.contains('thi') || input.contains('study')) {
          _learningGoals = ['STUDY'];
        } else {
          _learningGoals = ['CONNECT'];
        }
        _addBotMessage("Mục tiêu rất rõ ràng! Cuối cùng, mỗi ngày bạn có thể dành ra bao nhiêu phút cho việc luyện tập?");
        _step++;
      } else if (_step == 3) {
        final RegExp regex = RegExp(r'\d+');
        final match = regex.firstMatch(input);
        if (match != null) {
          _dailyGoalMinutes = int.parse(match.group(0)!);
        }
        
        _addBotMessage("Hoàn hảo! Dữ liệu đã được nạp. Đang kích hoạt Lõi AI để tạo Ngân Hà mới cho bạn...");
        // Cập nhật trạng thái
        _step++;
        setState(() {}); // Buộc rebuild để hiện suggestions mới
        
        // Gọi Event tạo lộ trình sau 1.5s
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          context.read<HomeBloc>().add(
            GenerateRoadmapEvent(
              targetLanguage: _targetLanguage,
              proficiencyLevel: _proficiencyLevel,
              learningGoals: _learningGoals,
              dailyGoalMinutes: _dailyGoalMinutes,
            )
          );
          Navigator.of(context).pop(); // Đóng Bottom Sheet
        });
      }
    });
  }

  List<String> get _currentSuggestions {
    switch (_step) {
      case 0: return ['Tiếng Anh', 'Tiếng Tây Ban Nha', 'Tiếng Pháp', 'Tiếng Nhật', 'Tiếng Hàn', 'Tiếng Trung'];
      case 1: return ['Mới bắt đầu', 'Trình độ trung bình', 'Khá giỏi'];
      case 2: return ['Để đi du lịch', 'Phục vụ công việc', 'Học thuật và thi cử', 'Giao tiếp cơ bản'];
      case 3: return ['5 phút', '15 phút', '30 phút', '60 phút'];
      default: return [];
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
                return Align(
                  alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: msg.isUser ? AppColors.macaw.withOpacity(0.2) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: msg.isUser ? AppColors.macaw.withOpacity(0.5) : Colors.white12,
                      )
                    ),
                    child: Text(
                      msg.text,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_currentSuggestions.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _currentSuggestions.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final suggestion = _currentSuggestions[index];
                  return ActionChip(
                    label: Text(suggestion, style: const TextStyle(color: Colors.white, fontSize: 13)),
                    backgroundColor: AppColors.macaw.withOpacity(0.2),
                    side: BorderSide(color: AppColors.macaw.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    onPressed: () {
                      _textController.text = suggestion;
                      _handleSubmitted(suggestion);
                    },
                  );
                },
              ),
            ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Nhập câu trả lời...',
                      hintStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: _handleSubmitted,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppColors.macaw,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () => _handleSubmitted(_textController.text),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
