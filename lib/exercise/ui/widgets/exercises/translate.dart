import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';

class Translate extends StatefulWidget {
  final TranslateMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;

  const Translate({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<Translate> createState() => _TranslateState();
}

class _TranslateState extends State<Translate>
    with TickerProviderStateMixin {
  TranslateMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitted = false;

  // Animation for text field feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  
  // Entry animations
  late AnimationController _entryController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

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
    
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeIn),
    );
    
    _controller.addListener(() {
      setState(() {}); // rebuild để nút biết text đã thay đổi
    });
    
    _entryController.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
    _entryController.dispose();
    super.dispose();
  }

  String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]', unicode: true), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _handleSubmit() {
    if (_controller.text.trim().isEmpty) {
      // Shake animation for empty input
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Vui lòng nhập bản dịch'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    final userInput = normalize(_controller.text);
    final correctAnswer = normalize(_meta.correctAnswer);

    context.read<ExerciseBloc>().add(
      TranslateCheck(
        userAnswer: userInput,
        sourceText: _meta.sourceText,
        correctAnswer: correctAnswer,
        exerciseId: _exerciseId,
      ),
    );
  }

  void _handleContinue() {
    context.read<ExerciseBloc>().add(AnswerClear());
    if (widget.onContinue != null) {
      widget.onContinue!();
    } else {
      setState(() {
        _controller.clear();
        _isSubmitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExerciseBloc, ExerciseState>(
      builder: (context, state) {
        if (state is! ExercisesLoaded) {
          return const SizedBox.shrink();
        }

        final isCorrect = state.isCorrect;

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),

            // Challenge header with source text
            AnimatedBuilder(
              animation: _entryController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: CharacterChallenge(
                        challengeTitle: 'Dịch câu này',
                        challengeContent: Text(
                          _meta.sourceText,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        character: Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.macaw.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.translate,
                            size: 40.sp,
                            color: AppColors.macaw,
                          ),
                        ),
                        characterPosition: CharacterPosition.left,
                        variant: isCorrect == null
                            ? SpeechBubbleVariant.neutral
                            : (isCorrect
                                ? SpeechBubbleVariant.correct
                                : SpeechBubbleVariant.incorrect),
                      ),
                    ),
                  ),
                );
              },
            ),            SizedBox(height: 24.h),

            // Hints section (if available)
            if (_meta.hints != null && _meta.hints!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.bee.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.bee.withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 20.sp,
                        color: AppColors.fox,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Gợi ý:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.fox,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            ...(_meta.hints!.map(
                              (hint) => Padding(
                                padding: EdgeInsets.only(bottom: 2.h),
                                child: Text(
                                  '• $hint',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.eel,
                                  ),
                                ),
                              ),
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (_meta.hints != null && _meta.hints!.isNotEmpty)
              SizedBox(height: 16.h),

            // Translation input area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeAnimation.value *
                            ((_shakeController.value * 4).floor().isEven
                                ? 1
                                : -1),
                        0,
                      ),
                      child: child,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 150.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.snow,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: _isSubmitted
                            ? (isCorrect == true
                                  ? AppColors.primary
                                  : AppColors.cardinal)
                            : AppColors.hare,
                        width: 2,
                      ),
                      boxShadow: _isSubmitted && isCorrect != null
                          ? [
                              BoxShadow(
                                color:
                                    (isCorrect
                                            ? AppColors.primary
                                            : AppColors.cardinal)
                                        .withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !_isSubmitted,
                      minLines: 4,
                      maxLines: 10,
                      style: TextStyle(
                        color: AppColors.eel,
                        fontSize: 16.sp,
                        height: 1.5,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Nhập bản dịch của bạn...',
                        hintStyle: TextStyle(
                          color: AppColors.hare,
                          fontSize: 16.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: isCorrect ? null : _meta.correctAnswer,
                hint: isCorrect
                    ? null
                    : (_meta.hints != null && _meta.hints!.isNotEmpty
                          ? _meta.hints!.first
                          : null),
              )
            else
              _buildCheckButton(),
          ],
        );
      },
    );
  }

  Widget _buildCheckButton() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: AppButton(
        label: 'KIỂM TRA',
        onPressed: _handleSubmit,
        isDisabled: _controller.text.trim().isEmpty,
        variant: ButtonVariant.primary,
        size: ButtonSize.medium,
      ),
    );
  }
}
