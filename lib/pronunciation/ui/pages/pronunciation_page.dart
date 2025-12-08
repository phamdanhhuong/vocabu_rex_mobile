import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/widgets/buttons/app_button.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/widgets/pronunciation_tile.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/dot_loading_indicator.dart';
import '../blocs/pronunciation_bloc.dart';
import '../../domain/entities/entities.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/insufficient_energy_dialog.dart';

// --- Giao diện Màn hình ---

/// Giao diện màn hình "Học phát âm", dựa trên ảnh chụp màn hình.
class PronunciationPage extends StatefulWidget {
  const PronunciationPage({Key? key}) : super(key: key);

  @override
  State<PronunciationPage> createState() => _PronunciationPageState();
}

class _PronunciationPageState extends State<PronunciationPage> {
  @override
  void initState() {
    super.initState();
    context.read<PronunciationBloc>().add(LoadPronunciationProgress());
    context.read<FabCubit>().hide();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.snow, // Nền trắng
      child: BlocBuilder<PronunciationBloc, PronunciationState>(
        builder: (context, state) {
          if (state is PronunciationLoading) {
            return const Center(child: DotLoadingIndicator(color: AppColors.macaw, size: 16));
          }

          if (state is PronunciationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Có lỗi xảy ra: ${state.message}',
                    style: const TextStyle(
                      color: AppColors.bodyText,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PronunciationBloc>().add(
                        RefreshPronunciationProgress(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (state is PronunciationLoaded) {
            return _buildLoadedContent(context, state.progress);
          }

          // PronunciationInitial
          return _buildLoadedContent(context, null);
        },
      ),
    );
  }

  Widget _buildLoadedContent(
    BuildContext context,
    PronunciationProgress? progress,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 1. Header (Tiêu đề + Nút Bắt đầu)
          _buildHeader(context, progress),

          // 2. Tiêu đề "Nguyên âm"
          _buildSectionTitle('Nguyên âm'),

          // 3. Lưới Nguyên âm
          _buildVowelGrid(context, progress?.vowelProgress ?? []),

          // 4. Tiêu đề "Phụ âm"
          _buildSectionTitle('Phụ âm'),

          // 5. Lưới Phụ âm
          _buildConsonantGrid(context, progress?.consonantProgress ?? []),

          // Thêm padding dưới cùng
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Widget con cho Header
  Widget _buildHeader(BuildContext context, PronunciationProgress? progress) {
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
          if (progress != null) ...[
            const SizedBox(height: 16),
            Text(
              'Tiến trình: ${progress.overallProgressPercentage}%',
              style: const TextStyle(
                color: AppColors.bodyText,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                fontFamily: 'DuolingoFeather',
              ),
            ),
            Text(
              '${progress.completedVowels}/${progress.totalVowels} nguyên âm • ${progress.completedConsonants}/${progress.totalConsonants} phụ âm',
              style: const TextStyle(
                color: AppColors.wolf,
                fontSize: 14,
                fontFamily: 'DuolingoFeather',
              ),
            ),
          ],
          const SizedBox(height: 24),
          // Dùng AppButton đã tạo
          AppButton(
            label: 'BẮT ĐẦU +10 KN',
            onPressed: () {
              // Check energy before starting pronunciation lesson
              final energyState = context.read<EnergyBloc>().state;
              int currentEnergy = 0;
              
              if (energyState is EnergyLoaded) {
                currentEnergy = energyState.response.currentEnergy;
              }
              
              // Require at least 1 energy to start
              if (currentEnergy < 1) {
                InsufficientEnergyDialog.show(
                  context,
                  currentEnergy: currentEnergy,
                  requiredEnergy: 1,
                );
                return;
              }

              Navigator.pushNamed(
                context,
                '/exercise',
                arguments: {
                  'lessonId': "",
                  'lessonTitle': "",
                  'isPronun': true,
                },
              );
            },
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

  // Widget con cho Lưới nguyên âm
  Widget _buildVowelGrid(BuildContext context, List<VowelProgress> vowels) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          const int columns = 3;
          const double spacing = 12.0;
          final double totalSpacing = spacing * (columns - 1);
          final double tileWidth = (totalWidth - totalSpacing) / columns;

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: vowels.map((vowel) {
              return PronunciationTile(
                symbol: vowel.symbol,
                example: vowel.name,
                width: tileWidth,
                progress: vowel.progressPercentage / 100.0,
                onPressed: () {
                  // TODO: Xử lý khi nhấn vào nguyên âm
                  debugPrint('Clicked vowel: ${vowel.symbol}');
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // Widget con cho Lưới phụ âm
  Widget _buildConsonantGrid(
    BuildContext context,
    List<ConsonantProgress> consonants,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double totalWidth = constraints.maxWidth;
          const int columns = 3;
          const double spacing = 12.0;
          final double totalSpacing = spacing * (columns - 1);
          final double tileWidth = (totalWidth - totalSpacing) / columns;

          return Wrap(
            alignment: WrapAlignment.center,
            spacing: spacing,
            runSpacing: spacing,
            children: consonants.map((consonant) {
              return PronunciationTile(
                symbol: consonant.symbol,
                example: consonant.name,
                width: tileWidth,
                progress: consonant.progressPercentage / 100.0,
                onPressed: () {
                  // TODO: Xử lý khi nhấn vào phụ âm
                  debugPrint('Clicked consonant: ${consonant.symbol}');
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
