import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/theme/widgets/challenges/challenge.dart';
import 'package:vocabu_rex_mobile/theme/widgets/hint_bubbles/app_hint_bubble.dart';
import 'package:vocabu_rex_mobile/theme/widgets/progress/app_progress_bar.dart';
import 'package:vocabu_rex_mobile/theme/widgets/word_tiles/app_word_tile.dart';

import '../colors.dart'; // Đảm bảo đường dẫn này chính xác

@Preview(name: 'All AppButton Variants')
Widget appButtonVariantsPreview() {
  return Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Variants', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              AppButton(
                label: 'Primary',
                onPressed: () {},
                variant: ButtonVariant.primary,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Secondary',
                onPressed: () {},
                variant: ButtonVariant.secondary,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Destructive',
                onPressed: () {},
                variant: ButtonVariant.destructive,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Highlight',
                onPressed: () {},
                variant: ButtonVariant.highlight,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Alternate',
                onPressed: () {},
                variant: ButtonVariant.alternate,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Outline',
                onPressed: () {},
                variant: ButtonVariant.outline,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Ghost',
                onPressed: () {},
                variant: ButtonVariant.ghost,
                width: 120,
              ),
            ],
          ),
          SizedBox(height: 24),
          Text('Sizes', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Row(
            children: [
              AppButton(
                label: 'Small',
                onPressed: () {},
                size: ButtonSize.small,
                width: 100,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Medium',
                onPressed: () {},
                size: ButtonSize.medium,
                width: 120,
              ),
              SizedBox(width: 12),
              AppButton(
                label: 'Large',
                onPressed: () {},
                size: ButtonSize.large,
                width: 140,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

@Preview(name: 'All Progress Variants')
Widget appProgressVariantsPreview() {
  return Material(
    color: Colors.white,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Progress Bars', style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          LessonProgressBar(progress: 1),
          SizedBox(height: 12),
          LessonProgressBar(progress: 0.25),
        ],
      ),
    ),
  );
}

@Preview(name: 'Word Tile States')
Widget wordTileStatesPreview() {
  return Material(
    color: Colors.white, // Nền trắng để xem
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Word Tiles Showcase',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColors.bodyText,
            ),
          ),
          const SizedBox(height: 24),

          // --- Hàng 1: Trạng thái Mặc định ---
          const Text(
            'Trạng thái: Default',
            style: TextStyle(color: AppColors.wolf),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0, // Khoảng cách ngang
            runSpacing: 8.0, // Khoảng cách dọc
            children: [
              WordTile(
                word: "Đây",
                onPressed: () {},
                state: WordTileState.defaults,
              ),
              WordTile(
                word: "là",
                onPressed: () {},
                state: WordTileState.defaults,
              ),
              WordTile(
                word: "trạng thái",
                onPressed: () {},
                state: WordTileState.defaults,
              ),
              WordTile(
                word: "mặc định",
                onPressed: () {},
                state: WordTileState.defaults,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // --- Hàng 2: Các trạng thái khác ---
          const Text(
            'Trạng thái: Tương tác',
            style: TextStyle(color: AppColors.wolf),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: [
              WordTile(
                word: "Đã chọn",
                onPressed: () {},
                state: WordTileState.selected,
              ),
              WordTile(
                word: "Đúng",
                onPressed: () {},
                state: WordTileState.correct,
              ),
              WordTile(
                word: "Sai",
                onPressed: () {},
                state: WordTileState.incorrect,
              ),
              WordTile(
                word: "Vô hiệu",
                onPressed: () {},
                state: WordTileState.disabled,
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

@Preview(name: 'Challenge Bubble Variants')
Widget HintBubbleVariantsPreview() {
  return Material(
    color: AppColors.background, // Dùng màu nền
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- 1. Mặc định (Xanh dương) ---
          HintBubble(
            title: 'Viết lại câu sau',
            variant: HintBubbleVariant.defaults,
            child: Text(
              'The quick brown fox jumps over the lazy dog.',
              style: TextStyle(
                fontFamily: 'DuolingoFeather',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.bodyText,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- 2. Đúng (Xanh lá) ---
          HintBubble(
            title: 'Tuyệt vời!',
            variant: HintBubbleVariant.correct,
            child: Text(
              'Good job!',
              style: TextStyle(
                fontFamily: 'DuolingoFeather',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.correctGreenDark,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- 3. Sai (Đỏ) ---
          HintBubble(
            title: 'Đáp án đúng:',
            variant: HintBubbleVariant.incorrect,
            child: Text(
              'The cat',
              style: TextStyle(
                fontFamily: 'DuolingoFeather',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.incorrectRedDark,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // --- 4. Trung tính (Trắng) ---
          HintBubble(
            title: 'Gợi ý',
            variant: HintBubbleVariant.neutral,
            child: Text(
              '"Dog" là một danh từ.',
              style: TextStyle(
                fontFamily: 'DuolingoFeather',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.bodyText,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

@Preview(name: 'Character Challenge Layout')
Widget characterChallengePreview() {
  // Placeholder đơn giản cho nhân vật
  final Widget characterPlaceholder = Container(
    width: 80,
    height: 100,
    decoration: BoxDecoration(
      color: AppColors.polar,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.swan),
    ),
    child: Center(
      child: Icon(
        Icons.person_outline, // Icon người
        color: AppColors.hare,
        size: 40,
      ),
    ),
  );

  return Material(
    color: AppColors.background,
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CharacterChallenge(
            statusText: 'Dạng mới',
            challengeTitle: 'Chọn nghĩa đúng',
            character: characterPlaceholder,
            challengeContent: Text(
              'the dog',
              style: TextStyle(
                fontFamily: 'DuolingoFeather',
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: AppColors.bodyText,
              ),
            ),
          ),
          const SizedBox(height: 32),
          CharacterChallenge(
            statusText: 'Bạn đã sai 3 câu',
            challengeTitle: 'Viết lại bằng tiếng Anh',
            character: characterPlaceholder,
            challengeContent: Row(
              children: [
                // Thêm nút audio
                Icon(Icons.volume_up, color: AppColors.macaw, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Con mèo',
                    style: TextStyle(
                      fontFamily: 'DuolingoFeather',
                      fontWeight: FontWeight.w700,
                      fontSize: 22,
                      color: AppColors.bodyText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
