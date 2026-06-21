import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:animate_do/animate_do.dart';

/// Audio speaker buttons - normal and slow speed with custom 3D styling and Waveform
class AudioSpeakerButtons extends StatefulWidget {
  final bool isPlayingNormal;
  final bool isPlayingSlow;
  final VoidCallback onPlayNormal;
  final VoidCallback onPlaySlow;

  const AudioSpeakerButtons({
    super.key,
    required this.isPlayingNormal,
    required this.isPlayingSlow,
    required this.onPlayNormal,
    required this.onPlaySlow,
  });

  @override
  State<AudioSpeakerButtons> createState() => _AudioSpeakerButtonsState();
}

class _AudioSpeakerButtonsState extends State<AudioSpeakerButtons> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Waveform Visualizer
        SizedBox(
          height: 40.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(15, (index) {
              final isPlaying = widget.isPlayingNormal || widget.isPlayingSlow;
              return _WaveBar(
                isPlaying: isPlaying,
                index: index,
              );
            }),
          ),
        ),
        SizedBox(height: 24.h),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Normal speed button
            _NeumorphicSpeakerButton(
              icon: Icons.volume_up_rounded,
              isPlaying: widget.isPlayingNormal,
              onPressed: widget.onPlayNormal,
              size: 80.w,
              color: AppColors.primary,
              shadowColor: AppColors.correctGreenDark, // Fixed shadow color
            ),
            
            SizedBox(width: 24.w),

            // Slow speed button (Turtle)
            _NeumorphicSpeakerButton(
              icon: Icons.pets_rounded, // Turtle icon approximation
              isPlaying: widget.isPlayingSlow,
              onPressed: widget.onPlaySlow,
              size: 64.w,
              color: AppColors.macaw,
              shadowColor: const Color(0xFF1175A4), // Fixed shadow color
            ),
          ],
        ),
      ],
    );
  }
}

class _WaveBar extends StatefulWidget {
  final bool isPlaying;
  final int index;

  const _WaveBar({required this.isPlaying, required this.index});

  @override
  State<_WaveBar> createState() => _WaveBarState();
}

class _WaveBarState extends State<_WaveBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + (widget.index * 50)),
    );
    final heights = [10.h, 24.h, 16.h, 32.h, 20.h, 40.h, 18.h, 36.h, 22.h, 30.h, 14.h, 26.h, 12.h, 28.h, 10.h];
    final targetHeight = heights[widget.index % heights.length];
    
    _animation = Tween<double>(begin: 4.h, end: targetHeight).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    if (widget.isPlaying) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_WaveBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _controller.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _controller.animateTo(0, duration: const Duration(milliseconds: 300));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 6.w,
          height: _animation.value,
          margin: EdgeInsets.symmetric(horizontal: 2.w),
          decoration: BoxDecoration(
            color: widget.isPlaying ? AppColors.primary : AppColors.hare,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      },
    );
  }
}

class _NeumorphicSpeakerButton extends StatefulWidget {
  final IconData icon;
  final bool isPlaying;
  final VoidCallback onPressed;
  final double size;
  final Color color;
  final Color shadowColor;

  const _NeumorphicSpeakerButton({
    required this.icon,
    required this.isPlaying,
    required this.onPressed,
    required this.size,
    required this.color,
    required this.shadowColor,
  });

  @override
  State<_NeumorphicSpeakerButton> createState() => _NeumorphicSpeakerButtonState();
}

class _NeumorphicSpeakerButtonState extends State<_NeumorphicSpeakerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool effectivePressed = _isPressed || widget.isPlaying;
    
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: widget.size,
        height: widget.size,
        margin: EdgeInsets.only(top: effectivePressed ? 6.h : 0, bottom: effectivePressed ? 0 : 6.h),
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.size * 0.25),
          boxShadow: effectivePressed ? [] : [
            BoxShadow(
              color: widget.shadowColor,
              offset: const Offset(0, 6),
              blurRadius: 0,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Icon(
          widget.icon,
          size: widget.size * 0.45,
          color: Colors.white,
        ),
      ),
    );
  }
}
