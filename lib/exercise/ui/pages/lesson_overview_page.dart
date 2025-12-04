import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';

class LessonOverviewPage extends StatelessWidget {
  final SubmitResponseEntity response;
  final Duration? completionTime;

  const LessonOverviewPage({
    super.key,
    required this.response,
    this.completionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Nền trắng giống hình
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              Spacer(),
              
              // 1. MASCOT IMAGE (Thay thế icon check cũ)
              // Bạn hãy thay đường dẫn ảnh con cú của bạn vào đây
              Container(
                height: 200,
                width: 200,
                alignment: Alignment.center,
                child: Image.asset(
                  'assets/images/mascot_finish.png', // Đổi thành path ảnh của bạn
                  errorBuilder: (context, error, stackTrace) {
                    // Placeholder nếu chưa có ảnh
                    return Icon(Icons.sentiment_very_satisfied_rounded, size: 120, color: AppColors.featherGreen);
                  },
                ),
              ),
              
              SizedBox(height: 24),
              
              // 2. TITLE & SUBTITLE
              Text(
                'Phù thủy từ vựng!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.bee, // Màu vàng
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                '6 từ mới? Bạn sắp thi siêu trí tuệ đấy nhỉ.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              SizedBox(height: 48),

              // 3. STATS ROW (Hàng ngang 3 thẻ)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Cột 1: XP (Vàng)
                    _buildGridStatCard(
                      title: 'TỔNG ĐIỂM KN',
                      value: '${response.xpEarned}',
                      icon: Icons.electric_bolt_rounded,
                      color: AppColors.bee,
                    ),
                    SizedBox(width: 12),
                    
                    // Cột 2: Chính xác (Xanh lá)
                    _buildGridStatCard(
                      title: 'TUYỆT VỜI',
                      value: '${response.accuracy.toInt()}%',
                      icon: Icons.track_changes_rounded, // Icon mục tiêu
                      color: AppColors.featherGreen,
                    ),
                    SizedBox(width: 12),
                    
                    // Cột 3: Tốc độ (Xanh dương)
                    _buildGridStatCard(
                      title: 'TỐC ĐỘ',
                      value: completionTime != null 
                          ? _formatDuration(completionTime!) 
                          : '--',
                      icon: Icons.timer_outlined,
                      color: AppColors.macaw, // Màu xanh dương
                    ),
                  ],
                ),
              ),
              
              Spacer(),
              
              // 4. BUTTON (Màu xanh dương)
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: AppButton(
                  label: 'NHẬN KN',
                  backgroundColor: AppColors.macaw,
                  shadowColor: AppColors.humpback,
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  width: double.infinity,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget xây dựng thẻ thống kê dạng lưới (Grid)
  Widget _buildGridStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 110, // Chiều cao cố định để các thẻ bằng nhau
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 2),
        ),
        child: Column(
          children: [
            // Phần Header màu nền
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(13), // Trừ đi border width để bo góc mượt
                  topRight: Radius.circular(13),
                ),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Phần Body nội dung
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(13),
                    bottomRight: Radius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 32),
                    SizedBox(width: 8),
                    Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    // Format dạng 2:52
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }
}