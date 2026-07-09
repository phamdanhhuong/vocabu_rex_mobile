import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/shop/ui/blocs/shop_bloc.dart';

class AvatarDisplay extends StatelessWidget {
  final String? avatarString;
  final double radius;
  final String? frameId;
  final String? backgroundId;

  const AvatarDisplay({
    super.key,
    this.avatarString,
    this.radius = 40,
    this.frameId,
    this.backgroundId,
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

    String? resolvedFrameUrl;
    String? resolvedBgUrl;

    if (frameId != null || backgroundId != null) {
      final shopState = context.read<ShopBloc>().state;
      if (frameId != null) {
        try {
          resolvedFrameUrl = shopState.items.firstWhere((e) => e.id == frameId).imageUrl;
        } catch (_) {}
      }
      if (backgroundId != null) {
        try {
          resolvedBgUrl = shopState.items.firstWhere((e) => e.id == backgroundId).imageUrl;
        } catch (_) {}
      }
    }

    return SizedBox(
      width: radius * 2.5,
      height: radius * 2.5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          if (resolvedBgUrl != null)
            Container(
              width: radius * 2,
              height: radius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(resolvedBgUrl),
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

          // Frame
          if (resolvedFrameUrl != null)
            Positioned.fill(
              child: Image.network(
                resolvedFrameUrl,
                fit: BoxFit.contain,
              ),
            ),
          
          // Avatar
          avatarWidget,
        ],
      ),
    );
  }
}

