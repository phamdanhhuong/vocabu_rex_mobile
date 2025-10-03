import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/level_option_tile.dart';

class ExperienceLevelScreen extends StatefulWidget {
  final String? selectedLevel;
  final Function(String) onLevelSelected;

  const ExperienceLevelScreen({
    super.key,
    this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  ExperienceLevelScreenState createState() => ExperienceLevelScreenState();
}

class ExperienceLevelScreenState extends State<ExperienceLevelScreen> {
  final List<Map<String, dynamic>> levels = [
    {
      'title': 'Tôi mới học tiếng Anh',
      'description': 'Hoàn toàn mới bắt đầu',
      'progress': 0.2,
      'value': 'beginner',
    },
    {
      'title': 'Tôi biết một vài từ thông dụng',
      'description': 'Hiểu được một số từ cơ bản',
      'progress': 0.4,
      'value': 'elementary',
    },
    {
      'title': 'Tôi có thể giao tiếp cơ bản',
      'description': 'Có thể tạo câu đơn giản',
      'progress': 0.6,
      'value': 'intermediate',
    },
    {
      'title': 'Tôi có thể nói về nhiều chủ đề',
      'description': 'Giao tiếp tự nhiên ở mức độ tốt',
      'progress': 0.8,
      'value': 'upper_intermediate',
    },
    {
      'title': 'Tôi có thể đi sâu vào hầu hết các chủ đề',
      'description': 'Thành thạo trong hầu hết các tình huống',
      'progress': 1.0,
      'value': 'advanced',
    },
  ];

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
    return Column(
      children: [
        DuoWithSpeechFactory.horizontal(
          duoType: DuoCharacterType.withBook,
          speechText: 'Trình độ tiếng Anh của bạn ở mức nào?',
        ),
      ],
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildLevelOptions(),
        ],
      ),
    );
  }

  Widget _buildLevelOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        children: levels.map((level) {
          return Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: LevelOptionTile(
              title: level['title'],
              description: level['description'],
              progress: level['progress'],
              isSelected: widget.selectedLevel == level['value'],
              onTap: () {
                widget.onLevelSelected(level['value']);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}