import 'package:flutter/material.dart';
import '../../../theme/colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'lesson_header_tokens.dart';

/// Thanh trạng thái (stats bar) hiển thị ở đầu màn hình bài học.
///
/// Bao gồm Cờ, Streak, Gems, Coins, và Hearts.
class LessonHeader extends StatelessWidget {
  /// Đường dẫn đến ảnh lá cờ.
  final String flagAssetPath = 'assets/flags/english.png';
  // SỬA ĐỔI: Thêm đường dẫn cho các icon PNG
  final String streakIconPath = 'assets/icons/streak.png';
  final String gemIconPath = 'assets/icons/gem.png';
  final String coinIconPath = 'assets/icons/coin.png';
  final String heartIconPath = 'assets/icons/heart.png';

  /// Số hiển thị bên cạnh cờ (ví dụ: cấp độ).
  final int courseProgress;
  final int streakCount;
  final int gemCount;
  final int coinCount; // Thêm loại tiền tệ thứ 2 theo yêu cầu
  final int heartCount;

  const LessonHeader({
    Key? key,
    // required this.flagAssetPath,
    // SỬA ĐỔI: Thêm vào constructor
    required this.courseProgress,
    required this.streakCount,
    required this.gemCount,
    required this.coinCount,
    required this.heartCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use tokens instead of magic numbers

    return Padding(
      // Padding để thanh không dính sát vào cạnh màn hình
      padding: const EdgeInsets.symmetric(horizontal: LessonHeaderTokens.horizontalPadding, vertical: LessonHeaderTokens.verticalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1. Cờ (Course) - Đã dùng Image.asset
          _StatItem(
            icon: Image.asset(flagAssetPath, width: LessonHeaderTokens.flagSize, height: LessonHeaderTokens.flagSize),
            value: courseProgress.toString(),
            color: AppColors.bodyText, // Màu chữ xám đậm
          ),

          // 2. Streak
          _StatItem(
            // SỬA ĐỔI: Dùng Image.asset
            icon: Image.asset(streakIconPath,
                width: LessonHeaderTokens.iconSize, height: LessonHeaderTokens.iconSize),
            value: streakCount.toString(),
            color: AppColors.hare, // Màu xám nhạt
          ),

          // 3. Gems (Blue)
          _StatItem(
            // SỬA ĐỔI: Dùng Image.asset
            icon:
                Image.asset(gemIconPath, width: LessonHeaderTokens.iconSize, height: LessonHeaderTokens.iconSize),
            value: gemCount.toString(),
            color: AppColors.macaw, // Màu xanh dương
          ),

          // 4. Coins (Yellow) - Thêm mới
          _StatItem(
            // SỬA ĐỔI: Dùng Image.asset
            icon:
                Image.asset(coinIconPath, width: LessonHeaderTokens.iconSize, height: LessonHeaderTokens.iconSize),
            value: coinCount.toString(),
            color: AppColors.bee, // Màu vàng
          ),

          // 5. Hearts
          _StatItem(
            // SỬA ĐỔI: Dùng Image.asset
            icon: Image.asset(heartIconPath,
                width: LessonHeaderTokens.iconSize, height: LessonHeaderTokens.iconSize),
            value: heartCount.toString(),
            color: AppColors.cardinal, // Màu đỏ
          ),
        ],
      ),
    );
  }
}

/// Một widget con riêng tư để hiển thị Icon + Giá trị
class _StatItem extends StatelessWidget {
  final Widget icon;
  final String value;
  final Color color;

  const _StatItem({
    Key? key,
    required this.icon,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min, // Co lại vừa đủ nội dung
      children: [
        icon,
        const SizedBox(width: LessonHeaderTokens.iconTextSpacing),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: LessonHeaderTokens.valueFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: LessonHeaderTokens.valueFontFamily, // Giả sử bạn có font này
          ),
        ),
      ],
    );
  }
}

