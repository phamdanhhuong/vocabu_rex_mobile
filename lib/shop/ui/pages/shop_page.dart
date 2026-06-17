import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import '../blocs/shop_bloc.dart';
import '../../data/models/shop_model.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({Key? key}) : super(key: key);

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShopBloc _shopBloc = sl<ShopBloc>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _shopBloc.add(LoadShopEvent());
    _shopBloc.add(LoadInventoryEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _shopBloc,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Cửa hàng', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.bodyText)),
          backgroundColor: AppColors.background,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.bodyText),
          bottom: TabBar(
            controller: _tabController,
            labelColor: AppColors.macaw,
            unselectedLabelColor: AppColors.wolf,
            indicatorColor: AppColors.macaw,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Khung'),
              Tab(text: 'Nền'),
              Tab(text: 'Vật phẩm'),
              Tab(text: 'Rương'),
            ],
          ),
          actions: [
            BlocBuilder<CurrencyBloc, CurrencyState>(
              builder: (context, state) {
                if (state is CurrencyLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.diamond, color: Colors.blue),
                        SizedBox(width: 4),
                        Text(state.balance.gems.toString(), style: TextStyle(color: AppColors.bodyText, fontWeight: FontWeight.bold)),
                        SizedBox(width: 12),
                        Icon(Icons.monetization_on, color: Colors.amber),
                        SizedBox(width: 4),
                        Text(state.balance.coins.toString(), style: TextStyle(color: AppColors.bodyText, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
        body: BlocConsumer<ShopBloc, ShopState>(
          listener: (context, state) {
            if (state.error != null) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
            }
            if (state.successMessage != null) {
               ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage!)));
               // Reload currency
               context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
            }
            if (state.chestReward != null) {
               showDialog(
                 context: context,
                 builder: (context) => AlertDialog(
                   title: Text('Phần thưởng!'),
                   content: Text(state.successMessage ?? 'Bạn nhận được quà'),
                   actions: [
                     TextButton(onPressed: () => Navigator.pop(context), child: Text('OK'))
                   ],
                 )
               );
            }
          },
          builder: (context, state) {
            if (state.isLoading) return Center(child: CircularProgressIndicator());
            
            final frames = state.items.where((e) => e.category == 'FRAME').toList();
            final backgrounds = state.items.where((e) => e.category == 'BACKGROUND').toList();
            final boosts = state.items.where((e) => e.category == 'BOOST_XP' || e.category == 'STREAK_FREEZE').toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildGrid(frames, state),
                _buildGrid(backgrounds, state),
                _buildGrid(boosts, state),
                _buildChestTab(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrid(List<ShopItemModel> items, ShopState state) {
    if (items.isEmpty) return Center(child: Text('Chưa có vật phẩm'));
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isOwned = state.inventory.any((inv) => inv.itemId == item.id);
        final isEquipped = state.equipped?.frameId == item.id || state.equipped?.backgroundId == item.id;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (item.imageUrl != null)
                 Image.network(item.imageUrl!, height: 60.h, errorBuilder: (c, e, s) => Icon(Icons.image, size: 60.h)),
              SizedBox(height: 12.h),
              Text(item.name, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(item.currencyType == 'GEMS' ? Icons.diamond : Icons.monetization_on, 
                        color: item.currencyType == 'GEMS' ? Colors.blue : Colors.amber, size: 16.r),
                   SizedBox(width: 4.w),
                   Text(item.price.toString()),
                ],
              ),
              SizedBox(height: 12.h),
              if (isOwned && (item.category == 'FRAME' || item.category == 'BACKGROUND'))
                 ElevatedButton(
                   onPressed: isEquipped ? null : () {
                      _shopBloc.add(EquipItemEvent(item.id));
                   },
                   child: Text(isEquipped ? 'Đang dùng' : 'Trang bị'),
                 )
              else
                 ElevatedButton(
                   onPressed: () {
                     _shopBloc.add(BuyItemEvent(item.id));
                   },
                   child: Text('Mua'),
                 )
            ],
          ),
        );
      },
    );
  }

  Widget _buildChestTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
           Icon(Icons.card_giftcard, size: 100.r, color: AppColors.macaw),
           SizedBox(height: 24.h),
           Text('Mở Rương Ngẫu Nhiên', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold)),
           SizedBox(height: 8.h),
           Text('50 Gems / Lần', style: TextStyle(fontSize: 16.sp, color: Colors.blue)),
           SizedBox(height: 24.h),
           ElevatedButton(
             style: ElevatedButton.styleFrom(
               padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
               backgroundColor: AppColors.macaw,
             ),
             onPressed: () {
               _shopBloc.add(OpenChestEvent());
             },
             child: Text('Mở Rương', style: TextStyle(color: Colors.white, fontSize: 18.sp)),
           )
        ],
      )
    );
  }
}
