import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';

class GenerateRoadmapFormDialog extends StatefulWidget {
  final String initialLanguage;
  final String initialProficiency;
  final List<String> initialGoals;
  final int initialMinutes;

  const GenerateRoadmapFormDialog({
    super.key,
    required this.initialLanguage,
    required this.initialProficiency,
    required this.initialGoals,
    required this.initialMinutes,
  });

  @override
  State<GenerateRoadmapFormDialog> createState() =>
      _GenerateRoadmapFormDialogState();
}

class _GenerateRoadmapFormDialogState extends State<GenerateRoadmapFormDialog> {
  late String _targetLanguage;
  late String _proficiencyLevel;
  late List<String> _learningGoals;
  late int _dailyGoalMinutes;

  final List<String> _languages = ['English', 'Spanish', 'French', 'German', 'Japanese', 'Korean', 'Chinese'];
  final List<String> _proficiencies = ['BEGINNER', 'ELEMENTARY', 'INTERMEDIATE', 'UPPER_INTERMEDIATE', 'ADVANCED', 'PROFICIENT'];
  final List<String> _availableGoals = ['CONNECT', 'TRAVEL', 'STUDY', 'ENTERTAINMENT', 'CAREER', 'HOBBY'];
  final List<int> _minutesOptions = [5, 10, 15, 30, 45, 60];

  @override
  void initState() {
    super.initState();
    _targetLanguage = widget.initialLanguage.isNotEmpty ? widget.initialLanguage : 'English';
    _proficiencyLevel = widget.initialProficiency.isNotEmpty ? widget.initialProficiency : 'BEGINNER';
    _learningGoals = widget.initialGoals.isNotEmpty ? List.from(widget.initialGoals) : ['CONNECT'];
    _dailyGoalMinutes = widget.initialMinutes > 0 ? widget.initialMinutes : 15;
  }

  void _submit() {
    Navigator.of(context).pop();
    context.read<HomeBloc>().add(
          GenerateRoadmapEvent(
            targetLanguage: _targetLanguage,
            proficiencyLevel: _proficiencyLevel,
            learningGoals: _learningGoals,
            dailyGoalMinutes: _dailyGoalMinutes,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppPreferences().isDarkMode;
    final textColor = isDark ? Colors.white : AppColors.bodyText;
    
    return AlertDialog(
      title: Text('Tạo Lộ Trình Mới', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      backgroundColor: isDark ? Colors.black87 : Colors.white,
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Lộ trình hiện tại sẽ bị hủy. Vui lòng cập nhật mục tiêu học tập mới của bạn nếu cần:'),
            const SizedBox(height: 16),
            
            Text('Ngôn ngữ mục tiêu', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            DropdownButton<String>(
              isExpanded: true,
              value: _languages.contains(_targetLanguage) ? _targetLanguage : null,
              dropdownColor: isDark ? Colors.black87 : Colors.white,
              items: _languages.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _targetLanguage = val);
              },
            ),
            const SizedBox(height: 16),
            
            Text('Trình độ hiện tại', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            DropdownButton<String>(
              isExpanded: true,
              value: _proficiencies.contains(_proficiencyLevel) ? _proficiencyLevel : null,
              dropdownColor: isDark ? Colors.black87 : Colors.white,
              items: _proficiencies.map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: textColor)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _proficiencyLevel = val);
              },
            ),
            const SizedBox(height: 16),
            
            Text('Mục tiêu học tập', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            Wrap(
              spacing: 8,
              children: _availableGoals.map((goal) {
                final isSelected = _learningGoals.contains(goal);
                return FilterChip(
                  label: Text(goal, style: TextStyle(color: isSelected ? Colors.white : textColor)),
                  selected: isSelected,
                  selectedColor: AppColors.macaw,
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _learningGoals.add(goal);
                      } else {
                        if (_learningGoals.length > 1) {
                           _learningGoals.remove(goal);
                        }
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            Text('Mục tiêu hàng ngày', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            DropdownButton<int>(
              isExpanded: true,
              value: _minutesOptions.contains(_dailyGoalMinutes) ? _dailyGoalMinutes : null,
              dropdownColor: isDark ? Colors.black87 : Colors.white,
              items: _minutesOptions.map((e) => DropdownMenuItem(value: e, child: Text('$e phút', style: TextStyle(color: textColor)))).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _dailyGoalMinutes = val);
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.macaw),
          child: const Text('Tạo Mới', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
