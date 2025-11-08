import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/duolingo_character.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/main_duo_character.dart';
import 'package:vocabu_rex_mobile/auth/ui/widgets/phone_with_coins.dart';

class CharacterIllustration extends StatelessWidget {
  const CharacterIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            // Main green mascot (Duo) - larger and centered
            Positioned(
              bottom: 60.h,
              right: 60.w,
              child: const MainDuoCharacter(),
            ),

            // Floating characters around
            Positioned(
              top: 20.h,
              left: 20.w,
              child: DuolingoCharacter(
                backgroundColor: Colors.pink,
                size: 80.w,
                eyeColor: Colors.black,
                skinColor: Colors.pink[200]!,
              ),
            ),
            Positioned(
              top: 40.h,
              right: 10.w,
              child: DuolingoCharacter(
                backgroundColor: AppColors.fox,
                size: 70.w,
                eyeColor: Colors.brown,
                skinColor: Colors.orange[200]!,
              ),
            ),
            Positioned(
              bottom: 120.h,
              left: 30.w,
              child: DuolingoCharacter(
                backgroundColor: AppColors.macaw,
                size: 75.w,
                eyeColor: Colors.white,
                skinColor: Colors.blue[200]!,
              ),
            ),
            Positioned(
              top: 80.h,
              left: 120.w,
              child: DuolingoCharacter(
                backgroundColor: AppColors.bee,
                size: 65.w,
                eyeColor: Colors.black,
                skinColor: Colors.yellow[200]!,
              ),
            ),
            Positioned(
              bottom: 140.h,
              right: 20.w,
              child: DuolingoCharacter(
                backgroundColor: AppColors.beetle,
                size: 70.w,
                eyeColor: Colors.white,
                skinColor: Colors.purple[200]!,
              ),
            ),

            // Phone with coins
            Positioned(
              bottom: 20.h,
              left: 50.w,
              child: const PhoneWithCoins(),
            ),
          ],
        ),
      ),
    );
  }
}