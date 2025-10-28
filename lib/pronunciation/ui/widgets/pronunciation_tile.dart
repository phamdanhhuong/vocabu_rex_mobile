import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vocabu_rex_mobile/theme/colors.dart';

/// Reusable pronunciation tile with Duolingo-like press animation (translate down + hide shadow)
class PronunciationTile extends StatefulWidget {
  final String symbol;
  final String example;
  final double width;
  final VoidCallback? onPressed;

  const PronunciationTile({
    Key? key,
    required this.symbol,
    required this.example,
    required this.width,
    this.onPressed,
  }) : super(key: key);

  @override
  State<PronunciationTile> createState() => _PronunciationTileState();
}

class _PronunciationTileState extends State<PronunciationTile> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  double get _tileWidth => widget.width;
  double get _tileHeight => (_tileWidth * 0.6).clamp(72.0, 120.0);

  void _setPressed(bool v) {
    if (_pressed == v) return;
    setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: _pressDuration,
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(0, _pressed ? 3.0 : 0.0, 0),
        child: SizedBox(
          width: _tileWidth,
          height: _tileHeight,
          child: Stack(
            children: [
              // background with shadow and border
              Positioned.fill(
                child: AnimatedContainer(
                  duration: _pressDuration,
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.all(0),
                  decoration: BoxDecoration(
                    color: AppColors.snow,
                    borderRadius: BorderRadius.circular(16.0),
                    border: Border.all(color: AppColors.swan, width: 2.0),
                    boxShadow: _pressed
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.hare,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                              blurRadius: 0,
                            )
                          ],
                  ),
                ),
              ),

              // Material + InkWell for ripple and content — fill the tile so internal
              // elements are centered properly instead of being top-left.
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16.0),
                    onTap: widget.onPressed,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.symbol,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.bodyText,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.example,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.wolf,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // short progress bar
                            Builder(builder: (c) {
                              final progress = min(1.0, widget.example.length / 8.0);
                              return SizedBox(
                                width: _tileWidth * 0.5,
                                height: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    backgroundColor: AppColors.swan,
                                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.fox),
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
