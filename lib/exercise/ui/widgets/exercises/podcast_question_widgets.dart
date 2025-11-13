import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'dart:async';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_match_tile.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/podcast_question_entity.dart';

/// Base widget for podcast questions
abstract class PodcastQuestionWidget extends StatefulWidget {
  final PodcastQuestionEntity question;
  final Function(bool isCorrect, dynamic answer) onAnswered;

  const PodcastQuestionWidget({
    super.key,
    required this.question,
    required this.onAnswered,
  });
}

/// Match pairs question widget
class PodcastMatchQuestionWidget extends PodcastQuestionWidget {
  const PodcastMatchQuestionWidget({
    super.key,
    required PodcastMatchQuestion question,
    required Function(bool isCorrect, dynamic answer) onAnswered,
  }) : super(question: question, onAnswered: onAnswered);

  @override
  State<PodcastMatchQuestionWidget> createState() =>
      _PodcastMatchQuestionWidgetState();
}

class _PodcastMatchQuestionWidgetState
    extends State<PodcastMatchQuestionWidget> {
  PodcastMatchQuestion get _question => widget.question as PodcastMatchQuestion;
  
  late List<String> _leftItems;
  late List<String> _rightItems;
  String? _selectedLeft;
  String? _selectedRight;
  Set<String> _matchedLeft = {};
  Set<String> _matchedRight = {};
  Set<String> _correctLeft = {};
  Set<String> _correctRight = {};
  Set<String> _incorrectLeft = {};
  Set<String> _incorrectRight = {};
  
  late FlutterTts _tts;
  Timer? _completionTimer;
  Timer? _correctAnimationTimer;
  Timer? _incorrectAnimationTimer;

  @override
  void initState() {
    super.initState();
    
    print('🎯 ========================================');
    print('🎯 MATCH QUESTION INITIALIZED');
    print('🎯 Question: ${_question.question}');
    print('🎯 Number of pairs: ${_question.pairs.length}');
    for (var i = 0; i < _question.pairs.length; i++) {
      print('🎯 Pair ${i + 1}: "${_question.pairs[i].left}" ↔️ "${_question.pairs[i].right}"');
    }
    print('🎯 ========================================');
    
    _leftItems = _question.pairs.map((p) => p.left).toList();
    _rightItems = _question.pairs.map((p) => p.right).toList()..shuffle();
    _tts = FlutterTts();
    _setupTts();
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(1);
    await _tts.setVolume(1.0);
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  void _handleSelection(String item, bool isLeft) {
    print('🎯 User selected: "$item" on ${isLeft ? "LEFT" : "RIGHT"} side');
    
    setState(() {
      if (isLeft) {
        if (_selectedLeft == item) {
          _selectedLeft = null;
          print('🎯 Deselected left item');
        } else {
          _selectedLeft = item;
          print('🎯 Selected left: "$item"');
          _speak(item);
        }
      } else {
        if (_selectedRight == item) {
          _selectedRight = null;
          print('🎯 Deselected right item');
        } else {
          _selectedRight = item;
          print('🎯 Selected right: "$item"');
        }
      }

      if (_selectedLeft != null && _selectedRight != null) {
        print('🎯 Checking match: "$_selectedLeft" ↔️ "$_selectedRight"');
        
        // Check if this is a correct match
        final isCorrectMatch = _question.pairs.any(
          (p) => p.left == _selectedLeft && p.right == _selectedRight,
        );

        print('🎯 Match result: ${isCorrectMatch ? "✅ CORRECT" : "❌ INCORRECT"}');

        final left = _selectedLeft!;
        final right = _selectedRight!;

        if (isCorrectMatch) {
          // Correct - show animation then mark as matched
          _correctLeft.add(left);
          _correctRight.add(right);

          _correctAnimationTimer?.cancel();
          _correctAnimationTimer = Timer(const Duration(milliseconds: 800), () {
            if (mounted) {
              setState(() {
                _correctLeft.remove(left);
                _correctRight.remove(right);
                _matchedLeft.add(left);
                _matchedRight.add(right);
                
                print('🎯 Matched pairs so far: ${_matchedLeft.length}/${_question.pairs.length}');
              });

              // Check if all matched
              if (_matchedLeft.length == _question.pairs.length) {
                print('🎯 ✅ ALL PAIRS MATCHED! Completing question...');
                
                _completionTimer?.cancel();
                _completionTimer = Timer(const Duration(milliseconds: 500), () {
                  if (mounted) {
                    final matchMap = _buildMatchMap();
                    print('🎯 Final match map: $matchMap');
                    widget.onAnswered(true, matchMap);
                  }
                });
              }
            }
          });
        } else {
          // Incorrect - show shake animation
          _incorrectLeft.add(left);
          _incorrectRight.add(right);

          _incorrectAnimationTimer?.cancel();
          _incorrectAnimationTimer = Timer(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _incorrectLeft.remove(left);
                _incorrectRight.remove(right);
              });
            }
          });
        }

        // Reset selection
        _selectedLeft = null;
        _selectedRight = null;
      }
    });
  }

  Map<String, String> _buildMatchMap() {
    final Map<String, String> matches = {};
    for (var pair in _question.pairs) {
      matches[pair.left] = pair.right;
    }
    return matches;
  }

  @override
  void dispose() {
    _completionTimer?.cancel();
    _correctAnimationTimer?.cancel();
    _incorrectAnimationTimer?.cancel();
    _tts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _question.question,
            style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                  color: AppColors.eel,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 20.h),
          LayoutBuilder(
            builder: (context, constraints) {
              final maxRows = max(_leftItems.length, _rightItems.length);
              final availableHeight = 400.h;
              final tileByHeight = maxRows > 0 ? (availableHeight / maxRows) : 100.h;
              final minTileH = 48.h;
              final maxTileH = 120.h;
              final tileHeight = tileByHeight.clamp(minTileH, maxTileH);
              final columnWidth = constraints.maxWidth * 0.42;

              return SizedBox(
                height: availableHeight,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    SizedBox(
                      width: columnWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _leftItems.map((item) {
                            final isMatched = _matchedLeft.contains(item);
                            final isCorrect = _correctLeft.contains(item);
                            final isIncorrect = _incorrectLeft.contains(item);
                            final isSelected = _selectedLeft == item;
                            final state = isMatched
                                ? MatchTileState.disabled
                                : isCorrect
                                    ? MatchTileState.correct
                                    : isIncorrect
                                        ? MatchTileState.incorrect
                                        : isSelected
                                            ? MatchTileState.selected
                                            : MatchTileState.defaults;

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: MatchTile(
                                word: item,
                                state: state,
                                height: tileHeight,
                                showSoundIcon: true,
                                onPressed: (isMatched || isCorrect || isIncorrect)
                                    ? null
                                    : () => _handleSelection(item, true),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // Right column
                    SizedBox(
                      width: columnWidth,
                      child: SingleChildScrollView(
                        child: Column(
                          children: _rightItems.map((item) {
                            final isMatched = _matchedRight.contains(item);
                            final isCorrect = _correctRight.contains(item);
                            final isIncorrect = _incorrectRight.contains(item);
                            final isSelected = _selectedRight == item;
                            final state = isMatched
                                ? MatchTileState.disabled
                                : isCorrect
                                    ? MatchTileState.correct
                                    : isIncorrect
                                        ? MatchTileState.incorrect
                                        : isSelected
                                            ? MatchTileState.selected
                                            : MatchTileState.defaults;

                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: MatchTile(
                                word: item,
                                state: state,
                                height: tileHeight,
                                showSoundIcon: false,
                                onPressed: (isMatched || isCorrect || isIncorrect)
                                    ? null
                                    : () => _handleSelection(item, false),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// True/False question widget
class PodcastTrueFalseQuestionWidget extends PodcastQuestionWidget {
  const PodcastTrueFalseQuestionWidget({
    super.key,
    required PodcastTrueFalseQuestion question,
    required Function(bool isCorrect, dynamic answer) onAnswered,
  }) : super(question: question, onAnswered: onAnswered);

  @override
  State<PodcastTrueFalseQuestionWidget> createState() =>
      _PodcastTrueFalseQuestionWidgetState();
}

class _PodcastTrueFalseQuestionWidgetState
    extends State<PodcastTrueFalseQuestionWidget> {
  PodcastTrueFalseQuestion get _question =>
      widget.question as PodcastTrueFalseQuestion;

  @override
  void initState() {
    super.initState();
    
    print('🎯 ========================================');
    print('🎯 TRUE/FALSE QUESTION INITIALIZED');
    print('🎯 Question: ${_question.question}');
    print('🎯 Statement: ${_question.statement}');
    print('🎯 Correct answer: ${_question.correctAnswer ? "TRUE" : "FALSE"}');
    print('🎯 ========================================');
  }

  void _handleAnswer(bool answer) {
    print('🎯 User answered: ${answer ? "TRUE" : "FALSE"}');
    
    final isCorrect = _question.validateAnswer(answer);
    
    print('🎯 Result: ${isCorrect ? "✅ CORRECT" : "❌ INCORRECT"}');
    
    widget.onAnswered(isCorrect, answer);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _question.question,
            style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                  color: AppColors.eel,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.polar,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.swan, width: 1.w),
            ),
            child: Text(
              _question.statement,
              style: AppTypography.defaultTextTheme().bodyLarge?.copyWith(
                    color: AppColors.eel,
                    height: 1.5,
                  ),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildOptionButton(
                  text: 'TRUE',
                  value: true,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildOptionButton(
                  text: 'FALSE',
                  value: false,
                  color: AppColors.cardinal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required bool value,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => _handleAnswer(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          border: Border.all(color: color, width: 2.w),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

/// Listen and choose words widget
class PodcastListenChooseQuestionWidget extends PodcastQuestionWidget {
  const PodcastListenChooseQuestionWidget({
    super.key,
    required PodcastListenChooseQuestion question,
    required Function(bool isCorrect, dynamic answer) onAnswered,
  }) : super(question: question, onAnswered: onAnswered);

  @override
  State<PodcastListenChooseQuestionWidget> createState() =>
      _PodcastListenChooseQuestionWidgetState();
}

class _PodcastListenChooseQuestionWidgetState
    extends State<PodcastListenChooseQuestionWidget> {
  PodcastListenChooseQuestion get _question =>
      widget.question as PodcastListenChooseQuestion;

  late List<String> _options;
  Set<String> _selectedWords = {};

  @override
  void initState() {
    super.initState();
    
    print('🎯 ========================================');
    print('🎯 LISTEN & CHOOSE QUESTION INITIALIZED');
    print('🎯 Question: ${_question.question}');
    print('🎯 Correct words: ${_question.correctWords.join(", ")}');
    print('🎯 All options: ${_question.allOptions.join(", ")}');
    print('🎯 ========================================');
    
    _options = _question.allOptions..shuffle();
  }

  void _toggleWord(String word) {
    setState(() {
      if (_selectedWords.contains(word)) {
        _selectedWords.remove(word);
        print('🎯 Deselected word: "$word"');
      } else {
        _selectedWords.add(word);
        print('🎯 Selected word: "$word"');
      }
      print('🎯 Currently selected: ${_selectedWords.join(", ")}');
    });
  }

  void _submitAnswer() {
    print('🎯 Submitting answer: ${_selectedWords.join(", ")}');
    
    final isCorrect = _question.validateAnswer(_selectedWords.toList());
    
    print('🎯 Result: ${isCorrect ? "✅ CORRECT" : "❌ INCORRECT"}');
    
    widget.onAnswered(isCorrect, _selectedWords.toList());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.headphones, color: AppColors.macaw, size: 24.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  _question.question,
                  style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                        color: AppColors.eel,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Select all words you hear',
            style: AppTypography.defaultTextTheme().bodySmall?.copyWith(
                  color: AppColors.wolf,
                ),
          ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 12.w,
            runSpacing: 12.h,
            children: _options.map((word) {
              final isSelected = _selectedWords.contains(word);
              return _buildWordChip(
                word: word,
                isSelected: isSelected,
                onTap: () => _toggleWord(word),
              );
            }).toList(),
          ),
          if (_selectedWords.isNotEmpty) ...[
            SizedBox(height: 20.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.snow,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'CHECK',
                  style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                        color: AppColors.snow,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWordChip({
    required String word,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.macaw.withOpacity(0.2)
              : AppColors.polar,
          border: Border.all(
            color: isSelected ? AppColors.macaw : AppColors.swan,
            width: 2.w,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          word,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                color: isSelected ? AppColors.macaw : AppColors.eel,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
        ),
      ),
    );
  }
}

/// Multiple choice question widget (existing type)
class PodcastMultipleChoiceQuestionWidget extends PodcastQuestionWidget {
  const PodcastMultipleChoiceQuestionWidget({
    super.key,
    required PodcastMultipleChoiceQuestion question,
    required Function(bool isCorrect, dynamic answer) onAnswered,
  }) : super(question: question, onAnswered: onAnswered);

  @override
  State<PodcastMultipleChoiceQuestionWidget> createState() =>
      _PodcastMultipleChoiceQuestionWidgetState();
}

class _PodcastMultipleChoiceQuestionWidgetState
    extends State<PodcastMultipleChoiceQuestionWidget> {
  PodcastMultipleChoiceQuestion get _question =>
      widget.question as PodcastMultipleChoiceQuestion;

  @override
  void initState() {
    super.initState();
    
    print('🎯 ========================================');
    print('🎯 MULTIPLE CHOICE QUESTION INITIALIZED');
    print('🎯 Question: ${_question.question}');
    print('🎯 Options: ${_question.options.join(", ")}');
    print('🎯 Correct answer: ${_question.correctAnswer}');
    print('🎯 ========================================');
  }

  void _handleAnswer(String answer) {
    print('🎯 User selected: "$answer"');
    
    final isCorrect = _question.validateAnswer(answer);
    
    print('🎯 Result: ${isCorrect ? "✅ CORRECT" : "❌ INCORRECT"}');
    
    widget.onAnswered(isCorrect, answer);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _question.question,
            style: AppTypography.defaultTextTheme().titleMedium?.copyWith(
                  color: AppColors.eel,
                  fontWeight: FontWeight.w700,
                ),
          ),
          SizedBox(height: 20.h),
          ...(_question.options.map((option) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildOptionButton(option),
            );
          }).toList()),
        ],
      ),
    );
  }

  Widget _buildOptionButton(String option) {
    return GestureDetector(
      onTap: () => _handleAnswer(option),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.polar,
          border: Border.all(color: AppColors.macaw, width: 2.w),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          option,
          style: AppTypography.defaultTextTheme().bodyMedium?.copyWith(
                color: AppColors.eel,
              ),
        ),
      ),
    );
  }
}
