import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class AvatarDisplay extends StatelessWidget {
  final String? avatarString;
  final double radius;
  final String? frameUrl;
  final String? backgroundUrl;

  const AvatarDisplay({
    super.key,
    this.avatarString,
    this.radius = 40,
    this.frameUrl,
    this.backgroundUrl,
  });

  @override
  Widget build(BuildContext context) {
    Widget avatarWidget;

    if (avatarString == null || avatarString!.isEmpty) {
      avatarWidget = CircleAvatar(
        radius: radius,
        backgroundColor: Colors.transparent,
        child: Icon(Icons.person, size: radius * 1.25, color: AppColors.cardinal),
      );
    } else {
      try {
        final svgString = FluttermojiFunctions().decodeFluttermojifromString(avatarString!);
        avatarWidget = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
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
        avatarWidget = CircleAvatar(
          radius: radius,
          backgroundColor: Colors.transparent,
          child: Icon(Icons.person, size: radius * 1.25, color: AppColors.cardinal),
        );
      }
    }

    return SizedBox(
      width: radius * 2.5,
      height: radius * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          if (backgroundUrl != null)
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(backgroundUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.polar, // Default background
              ),
            ),
          
          // Avatar
          avatarWidget,

          // Frame
          if (frameUrl != null)
            Positioned.fill(
              child: Image.network(
                frameUrl!,
                fit: BoxFit.contain,
              ),
            ),
        ],
      ),
    );
  }
}
