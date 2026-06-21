import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/payment_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/core/injection.dart' as di;

class CurrencyBottomSheet extends StatelessWidget {
  const CurrencyBottomSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => BlocProvider(
        create: (_) => di.sl<PaymentBloc>()..add(LoadPaymentPackagesEvent()),
        child: const CurrencyBottomSheet(),
      ),
    );
  }

  Future<void> _launchPaymentUrl(BuildContext context, CreatePaymentResultEntity result) async {
    final url = Uri.parse(result.paymentUrl);
    try {
      final launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở trang thanh toán'), backgroundColor: AppColors.cardinal),
        );
      } else {
        if (context.mounted) {
          Future.delayed(const Duration(seconds: 2), () {
            if (context.mounted) {
              context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
            }
          });
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: AppColors.cardinal),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final bgColor = isDark ? AppColors.polar : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.bodyText;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentCreated) {
            _launchPaymentUrl(context, state.result);
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.cardinal));
          }
        },
        builder: (context, state) {
          if (state is PaymentPackagesLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.macaw));
          }

          List<PaymentPackageEntity> packages = [];
          bool isCreating = false;

          if (state is PaymentPackagesLoaded) {
            packages = state.packages;
          } else if (state is PaymentCreating) {
            packages = state.packages;
            isCreating = true;
          } else if (state is PaymentCreated) {
            packages = state.packages;
          } else if (state is PaymentError) {
            packages = state.packages ?? [];
          }

          if (packages.isEmpty && state is! PaymentPackagesLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.store_outlined, size: 64.r, color: AppColors.hare),
                  SizedBox(height: 16.h),
                  Text('Không tải được gói nạp', style: TextStyle(color: AppColors.wolf, fontSize: 16.sp)),
                  SizedBox(height: 12.h),
                  ElevatedButton(
                    onPressed: () => context.read<PaymentBloc>().add(LoadPaymentPackagesEvent()),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.macaw),
                    child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final gemPackages = packages.where((p) => p.gems > 0).toList();
          final coinPackages = packages.where((p) => p.coins > 0).toList();

          return Stack(
            children: [
              Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 16.h, bottom: 24.h),
                      width: 48.w,
                      height: 5.h,
                      decoration: BoxDecoration(
                        color: AppColors.swan,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                  ),
                  
                  Text(
                    'Ngân khố',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('assets/icons/gem.png', 'NẠP GEMS', AppColors.macaw, textColor),
                          SizedBox(height: 16.h),
                          ...gemPackages.map((pkg) => _PackageCard(
                            package: pkg,
                            isCreating: isCreating,
                            iconPath: 'assets/icons/gem.png',
                            accentColor: AppColors.macaw,
                            onTap: () => context.read<PaymentBloc>().add(CreatePaymentEvent(pkg.id)),
                          )),
                          
                          SizedBox(height: 32.h),
                          
                          _buildSectionHeader('assets/icons/coin.png', 'NẠP COINS', AppColors.bee, textColor),
                          SizedBox(height: 16.h),
                          ...coinPackages.map((pkg) => _PackageCard(
                            package: pkg,
                            isCreating: isCreating,
                            iconPath: 'assets/icons/coin.png',
                            accentColor: AppColors.bee,
                            onTap: () => context.read<PaymentBloc>().add(CreatePaymentEvent(pkg.id)),
                          )),
                          
                          SizedBox(height: 32.h),
                          
                          // Info footer
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.background : AppColors.snow,
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(color: AppColors.swan, width: 1),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.wolf, size: 24.r),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Thanh toán an toàn qua VNPay. Gems/Coins sẽ được cộng ngay sau khi thanh toán thành công.',
                                    style: TextStyle(color: AppColors.wolf, fontSize: 13.sp),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 32.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              if (isCreating)
                Container(
                  color: Colors.black.withValues(alpha: 0.3),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16.h),
                        Text(
                          'Đang tạo đơn thanh toán...',
                          style: TextStyle(color: Colors.white, fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String iconPath, String title, Color accentColor, Color textColor) {
    return Row(
      children: [
        Image.asset(iconPath, width: 32.w, height: 32.w),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: textColor,
          ),
        ),
      ],
    );
  }
}

class _PackageCard extends StatelessWidget {
  final PaymentPackageEntity package;
  final bool isCreating;
  final String iconPath;
  final Color accentColor;
  final VoidCallback onTap;

  const _PackageCard({
    required this.package,
    required this.isCreating,
    required this.iconPath,
    required this.accentColor,
    required this.onTap,
  });

  String _formatPrice(int price) {
    final formatted = price.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
    return '${formatted}₫';
  }

  @override
  Widget build(BuildContext context) {
    final currencyAmount = package.gems > 0 ? package.gems : package.coins;
    final currencyName = package.gems > 0 ? 'Gems' : 'Coins';
    final isDark = AppPreferences().isDarkMode;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: isDark ? AppColors.polar : AppColors.snow,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isDark ? Colors.black26 : AppColors.swan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.15),
            blurRadius: 10.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.r),
          onTap: isCreating ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Center(
                    child: Image.asset(iconPath, width: 32.w, height: 32.w),
                  ),
                ),

                SizedBox(width: 16.w),

                // Package info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currencyAmount $currencyName',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.eel,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        package.name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.wolf,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price button
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.4),
                        blurRadius: 8.r,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPrice(package.price),
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
