import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Wrapper widget để constrain fullscreen dialog/pages vào vùng trung tâm trên web.
///
/// Trên web wide screen (≥768px): Hiển thị content trong card bo góc ở giữa màn hình
/// Trên mobile/web narrow: Giữ nguyên behavior fullscreen
class CenteredDialogWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const CenteredDialogWrapper({
    super.key,
    required this.child,
    this.maxWidth = 700,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideWeb = kIsWeb && constraints.maxWidth >= 768;

        if (isWideWeb) {
          return Scaffold(
            backgroundColor:
                backgroundColor ?? AppColors.polar.withOpacity(0.95),
            body: SafeArea(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  margin: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: child,
                  ),
                ),
              ),
            ),
          );
        }

        // Mobile hoặc web narrow: giữ nguyên fullscreen
        return child;
      },
    );
  }
}
