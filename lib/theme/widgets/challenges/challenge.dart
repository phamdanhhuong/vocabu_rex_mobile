import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/speech_bubbles/speech_bubble.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác

/// Biểu thị vị trí của nhân vật so với bóng thoại.
enum CharacterPosition {
  left,
  right,
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

  /// Widget nhân vật (thường là một hình ảnh hoặc animation)
  final Widget character;

  /// Vị trí của nhân vật (trái hoặc phải).
  final CharacterPosition characterPosition;

  /// Trạng thái màu sắc của bóng thoại (neutral, defaults, correct, incorrect).
  final SpeechBubbleVariant variant;

  const CharacterChallenge({
    Key? key,
    this.statusText,
    required this.challengeTitle,
    required this.challengeContent,
    required this.character,
    this.characterPosition = CharacterPosition.left,
    this.variant = SpeechBubbleVariant.neutral,
  }) : super(key: key);

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
        child: challengeContent,
        variant: variant,
        tailDirection: tailDirection,
        tailOffset: 20.0, // Có thể tùy chỉnh nếu muốn
      ),
    );

    const spacer = SizedBox(width: 8);

    if (characterPosition == CharacterPosition.left) {
      return [character, spacer, speechBubble];
    } else {
      return [speechBubble, spacer, character];
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

