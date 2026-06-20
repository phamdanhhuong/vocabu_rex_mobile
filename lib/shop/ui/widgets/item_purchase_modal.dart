import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import '../../data/models/shop_model.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';

class ItemPurchaseModal extends StatelessWidget {
  final ShopItemModel item;
  final VoidCallback onPurchase;
  final bool isLoading;

  const ItemPurchaseModal({
    super.key,
    required this.item,
    required this.onPurchase,
    this.isLoading = false,
  });

  static void show(BuildContext context, ShopItemModel item, VoidCallback onPurchase) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ItemPurchaseModal(item: item, onPurchase: onPurchase),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final bgColor = isDark ? AppColors.polar : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.bodyText;
    final iconPath = item.currencyType == 'GEMS' ? 'assets/icons/gem.png' : 'assets/icons/coin.png';

    return FadeInUp(
      duration: const Duration(milliseconds: 300),
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 24.h,
          left: 24.w,
          right: 24.w,
          top: 32.h,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20.r,
              spreadRadius: 5.r,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: AppColors.swan,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            // Item Image with glowing background
            ZoomIn(
              duration: const Duration(milliseconds: 500),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 150.r,
                    height: 150.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.macaw.withValues(alpha: 0.3),
                          Colors.transparent,
                        ],
                        radius: 0.8,
                      ),
                    ),
                  ),
                  if (item.imageUrl != null)
                    Image.network(
                      item.imageUrl!,
                      height: 120.h,
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) => Icon(Icons.image, size: 80.h, color: AppColors.swan),
                    )
                  else
                    Icon(Icons.stars_rounded, size: 100.h, color: AppColors.macaw),
                ],
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Item Name
            FadeInUp(
              delay: const Duration(milliseconds: 100),
              child: Text(
                item.name,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: textColor,
                ),
              ),
            ),
            
            SizedBox(height: 8.h),
            
            // Description (mock description since model might not have one)
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Text(
                'Làm nổi bật hồ sơ của bạn với vật phẩm độc đáo này!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.wolf,
                ),
              ),
            ),
            
            SizedBox(height: 32.h),
            
            // Purchase Button
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // Close modal
                    onPurchase(); // Trigger purchase
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      boxShadow: [
                        BoxShadow(
                          color: (item.currencyType == 'GEMS' ? AppColors.macaw : AppColors.bee).withValues(alpha: 0.4),
                          blurRadius: 12.r,
                          offset: const Offset(0, 6),
                        )
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Solid base
                        Container(
                          height: 56.h,
                          decoration: BoxDecoration(
                            color: item.currencyType == 'GEMS' ? AppColors.macaw : AppColors.bee,
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                        ),
                        // Shimmer reflection
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20.r),
                          child: Shimmer.fromColors(
                            baseColor: Colors.transparent,
                            highlightColor: Colors.white.withValues(alpha: 0.4),
                            period: const Duration(milliseconds: 2000),
                            child: Container(
                              height: 56.h,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        // Content
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'MUA VỚI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            SizedBox(width: 12.w),
                            Image.asset(iconPath, width: 24.w, height: 24.w),
                            SizedBox(width: 6.w),
                            Text(
                              item.price.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
