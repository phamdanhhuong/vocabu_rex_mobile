import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class AutoScrollDialog extends StatefulWidget {
  final String title;
  final String content;

  const AutoScrollDialog({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  State<AutoScrollDialog> createState() => _AutoScrollDialogState();
}

class _AutoScrollDialogState extends State<AutoScrollDialog> with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    
    // Calculate a rough duration based on content length. 
    // Approx 250 characters per second so it's readable but moves.
    final durationSeconds = (widget.content.length / 30).clamp(15, 120).toInt();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: durationSeconds),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (_scrollController.hasClients) {
      // Small delay before starting
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted && _scrollController.hasClients) {
          _animationController.forward();
          _animationController.addListener(() {
            if (_scrollController.hasClients) {
              final maxScroll = _scrollController.position.maxScrollExtent;
              _scrollController.jumpTo(_animationController.value * maxScroll);
            }
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final bgColor = isDark ? const Color(0xFF1A1A2E) : Colors.black87;
    final textColor = Colors.white;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.macaw, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.macaw.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 2,
            )
          ],
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white24, width: 1)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      widget.title.toUpperCase(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.macaw,
                        letterSpacing: 2.0,
                        fontFamily: 'DuolingoFeather',
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            
            // Scrolling Content
            Expanded(
              child: GestureDetector(
                onPanDown: (_) => _animationController.stop(), // Pause on touch
                onPanCancel: () => _animationController.forward(), // Resume on release
                onPanEnd: (_) => _animationController.forward(),
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black,
                        Colors.black,
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.1, 0.9, 1.0],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          // Top padding so text starts from bottom
                          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                          
                          Text(
                            widget.content,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16.sp,
                              height: 1.8,
                              color: textColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          
                          // Bottom padding so text scrolls completely off
                          SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Skip Button
            Padding(
              padding: EdgeInsets.all(16.h),
              child: TextButton(
                onPressed: () {
                  _animationController.stop();
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                    );
                  }
                },
                child: Text(
                  'TUA NHANH',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
