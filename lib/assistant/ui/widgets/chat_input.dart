import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final bool isComposing;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onChanged,
    required this.isComposing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Padding xung quanh thanh nhập liệu
      padding: const EdgeInsets.only(left: 16, right: 8, top: 8, bottom: 20),
      decoration: const BoxDecoration(color: AppColors.polar),
      child: Container(
        // Container chính cho TextField, tạo hiệu ứng bo tròn và bóng đổ
        decoration: BoxDecoration(
          color: AppColors.polar,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3), // Bóng đổ nhẹ
            ),
          ],
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // --- TextField ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, top: 4, bottom: 4),
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: onChanged,
                  onSubmitted: onSubmitted,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border:
                        InputBorder.none, // Quan trọng: Loại bỏ border mặc định
                    contentPadding:
                        EdgeInsets.zero, // Điều chỉnh padding nội dung
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),

            // --- Nút Gửi (Send Button) ---
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: isComposing
                    ? const Color(0xFF10A37F) // Màu xanh lá khi có text
                    : const Color(0xFFE0E0E0), // Màu xám khi không có text
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: isComposing
                      ? () => onSubmitted(controller.text)
                      : null, // Vô hiệu hóa khi không có text
                  padding: EdgeInsets.zero,
                  splashRadius: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
