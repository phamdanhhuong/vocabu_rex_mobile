import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class AvatarDisplay extends StatelessWidget {
  final String? avatarString;
  final double radius;

  const AvatarDisplay({super.key, this.avatarString, this.radius = 40});

  @override
  Widget build(BuildContext context) {
    if (avatarString == null || avatarString!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.cardinal.withOpacity(0.2),
        child: Icon(Icons.person, size: radius * 1.25, color: AppColors.cardinal),
      );
    }

    try {
      final svgString = FluttermojiFunctions().decodeFluttermojifromString(avatarString!);
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.polar,
        child: ClipOval(
          child: SvgPicture.string(
            svgString,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
          ),
        ),
      );
    } catch (e) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.cardinal.withOpacity(0.2),
        child: Icon(Icons.person, size: radius * 1.25, color: AppColors.cardinal),
      );
    }
  }
}
