import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import '../blocs/shop_bloc.dart';
import '../../data/models/shop_model.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/payment_bloc.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:animate_do/animate_do.dart';
import '../widgets/shop_item_card.dart';
import '../widgets/item_purchase_modal.dart';
import '../widgets/gacha_machine_widget.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/jiggle_widget.dart';

class ShopPage extends StatefulWidget {
  final bool showGacha;
  
  const ShopPage({super.key, this.showGacha = true});

  @override
  ShopPageState createState() => ShopPageState();
}

class ShopPageState extends State<ShopPage> {
  final ShopBloc _shopBloc = sl<ShopBloc>();
  final PaymentBloc _paymentBloc = sl<PaymentBloc>();

  @override
  void initState() {
    super.initState();
    _shopBloc.add(LoadShopEvent());
    _shopBloc.add(LoadInventoryEvent());
    _paymentBloc.add(LoadPaymentPackagesEvent());
  }

  void _showRewardDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Center(
        child: Material(
          color: Colors.transparent,
          child: BounceInDown(
            duration: const Duration(milliseconds: 600),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 24.w),
              padding: EdgeInsets.all(32.w),
              decoration: BoxDecoration(
                color: AppPreferences().isDarkMode ? AppColors.polar : Colors.white,
                borderRadius: BorderRadius.circular(32.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.macaw.withValues(alpha: 0.3),
                    blurRadius: 40.r,
                    spreadRadius: 10.r,
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Pulse(
                    infinite: true,
                    child: Icon(Icons.stars_rounded, size: 80.r, color: AppColors.macaw),
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    'CHÚC MỪNG!',
                    style: TextStyle(
                      color: AppColors.macaw,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppPreferences().isDarkMode ? Colors.white : AppColors.bodyText,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 32.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.macaw,
                      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('TẤT NHIÊN RỒI', style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
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
    final bgColor = isDark ? AppColors.background : AppColors.snow;
    final textColor = isDark ? Colors.white : AppColors.bodyText;

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _shopBloc),
        BlocProvider.value(value: _paymentBloc),
      ],
      child: Scaffold(
        backgroundColor: bgColor,
        body: MultiBlocListener(
          listeners: [
            BlocListener<ShopBloc, ShopState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!, style: TextStyle(color: Colors.white)), backgroundColor: AppColors.cardinal));
                }
                if (state.successMessage != null) {
                  context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
                  if (state.chestReward == null) {
                     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage!, style: TextStyle(color: Colors.white)), backgroundColor: AppColors.macaw));
                  }
                }
                if (state.chestReward != null) {
                  _showRewardDialog(context, state.successMessage ?? 'Bạn nhận được phần thưởng!');
                }
              },
            ),
            BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                if (state is PaymentCreated) {
                  _launchPaymentUrl(context, state.result);
                }
                if (state is PaymentError) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: AppColors.cardinal));
                }
              },
            ),
          ],
          child: BlocBuilder<ShopBloc, ShopState>(
            builder: (context, shopState) {
              final frames = shopState.items.where((e) => e.category == 'FRAME').toList();
              final backgrounds = shopState.items.where((e) => e.category == 'BACKGROUND').toList();
              final boosts = shopState.items.where((e) => e.category == 'BOOST_XP' || e.category == 'STREAK_FREEZE').toList();

              return BlocBuilder<PaymentBloc, PaymentState>(
                builder: (context, paymentState) {
                  List<PaymentPackageEntity> packages = [];
                  bool isCreating = false;

                  if (paymentState is PaymentPackagesLoaded) {
                    packages = paymentState.packages;
                  } else if (paymentState is PaymentCreating) {
                    packages = paymentState.packages;
                    isCreating = true;
                  } else if (paymentState is PaymentCreated) {
                    packages = paymentState.packages;
                  } else if (paymentState is PaymentError) {
                    packages = paymentState.packages ?? [];
                  }

                  final gemPackages = packages.where((p) => p.gems > 0).toList();
                  final coinPackages = packages.where((p) => p.coins > 0).toList();

                  return Stack(
                    children: [
                      CustomScrollView(
                        slivers: [
                          SliverAppBar(
                            automaticallyImplyLeading: false,
                            expandedHeight: 70.h,
                            floating: true,
                            pinned: true,
                            backgroundColor: isDark ? AppColors.polar : Colors.white,
                            elevation: 2,
                            iconTheme: IconThemeData(color: textColor),
                            flexibleSpace: FlexibleSpaceBar(
                              title: Padding(
                                padding: EdgeInsets.only(left: 24.w),
                                child: Text(
                                  'Cửa hàng',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 24.sp,
                                  ),
                                ),
                              ),
                              background: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.macaw.withValues(alpha: 0.1),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            actions: [
                              _buildCurrencyPills(),
                              SizedBox(width: 16.w),
                            ],
                          ),
                          
                          if (shopState.isLoading || paymentState is PaymentPackagesLoading)
                            SliverFillRemaining(
                              child: Center(child: CircularProgressIndicator(color: AppColors.macaw)),
                            )
                          else ...[
                            // Gacha Section
                            if (widget.showGacha)
                              SliverToBoxAdapter(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 40.h),
                                  child: GachaMachineWidget(
                                    price: 50,
                                    onSpin: () => _shopBloc.add(OpenChestEvent()),
                                  ),
                                ),
                              ),
                            
                            // Payment Packages (Gems)
                            ..._buildPaymentSection('NẠP GEMS', gemPackages, isCreating, 'assets/icons/gem.png', AppColors.macaw, textColor),
                            
                            // Payment Packages (Coins)
                            ..._buildPaymentSection('NẠP COINS', coinPackages, isCreating, 'assets/icons/coin.png', AppColors.bee, textColor),

                            // Shop Sections
                            ..._buildSection('KHUNG AVATAR ĐẶC BIỆT', frames, shopState, Icons.stars_rounded, AppColors.macaw, textColor),
                            ..._buildSection('NỀN HỒ SƠ NỔI BẬT', backgrounds, shopState, Icons.wallpaper_rounded, AppColors.humpback, textColor),
                            ..._buildSection('VẬT PHẨM HỖ TRỢ', boosts, shopState, Icons.flash_on_rounded, AppColors.bee, textColor),
                            
                            // Footer info
                            SliverToBoxAdapter(
                              child: Container(
                                margin: EdgeInsets.all(24.w),
                                padding: EdgeInsets.all(16.w),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.polar : AppColors.snow,
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
                            ),
                            SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                          ]
                        ],
                      ),
                      
                      // Loading Overlay for Payment
                      if (isCreating)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
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
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCurrencyPills() {
    return BlocBuilder<CurrencyBloc, CurrencyState>(
      builder: (context, state) {
        int gems = 0;
        int coins = 0;
        if (state is CurrencyLoaded) {
          gems = state.balance.gems;
          coins = state.balance.coins;
        }

        final isDark = AppPreferences().isDarkMode;
        final pillBg = isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.swan.withValues(alpha: 0.3);

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            JiggleWidget(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/gem.png', width: 20.w, height: 20.w),
                    SizedBox(width: 4.w),
                    Text(
                      gems.toString(),
                      style: TextStyle(color: AppColors.macaw, fontWeight: FontWeight.w800, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 8.w),
            JiggleWidget(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  children: [
                    Image.asset('assets/icons/coin.png', width: 20.w, height: 20.w),
                    SizedBox(width: 4.w),
                    Text(
                      coins.toString(),
                      style: TextStyle(color: AppColors.bee, fontWeight: FontWeight.w800, fontSize: 16.sp),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildPaymentSection(String title, List<PaymentPackageEntity> packages, bool isCreating, String iconPath, Color accentColor, Color textColor) {
    if (packages.isEmpty) return [SliverToBoxAdapter(child: SizedBox.shrink())];
    
    return [
      SliverToBoxAdapter(
        child: FadeInUp(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 16.h),
            child: Row(
              children: [
                Image.asset(iconPath, width: 32.w, height: 32.w),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final pkg = packages[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              child: FadeInUp(
                delay: Duration(milliseconds: 50 * (index % 4)),
                child: _PackageCard(
                  package: pkg,
                  isCreating: isCreating,
                  iconPath: iconPath,
                  accentColor: accentColor,
                  onTap: () {
                    context.read<PaymentBloc>().add(CreatePaymentEvent(pkg.id));
                  },
                ),
              ),
            );
          },
          childCount: packages.length,
        ),
      ),
    ];
  }

  List<Widget> _buildSection(String title, List<ShopItemModel> items, ShopState state, IconData icon, Color iconColor, Color textColor) {
    if (items.isEmpty) return [SliverToBoxAdapter(child: SizedBox.shrink())];
    
    return [
      SliverToBoxAdapter(
        child: FadeInUp(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 16.h),
            child: Row(
              children: [
                Icon(icon, color: iconColor, size: 32.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              final isOwned = state.inventory.any((inv) => inv.itemId == item.id);
              final isEquipped = state.equipped?.frameId == item.id || state.equipped?.backgroundId == item.id;

              return ShopItemCard(
                index: index,
                item: item,
                isOwned: isOwned,
                isEquipped: isEquipped,
                onTap: () {
                  if (isEquipped) return;
                  if (isOwned && (item.category == 'FRAME' || item.category == 'BACKGROUND')) {
                    _shopBloc.add(EquipItemEvent(item.id));
                  } else {
                    ItemPurchaseModal.show(context, item, () {
                      _shopBloc.add(BuyItemEvent(item.id));
                    });
                  }
                },
              );
            },
            childCount: items.length,
          ),
        ),
      ),
    ];
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
