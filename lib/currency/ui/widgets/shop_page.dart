import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabu_rex_mobile/currency/domain/entities/payment_entity.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/payment_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class ShopPage extends StatelessWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.eel),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Cửa hàng',
          style: TextStyle(
            color: AppColors.eel,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentCreated) {
            _launchPaymentUrl(context, state.result);
          }
          if (state is PaymentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.cardinal,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PaymentPackagesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.featherGreen),
            );
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
                  Icon(Icons.store_outlined, size: 64, color: AppColors.hare),
                  const SizedBox(height: 16),
                  Text(
                    'Không tải được gói nạp',
                    style: TextStyle(color: AppColors.wolf, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PaymentBloc>().add(LoadPaymentPackagesEvent());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.featherGreen,
                    ),
                    child: const Text('Thử lại', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          // Tách gems packages và coins packages
          final gemPackages = packages.where((p) => p.gems > 0).toList();
          final coinPackages = packages.where((p) => p.coins > 0).toList();

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header section
                    _buildSectionHeader(
                      icon: 'assets/icons/gem.png',
                      title: 'Nạp Gems',
                      color: AppColors.macaw,
                    ),
                    const SizedBox(height: 12),
                    ...gemPackages.map(
                      (pkg) => _PackageCard(
                        package: pkg,
                        isCreating: isCreating,
                        iconPath: 'assets/icons/gem.png',
                        accentColor: AppColors.macaw,
                        onTap: () {
                          context.read<PaymentBloc>().add(CreatePaymentEvent(pkg.id));
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader(
                      icon: 'assets/icons/coin.png',
                      title: 'Nạp Coins',
                      color: AppColors.bee,
                    ),
                    const SizedBox(height: 12),
                    ...coinPackages.map(
                      (pkg) => _PackageCard(
                        package: pkg,
                        isCreating: isCreating,
                        iconPath: 'assets/icons/coin.png',
                        accentColor: AppColors.bee,
                        onTap: () {
                          context.read<PaymentBloc>().add(CreatePaymentEvent(pkg.id));
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Info footer
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.polar,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.wolf, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Thanh toán an toàn qua VNPay. Gems/Coins sẽ được cộng ngay sau khi thanh toán thành công.',
                              style: TextStyle(
                                color: AppColors.wolf,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Loading overlay
              if (isCreating)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(height: 16),
                        Text(
                          'Đang tạo đơn thanh toán...',
                          style: TextStyle(color: Colors.white, fontSize: 16),
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

  Widget _buildSectionHeader({
    required String icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Image.asset(icon, width: 24, height: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<void> _launchPaymentUrl(
    BuildContext context,
    CreatePaymentResultEntity result,
  ) async {
    final url = Uri.parse(result.paymentUrl);
    try {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không thể mở trang thanh toán'),
              backgroundColor: AppColors.cardinal,
            ),
          );
        }
      } else {
        // Khi quay lại app, refresh currency balance
        if (context.mounted) {
          // Đợi 1 giây rồi refresh
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
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.cardinal,
          ),
        );
      }
    }
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
    // Format VND: 20000 → 20.000₫
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.swan, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isCreating ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Image.asset(iconPath, width: 28, height: 28),
                  ),
                ),

                const SizedBox(width: 14),

                // Package info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$currencyAmount $currencyName',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.eel,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        package.name,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.wolf,
                        ),
                      ),
                    ],
                  ),
                ),

                // Price button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _formatPrice(package.price),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
