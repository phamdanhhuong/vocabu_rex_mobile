import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'dart:math';

class HomeLoadingSkeleton extends StatefulWidget {
  const HomeLoadingSkeleton({super.key});

  @override
  State<HomeLoadingSkeleton> createState() => _HomeLoadingSkeletonState();
}

class _HomeLoadingSkeletonState extends State<HomeLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _dotsAnimation;
  
  // Danh sách các tips ngẫu nhiên
  static const List<String> _tips = [
    'Hãy chú ý đến những bài tập giúp bạn cải thiện kỹ năng nói, nghe, đọc và viết!',
    'Học từ vựng mỗi ngày giúp bạn nhớ lâu hơn!',
    'Thực hành thường xuyên là chìa khóa để thành thạo ngôn ngữ!',
    'Đừng quên ôn tập những bài đã học để không bị quên!',
    'Mỗi bài học là một bước tiến nhỏ trên hành trình chinh phục ngôn ngữ!',
    'Hãy dành ít nhất 10 phút mỗi ngày để học!',
    'Luyện phát âm giúp bạn tự tin hơn khi giao tiếp!',
  ];
  
  late String _selectedTip;

  @override
  void initState() {
    super.initState();
    
    // Chọn ngẫu nhiên một tip
    _selectedTip = _tips[Random().nextInt(_tips.length)];
    
    // Animation controller cho dấu chấm
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    
    _dotsAnimation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo/Mascot
            Image.asset(
              'assets/logo.png',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            
            const SizedBox(height: 32),
            
            // LOADING... với animation
            AnimatedBuilder(
              animation: _dotsAnimation,
              builder: (context, child) {
                String dots = '.' * _dotsAnimation.value;
                return Text(
                  'LOADING$dots',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.swan,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 48),
            
            // Tip ngẫu nhiên
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _selectedTip,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.bodyText,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
