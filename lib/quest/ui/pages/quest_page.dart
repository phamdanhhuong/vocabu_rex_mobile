import 'package:flutter/material.dart';
import 'dart:math'; // Cần cho icon
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../widgets/quest_tokens.dart';

// --- Định nghĩa màu sắc mới dựa trên ảnh (Quests Screen) ---
const Color _questPurpleLight = Color(0xFF9044DF);
const Color _questPurpleDark = Color(0xFF532488);
const Color _questOrange = Color(0xFFF9A800);
const Color _questGrayText = Color(0xFF777777); // Giống wolf
const Color _questGrayBorder = Color(0xFFE5E5E5); // Giống swan
const Color _questGrayBackground = Color(0xFFF7F7F7); // Giống polar
const Color _questPurpleProgress = Color(0xFF7032B3);

/// Giao diện màn hình "Nhiệm vụ" (Quests).
class QuestsPage extends StatelessWidget {
  const QuestsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _questGrayBackground, // Nền xám nhạt
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Banner màu tím trên cùng
            const _TopBanner(),

            // 2. Thẻ Nhiệm vụ Bạn bè
            const _FriendsQuestCard(),

            // 3. Thẻ Nhiệm vụ Hàng ngày
            const _DailyQuestsSection(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// --- 1. TOP BANNER (TÍM) ---
class _TopBanner extends StatelessWidget {
  const _TopBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
  // ensure banner is tall enough to hold the right-side artwork
  constraints: const BoxConstraints(minHeight: kQuestTopBannerMinHeight),
  padding: const EdgeInsets.all(kQuestTopBannerPadding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_questPurpleLight, _questPurpleDark],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Nội dung text
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min, // ← Prevent overflow
                children: [
                  Text(
                    'Nhận thưởng khi\nxong nhiệm vụ!',
                    style: TextStyle(
                      color: AppColors.snow,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.2, // ← Reduce line height
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h), // ← Reduced from 8
                  Flexible( // ← Make flexible to prevent overflow
                    child: Text(
                      'Hôm nay bạn đã hoàn\nthành 1 trên tổng số 3\nnhiệm vụ.',
                      style: TextStyle(
                        color: AppColors.snow,
                        fontSize: 16.sp,
                        height: 1.3, // ← Reduce line height
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Ảnh Duo và Rương (dùng placeholder)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Placeholder cho Rương
              Container(
                width: kQuestChestSize,
                height: kQuestChestSize,
                decoration: BoxDecoration(
                  color: _questOrange.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2,
                    color: AppColors.snow, size: 30),
              ),
              const SizedBox(width: 8),
              // Placeholder cho Duo
              Container(
                width: kQuestDuoSize,
                height: kQuestDuoSize,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.adb, color: AppColors.snow, size: 50),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- 2. THẺ NHIỆM VỤ BẠN BÈ ---
class _FriendsQuestCard extends StatelessWidget {
  const _FriendsQuestCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(kQuestTopBannerPadding),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(kQuestCardBorderRadius),
        border: Border.all(color: _questGrayBorder, width: kQuestCardBorderWidth),
      ),
      child: Column(
        children: [
          // Header (Nhiệm vụ bạn bè + 3 ngày)
          _SectionHeader(title: 'Nhiệm vụ bạn bè', time: '3 NGÀY'),
          const SizedBox(height: 16),
          // Ảnh (silhouette + trứng)
          _buildFriendsImages(),
          const SizedBox(height: 16),
          // Tiêu đề (Đạt được 200 KN)
          const Text(
            'Đạt được 200 KN',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText),
          ),
          const SizedBox(height: 8),
          // Thanh tiến độ chung
          _QuestProgressBar(
            current: 60,
            total: 200,
            color: _questPurpleProgress,
            showValues: true,
          ),
          const SizedBox(height: 16),
          // Tiến độ cá nhân
          _buildFriendProgress('Bạn', 25, _questPurpleProgress),
          _buildFriendProgress('ok ok', 35, AppColors.wolf),
          const SizedBox(height: 16),
          // 2 Nút
          Row(
            children: [
              Expanded(
                child: _QuestButton(
                  text: 'NHẮC NHẸ',
                  icon: Icons.waving_hand, // Placeholder
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _QuestButton(
                  text: 'TẶNG QUÀ',
                  icon: Icons.card_giftcard, // Placeholder
                  onPressed: () {},
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // Widget con cho ảnh bạn bè
  Widget _buildFriendsImages() {
        return Stack(
      alignment: Alignment.center,
      children: [
        // Thanh vàng (placeholder)
        Container(
          height: kQuestFriendsImageHeight,
          margin: const EdgeInsets.symmetric(horizontal: 60),
          decoration: BoxDecoration(
            color: _questOrange.withOpacity(0.3),
            border: Border.all(color: _questOrange, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(Icons.person, size: kQuestFriendIconSize, color: Colors.grey[400]),
            Container(
              width: kQuestFriendIconSize,
              height: kQuestFriendIconSize,
              decoration: BoxDecoration(
                color: AppColors.primaryVariant.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.egg, color: AppColors.primary, size: 40),
            ),
            Icon(Icons.person, size: kQuestFriendIconSize, color: Colors.grey[800]),
          ],
        ),
      ],
    );
  }

  // Widget con cho tiến độ từng người
  Widget _buildFriendProgress(String name, int value, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(Icons.circle, color: dotColor, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText),
            ),
          ),
          Text(
            '$value KN',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.bodyText),
          ),
        ],
      ),
    );
  }
}

// --- 3. KHỐI NHIỆM VỤ HÀNG NGÀY ---
class _DailyQuestsSection extends StatelessWidget {
  const _DailyQuestsSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.snow,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: _questGrayBorder, width: 2.0),
      ),
      child: Column(
        children: [
          _SectionHeader(title: 'Nhiệm vụ hằng ngày', time: '11 TIẾNG'),
          const SizedBox(height: 16),
          _DailyQuestCard(
            title: 'Streak mở màn',
            current: 1,
            total: 1,
            chestIconPath: 'assets/icons/chest_gold_close.png', // Placeholder
          ),
          const Divider(color: _questGrayBorder, height: 24),
          _DailyQuestCard(
            title: 'Hoàn thành 1 cấp độ',
            current: 0,
            total: 1,
            chestIconPath: 'assets/icons/chest_silver_close.png', // Placeholder
          ),
          const Divider(color: _questGrayBorder, height: 24),
          _DailyQuestCard(
            title: 'Hoàn thành 3 bài học đạt độ chính xác từ 80% trở lên',
            current: 1,
            total: 3,
            chestIconPath: 'assets/icons/chest_bronze_close.png', // Placeholder
          ),
        ],
      ),
    );
  }
}

// --- WIDGET CON (HELPER) ---

// Header cho mỗi thẻ (ví dụ: "Nhiệm vụ bạn bè")
class _SectionHeader extends StatelessWidget {
  final String title;
  final String time;

  const _SectionHeader({Key? key, required this.title, required this.time})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible( // ← Make title flexible
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 8.w), // ← Add spacing
        Row(
          mainAxisSize: MainAxisSize.min, // ← Only take needed space
          children: [
            Icon(Icons.timer, color: _questOrange, size: 20.sp),
            SizedBox(width: 4.w),
            Text(
              time,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: _questOrange,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// Thẻ nhiệm vụ hàng ngày
class _DailyQuestCard extends StatelessWidget {
  final String title;
  final int current;
  final int total;
  final String chestIconPath; // Placeholder

  const _DailyQuestCard({
    Key? key,
    required this.title,
    required this.current,
    required this.total,
    required this.chestIconPath,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.bodyText),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuestProgressBar(
                current: current,
                total: total,
                color: _questPurpleProgress,
                showValues: true,
              ),
            ),
            const SizedBox(width: 12),
            // Placeholder cho Rương
            Image.asset(chestIconPath, width: 40, height: 40),
          ],
        ),
      ],
    );
  }
}

// Thanh tiến độ tùy chỉnh (dùng trong cả 2 loại thẻ)
class _QuestProgressBar extends StatelessWidget {
  final int current;
  final int total;
  final Color color;
  final bool showValues;

  const _QuestProgressBar({
    Key? key,
    required this.current,
    required this.total,
    required this.color,
    this.showValues = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double progress = (total == 0) ? 0 : (current / total);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Nền
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: _questGrayBorder,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Tiến độ
            Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: constraints.maxWidth * progress,
                height: 20,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            // Text (ví dụ: 60 / 200)
            if (showValues)
              Text(
                '$current / $total',
                style: const TextStyle(
                  color: AppColors.snow,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        );
      }
    );
  }
}

// Nút tùy chỉnh (Nhắc nhẹ, Tặng quà)
class _QuestButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _QuestButton({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.snow,
      // Provide shape only (don't pass borderRadius + shape together)
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(color: _questGrayBorder, width: 2.0),
      ),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: _questGrayText, size: 20),
              const SizedBox(width: 8),
              Text(
                text,
                style: const TextStyle(
                  color: _questGrayText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
