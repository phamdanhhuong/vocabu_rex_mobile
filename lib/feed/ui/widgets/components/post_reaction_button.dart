import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionButton extends StatelessWidget {
  final bool hasReacted;
  final bool isOwnPost;
  final ReactionType userReactionType;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final GlobalKey buttonKey;

  const PostReactionButton({
    Key? key,
    required this.hasReacted,
    required this.isOwnPost,
    required this.userReactionType,
    this.onTap,
    this.onLongPress,
    required this.buttonKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: buttonKey,
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 160.w,
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: hasReacted ? AppColors.macawLight : AppColors.snow,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: hasReacted ? AppColors.macaw : AppColors.feedDivider,
            width: 2,
          ),
          boxShadow: hasReacted
              ? []
              : [
                  BoxShadow(
                    color: AppColors.swan,
                    offset: const Offset(0, 2),
                    blurRadius: 0,
                  )
                ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              hasReacted ? userReactionType.emoji : ReactionType.congrats.emoji,
              style: TextStyle(fontSize: 20.sp),
            ),
            SizedBox(width: 8.w),
            Text(
              isOwnPost
                  ? 'CHIA SẺ'
                  : hasReacted
                      ? userReactionType.reactedText
                      : userReactionType.actionText,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w800,
                color: isOwnPost
                    ? AppColors.feedTextPrimary
                    : hasReacted
                        ? AppColors.macaw
                        : AppColors.macaw,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
