import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác

/// Biểu thị vị trí của nhân vật so với bóng thoại.
enum CharacterPosition { left, right }

/// Quản lý trạng thái Mascot toàn cục cho một bài học
class MascotManager {
  static int currentMascotId = 1;
  static const List<int> availableIds = [1, 2, 3, 5, 6, 7, 8, 9, 10];
}

/// Widget quản lý Mascot tự động theo trạng thái
class MascotAvatar extends StatefulWidget {
  final SpeechBubbleVariant variant;
  const MascotAvatar({super.key, required this.variant});

  @override
  State<MascotAvatar> createState() => _MascotAvatarState();
}

class _MascotAvatarState extends State<MascotAvatar> {
  late int mascotId;

  @override
  void initState() {
    super.initState();
    // Lấy ID từ MascotManager đã được set trước trong ExercisePage
    mascotId = MascotManager.currentMascotId;
  }

  @override
  Widget build(BuildContext context) {
    String suffix = 'I';
    if (widget.variant == SpeechBubbleVariant.correct) {
      suffix = 'R';
    } else if (widget.variant == SpeechBubbleVariant.incorrect) {
      suffix = 'F';
    }

    final assetPath =
        'assets/animations/${mascotId}_${suffix}_transparent.webp';

    return Image.asset(
      assetPath,
      width: 100.w, // Tăng kích thước so với 80 cũ
      height: 100.h,
      fit: BoxFit.contain,
      cacheWidth: 300, // Tối ưu: Giới hạn độ phân giải khi giải mã

      errorBuilder: (context, error, stackTrace) {
        // Fallback nếu file chưa tồn tại
        return Container(
          width: 80.w,
          height: 80.h,
          decoration: BoxDecoration(
            color: AppColors.macaw.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.pets, size: 40.sp, color: AppColors.macaw),
        );
      },
    );
  }
}

/// Một widget bố cục đề bài hoàn chỉnh bao gồm:
/// 1. Một chip trạng thái (ví dụ: "Dạng mới")
/// 2. Một tiêu đề bài tập (ví dụ: "Chọn nghĩa đúng")
/// 3. Một hàng (Row) chứa nhân vật và bóng thoại.
class CharacterChallenge extends StatelessWidget {
  /// Văn bản trạng thái tùy chọn (ví dụ: "Dạng mới", "Các câu sai")
  final String? statusText;

  /// Tiêu đề chính của bài tập (ví dụ: "Chọn nghĩa đúng")
  final String challengeTitle;

  /// Nội dung của đề bài (sẽ được đặt bên trong bóng thoại)
  final Widget challengeContent;

  /// Widget nhân vật (nếu truyền vào sẽ dùng thay thế mascot mặc định)
  final Widget? character;

  /// Vị trí của nhân vật (trái hoặc phải).
  final CharacterPosition characterPosition;

  /// Trạng thái màu sắc của bóng thoại (neutral, defaults, correct, incorrect).
  final SpeechBubbleVariant variant;

  const CharacterChallenge({
    super.key,
    this.statusText,
    required this.challengeTitle,
    required this.challengeContent,
    this.character,
    this.characterPosition = CharacterPosition.left,
    this.variant = SpeechBubbleVariant.neutral,
  });

  // --- Các phương thức Build con ---

  /// Xây dựng chip trạng thái ở trên cùng
  Widget _buildStatusChip(BuildContext context) {
    if (statusText == null || statusText!.isEmpty) {
      return const SizedBox.shrink(); // Không hiển thị gì nếu không có text
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.polar, // Màu xám rất nhạt
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        statusText!.toUpperCase(),
        style: TextStyle(
          color: AppColors.hare, // Màu xám trung bình
          fontWeight: FontWeight.bold,
          fontSize: 12,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Xây dựng tiêu đề bài tập
  Widget _buildChallengeTitle(BuildContext context) {
    return Text(
      challengeTitle,
      style: TextStyle(
        fontFamily: 'DuolingoFeather',
        fontWeight: FontWeight.w700,
        fontSize: 22,
        color: AppColors.bodyText, // Màu chữ xám đậm
      ),
    );
  }

  /// Xây dựng bố cục hàng (Row) dựa trên vị trí nhân vật
  List<Widget> _buildLayoutChildren() {
    final tailDirection = (characterPosition == CharacterPosition.left)
        ? SpeechBubbleTailDirection.left
        : SpeechBubbleTailDirection.right;

    final speechBubble = Expanded(
      child: SpeechBubble(
        variant: variant,
        tailDirection: tailDirection,
        tailOffset: 20.0,
        showShadow: false,
        child: challengeContent, // Tắt shadow
      ),
    );

    const spacer = SizedBox(width: 8);

    // Nếu không truyền character, dùng MascotAvatar tự động
    final activeCharacter = character ?? MascotAvatar(variant: variant);

    if (characterPosition == CharacterPosition.left) {
      return [activeCharacter, spacer, speechBubble];
    } else {
      return [speechBubble, spacer, activeCharacter];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
      children: [
        _buildStatusChip(context),
        const SizedBox(height: 8),
        _buildChallengeTitle(context),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Căn nhân vật lên trên
          children: _buildLayoutChildren(), // SỬ DỤNG HÀM MỚI
        ),
      ],
    );
  }
}
