import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class HorizontalQuestCarousel extends StatefulWidget {
  final List<Widget> pages;

  const HorizontalQuestCarousel({
    super.key,
    required this.pages,
  });

  @override
  State<HorizontalQuestCarousel> createState() => _HorizontalQuestCarouselState();
}

class _HorizontalQuestCarouselState extends State<HorizontalQuestCarousel> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 0;
  double _pageWidth = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_pageWidth > 0 && _scrollController.hasClients) {
      final page = (_scrollController.offset / _pageWidth).round();
      if (page != _currentPage && page >= 0 && page < widget.pages.length) {
        setState(() {
          _currentPage = page;
        });
      }
    }
  }

  void _nextPage() {
    if (_currentPage < widget.pages.length - 1 && _scrollController.hasClients) {
      _scrollController.animateTo(
        (_currentPage + 1) * _pageWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0 && _scrollController.hasClients) {
      _scrollController.animateTo(
        (_currentPage - 1) * _pageWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pages.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show navigation arrows on all screens
    final showArrows = true;

    return LayoutBuilder(
      builder: (context, constraints) {
        _pageWidth = constraints.maxWidth;

        return Stack(
          alignment: Alignment.center,
          children: [
            SingleChildScrollView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const PageScrollPhysics(), // Tự động snap trang
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: widget.pages.map((page) {
                  return SizedBox(
                    width: constraints.maxWidth, // Mỗi trang chiếm đúng 1 màn hình
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: page,
                    ),
                  );
                }).toList(),
              ),
            ),
            if (showArrows && _currentPage > 0)
              Positioned(
                left: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chevron_left, size: 36.w, color: AppColors.wolf),
                    onPressed: _previousPage,
                  ),
                ),
              ),
            if (showArrows && _currentPage < widget.pages.length - 1)
              Positioned(
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.chevron_right, size: 36.w, color: AppColors.wolf),
                    onPressed: _nextPage,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
