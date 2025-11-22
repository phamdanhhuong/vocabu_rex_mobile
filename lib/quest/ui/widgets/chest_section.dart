import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/quest/domain/entities/quest_chest_entity.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_state.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_event.dart';

class ChestSection extends StatelessWidget {
  const ChestSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestChestBloc, QuestChestState>(
      listener: (context, state) {
        if (state is QuestChestOpened) {
          _showChestRewardDialog(context, state.openedChest);
        }
      },
      builder: (context, state) {
        if (state is QuestChestLoading) {
          return _buildLoadingState();
        }

        if (state is QuestChestError) {
          return _buildErrorState(state.message);
        }

        if (state is QuestChestLoaded || state is QuestChestOpening) {
          final chests = state is QuestChestLoaded
              ? state.chests
              : (state as QuestChestOpening).chests;

          if (chests.isEmpty) {
            return const SizedBox.shrink();
          }

          final openingChestId = state is QuestChestOpening ? state.openingChestId : null;

          return _buildChestList(context, chests, openingChestId);
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Lỗi: $message',
        style: TextStyle(color: Colors.red),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildChestList(BuildContext context, List<QuestChestEntity> chests, String? openingChestId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(Icons.inventory_2, color: Colors.amber[700], size: 24.w),
              SizedBox(width: 8.w),
              Text(
                'Rương báu đã mở khóa (${chests.length})',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 180.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: chests.length,
            itemBuilder: (context, index) {
              final chest = chests[index];
              final isOpening = openingChestId == chest.id;
              return _buildChestCard(context, chest, isOpening);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChestCard(BuildContext context, QuestChestEntity chest, bool isOpening) {
    final chestColor = _getChestColor(chest.chestType.toString());
    final chestName = _getChestName(chest.chestType.toString());

    return Container(
      width: 140.w,
      margin: EdgeInsets.only(right: 12.w),
      child: GestureDetector(
        onTap: chest.canOpen && !isOpening
            ? () => context.read<QuestChestBloc>().add(OpenChestEvent(chest.id))
            : null,
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                chestColor.withOpacity(0.2),
                chestColor.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: chestColor,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: chestColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.inventory_2,
                    color: chestColor,
                    size: 64.w,
                  ),
                  if (isOpening)
                    SizedBox(
                      width: 80.w,
                      height: 80.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(chestColor),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                chestName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: chestColor,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 4.h),
              if (chest.canOpen)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: chestColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Nhấn để mở',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: chestColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              else
                Text(
                  chest.status.toString().split('.').last,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showChestRewardDialog(BuildContext context, QuestChestEntity chest) {
    final chestColor = _getChestColor(chest.chestType.toString());
    final chestName = _getChestName(chest.chestType.toString());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                chestColor.withOpacity(0.1),
                Colors.white,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.inventory_2,
                color: chestColor,
                size: 80.w,
              ),
              SizedBox(height: 16.h),
              Text(
                'Chúc mừng!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.bodyText,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Bạn đã mở $chestName',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: chestColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 24.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      'Phần thưởng',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    if (chest.rewardXp != null && chest.rewardXp! > 0) ...[
                      _buildRewardRow(Icons.stars, '+${chest.rewardXp} XP', Colors.amber),
                      SizedBox(height: 8.h),
                    ],
                    if (chest.rewardGems != null && chest.rewardGems! > 0) ...[
                      _buildRewardRow(Icons.diamond, '+${chest.rewardGems} Gems', Colors.blue),
                      SizedBox(height: 8.h),
                    ],
                    if (chest.rewardCoins != null && chest.rewardCoins! > 0)
                      _buildRewardRow(Icons.monetization_on, '+${chest.rewardCoins} Coins', Colors.orange),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<QuestChestBloc>().add(RefreshChestsEvent());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: chestColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Tuyệt vời!',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRewardRow(IconData icon, String text, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: 24.w),
        SizedBox(width: 8.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.bodyText,
          ),
        ),
      ],
    );
  }

  Color _getChestColor(String chestType) {
    if (chestType.contains('bronze')) return Colors.brown[600]!;
    if (chestType.contains('silver')) return Colors.grey[600]!;
    if (chestType.contains('gold')) return Colors.amber[700]!;
    if (chestType.contains('legendary')) return Colors.purple[700]!;
    return Colors.grey;
  }

  String _getChestName(String chestType) {
    if (chestType.contains('bronze')) return 'Rương Đồng';
    if (chestType.contains('silver')) return 'Rương Bạc';
    if (chestType.contains('gold')) return 'Rương Vàng';
    if (chestType.contains('legendary')) return 'Rương Huyền thoại';
    return 'Rương';
  }
}
