import 'package:flutter/material.dart';
// dart:math no longer needed here (moved to PronunciationTile)
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/widgets/pronunciation_tile.dart';
// Giả sử AppButton của bạn ở đây

// --- Dữ liệu giả (Mock Data) ---

// Một class đơn giản để chứa dữ liệu cho mỗi ô
class PronunciationTileData {
  final String symbol; // Ký hiệu phiên âm, ví dụ: 'æ'
  final String example; // Từ ví dụ, ví dụ: 'cat'

  const PronunciationTileData(this.symbol, this.example);
}

// Dữ liệu giả cho Nguyên âm
const List<PronunciationTileData> vowelData = [
  PronunciationTileData('ɑ', 'hot'),
  PronunciationTileData('æ', 'cat'),
  PronunciationTileData('ʌ', 'but'),
  PronunciationTileData('ɛ', 'bed'),
  PronunciationTileData('eɪ', 'say'),
  PronunciationTileData('ə', 'bird'),
  PronunciationTileData('ɪ', 'ship'),
  PronunciationTileData('i', 'sheep'),
  PronunciationTileData('ə', 'about'),
  PronunciationTileData('oʊ', 'boat'),
  PronunciationTileData('ʊ', 'foot'),
  PronunciationTileData('u', 'food'),
  PronunciationTileData('aʊ', 'cow'),
  PronunciationTileData('aɪ', 'time'),
  PronunciationTileData('ɔɪ', 'boy'),
];

// Dữ liệu giả cho Phụ âm
const List<PronunciationTileData> consonantData = [
  PronunciationTileData('b', 'book'),
  PronunciationTileData('tʃ', 'chair'),
  PronunciationTileData('d', 'day'),
  PronunciationTileData('f', 'fish'),
  PronunciationTileData('g', 'go'),
  PronunciationTileData('h', 'home'),
  PronunciationTileData('dʒ', 'job'),
  PronunciationTileData('k', 'key'),
  PronunciationTileData('l', 'lion'),
  PronunciationTileData('m', 'moon'),
  PronunciationTileData('n', 'nose'),
  PronunciationTileData('ŋ', 'sing'),
  PronunciationTileData('p', 'pig'),
  PronunciationTileData('r', 'red'),
  PronunciationTileData('s', 'see'),
  PronunciationTileData('ʒ', 'measure'),
  PronunciationTileData('ʃ', 'shoe'),
  PronunciationTileData('t', 'time'),
  PronunciationTileData('ð', 'then'),
  PronunciationTileData('θ', 'think'),
  PronunciationTileData('v', 'very'),
  PronunciationTileData('w', 'water'),
  PronunciationTileData('j', 'you'),
  PronunciationTileData('z', 'zoo'),
];

// --- Giao diện Màn hình ---

/// Giao diện màn hình "Học phát âm", dựa trên ảnh chụp màn hình.
class PronunciationPage extends StatelessWidget {
  const PronunciationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow, // Nền trắng
      child: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Header (Tiêu đề + Nút Bắt đầu)
            _buildHeader(context),

            // 2. Tiêu đề "Nguyên âm"
            _buildSectionTitle('Nguyên âm'),

            // 3. Lưới Nguyên âm
            _buildTileGrid(vowelData),

            // 4. Tiêu đề "Phụ âm"
            _buildSectionTitle('Phụ âm'),

            // 5. Lưới Phụ âm
            _buildTileGrid(consonantData),

            // Thêm padding dưới cùng
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // Widget con cho Header
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16), // Khoảng đệm trên cùng
          const Text(
            'Cùng học phát âm tiếng Anh!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.bodyText,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'DuolingoFeather',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tập nghe và học phát âm các âm trong tiếng Anh',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.wolf, // Xám nhạt
              fontSize: 16,
              fontFamily: 'DuolingoFeather',
            ),
          ),
          const SizedBox(height: 24),
          // Dùng AppButton đã tạo
          AppButton(
            label: 'BẮT ĐẦU +10 KN',
            onPressed: () {},
            // Giả sử 'alternate' là biến thể màu xanh 'macaw'
            variant: ButtonVariant.alternate,
            // Make the button 70% of the screen width
            width: MediaQuery.of(context).size.width * 0.7,
            size: ButtonSize.medium,
          ),
        ],
      ),
    );
  }

  // Widget con cho Tiêu đề (Nguyên âm, Phụ âm)
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.swan, thickness: 1)),
          const SizedBox(width: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.bodyText,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'DuolingoFeather',
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider(color: AppColors.swan, thickness: 1)),
        ],
      ),
    );
  }

  // Widget con cho Lưới các ô
  Widget _buildTileGrid(List<PronunciationTileData> tiles) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(builder: (context, constraints) {
        // Calculate tile width to fit 3 columns responsively within available width
        final double totalWidth = constraints.maxWidth;
        const int columns = 3;
        const double spacing = 12.0;
        final double totalSpacing = spacing * (columns - 1);
        final double tileWidth = (totalWidth - totalSpacing) / columns;

        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: tiles.map((tile) {
            return PronunciationTile(
              symbol: tile.symbol,
              example: tile.example,
              width: tileWidth,
              onPressed: () {
                // TODO: Xử lý khi nhấn vào 1 âm
              },
            );
          }).toList(),
        );
      }),
    );
  }
}
