import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class CourseProgressView extends StatelessWidget {
  final int currentLevel;
  final String courseName;
  final int completionPercentage;
  final VoidCallback? onClose;

  const CourseProgressView({
    Key? key,
    required this.currentLevel,
    required this.courseName,
    required this.completionPercentage,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final nextLevel = currentLevel + 1;
    final progress = completionPercentage / 100.0; // Chuyển từ % sang 0.0 - 1.0

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Phần Header (Cờ & Nút thêm)
          _HeaderSection(courseName: courseName),
          const SizedBox(height: 24),

          // 2. Thẻ hiển thị điểm/tiến độ
          _ProgressCard(
            currentLevel: currentLevel,
            nextLevel: nextLevel,
            progress: progress,
          ),
          const SizedBox(height: 32),

          // 3. Tiêu đề danh sách khóa học
          const Text(
            'Các khóa học mới',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
              fontFamily: 'DuolingoFeather', // Font của bạn
            ),
          ),
          const SizedBox(height: 16),

          // 4. Danh sách các icon khóa học
          const _NewCoursesList(),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------
/// Widget 1: Header (Cờ Tiếng Anh + Nút Thêm Khóa học)
/// ---------------------------------------------------------
class _HeaderSection extends StatelessWidget {
  final String courseName;

  const _HeaderSection({Key? key, required this.courseName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Item 1: Tiếng Anh
        Column(
          children: [
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                // Thay Icon này bằng Image.asset cờ Mỹ của bạn
                child: const Icon(Icons.flag, color: AppColors.cardinal, size: 30), 
              ),
            ),
            const SizedBox(height: 8),
            Text(
              courseName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),

        // Item 2: Nút thêm khóa học
        Column(
          children: [
            Container(
              width: 50,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border, width: 2),
              ),
              child: const Icon(Icons.add, color: AppColors.wolf),
            ),
            const SizedBox(height: 8),
            const Text(
              'Khoá học',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.wolf,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// ---------------------------------------------------------
/// Widget 2: Card tiến độ (Giống hình 5 --- 6)
/// ---------------------------------------------------------
class _ProgressCard extends StatelessWidget {
  final int currentLevel;
  final int nextLevel;
  final double progress; // Giá trị từ 0.0 đến 1.0

  const _ProgressCard({
    Key? key,
    required this.currentLevel,
    required this.nextLevel,
    required this.progress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 2),
        boxShadow: [
           // Hiệu ứng bóng nhẹ nếu cần
           BoxShadow(
             color: Colors.black.withOpacity(0.05),
             offset: const Offset(0, 2),
             blurRadius: 4,
           )
        ]
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          // Row chứa số 5 -- thanh bar -- số 6
          Row(
            children: [
              Text(
                '$currentLevel',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.fern),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '$nextLevel',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Text thông báo
          Text(
            'Điểm tiếng Anh của bạn là $currentLevel',
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.wolf,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),

          // Link "TÌM HIỂU THÊM"
          GestureDetector(
            onTap: () {},
            child: const Text(
              'TÌM HIỂU THÊM',
              style: TextStyle(
                color: AppColors.macaw,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------
/// Widget 3: Danh sách khóa học mới (Toán, Âm nhạc, Cờ vua)
/// ---------------------------------------------------------
class _NewCoursesList extends StatelessWidget {
  const _NewCoursesList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround, // Căn đều các icon
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCourseItem(
          icon: Icons.calculate, // Icon Toán
          label: 'Toán',
          color: AppColors.macaw,
        ),
        _buildCourseItem(
          icon: Icons.music_note, // Icon Âm nhạc
          label: 'Âm nhạc',
          color: AppColors.beetle,
        ),
        _buildCourseItem(
          icon: Icons.castle, // Icon Cờ vua (Rook/Castle)
          label: 'Cờ vua',
          color: AppColors.teal,
          isNew: true, // Badge Mới
        ),
      ],
    );
  }

  Widget _buildCourseItem({
    required IconData icon,
    required String label,
    required Color color,
    bool isNew = false,
  }) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Khối màu nền chứa icon
            Container(
              width: 60,
              height: 50,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    offset: const Offset(0, 4),
                  )
                ]
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            
            // Badge "MỚI" nếu có
            if (isNew)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardinal,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Text(
                    'MỚI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.bodyText,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}