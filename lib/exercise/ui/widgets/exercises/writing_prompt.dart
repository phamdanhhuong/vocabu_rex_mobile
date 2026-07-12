import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/writing_score_entity.dart';

class WritingPrompt extends StatefulWidget {
  final WritingPromptMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const WritingPrompt({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<WritingPrompt> createState() => _WritingPromptState();
}

class _WritingPromptState extends State<WritingPrompt>
    with TickerProviderStateMixin {
  WritingPromptMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitted = false;
  bool _isLoading = false;
  int _wordCount = 0;
  bool _isFocused = false;

  // Animation for text field feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  // AI Scanning animation
  late AnimationController _laserController;

  // Flip animation
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );

    _laserController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _controller.addListener(_updateWordCount);
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _laserController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _updateWordCount() {
    final text = _controller.text.trim();
    final words = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    setState(() {
      _wordCount = words;
    });
  }

  void _handleSubmit() {
    final text = _controller.text.trim();

    if (text.isEmpty) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập nội dung'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
      _isLoading = true;
    });
    
    _laserController.repeat(); // Start scanning

    // For writing prompts, we'll send to AI for evaluation
    context.read<ExerciseBloc>().add(
      WritingCheck(userAnswer: text, meta: _meta, exerciseId: _exerciseId),
    );
  }

  void _handleContinue() {
    context.read<ExerciseBloc>().add(AnswerClear());
    _flipController.reverse();
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      setState(() {
        _controller.clear();
        _isSubmitted = false;
        _isLoading = false;
        _wordCount = 0;
      });
    }
  }

  Color _getProgressColor() {
    if (_meta.minWords != null && _meta.maxWords != null) {
      if (_wordCount < _meta.minWords!) return AppColors.fox;
      if (_wordCount <= _meta.maxWords!) return AppColors.correctGreenDark;
      return AppColors.cardinal;
    } else if (_meta.minWords != null) {
      return _wordCount >= _meta.minWords! ? AppColors.correctGreenDark : AppColors.fox;
    }
    return AppColors.primary;
  }

  double _getProgressValue() {
    if (_meta.maxWords != null) {
      return (_wordCount / _meta.maxWords!).clamp(0.0, 1.0);
    } else if (_meta.minWords != null) {
      return (_wordCount / _meta.minWords!).clamp(0.0, 1.0);
    }
    return 1.0;
  }

  Widget _buildFeedbackCard({
    required String title,
    required IconData icon,
    required Color color,
    required String? content,
    required bool isDark,
  }) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? color.withOpacity(0.1) : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18.sp, color: color),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              content,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.bodyText,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedErrors(List<dynamic> errors, bool isDark) {
    if (errors.isEmpty) return const SizedBox.shrink();
    
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
            child: Text(
              'Lỗi cần khắc phục:',
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.cardinal,
              ),
            ),
          ),
          ...errors.map((error) => Container(
                margin: EdgeInsets.only(bottom: 8.h),
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.snow : AppColors.polar,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.hare.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 14.sp, height: 1.5),
                        children: [
                          TextSpan(
                            text: error.original,
                            style: TextStyle(
                              color: AppColors.cardinal,
                              decoration: TextDecoration.lineThrough,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          TextSpan(text: ' ➔ ', style: TextStyle(color: AppColors.wolf)),
                          TextSpan(
                            text: error.corrected,
                            style: TextStyle(
                              color: AppColors.correctGreenDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      error.explanation,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.wolf,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildScrollablePage(Widget content) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: content,
    );
  }

  Widget _buildBackCard(WritingScoreEntity score, bool isDark) {
    final List<Widget> pages = [];
    if (score.grammarFeedback != null && score.grammarFeedback!.isNotEmpty) {
      pages.add(_buildScrollablePage(
        _buildFeedbackCard(
          title: 'Ngữ pháp',
          icon: Icons.spellcheck,
          color: AppColors.primary,
          content: score.grammarFeedback,
          isDark: isDark,
        )
      ));
    }
    if (score.vocabularyFeedback != null && score.vocabularyFeedback!.isNotEmpty) {
      pages.add(_buildScrollablePage(
        _buildFeedbackCard(
          title: 'Từ vựng',
          icon: Icons.translate,
          color: AppColors.macaw,
          content: score.vocabularyFeedback,
          isDark: isDark,
        )
      ));
    }
    if (score.contentFeedback != null && score.contentFeedback!.isNotEmpty) {
      pages.add(_buildScrollablePage(
        _buildFeedbackCard(
          title: 'Nội dung',
          icon: Icons.article_outlined,
          color: AppColors.fox,
          content: score.contentFeedback,
          isDark: isDark,
        )
      ));
    }
    if (score.detailedErrors.isNotEmpty) {
      pages.add(_buildScrollablePage(
        _buildDetailedErrors(score.detailedErrors, isDark)
      ));
    }

    if (pages.isEmpty) {
      pages.add(Center(
        child: Text(
          score.feedback.isNotEmpty ? score.feedback : 'Không có chi tiết.',
          style: TextStyle(fontSize: 14.sp, color: AppColors.bodyText),
          textAlign: TextAlign.center,
        ),
      ));
    }

    return Container(
      width: double.infinity,
      height: 350.h,
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: isDark ? AppColors.polar : AppColors.snow,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: score.isCorrect ? AppColors.featherGreen : AppColors.cardinal,
          width: 2,
        ),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.05), blurRadius: 10, spreadRadius: 2)],
      ),
      child: Column(
        children: [
          Expanded(
            child: PageView(
              physics: const BouncingScrollPhysics(),
              children: pages,
            ),
          ),
          if (pages.length > 1) ...[
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.swipe, size: 14.sp, color: AppColors.hare),
                SizedBox(width: 4.w),
                Text(
                  'Vuốt ngang để xem thêm chi tiết',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.hare,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildFrontCard(bool isDark, bool? isCorrect) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            _shakeAnimation.value * ((_shakeController.value * 4).floor().isEven ? 1 : -1),
            0,
          ),
          child: child,
        );
      },
      child: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 250.h),
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: _isFocused ? AppColors.snow : AppColors.polar,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(
                color: _isSubmitted
                    ? (isCorrect == true ? AppColors.featherGreen : AppColors.cardinal)
                    : (_isFocused ? AppColors.primary : Colors.transparent),
                width: 2,
              ),
              boxShadow: _isFocused && !_isSubmitted
                  ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 10, spreadRadius: 2)]
                  : [],
            ),
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              enabled: !_isSubmitted,
              minLines: 8,
              maxLines: 15,
              style: TextStyle(
                color: AppColors.bodyText,
                fontSize: 16.sp,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'Nhập đoạn văn của bạn vào đây...',
                hintStyle: TextStyle(
                  color: AppColors.hare,
                  fontSize: 16.sp,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.only(bottom: 40.h), // Room for counter
              ),
            ),
          ),

          // AI Scanning Laser Overlay
          if (_isLoading)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _laserController,
                builder: (context, child) {
                  return IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          stops: [
                            (_laserController.value - 0.3).clamp(0.0, 1.0),
                            _laserController.value,
                            (_laserController.value + 0.05).clamp(0.0, 1.0),
                          ],
                          colors: [
                            Colors.transparent,
                            AppColors.primary.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Circular Progress Indicator
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _getProgressValue(),
                    strokeWidth: 4.w,
                    backgroundColor: AppColors.hare.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(_getProgressColor()),
                  ),
                  Text(
                    '$_wordCount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: _getProgressColor(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;

    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) {
          return const SizedBox.shrink();
        }

        final isCorrect = state.isCorrect;
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() => _isLoading = false);
              _laserController.stop();
              _flipController.forward();
            }
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    SizedBox(height: 12.h),

                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CharacterChallenge(
                        challengeTitle: 'Viết đoạn văn',
                        challengeContent: Text(
                          _meta.prompt,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.bodyText,
                            height: 1.4,
                          ),
                        ),
                        characterPosition: CharacterPosition.left,
                        variant: isCorrect == null ? SpeechBubbleVariant.neutral : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // Criteria Tags (Horizontal Scroll)
                    if (_meta.criteria != null && _meta.criteria!.isNotEmpty)
                      FadeIn(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 200),
                        child: SizedBox(
                          height: 36.h,
                          child: ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            itemCount: _meta.criteria!.length,
                            separatorBuilder: (context, index) => SizedBox(width: 8.w),
                            itemBuilder: (context, index) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.macawLight.withOpacity(0.15) : AppColors.macawLight.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20.r),
                                  border: Border.all(color: AppColors.macaw.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle_outline, size: 14.sp, color: AppColors.macaw),
                                    SizedBox(width: 6.w),
                                    Text(
                                      _meta.criteria![index],
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.macaw : AppColors.macaw.withOpacity(0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                    if (_meta.criteria != null && _meta.criteria!.isNotEmpty)
                      SizedBox(height: 16.h),

                    // Flip Card Area
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: AnimatedBuilder(
                        animation: _flipAnimation,
                        builder: (context, child) {
                          final angle = _flipAnimation.value * pi;
                          final isFront = angle < pi / 2;
                          
                          return Transform(
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(angle),
                            alignment: Alignment.center,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                IgnorePointer(
                                  ignoring: !isFront,
                                  child: Opacity(
                                    opacity: isFront ? 1.0 : 0.0,
                                    child: _buildFrontCard(isDark, isCorrect),
                                  ),
                                ),
                                IgnorePointer(
                                  ignoring: isFront,
                                  child: Opacity(
                                    opacity: isFront ? 0.0 : 1.0,
                                    child: Transform(
                                      transform: Matrix4.identity()..rotateY(pi),
                                      alignment: Alignment.center,
                                      child: (state.writingScoreResult != null)
                                          ? _buildBackCard(state.writingScoreResult!, isDark)
                                          : const SizedBox.shrink(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Example Answer Area
                    if (_isSubmitted && isCorrect == false && _meta.exampleAnswer != null)
                      FadeInUp(
                        duration: const Duration(milliseconds: 400),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.cardinal.withOpacity(0.15) : AppColors.incorrectRedLight,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.cardinal.withOpacity(0.5)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.lightbulb, size: 16.sp, color: AppColors.cardinal),
                                    SizedBox(width: 6.w),
                                    Text(
                                      'Gợi ý tham khảo:',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.cardinal,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  _meta.exampleAnswer!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: AppColors.bodyText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (_isSubmitted && isCorrect == false && _meta.exampleAnswer != null)
                      SizedBox(height: 16.h),
                  ],
                ),
              ),
            ),

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: null, // We handled exampleAnswer above
                hint: null,
                feedbackText: null, // Don't show bulky text here
                errorTitle: isCorrect 
                    ? null 
                    : ((state.writingScoreResult?.scorePercentage ?? 0) >= 30 
                        ? 'Đáp án gần đúng:' 
                        : 'Sai:'),
              )
            else
              FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  child: AppButton(
                    label: _isLoading ? 'ĐANG CHẤM ĐIỂM...' : 'KIỂM TRA',
                    onPressed: _handleSubmit,
                    isDisabled: _controller.text.trim().isEmpty || _isLoading,
                    isLoading: _isLoading,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
