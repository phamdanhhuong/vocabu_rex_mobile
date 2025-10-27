import 'package:flutter/material.dart';
import '../../colors.dart'; // Đảm bảo đường dẫn này chính xác
import 'app_bottom_nav_tokens.dart';

class AppBottomNavItem {
  final String imageAssetPath;
  final String label;

  const AppBottomNavItem({
    required this.imageAssetPath,
    required this.label,
  });
}

/// Thanh điều hướng (bottom navigation) tùy chỉnh giống Duolin
class AppBottomNav extends StatefulWidget {
  final List<AppBottomNavItem> items;
  final Function(int) onTap;
  final int initialIndex;

  const AppBottomNav({
    Key? key,
    required this.items,
    required this.onTap,
    this.initialIndex = 0,
  })  : assert(items.length == AppBottomNavTokens.expectedItemCount, 'Thanh điều hướng phải có đúng ${AppBottomNavTokens.expectedItemCount} mục'),
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
    return BottomAppBar(
      color: AppColors.background, // Dùng màu nền
      elevation: 0, // Tắt bóng
      child: Container(
        height: AppBottomNavTokens.height, // Chiều cao cố định
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.transparent, width: AppBottomNavTokens.topBorderWidth),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(widget.items.length, (index) {
            final item = widget.items[index];
            final bool isSelected = index == _currentIndex;

            return _BottomNavButton(
              imageAssetPath: item.imageAssetPath,
              label: item.label,
              isSelected: isSelected,
              onTap: () => _onItemTapped(index),
            );
          }),
        ),
      ),
    );
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
            borderRadius: BorderRadius.circular(AppBottomNavTokens.selectedBorderRadius), // Bo góc
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
        padding: const EdgeInsets.symmetric(horizontal: AppBottomNavTokens.paddingHorizontal, vertical: AppBottomNavTokens.paddingVertical),
        child: Center(
          // SỬA ĐỔI: Thêm AspectRatio để giữ hình vuông và responsive
          child: AspectRatio(
            aspectRatio: AppBottomNavTokens.aspectRatio, // Giữ tỷ lệ 1:1 (vuông)
            child: AnimatedContainer(
              duration: const Duration(milliseconds: AppBottomNavTokens.animationDurationMs),
              decoration: decoration,
              // SỬA ĐỔI: Xóa width và height cố định ở đây
              child: InkWell(
                onTap: onTap,
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                borderRadius: BorderRadius.circular(AppBottomNavTokens.selectedBorderRadius),
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

