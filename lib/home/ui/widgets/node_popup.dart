import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'node_types.dart';

class NodePopup extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final bool isLocked;
  final Color backgroundColor;
  final Color borderColor;
  final Color buttonTextColor;
  final Color? shadowColor;
  final VoidCallback onPressed;
  final NodeStatus? status; // optional, only used for styling variations

  const NodePopup({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.isLocked,
    required this.backgroundColor,
    required this.borderColor,
    required this.buttonTextColor,
    required this.onPressed,
    this.shadowColor,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                AppButton(
                  child: Text(
                    buttonText,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: buttonTextColor),
                  ),
                  onPressed: () {
                    onPressed();
                  },
                  size: ButtonSize.medium,
                  width: double.infinity,
                  variant: status == NodeStatus.legendary
                      ? ButtonVariant.highlight
                      : (isLocked ? ButtonVariant.ghost : ButtonVariant.overlayWhite),
                  backgroundColor: status == NodeStatus.legendary ? AppColors.legendaryButtonBg : AppColors.snow,
                  shadowColor: status == NodeStatus.legendary ? AppColors.legendaryButtonShadow : (isLocked ? null : shadowColor ?? AppColors.swan),
                  shadowOpacity: 1.0,
                  isDisabled: isLocked,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
