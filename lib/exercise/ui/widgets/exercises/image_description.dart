import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/exercise_feedback.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';

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

class _ImageDescriptionState extends State<ImageDescription> with TickerProviderStateMixin {
  ImageDescriptionMetaEntity get _meta => widget.meta;
  String get _exerciseId => widget.exerciseId;

  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isFocused = false;
  bool _isSubmitted = false;
  bool _isLoading = false;
  bool _showFlash = false;
  int _wordCount = 0;

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
      _isLoading = true;
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
        _isLoading = false;
        _wordCount = 0;
        _showFlash = false;
      });
    }
  }

  void _triggerFlash() async {
    if (_showFlash) return;
    HapticFeedback.heavyImpact();
    setState(() => _showFlash = true);
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) {
      setState(() => _showFlash = false);
    }
  }

  void _showFullScreenImage() {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, _, __) {
          return Scaffold(
            backgroundColor: Colors.black.withOpacity(0.9),
            body: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Center(
                child: Hero(
                  tag: 'polaroid_image_${_meta.imageUrl}',
                  child: InteractiveViewer(
                    maxScale: 4.0,
                    child: Image.network(
                      _meta.imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPolaroid(bool? isCorrect) {
    // Góc nghiêng khi không focus
    final double angle = (_isFocused || _isSubmitted) ? 0.0 : 0.04; // ~2.3 degrees

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
      child: AnimatedRotation(
        turns: angle / (2 * 3.14159),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 15,
                spreadRadius: 2,
                offset: Offset(4, 8),
              ),
              // Viền mỏng mờ giả lập giấy ảnh
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 1,
                spreadRadius: 0,
                offset: Offset(0, 0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Khu vực hình ảnh
              Padding(
                padding: EdgeInsets.only(left: 12.w, right: 12.w, top: 12.h, bottom: 8.h),
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 220.h,
                      decoration: BoxDecoration(color: Colors.black87),
                      child: Hero(
                        tag: 'polaroid_image_${_meta.imageUrl}',
                        child: Image.network(
                          _meta.imageUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: DotLoadingIndicator(color: AppColors.white, size: 16.0),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) =>
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image, size: 48.sp, color: AppColors.wolf),
                                  SizedBox(height: 8.h),
                                  Text(
                                    'Lỗi tải ảnh',
                                    style: TextStyle(color: AppColors.wolf, fontSize: 12.sp),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    
                    // Nút phóng to
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: GestureDetector(
                        onTap: _showFullScreenImage,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.zoom_in, color: Colors.white, size: 20.sp),
                        ),
                      ),
                    ),

                    // Con dấu Stamp chấm điểm
                    if (isCorrect != null && _isSubmitted)
                      Positioned.fill(
                        child: Center(
                          child: BounceInDown(
                            duration: const Duration(milliseconds: 600),
                            child: Transform.rotate(
                              angle: isCorrect ? -0.2 : 0.15,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isCorrect ? Colors.green[600]! : Colors.red[600]!,
                                    width: 4,
                                  ),
                                  borderRadius: BorderRadius.circular(8.r),
                                  color: Colors.white.withOpacity(0.85),
                                ),
                                child: Text(
                                  isCorrect ? 'PERFECT' : 'NEEDS WORK',
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.w900,
                                    color: isCorrect ? Colors.green[800] : Colors.red[800],
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Khu vực caption viết tay
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 20.h, top: 4.h),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  enabled: !_isSubmitted,
                  minLines: 2,
                  maxLines: 4,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.caveat(
                    textStyle: TextStyle(
                      color: Color(0xFF1E3A8A), // Mực xanh đậm
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Viết caption vào đây...',
                    hintStyle: GoogleFonts.caveat(
                      textStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 24.sp,
                      ),
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ExerciseBloc, ExerciseState>(
      listener: (context, state) {
        if (state is ExercisesLoaded && _isLoading && state.isCorrect != null) {
          // Bật hiệu ứng Flash máy ảnh khi có kết quả
          _triggerFlash();
        }
      },
      builder: (context, state) {
        if (state is! ExercisesLoaded) return const SizedBox.shrink();

        final isCorrect = state.isCorrect;
        if (_isLoading && isCorrect != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _isLoading = false);
          });
        }

        return Stack(
          children: [
            // Nội dung chính
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                SizedBox(height: 12.h),

                // Challenge header
                FadeInDown(
                  duration: const Duration(milliseconds: 500),
                  child: Padding(
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
                        child: Icon(Icons.camera_alt, size: 40.sp, color: AppColors.fox),
                      ),
                      characterPosition: CharacterPosition.left,
                      variant: isCorrect == null ? SpeechBubbleVariant.neutral : (isCorrect ? SpeechBubbleVariant.correct : SpeechBubbleVariant.incorrect),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                // Polaroid Frame
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        FadeInUp(
                          duration: const Duration(milliseconds: 600),
                          child: _buildPolaroid(isCorrect),
                        ),
                        
                        // Word count
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24.w),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '$_wordCount words',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.wolf,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],
                    ),
                  ),
                ),

                // Expected result hint (if incorrect and available)
                if (_isSubmitted && isCorrect == false && _meta.expectedResults.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.primary),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            _meta.expectedResults,
                            style: TextStyle(fontSize: 13.sp, color: AppColors.eel, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Action buttons
                if (isCorrect != null)
                  ExerciseFeedback(
                    isCorrect: isCorrect,
                    onContinue: _handleContinue,
                    correctAnswer: null,
                    hint: _meta.expectedResults.isNotEmpty ? 'Thử tập trung vào: ${_meta.expectedResults}' : null,
                  )
                else
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                    child: AppButton(
                      label: 'NỘP BẢN MÔ TẢ',
                      onPressed: _handleSubmit,
                      isDisabled: _controller.text.trim().isEmpty,
                      isLoading: _isLoading,
                      variant: ButtonVariant.primary,
                      size: ButtonSize.medium,
                    ),
                  ),
              ],
            ),

            // Hiệu ứng Flash lóa sáng toàn màn hình
            IgnorePointer(
              child: AnimatedOpacity(
                opacity: _showFlash ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 100),
                child: Container(
                  color: Colors.white,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
