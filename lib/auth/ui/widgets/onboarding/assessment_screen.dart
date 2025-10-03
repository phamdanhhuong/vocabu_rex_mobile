import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/assessment_option_tile.dart';
import 'components/skip_button.dart';

class AssessmentScreen extends StatefulWidget {
  final Function(String) onAssessmentSelected;

  const AssessmentScreen({
    super.key,
    required this.onAssessmentSelected,
  });

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  String? selectedOption;

  void _selectOption(String value) {
    setState(() {
      selectedOption = value;
    });
    widget.onAssessmentSelected(value);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fixed header section - using horizontal layout for better space usage
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
      speechText: 'Tôi muốn đánh giá khả năng tiếng Anh hiện tại của bạn!',
      duoType: DuoCharacterType.withGrad,
    );
  }
  
  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildAssessmentOptions(),
          SizedBox(height: 24.h),
          _buildSkipButton(),
        ],
      ),
    );
  }

  Widget _buildAssessmentOptions() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: [
          // Test đánh giá option
          AssessmentOptionTile(
            icon: '📝',
            title: 'Tôi muốn làm bài test đánh giá',
            description: 'Làm bài test ngắn để đánh giá chính xác trình độ hiện tại của bạn (5-10 phút)',
            buttonText: 'Bắt đầu',
            value: 'assessment',
            hasBlueAccent: true,
            isSelected: selectedOption == 'assessment',
            onTap: () => _selectOption('assessment'),
          ),
          
          SizedBox(height: 16.h),
          
          // Beginner option
          AssessmentOptionTile(
            icon: '🌱',
            title: 'Tôi là người mới bắt đầu',
            description: 'Tôi chưa có kiến thức gì về tiếng Anh hoặc chỉ biết một chút cơ bản',
            value: 'beginner',
            isSelected: selectedOption == 'beginner',
            onTap: () => _selectOption('beginner'),
          ),
        ],
      ),
    );
  }



  Widget _buildSkipButton() {
    return SkipButton(
      isSelected: selectedOption == 'skip',
      onTap: () => _selectOption('skip'),
    );
  }

  bool get hasSelectedOption => selectedOption != null;
  String? get selectedAssessment => selectedOption;
  
  void handleContinue() {
    if (selectedOption != null) {
      widget.onAssessmentSelected(selectedOption!);
    }
  }
}

