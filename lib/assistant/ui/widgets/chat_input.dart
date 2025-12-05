import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class ChatInputBar extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSubmitted;
  final Function(String) onChanged;
  final bool isComposing;
  final String? selectedRole;
  final Function(String)? onRoleChanged;

  const ChatInputBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
    required this.onChanged,
    required this.isComposing,
    this.selectedRole,
    this.onRoleChanged,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final Map<String, String> _roleLabels = {
    'vocabulary_expert': 'Vocabulary Expert',
    'grammar_tutor': 'Grammar Tutor',
    'speaking_partner': 'Speaking Partner',
    'corrector_assistant': 'Corrector',
  };

  final Map<String, IconData> _roleIcons = {
    'vocabulary_expert': Icons.book,
    'grammar_tutor': Icons.school,
    'speaking_partner': Icons.chat_bubble_outline,
    'corrector_assistant': Icons.edit,
  };

  @override
  Widget build(BuildContext context) {
    final currentRole = widget.selectedRole ?? 'vocabulary_expert';
    
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8, top: 12, bottom: 20),
      decoration: BoxDecoration(
        color: AppColors.snow,
        border: Border(
          top: BorderSide(color: AppColors.swan, width: 1),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.snow,
          borderRadius: BorderRadius.circular(25.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.macaw.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(color: AppColors.swan, width: 1.5),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            // Role Selector Button
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8),
              child: PopupMenuButton<String>(
                onSelected: (String role) {
                  widget.onRoleChanged?.call(role);
                },
                itemBuilder: (BuildContext context) {
                  return _roleLabels.entries.map((entry) {
                    return PopupMenuItem<String>(
                      value: entry.key,
                      child: Row(
                        children: [
                          Icon(
                            _roleIcons[entry.key],
                            size: 20,
                            color: currentRole == entry.key 
                                ? AppColors.macaw 
                                : AppColors.wolf,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            entry.value,
                            style: TextStyle(
                              color: currentRole == entry.key 
                                  ? AppColors.macaw 
                                  : AppColors.eel,
                              fontWeight: currentRole == entry.key
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          if (currentRole == entry.key) ...[
                            const Spacer(),
                            Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.macaw,
                            ),
                          ],
                        ],
                      ),
                    );
                  }).toList();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.macaw.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.macaw.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _roleIcons[currentRole],
                        size: 16,
                        color: AppColors.macaw,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _roleLabels[currentRole]!.split(' ')[0], // First word only
                        style: TextStyle(
                          color: AppColors.macaw,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: AppColors.macaw,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // TextField
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 10, left: 4),
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: widget.onSubmitted,
                  minLines: 1,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.send,
                  decoration: InputDecoration(
                    hintText: 'Ask anything...',
                    hintStyle: TextStyle(color: AppColors.hare, fontSize: 15),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: AppColors.eel,
                  ),
                ),
              ),
            ),

            // Send Button
            Padding(
              padding: const EdgeInsets.only(right: 6, bottom: 6, left: 6),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: widget.isComposing
                    ? AppColors.featherGreen
                    : AppColors.swan,
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: widget.isComposing ? AppColors.snow : AppColors.hare,
                    size: 20,
                  ),
                  onPressed: widget.isComposing
                      ? () => widget.onSubmitted(widget.controller.text)
                      : null,
                  padding: EdgeInsets.zero,
                  splashRadius: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}