import 'package:flutter/widget_previews.dart';
import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
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
