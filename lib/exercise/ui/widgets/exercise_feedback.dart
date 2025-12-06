import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'dart:math' as math;

class ExerciseFeedback extends StatefulWidget {
  final bool isCorrect;
  final VoidCallback onContinue;
  final String? correctAnswer;
  final String? hint;
  final Widget? additionalContent;

  const ExerciseFeedback({
    super.key,
    required this.isCorrect,
    required this.onContinue,
    this.correctAnswer,
    this.hint,
    this.additionalContent,
  });

  @override
  State<ExerciseFeedback> createState() => _ExerciseFeedbackState();
}

class _ExerciseFeedbackState extends State<ExerciseFeedback>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  // Random messages cho trường hợp ĐÚNG
  static final List<String> _correctMessages = [
    'Tuyệt quá!',
    'Chính xác!',
    'Xuất sắc!',
    'Làm tốt lắm!',
    'Hoàn hảo!',
    'Tuyệt vời!',
  ];

  String get _successMessage {
    final random = math.Random();
    return _correctMessages[random.nextInt(_correctMessages.length)];
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Nhanh hơn chút cho snappy
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack, // Hiệu ứng nảy nhẹ giống Duo
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Xác định màu sắc chủ đạo dựa trên trạng thái
    final Color backgroundColor = widget.isCorrect
        ? AppColors.correctGreenLight // Màu nền xanh nhạt (như hình 2)
        : AppColors.incorrectRedLight; // Màu nền đỏ nhạt (như hình 1)
    
    final Color mainTextColor = widget.isCorrect
        ? AppColors.primary // Xanh lá đậm
        : AppColors.cardinal; // Đỏ đậm

    // Giả sử AppButton có variant cho màu đỏ (danger), nếu chưa có bạn hãy map màu vào property color của nút
    // Ở đây mình ví dụ dùng biến variant logic
    final btnVariant = widget.isCorrect ? ButtonVariant.primary : ButtonVariant.destructive; 
    // Lưu ý: Nếu AppButton của bạn chưa có variant.danger, hãy đổi logic này để truyền color trực tiếp.

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 16.h,
          bottom: 24.h, // Padding bottom để tránh sát mép màn hình
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          // Nếu muốn bo tròn 2 góc trên giống BottomSheet thì uncomment dòng dưới
          // borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start, // Căn trái toàn bộ
          children: [
            // Row 1: Title & Icon Flag
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        widget.isCorrect ? _successMessage : 'Đáp án đúng:',
                        style: TextStyle(
                          color: mainTextColor,
                          fontSize: 20.sp, 
                          fontWeight: FontWeight.w800, // Font đậm như hình
                        ),
                      ),
                      
                      // Nếu SAI thì hiện đáp án đúng ngay dưới tiêu đề (như hình 1)
                      if (!widget.isCorrect && widget.correctAnswer != null) ...[
                        SizedBox(height: 8.h),
                        Text(
                          widget.correctAnswer!,
                          style: TextStyle(
                            color: mainTextColor, // Vẫn dùng màu đỏ
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Icon Flag (Báo cáo) ở góc phải
                Padding(
                  padding: EdgeInsets.only(left: 12.w),
                  child: Icon(
                    Icons.flag_outlined, // Hoặc Icons.outlined_flag
                    color: mainTextColor.withOpacity(0.6),
                    size: 24.sp,
                  ),
                ),
              ],
            ),

            // Hint (Optional - Nếu có hint và sai thì hiển thị thêm)
            if (!widget.isCorrect && widget.hint != null) ...[
              SizedBox(height: 12.h),
              Text(
                'Gợi ý: ${widget.hint}',
                style: TextStyle(
                  color: mainTextColor.withOpacity(0.8),
                  fontSize: 14.sp,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],

            // Khoảng cách đến nút bấm
            SizedBox(height: 24.h),

            // Button TIẾP TỤC
            SizedBox(
              width: double.infinity, // Full width button
              child: AppButton(
                label: 'TIẾP TỤC',
                onPressed: widget.onContinue,
                variant: btnVariant, // Cần đảm bảo AppButton hỗ trợ đổi màu đỏ
                size: ButtonSize.large, // Nút to hơn
                // Nếu AppButton chưa hỗ trợ đổi màu background qua variant, 
                // bạn có thể cần thêm tham số backgroundColor vào AppButton
              ),
            ),
          ],
        ),
      ),
    );
  }
}