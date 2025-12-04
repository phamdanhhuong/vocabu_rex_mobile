import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'pronunciation_tokens.dart';

/// Reusable pronunciation tile with Duolingo-like press animation (translate down + hide shadow)
class PronunciationTile extends StatefulWidget {
  final String symbol;
  final String example;
  final double width;
  final double progress;
  final VoidCallback? onPressed;

  const PronunciationTile({
    Key? key,
    required this.symbol,
    required this.example,
    required this.width,
    required this.progress,
    this.onPressed,
  }) : super(key: key);

  @override
  State<PronunciationTile> createState() => _PronunciationTileState();
}

class _PronunciationTileState extends State<PronunciationTile> {
  bool _pressed = false;
  static const Duration _pressDuration = Duration(milliseconds: 90);

  double get _tileWidth => widget.width;
  double get _tileHeight => (_tileWidth * kPronunciationTileAspect).clamp(
    kPronunciationTileMinHeight,
    kPronunciationTileMaxHeight,
  );

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
        transform: Matrix4.translationValues(
          0,
          _pressed ? kPronunciationTileTranslateY : 0.0,
          0,
        ),
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
                    borderRadius: BorderRadius.circular(
                      kPronunciationTileBorderRadius,
                    ),
                    border: Border.all(color: AppColors.swan, width: 2.0),
                    boxShadow: _pressed
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.hare,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                              blurRadius: 0,
                            ),
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
                    borderRadius: BorderRadius.circular(
                      kPronunciationTileBorderRadius,
                    ),
                    onTap: widget.onPressed,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(
                          kPronunciationTilePadding,
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculate responsive font sizes based on available height
                            final availableHeight = constraints.maxHeight;
                            final symbolFontSize = (availableHeight * 0.25)
                                .clamp(12.0, kPronunciationSymbolFontSize);
                            final exampleFontSize = (availableHeight * 0.18)
                                .clamp(10.0, kPronunciationExampleFontSize);

                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    widget.symbol,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: AppColors.bodyText,
                                      fontSize: symbolFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: availableHeight * 0.05),
                                Flexible(
                                  child: Text(
                                    widget.example,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: TextStyle(
                                      color: AppColors.wolf,
                                      fontSize: exampleFontSize,
                                    ),
                                  ),
                                ),
                                SizedBox(height: availableHeight * 0.08),
                                // short progress bar
                                Builder(
                                  builder: (c) {
                                    final progress = widget.progress;
                                    return SizedBox(
                                      width:
                                          _tileWidth *
                                          kPronunciationProgressWidthFactor,
                                      height: kPronunciationProgressHeight,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: LinearProgressIndicator(
                                          value: progress,
                                          backgroundColor: AppColors.swan,
                                          valueColor:
                                              const AlwaysStoppedAnimation<
                                                Color
                                              >(AppColors.fox),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            );
                          },
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
