import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';

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

class _WritingPromptState extends State<WritingPrompt> with SingleTickerProviderStateMixin {
  WritingPromptMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;
  
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitted = false;
  int _wordCount = 0;
  
  // Animation for text field feedback
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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
    
    _controller.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateWordCount);
    _controller.dispose();
    _focusNode.dispose();
    _shakeController.dispose();
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
        SnackBar(
          content: Text('Vui lòng nhập nội dung'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check minimum words if specified
    if (_meta.minWords != null && _wordCount < _meta.minWords!) {
      _shakeController.forward(from: 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cần ít nhất ${_meta.minWords} từ (hiện tại: $_wordCount)'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    // For writing prompts, we'll send to AI for evaluation
    // Using DescriptionCheck event with prompt as expectResult
    context.read<ExerciseBloc>().add(
      DescriptionCheck(
        content: text,
        expectResult: _meta.prompt,
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
        _wordCount = 0;
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
            
            // Challenge header with prompt
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Viết đoạn văn',
                challengeContent: Text(
                  _meta.prompt,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.beetle.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.create, size: 40.sp, color: AppColors.beetle),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Word count and limits info
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: [
                  Icon(Icons.text_fields, size: 16.sp, color: AppColors.wolf),
                  SizedBox(width: 4.w),
                  Text(
                    'Số từ: $_wordCount',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: _getWordCountColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_meta.minWords != null || _meta.maxWords != null) ...[
                    Text(
                      ' / ',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.wolf),
                    ),
                    Text(
                      _meta.minWords != null && _meta.maxWords != null
                          ? '${_meta.minWords}-${_meta.maxWords} từ'
                          : _meta.minWords != null
                              ? 'Tối thiểu ${_meta.minWords} từ'
                              : 'Tối đa ${_meta.maxWords} từ',
                      style: TextStyle(fontSize: 13.sp, color: AppColors.wolf),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Criteria section (if available)
            if (_meta.criteria != null && _meta.criteria!.isNotEmpty)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.macaw.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.macaw.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.checklist, size: 16.sp, color: AppColors.humpback),
                          SizedBox(width: 6.w),
                          Text(
                            'Tiêu chí đánh giá:',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.humpback,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      ...(_meta.criteria!.map((criterion) => Padding(
                        padding: EdgeInsets.only(bottom: 4.h),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('• ', style: TextStyle(color: AppColors.eel)),
                            Expanded(
                              child: Text(
                                criterion,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.eel,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ))),
                    ],
                  ),
                ),
              ),
            
            if (_meta.criteria != null && _meta.criteria!.isNotEmpty)
              SizedBox(height: 16.h),
            
            // Writing input area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(_shakeAnimation.value * 
                        ((_shakeController.value * 4).floor().isEven ? 1 : -1), 0),
                      child: child,
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    constraints: BoxConstraints(minHeight: 200.h),
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
                                color: (isCorrect 
                                    ? AppColors.primary 
                                    : AppColors.cardinal).withOpacity(0.2),
                                blurRadius: 8,
                                spreadRadius: 2,
                              )
                            ]
                          : [],
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      enabled: !_isSubmitted,
                      minLines: 8,
                      maxLines: 15,
                      style: TextStyle(
                        color: AppColors.eel,
                        fontSize: 15.sp,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Viết đoạn văn của bạn ở đây...',
                        hintStyle: TextStyle(
                          color: AppColors.hare,
                          fontSize: 15.sp,
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
            
            // Example answer section (if incorrect and example provided)
            if (_isSubmitted && isCorrect == false && _meta.exampleAnswer != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.correctGreenLight,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ví dụ tham khảo:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _meta.exampleAnswer!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.eel,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            
            if (_isSubmitted && isCorrect == false && _meta.exampleAnswer != null)
              SizedBox(height: 16.h),
            
            // Action buttons
            _buildActionButtons(isCorrect),
          ],
        );
      },
    );
  }

  Color _getWordCountColor() {
    if (_meta.minWords != null && _wordCount < _meta.minWords!) {
      return AppColors.cardinal;
    }
    if (_meta.maxWords != null && _wordCount > _meta.maxWords!) {
      return AppColors.fox;
    }
    return AppColors.primary;
  }

  Widget _buildActionButtons(bool? isCorrect) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: isCorrect != null
          ? Container(
              padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
              decoration: BoxDecoration(
                color: isCorrect ? AppColors.correctGreenLight : AppColors.incorrectRedLight,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Text(
                    isCorrect ? 'Chính xác !!!' : 'Cần cải thiện',
                    style: TextStyle(
                      color: isCorrect ? AppColors.primary : AppColors.cardinal,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppButton(
                    label: 'TIẾP TỤC',
                    onPressed: _handleContinue,
                    variant: ButtonVariant.primary,
                    size: ButtonSize.medium,
                  ),
                ],
              ),
            )
          : AppButton(
              label: 'KIỂM TRA',
              onPressed: _handleSubmit,
              isDisabled: _controller.text.trim().isEmpty,
              variant: ButtonVariant.primary,
              size: ButtonSize.medium,
            ),
    );
  }
}
