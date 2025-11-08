import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/submit_response_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/exercise/ui/widgets/custom_button.dart';

typedef OnAccept = void Function();

class RewardSummary extends StatelessWidget {
  final SubmitResponseEntity response;
  final OnAccept onAccept;

  const RewardSummary({super.key, required this.response, required this.onAccept});

  Widget _infoCard(String label, Widget child, Color color) {
    return Container(
      width: 110,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.9), width: 3),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              )),
          SizedBox(height: 8),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resp = response;
    final title = resp.isLessonSuccessful
        ? (resp.isPerfect ? 'Hoàn hảo' : 'Hoàn thành')
        : 'Kết thúc';
    final subtitle = resp.message;

    return Scaffold(
      backgroundColor: AppColors.polar,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 20),
            SizedBox(
              height: 180,
              child: Center(
                child: Icon(
                  Icons.celebration,
                  size: 110,
                  color: AppColors.featherGreen,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                color: AppColors.featherGreen,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.macaw,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(height: 18),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoCard(
                    'TỔNG ĐIỂM KN',
                    Text('${resp.xpEarned}',
                        style: TextStyle(
                            color: Colors.orange,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Colors.orange,
                  ),
                  _infoCard(
                    'CỰC NHANH',
                    Text('${resp.correctExercises}/${resp.totalExercises}',
                        style: TextStyle(
                            color: Colors.lightBlue,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Colors.lightBlue,
                  ),
                  _infoCard(
                    'ĐỈNH CAO',
                    Text('${(resp.accuracy).toStringAsFixed(0)}%',
                        style: TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                    Colors.green,
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            if (resp.rewards.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Phần thưởng',
                        style: TextStyle(
                            color: AppColors.macaw,
                            fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final r = resp.rewards[index];
                          final type = r.type;
                          final amount = r.amount;
                          final title = r.title ?? '';
                          return Container(
                            width: 140,
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.03),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: AppColors.correctGreenLight,
                                  width: 1),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(type.toString().toUpperCase(),
                                    style: TextStyle(
                                        color: AppColors.macaw,
                                        fontSize: 12)),
                                SizedBox(height: 6),
                                Text('$amount',
                                    style: TextStyle(
                                        color: AppColors.featherGreen,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold)),
                                if (title.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(title,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: AppColors.macaw,
                                          fontSize: 12,
                                        )),
                                  ),
                              ],
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => SizedBox(width: 12),
                        itemCount: resp.rewards.length,
                      ),
                    ),
                  ],
                ),
              ),

            Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
              child: CustomButton(
                color: AppColors.macaw,
                onTap: onAccept,
                label: 'NHẬN KN',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
