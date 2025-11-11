import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/daily_goal_tile.dart';

class DailyGoalScreen extends StatefulWidget {
  final String? selectedGoal;
  final Function(String) onGoalSelected;

  const DailyGoalScreen({
    super.key,
    this.selectedGoal,
    required this.onGoalSelected,
  });

  @override
  State<DailyGoalScreen> createState() => _DailyGoalScreenState();
}

class _DailyGoalScreenState extends State<DailyGoalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _scaleAnimations;
  late List<Animation<Offset>> _slideAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Bounce animations for each goal
    _scaleAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.4 + (index * 0.15),
            curve: Curves.elasticOut,
          ),
        ),
      ),
    );

    _slideAnimations = List.generate(
      4,
      (index) => Tween<Offset>(
        begin: const Offset(0, 0.5),
        end: Offset.zero,
      ).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.15,
            0.4 + (index * 0.15),
            curve: Curves.easeOut,
          ),
        ),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header section
        _buildFixedHeader(),
        
        // Scrollable content
        Expanded(
          child: _buildScrollableContent(),
        ),
      ],
    );
  }

  Widget _buildFixedHeader() {
    return DuoWithSpeechFactory.horizontal(
      speechText: 'Chọn mục tiêu học tập hàng ngày của bạn!',
      duoType: DuoCharacterType.happy,
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildGoalsList(),
        ],
      ),
    );
  }

  Widget _buildGoalsList() {
    final goals = [
      ('5', '5 phút/ngày', 'Thư giãn', 'casual', AppColors.primary),
      ('10', '10 phút/ngày', 'Đều đặn', 'regular', AppColors.macaw),
      ('15', '15 phút/ngày', 'Nghiêm túc', 'serious', AppColors.fox),
      ('20', '20 phút/ngày', 'Cường độ cao', 'intense', AppColors.cardinal),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: goals.asMap().entries.map((entry) {
          final index = entry.key;
          final goal = entry.value;
          
          return SlideTransition(
            position: _slideAnimations[index],
            child: ScaleTransition(
              scale: _scaleAnimations[index],
              child: Column(
                children: [
                  DailyGoalTile(
                    time: goal.$1,
                    title: goal.$2,
                    subtitle: '',
                    difficulty: goal.$3,
                    difficultyColor: goal.$5,
                    isSelected: widget.selectedGoal == goal.$4,
                    onTap: () => widget.onGoalSelected(goal.$4),
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}