import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';

/// Select mode for ListenChoose - fast tactile 3D mechanism
class ListenChooseSelectMode extends StatelessWidget {
  final ListenChooseMetaEntity meta;
  final bool isSubmitted;
  final bool revealed;
  final bool? isCorrect;
  final List<String> selectedWords;
  final List<String> availableWords;
  final Function(String) onSelectWord;
  final Function(int) onUnselectWord;

  const ListenChooseSelectMode({
    super.key,
    required this.meta,
    required this.isSubmitted,
    required this.revealed,
    required this.isCorrect,
    required this.selectedWords,
    required this.availableWords,
    required this.onSelectWord,
    required this.onUnselectWord,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    
    // Build the list of available words keeping their original positions,
    // but hide the ones that are already selected.
    // Wait, availableWords might contain duplicates.
    // To handle duplicates properly, we count occurrences.
    // A simpler way: we just track the index of the selected word from availableWords.
    // But currently the API is onSelectWord(String), so it just passes the string.
    // We'll count frequencies to determine if a word should be hidden in available pool.

    Map<String, int> selectedCounts = {};
    for (var w in selectedWords) {
      selectedCounts[w] = (selectedCounts[w] ?? 0) + 1;
    }

    Map<String, int> drawnCounts = {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Answer Slot Area
        Container(
          constraints: BoxConstraints(minHeight: 120.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: isDark ? AppColors.swan : AppColors.snow,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isCorrect == null
                  ? AppColors.hare.withValues(alpha: 0.5)
                  : (isCorrect! ? AppColors.featherGreen : AppColors.cardinal),
              width: isCorrect == null ? 1 : 2,
            ),
          ),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: List.generate(selectedWords.length, (index) {
              final word = selectedWords[index];
              return ZoomIn(
                duration: const Duration(milliseconds: 200),
                child: _NeumorphicWordTile(
                  word: word,
                  isCorrect: isCorrect,
                  onTap: () {
                    if (!isSubmitted && !revealed) {
                      HapticFeedback.lightImpact();
                      onUnselectWord(index);
                    }
                  },
                ),
              );
            }),
          ),
        ),

        SizedBox(height: 24.h),

        // Word Bank Area
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: 8.w,
              runSpacing: 12.h,
              alignment: WrapAlignment.center,
              children: availableWords.asMap().entries.map((entry) {
                int index = entry.key;
                String word = entry.value;

                int drawn = drawnCounts[word] ?? 0;
                drawnCounts[word] = drawn + 1;
                
                int selected = selectedCounts[word] ?? 0;
                bool isUsed = drawn < selected;

                return FadeInUp(
                  duration: const Duration(milliseconds: 400),
                  delay: Duration(milliseconds: 100 * index),
                  child: _NeumorphicWordTile(
                    word: word,
                    isPlaceholder: isUsed,
                    onTap: () {
                      if (!isUsed && !isSubmitted && !revealed) {
                        HapticFeedback.lightImpact();
                        onSelectWord(word);
                      }
                    },
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

class _NeumorphicWordTile extends StatefulWidget {
  final String word;
  final bool isPlaceholder;
  final bool? isCorrect;
  final VoidCallback onTap;

  const _NeumorphicWordTile({
    required this.word,
    this.isPlaceholder = false,
    this.isCorrect,
    required this.onTap,
  });

  @override
  State<_NeumorphicWordTile> createState() => _NeumorphicWordTileState();
}

class _NeumorphicWordTileState extends State<_NeumorphicWordTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.isPlaceholder) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: AppColors.hare.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          widget.word,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.transparent,
          ),
        ),
      );
    }

    final isDark = AppPreferences().isDarkMode;
    
    Color bgColor = isDark ? AppColors.swan : AppColors.snow;
    Color textColor = AppColors.eel;
    Color shadowColor = isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.hare.withValues(alpha: 0.3);

    if (widget.isCorrect != null) {
      bgColor = widget.isCorrect! ? AppColors.featherGreen : AppColors.cardinal;
      textColor = Colors.white;
      shadowColor = widget.isCorrect! 
          ? AppColors.maskGreen.withValues(alpha: 0.5) 
          : Colors.red[900]!.withValues(alpha: 0.5);
    }

    final effectivePressed = _isPressed || widget.isCorrect != null;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 50),
        margin: EdgeInsets.only(top: effectivePressed ? 4.h : 0, bottom: effectivePressed ? 0 : 4.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: widget.isCorrect != null ? Colors.transparent : AppColors.hare.withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: effectivePressed ? [] : [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              blurRadius: 0,
            )
          ],
        ),
        child: Text(
          widget.word,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
