import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

class RewardCollectPage extends StatelessWidget {
  final SubmitResponseEntity response;
  final String? imageAsset; // optional asset path or network URL

  const RewardCollectPage({super.key, required this.response, this.imageAsset});

  @override
  Widget build(BuildContext context) {
    // Determine main amount to show: prefer gems in rewards, otherwise show xpEarned
    int displayAmount = response.xpEarned;
    String displayLabel = 'KN';
    if (response.rewards.isNotEmpty) {
      final gem = response.rewards.firstWhere(
        (r) => (r.type == 'gems' || r.type == 'gem' || r.type == 'xp'),
        orElse: () => response.rewards.first,
      );
      displayAmount = gem.amount;
      displayLabel = gem.type.toUpperCase();
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 24),
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.diamond, color: Colors.lightBlue, size: 20),
                    SizedBox(width: 6),
                    Text('${displayAmount}',
                        style: TextStyle(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Image or placeholder
                    if (imageAsset != null)
                      Image.asset(imageAsset!, width: 180, height: 180)
                    else
                      Icon(Icons.card_giftcard,
                          size: 160, color: AppColors.primaryBlue),
                    SizedBox(height: 18),
                    Text('$displayLabel',
                        style: TextStyle(
                            color: AppColors.textBlue,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Text('Bạn vừa nhận được',
                        style: TextStyle(color: AppColors.textBlue)),
                    SizedBox(height: 6),
                    Text('$displayAmount',
                        style: TextStyle(
                            color: AppColors.primaryGreen,
                            fontSize: 34,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
              child: CustomButton(
                color: AppColors.primaryBlue,
                onTap: () {
                  Navigator.of(context).pop(true);
                },
                label: 'TIẾP TỤC',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
