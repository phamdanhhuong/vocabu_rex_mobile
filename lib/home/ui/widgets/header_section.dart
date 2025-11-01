import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/typography.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/theme/widgets/pressables/pressables.dart';

/// Extracted header delegate for the learning map.
class SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final String subtitle;
  final VoidCallback onPressed;
  final Color buttonColor;

  SectionHeaderDelegate({
    required this.title,
    required this.subtitle,
    required this.onPressed,
    this.buttonColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(
      height: maxExtent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Row(
            children: [
              Expanded(
                child: PressableRounded(
                  onTap: onPressed,
                  height: maxExtent,
                  backgroundColor: buttonColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.defaultTextTheme(AppColors.onPrimary)
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppColors.onPrimary.withAlpha(AppTokens.titleAlpha),
                                    fontWeight: FontWeight.w600,
                                    height: 1.0,
                                  ) ??
                              const TextStyle(fontSize: AppTokens.titleFontSize),
                        ),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.defaultTextTheme(AppColors.onPrimary)
                                  .displaySmall
                                  ?.copyWith(
                                    color: AppColors.onPrimary,
                                    fontSize: AppTokens.subtitleFontSize,
                                    fontWeight: FontWeight.w800,
                                    height: 1.0,
                                  ) ??
                              const TextStyle(fontSize: AppTokens.subtitleFontSize),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CircleIconButton(
                icon: Icons.list,
                onTap: onPressed,
                height: maxExtent,
                width: AppTokens.headerButtonWidth,
                backgroundColor: buttonColor,
                iconColor: AppColors.onPrimary,
                borderRadius: const BorderRadius.only(topRight: Radius.circular(12), bottomRight: Radius.circular(12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => AppTokens.headerHeight;

  @override
  double get minExtent => AppTokens.headerHeight;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => true;
}
