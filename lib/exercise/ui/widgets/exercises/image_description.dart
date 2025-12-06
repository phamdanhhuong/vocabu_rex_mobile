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

class ImageDescription extends StatefulWidget {
  final ImageDescriptionMetaEntity meta;
  final String exerciseId;
  final VoidCallback? onContinue;
  
  const ImageDescription({
    super.key,
    required this.meta,
    required this.exerciseId,
    this.onContinue,
  });

  @override
  State<ImageDescription> createState() => _ImageDescriptionState();
}

class _ImageDescriptionState extends State<ImageDescription> with SingleTickerProviderStateMixin {
  ImageDescriptionMetaEntity get _meta => widget.meta;
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
          content: Text('Vui lòng mô tả hình ảnh'),
          backgroundColor: AppColors.cardinal,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitted = true;
    });

    context.read<ExerciseBloc>().add(
      DescriptionCheck(
        content: text,
        expectResult: _meta.expectedResults,
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
            
            // Challenge header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: CharacterChallenge(
                challengeTitle: 'Mô tả hình ảnh',
                challengeContent: Text(
                  _meta.prompt,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
                ),
                character: Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: AppColors.fox.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.image, size: 40.sp, color: AppColors.fox),
                ),
                characterPosition: CharacterPosition.left,
                variant: isCorrect == null
                    ? SpeechBubbleVariant.neutral
                    : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Image display
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Container(
                width: double.infinity,
                constraints: BoxConstraints(maxHeight: 250.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.eel.withOpacity(0.15),
                      blurRadius: 12,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(
                    _meta.imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: AppColors.hare.withOpacity(0.3),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.macaw),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: AppColors.hare.withOpacity(0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48.sp, color: AppColors.wolf),
                          SizedBox(height: 8.h),
                          Text(
                            'Không tải được hình ảnh',
                            style: TextStyle(color: AppColors.wolf, fontSize: 12.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Word count
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
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Description input area
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
                      minLines: 6,
                      maxLines: 12,
                      style: TextStyle(
                        color: AppColors.eel,
                        fontSize: 15.sp,
                        height: 1.6,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Mô tả hình ảnh bạn nhìn thấy...',
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
            
            // Expected result hint (if incorrect and available)
            if (_isSubmitted && isCorrect == false && _meta.expectedResults.isNotEmpty)
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
                        'Gợi ý mô tả:',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _meta.expectedResults,
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
            
            if (_isSubmitted && isCorrect == false && _meta.expectedResults.isNotEmpty)
              SizedBox(height: 16.h),
            
            // Action buttons
            if (isCorrect != null)
              ExerciseFeedback(
                isCorrect: isCorrect,
                onContinue: _handleContinue,
                correctAnswer: null,
                hint: _meta.expectedResults.isNotEmpty
                    ? 'Thử tập trung vào: ${_meta.expectedResults}'
                    : null,
              )
            else
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: AppButton(
                  label: 'KIỂM TRA',
                  onPressed: _handleSubmit,
                  isDisabled: _controller.text.trim().isEmpty,
                  variant: ButtonVariant.primary,
                  size: ButtonSize.medium,
                ),
              ),
          ],
        );
      },
    );
  }
}
