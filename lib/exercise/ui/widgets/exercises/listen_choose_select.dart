import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_choice_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';

/// Select mode for ListenChoose - with flying animations like multiple_choice_complex
class ListenChooseSelectMode extends StatefulWidget {
  final ListenChooseMetaEntity meta;
  final bool isSubmitted;
  final bool revealed;
  final bool? isCorrect;
  final List<String> selectedWords;
  final List<String> availableWords;
  final Function(String) onSelectWord;
  final Function(int) onUnselectWord;

  const ListenChooseSelectMode({
    Key? key,
    required this.meta,
    required this.isSubmitted,
    required this.revealed,
    required this.isCorrect,
    required this.selectedWords,
    required this.availableWords,
    required this.onSelectWord,
    required this.onUnselectWord,
  }) : super(key: key);

  @override
  State<ListenChooseSelectMode> createState() => _ListenChooseSelectModeState();
}

class _ListenChooseSelectModeState extends State<ListenChooseSelectMode>
    with TickerProviderStateMixin {
  
  final Map<String, GlobalKey> _availablePlaceholderKeys = {};
  final Map<int, GlobalKey> _selectedSlotKeys = {};
  final Set<String> _animating = {};
  final Duration _flyDuration = const Duration(milliseconds: 400);

  @override
  void initState() {
    super.initState();
    // Initialize keys for placeholders
    for (var word in widget.availableWords) {
      _availablePlaceholderKeys[word] = GlobalKey();
    }
  }

  @override
  void didUpdateWidget(covariant ListenChooseSelectMode oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep available placeholder keys in sync when availableWords change
    for (var word in widget.availableWords) {
      _availablePlaceholderKeys.putIfAbsent(word, () => GlobalKey());
    }
    // Remove keys for words no longer present
    final toRemove = _availablePlaceholderKeys.keys
        .where((k) => !widget.availableWords.contains(k))
        .toList();
    for (var k in toRemove) {
      _availablePlaceholderKeys.remove(k);
    }
  }

  Future<void> _handleSelectWithAnimation(String word) async {
    if (_animating.contains(word) || widget.isSubmitted || widget.revealed) return;
    // Ensure we have a slot key for the upcoming selected index so the
    // animation target exists in the render tree.
    final targetIndex = widget.selectedWords.length;
    _selectedSlotKeys.putIfAbsent(targetIndex, () => GlobalKey());

    setState(() {
      // mark animating so source placeholder becomes invisible
      _animating.add(word);
    });

    // Wait for one frame so the new slot key's RenderObject is created.
    final completer = Completer<void>();
    WidgetsBinding.instance.addPostFrameCallback((_) => completer.complete());
    await completer.future;

    await _animateTileMove(word, toSelected: true);

    widget.onSelectWord(word);

    setState(() {
      _animating.remove(word);
      // clean up any empty phantom slots that aren't needed
      _selectedSlotKeys.removeWhere((k, v) => k >= widget.selectedWords.length);
    });
  }

  Future<void> _handleUnselectWithAnimation(int index) async {
    final word = widget.selectedWords[index];
    if (_animating.contains(word) || widget.isSubmitted || widget.revealed) return;
    
    setState(() {
      _animating.add(word);
    });
    
    await _animateTileMove(word, toSelected: false, fromSelectedIndex: index);
    
    widget.onUnselectWord(index);
    
    setState(() {
      _animating.remove(word);
    });
  }

  Future<void> _animateTileMove(
    String word, {
    required bool toSelected,
    int? fromSelectedIndex,
  }) async {
    final overlay = Overlay.of(context);
    
    GlobalKey? startKey;
    GlobalKey? endKey;
    
    if (toSelected) {
      startKey = _availablePlaceholderKeys[word];
      endKey = _selectedSlotKeys[widget.selectedWords.length];
    } else {
      startKey = _selectedSlotKeys[fromSelectedIndex ?? 0];
      endKey = _availablePlaceholderKeys[word];
    }
    
    if (startKey?.currentContext == null || endKey?.currentContext == null) {
      return;
    }
    
    final startBox = startKey!.currentContext!.findRenderObject() as RenderBox;
    final endBox = endKey!.currentContext!.findRenderObject() as RenderBox;
    final startPos = startBox.localToGlobal(Offset.zero);
    final endPos = endBox.localToGlobal(Offset.zero);
    final tileSize = startBox.size;
    
    final controller = AnimationController(vsync: this, duration: _flyDuration);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);
    
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final t = curved.value;
      // Add a little lift curve when flying to selected (fly up)
      final basePos = Offset.lerp(startPos, endPos, t)!;
      final lift = toSelected
        ? -20.0 * (4 * t * (1 - t)) // simple hump (0 at ends, peak mid)
        : 0.0;
      final currentPos = basePos + Offset(0, lift);
            
            return Positioned(
              left: currentPos.dx,
              top: currentPos.dy,
              width: tileSize.width,
              height: tileSize.height,
              child: Material(
                color: Colors.transparent,
                child: ChoiceTile(
                  text: word,
                  state: ChoiceTileState.defaults,
                  onPressed: () {},
                ),
              ),
            );
          },
        );
      },
    );
    
    overlay.insert(entry);
    await controller.forward();
    entry.remove();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Selected words area
        Container(
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!, width: 2),
            ),
          ),
          constraints: BoxConstraints(minHeight: 60.h),
            child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (widget.selectedWords.isEmpty)
                Text(
                  'Chọn từ bên dưới...',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14.sp),
                )
              else ...widget.selectedWords.asMap().entries.map((entry) {
                final index = entry.key;
                final word = entry.value;
                final correctWords = widget.meta.correctAnswer.split(' ');
                final isAnimating = _animating.contains(word);

                ChoiceTileState tileState = ChoiceTileState.defaults;
                if (widget.isCorrect != null) {
                  if (index < correctWords.length && word == correctWords[index]) {
                    tileState = ChoiceTileState.correct;
                  } else {
                    tileState = ChoiceTileState.incorrect;
                  }
                }

                return KeyedSubtree(
                  key: _selectedSlotKeys.putIfAbsent(index, () => GlobalKey()),
                  child: Opacity(
                    opacity: isAnimating ? 0.0 : 1.0,
                    child: ChoiceTile(
                      text: word,
                      state: tileState,
                      onPressed: widget.isSubmitted || widget.revealed
                          ? () {}
                          : () => _handleUnselectWithAnimation(index),
                    ),
                  ),
                );
              }).toList(),
              // Render phantom slots for any keys we've created for upcoming indices
              ..._selectedSlotKeys.entries
                  .where((e) => e.key >= widget.selectedWords.length)
                  .map((e) => KeyedSubtree(
                        key: e.value,
                        child: Opacity(
                          opacity: 0.0,
                          child: ChoiceTile(
                            text: '',
                            state: ChoiceTileState.defaults,
                            onPressed: () {},
                          ),
                        ),
                      ))
                  .toList(),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),
        
        // Available words with fixed placeholders
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: widget.availableWords.map((word) {
                final isSelected = widget.selectedWords.contains(word);
                final isAnimating = _animating.contains(word);
                
                return KeyedSubtree(
                  key: _availablePlaceholderKeys[word]!,
                  child: Opacity(
                    opacity: (isSelected || isAnimating || widget.revealed) ? 0.0 : 1.0,
                    child: ChoiceTile(
                      text: word,
                      state: ChoiceTileState.defaults,
                      onPressed: (widget.isSubmitted || widget.revealed || isSelected)
                          ? () {}
                          : () => _handleSelectWithAnimation(word),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
