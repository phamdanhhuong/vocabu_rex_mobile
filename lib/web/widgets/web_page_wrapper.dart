import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:vocabu_rex_mobile/theme/colors.dart';

class WebPageWrapper extends StatelessWidget {
  final Widget mobileScaffold;

  const WebPageWrapper({super.key, required this.mobileScaffold});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = kIsWeb && constraints.maxWidth >= 768;

        if (isWide) {
          return Scaffold(
            backgroundColor: AppColors.polar, // Clean context for desktop card
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 700),
                  margin: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 12),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: mobileScaffold,
                  ),
                ),
              ),
            ),
          );
        }

        return mobileScaffold;
      },
    );
  }
}
