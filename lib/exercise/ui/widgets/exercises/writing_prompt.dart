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
            }
          });
        }

        return Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            SizedBox(height: 12.h),

            // Instruction Title
            FadeInDown(
              duration: const Duration(milliseconds: 500),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Viết đoạn văn',
                    style: TextStyle(
                      fontFamily: 'DuolingoFeather',
                      fontWeight: FontWeight.w700,
                      fontSize: 22.sp,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),

            // Prompt Quote Box
            FadeInDown(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.polar,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border(
                      left: BorderSide(color: AppColors.primary, width: 4.w),
                    ),
                  ),
                  child: Text(
                    _meta.prompt,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.bodyText,
                      height: 1.4,
                    ),
                  ),
                ),
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

            // Writing input area
            Expanded(
              child: FadeInUp(
                duration: const Duration(milliseconds: 600),
                delay: const Duration(milliseconds: 300),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: AnimatedBuilder(
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
                  ),
                ),
              ),
            ),

            SizedBox(height: 16.h),

            // Example Answer / Feedback Area
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

            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: null, // We handled exampleAnswer above
                hint: _meta.criteria != null && _meta.criteria!.isNotEmpty
                    ? _meta.criteria!.join('\n')
                    : null,
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
