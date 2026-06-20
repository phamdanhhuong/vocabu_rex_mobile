import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class MiniGameNode extends StatelessWidget {
  final VoidCallback onTap;

  const MiniGameNode({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Pulse(
      infinite: true,
      duration: const Duration(seconds: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.macaw,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.macaw.withValues(alpha: 0.5),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 4),
              ),
              // Inner border shadow simulation
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 0,
                spreadRadius: -4,
                offset: const Offset(0, -6),
              ),
            ],
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.5),
              width: 3,
            ),
          ),
          child: const Center(
            child: Icon(
              Icons.card_giftcard_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
