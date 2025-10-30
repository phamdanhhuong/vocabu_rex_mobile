import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

// --- Định nghĩa màu sắc (nếu cần) ---
const Color _cardBorderColor = Color(0xFFE5E5E5); // Giống swan
const Color _grayText = Color(0xFF777777); // Giống wolf
const Color _pageBackground = Color(0xFFFFFFFF);

/// Giao diện màn hình "Xem tất cả thành tích".
class AllAchievementsView extends StatelessWidget {
  const AllAchievementsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dữ liệu giả
    final List<Map<String, String>> records = [
      {'img': 'assets/images/badge_streak.png', 'level': '2', 'title': 'Kỷ lục Streak', 'date': '21 thg 10, 2025'},
      {'img': 'assets/images/badge_xp.png', 'level': '90', 'title': 'Kỷ lục KN', 'date': '17 thg 10, 2025'},
      {'img': 'assets/images/badge_lesson.png', 'level': '8', 'title': 'Bài học', 'date': '8 thg 10, 2025'},
    ];

    final List<Map<String, dynamic>> awards = [
      {'img': 'assets/images/badge_fixer.png', 'level': '10', 'title': 'Thợ sửa lỗi sai', 'progress': '1 trên 10', 'isLocked': false},
      {'img': 'assets/images/badge_legend.png', 'level': '100', 'title': 'Vị thần KN', 'progress': '1 trên 10', 'isLocked': false},
      {'img': 'assets/images/badge_night.png', 'level': '3', 'title': 'Thợ săn đêm', 'progress': '1 trên 10', 'isLocked': false},
      {'img': 'assets/images/badge_archer.png', 'level': '1', 'title': 'Thiện xạ', 'progress': '1 trên 5', 'isLocked': false},
      {'img': 'assets/images/badge_friend.png', 'level': '5', 'title': 'Người tiếp lửa', 'progress': 'Chưa có', 'isLocked': true},
      {'img': 'assets/images/badge_social.png', 'level': '1', 'title': 'Hoa hậu thân thiện', 'progress': 'Chưa có', 'isLocked': true},
    ];

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _pageBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _grayText, size: 28),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Thành tích',
          style: TextStyle(
            color: AppColors.bodyText,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Kỷ lục cá nhân
            _buildSectionHeader('Kỷ lục cá nhân'),
            _buildRecordsList(records),

            const SizedBox(height: 32),

            // 2. Giải thưởng
            _buildSectionHeader('Giải thưởng'),
            _buildAwardsGrid(awards),
          ],
        ),
      ),
    );
  }

  // --- WIDGET CON (HELPER) ---

  /// Tiêu đề cho mỗi mục (ví dụ: "Kỷ lục cá nhân")
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.bodyText,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Danh sách cuộn ngang cho "Kỷ lục cá nhân"
  Widget _buildRecordsList(List<Map<String, String>> records) {
    return Container(
      height: 200, // Chiều cao cố định cho danh sách ngang
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return _RecordCard(
            imagePath: record['img']!,
            level: record['level']!,
            title: record['title']!,
            date: record['date']!,
          );
        },
      ),
    );
  }

  /// Lưới 3 cột cho "Giải thưởng"
  Widget _buildAwardsGrid(List<Map<String, dynamic>> awards) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 cột
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75, // Tỷ lệ (rộng/cao) của mỗi ô
      ),
      itemCount: awards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Tắt cuộn của GridView
      itemBuilder: (context, index) {
        final award = awards[index];
        return _AchievementTile(
          imagePath: award['img']!,
          level: award['level']!,
          title: award['title']!,
          progress: award['progress']!,
          isLocked: award['isLocked'],
        );
      },
    );
  }
}

/// Thẻ lớn trong "Kỷ lục cá nhân"
class _RecordCard extends StatelessWidget {
  final String imagePath;
  final String level;
  final String title;
  final String date;

  const _RecordCard({
    Key? key,
    required this.imagePath,
    required this.level,
    required this.title,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160, // Chiều rộng cố định
      margin: const EdgeInsets.only(right: 12.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: _pageBackground,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _cardBorderColor, width: 2.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh và Level (dùng Stack)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Placeholder ảnh
                Image.asset(imagePath, fit: BoxFit.contain),
                // Level
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Text(
                    level,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(blurRadius: 2.0, color: Colors.black54)
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tiêu đề
          Text(
            title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Ngày
          Text(
            date,
            style: const TextStyle(fontSize: 14, color: _grayText),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Ô nhỏ trong "Giải thưởng"
class _AchievementTile extends StatelessWidget {
  final String imagePath;
  final String level;
  final String title;
  final String progress;
  final bool isLocked;

  const _AchievementTile({
    Key? key,
    required this.imagePath,
    required this.level,
    required this.title,
    required this.progress,
    this.isLocked = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Làm mờ nếu bị khóa
    final Widget image = Opacity(
      opacity: isLocked ? 0.3 : 1.0,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(imagePath, fit: BoxFit.contain),
          if (!isLocked) // Chỉ hiển thị level nếu không bị khóa
            Positioned(
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  level,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(child: image),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isLocked ? _grayText : AppColors.bodyText,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          progress,
          style: const TextStyle(fontSize: 14, color: _grayText),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
