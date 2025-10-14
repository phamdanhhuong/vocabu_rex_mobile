import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/assistant/ui/widgets/chat_input.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;

    // Xử lý gửi tin nhắn ở đây
    print('Tin nhắn đã gửi: $text');

    // Sau khi gửi, xóa nội dung và đặt lại trạng thái
    _controller.clear();
    setState(() {
      _isComposing = false;
    });
    _focusNode.requestFocus(); // Giữ focus sau khi gửi
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ChatInputBar(
            controller: _controller,
            focusNode: _focusNode,
            onSubmitted: _handleSubmitted,
            onChanged: (text) {
              setState(() {
                _isComposing = text.trim().isNotEmpty;
              });
            },
            isComposing: _isComposing,
          ),
        ],
      ),
    );
  }
}
