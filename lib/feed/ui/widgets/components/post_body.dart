import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/feed/ui/utils/feed_constants.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class PostBody extends StatelessWidget {
  final String content;
  final PostTypeConfig config;

  const PostBody({
    Key? key,
    required this.content,
    required this.config,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Content Text on the Left
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 26.sp,
              color: AppColors.feedTextPrimary,
              height: 1.3,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        SizedBox(width: 12.w),

        // Large Achievement Icon on the Right
        Container(
          width: 100.w,
          height: 100.w,
          decoration: BoxDecoration(
            color: config.backgroundColor.withOpacity(0.1), 
            shape: BoxShape.circle,
          ),
          child: Icon(
            config.icon,
            size: 60.sp,
          ),
        ),
      ],
    );
  }
}
