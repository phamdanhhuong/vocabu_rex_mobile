import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_bottom_nav_tokens.dart';
import 'package:showcaseview/showcaseview.dart';

class AppBottomNavItem {
  final String imageAssetPath;
  final String label;

  const AppBottomNavItem({required this.imageAssetPath, required this.label});
}

/// Thanh điều hướng (bottom navigation) tùy chỉnh giống Duolin
class AppBottomNav extends StatefulWidget {
  final List<AppBottomNavItem> items;
  final Function(int) onTap;
  final int initialIndex;
  final List<GlobalKey>? showcaseKeys;

  const AppBottomNav({
    Key? key,
    required this.items,
    required this.onTap,
    this.showcaseKeys,
    this.initialIndex = 0,
  }) : assert(
         items.length == AppBottomNavTokens.expectedItemCount,
         'Thanh điều hướng phải có đúng ${AppBottomNavTokens.expectedItemCount} mục',
       ),
       super(key: key);

  @override
  State<AppBottomNav> createState() => _AppBottomNavState();
}

class _AppBottomNavState extends State<AppBottomNav> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    widget.onTap(index);
  }

  @override
  Widget build(BuildContext context) {
    final bool useShowcase =
        widget.showcaseKeys != null &&
        widget.showcaseKeys!.length == widget.items.length;
    return BottomAppBar(
      color: AppColors.background, // Dùng màu nền
      elevation: 0, // Tắt bóng
      child: Container(
        height: AppBottomNavTokens.height, // Chiều cao cố định
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.transparent,
              width: AppBottomNavTokens.topBorderWidth,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final bool isSelected = index == _currentIndex;

            final GlobalKey? itemKey = useShowcase
                ? widget.showcaseKeys![index]
                : null;

            final Widget button = _BottomNavButton(
              imageAssetPath: item.imageAssetPath,
              label: item.label,
              isSelected: isSelected,
              onTap: () => _onItemTapped(index),
            );

            if (useShowcase) {
              return Showcase(
                key: itemKey!,
                title: item.label,
                description: _getTabDescription(
                  item.label,
                ), // Thêm hàm helper để lấy description
                targetShapeBorder:
                    const CircleBorder(), // Giả sử icon là hình tròn
                child: button,
              );
            }

            return button;
          }),
        ),
      ),
    );
  }

  String _getTabDescription(String label) {
    switch (label) {
      case 'Học':
        return 'Bắt đầu bài học mới và rèn luyện từ vựng của bạn.';
      case 'Nhiệm vụ':
        return 'Kiểm tra các mục tiêu và nhận phần thưởng mới.';
      case 'Bảng xếp hạng':
        return 'Xem thứ hạng của bạn so với bạn bè.';
      case 'Bảng tin':
        return 'Cập nhật tin tức và bài viết cộng đồng.';
      case 'Trợ lý':
        return 'Trò chuyện với Trợ lý AI để hỗ trợ học tập.';
      case 'Thêm':
        return 'Truy cập cài đặt, hồ sơ và các tính năng mở rộng khác.';
      default:
        return 'Tính năng quan trọng.';
    }
  }
}

/// Nút bấm bên trong thanh điều hướng
class _BottomNavButton extends StatelessWidget {
  final String imageAssetPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _BottomNavButton({
    Key? key,
    required this.imageAssetPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // const double iconSize = 48.0; // Không còn dùng ở đây

    final BoxDecoration decoration = isSelected
        ? BoxDecoration(
            color: AppColors.selectionBlueDark, // Nền
            borderRadius: BorderRadius.circular(
              AppBottomNavTokens.selectedBorderRadius,
            ), // Bo góc
            border: Border.all(
              color: AppColors.macaw, // Viền
              width: AppBottomNavTokens.selectedBorderWidth,
            ),
          )
        : const BoxDecoration(
            // Trạng thái không chọn
            color: Colors.transparent,
          );

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppBottomNavTokens.paddingHorizontal,
          vertical: AppBottomNavTokens.paddingVertical,
        ),
        child: Center(
          // SỬA ĐỔI: Thêm AspectRatio để giữ hình vuông và responsive
          child: AspectRatio(
            aspectRatio:
                AppBottomNavTokens.aspectRatio, // Giữ tỷ lệ 1:1 (vuông)
            child: AnimatedContainer(
              duration: const Duration(
                milliseconds: AppBottomNavTokens.animationDurationMs,
              ),
              decoration: decoration,
              // SỬA ĐỔI: Xóa width và height cố định ở đây
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(
                  AppBottomNavTokens.selectedBorderRadius,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // SỬA ĐỔI: Bọc Image.asset trong Flexible
                    Flexible(
                      child: Image.asset(
                        imageAssetPath,
                        // SỬA ĐỔI: Xóa width và height cố định
                        // width: iconSize,
                        // height: iconSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
