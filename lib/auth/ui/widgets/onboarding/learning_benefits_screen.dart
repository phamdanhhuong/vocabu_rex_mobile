import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'components/duo_with_speech.dart';
import 'components/duo_character.dart';
import 'components/benefit_item.dart';

class LearningBenefitsScreen extends StatelessWidget {
  const LearningBenefitsScreen({super.key});

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
      speechText: 'Và đây là những gì bạn có thể đạt được sau 3 tháng!',
      duoType: DuoCharacterType.withBook,
    );
  }

  Widget _buildScrollableContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildBenefitsList(),
        ],
      ),
    );
  }

  Widget _buildBenefitsList() {
    final benefits = [
      (
        '💬',
        'Tự tin giao tiếp',
        'Luyện nghe nói không áp lực',
        Colors.purple[300]!,
      ),
      (
        '📖',
        'Xây dựng vốn từ',
        'Các từ và cụm từ phổ biến, thiết thực trong đời sống',
        Colors.blue[300]!,
      ),
      (
        '⏰',
        'Tạo thói quen học tập',
        'Nhắc nhở thông minh, thử thách vui nhộn và còn nhiều tính năng thú vị khác',
        Colors.orange[300]!,
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(
        children: benefits.map((benefit) {
          return Column(
            children: [
              BenefitItem(
                icon: benefit.$1,
                title: benefit.$2,
                description: benefit.$3,
                iconColor: benefit.$4,
              ),
              SizedBox(height: 24.h),
            ],
          );
        }).toList(),
      ),
    );
  }


}

