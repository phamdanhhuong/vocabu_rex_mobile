import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import '../../data/models/shop_model.dart';
import 'package:animate_do/animate_do.dart';

class ShopItemCard extends StatefulWidget {
  final ShopItemModel item;
  final bool isOwned;
  final bool isEquipped;
  final VoidCallback onTap;
  final int index;

  const ShopItemCard({
    super.key,
    required this.item,
    required this.isOwned,
    required this.isEquipped,
    required this.onTap,
    this.index = 0,
  });

  @override
  State<ShopItemCard> createState() => _ShopItemCardState();
}

class _ShopItemCardState extends State<ShopItemCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final cardColor = isDark ? AppColors.polar : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.bodyText;
    final iconPath = widget.item.currencyType == 'GEMS' ? 'assets/icons/gem.png' : 'assets/icons/coin.png';

    // Shadow color specifically for 3D effect
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.6) : AppColors.swan;
    
    // Status color
    Color statusBgColor = Colors.transparent;
    Color statusTextColor = Colors.transparent;
    String statusText = '';
    if (widget.isEquipped) {
      statusBgColor = AppColors.maskGreen.withValues(alpha: 0.2);
      statusTextColor = AppColors.maskGreen;
      statusText = 'Đang dùng';
    } else if (widget.isOwned && (widget.item.category == 'FRAME' || widget.item.category == 'BACKGROUND')) {
      statusBgColor = AppColors.humpback.withValues(alpha: 0.2);
      statusTextColor = AppColors.humpback;
      statusText = 'Đã sở hữu';
    }

    Widget content = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: EdgeInsets.only(top: _isPressed ? 4.h : 0), // Push down effect
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: shadowColor, width: 2),
          boxShadow: _isPressed ? [] : [
            BoxShadow(
              color: shadowColor,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Status tag
            if (statusText.isNotEmpty)
              Container(
                margin: EdgeInsets.only(top: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusTextColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              SizedBox(height: 24.h), // Placeholder for alignment
            
            Expanded(
              child: Center(
                child: widget.item.imageUrl != null
                    ? Image.network(
                        widget.item.imageUrl!,
                        height: 70.h,
                        errorBuilder: (c, e, s) => Icon(Icons.image, size: 60.h, color: AppColors.swan),
                      )
                    : Icon(Icons.stars_rounded, size: 60.h, color: AppColors.macaw),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Text(
                widget.item.name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14.sp,
                  color: textColor,
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Price Tag
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              margin: EdgeInsets.only(bottom: 12.h),
              decoration: BoxDecoration(
                color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.snow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(iconPath, width: 16.w, height: 16.w),
                  SizedBox(width: 6.w),
                  Text(
                    widget.item.price.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.sp,
                      color: widget.item.currencyType == 'GEMS' ? AppColors.macaw : AppColors.bee,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    // FadeInUp animation cascade based on index
    return FadeInUp(
      delay: Duration(milliseconds: 50 * (widget.index % 4)),
      duration: const Duration(milliseconds: 400),
      child: content,
    );
  }
}
