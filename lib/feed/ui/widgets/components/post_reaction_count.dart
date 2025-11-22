import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/domain/enums/feed_enums.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostReactionCount extends StatelessWidget {
  final int totalReactions;
  final List<ReactionType> reactionTypes;
  final VoidCallback onTap;

  const PostReactionCount({
    Key? key,
    required this.totalReactions,
    required this.reactionTypes,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (totalReactions == 0) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          // Hiển thị tối đa 3 reaction types chồng lên nhau
          SizedBox(
            width: reactionTypes.isEmpty 
                ? 40.w 
                : (40.w + (reactionTypes.length > 3 ? 2 : reactionTypes.length - 1) * 24.w),
            height: 40.w,
            child: Stack(
              children: [
                for (int i = (reactionTypes.length > 3 ? 3 : reactionTypes.length) - 1; i >= 0; i--)
                  Positioned(
                    left: i * 24.w,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.snow,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.feedDivider, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          reactionTypes[reactionTypes.length > 3 ? reactionTypes.length - 3 + i : i].emoji,
                          style: TextStyle(fontSize: 18.sp),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(width: 6.w),

          // Số nằm bên ngoài
          Text(
            '$totalReactions',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.feedTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
