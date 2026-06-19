import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/core/app_preferences.dart';
import 'package:vocabu_rex_mobile/exercise/domain/entities/exercise_meta_entity.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';

class BattleMultipleChoice extends StatefulWidget {
  final MultipleChoiceMetaEntity meta;
  final String exerciseId;

  const BattleMultipleChoice({
    super.key,
    required this.meta,
    required this.exerciseId,
  });

  @override
  State<BattleMultipleChoice> createState() => _BattleMultipleChoiceState();
}

class _BattleMultipleChoiceState extends State<BattleMultipleChoice> {
  int? _selectedOrder;
  bool _submitted = false;

  void _onOptionSelected(int order) {
    if (_submitted) return;
    setState(() {
      _selectedOrder = order;
      _submitted = true;
    });

    final correctAnswerOrder = widget.meta.correctOrder.isNotEmpty 
        ? widget.meta.correctOrder.first.toString() 
        : '';
    context.read<ExerciseBloc>().add(
      AnswerSelected(
        exerciseId: widget.exerciseId,
        selectedAnswer: order.toString(),
        correctAnswer: correctAnswerOrder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E2C) : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? Colors.white12 : AppColors.swan),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.macaw.withValues(alpha: 0.1),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.meta.question,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.bodyText,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.h),
              
              Expanded(
                child: ListView.separated(
                  itemCount: widget.meta.options.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (ctx, idx) {
                    final option = widget.meta.options[idx];
                    final isSelected = _selectedOrder == option.order;
                    final isCorrect = widget.meta.correctOrder.contains(option.order);
                    
                    String status = 'idle';
                    if (_submitted) {
                      if (isSelected) {
                        status = isCorrect ? 'correct' : 'wrong';
                      } else if (isCorrect) {
                        status = 'correct';
                      }
                    }

                    Widget btn = _BattleOptionButton(
                      text: option.text,
                      status: status,
                      onTap: () => _onOptionSelected(option.order),
                    );

                    if (_submitted && isSelected) {
                      if (isCorrect) {
                        btn = Flash(duration: const Duration(milliseconds: 600), child: BounceInDown(child: btn));
                      } else {
                        btn = ShakeX(duration: const Duration(milliseconds: 400), child: btn);
                      }
                    } else if (_submitted && isCorrect) {
                      btn = Pulse(infinite: true, child: btn);
                    }

                    return btn;
                  },
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}

class _BattleOptionButton extends StatelessWidget {
  final String text;
  final String status;
  final VoidCallback onTap;

  const _BattleOptionButton({
    required this.text,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppPreferences(),
      builder: (context, _) {
        final isDark = AppPreferences().isDarkMode;
        Color borderColor = isDark ? Colors.white24 : AppColors.swan;
        Color bgColor = isDark ? const Color(0xFF2A2A3C) : Colors.white;
        Color textColor = isDark ? Colors.white : AppColors.bodyText;
        Color glowColor = Colors.transparent;

        if (status == 'correct') {
          borderColor = AppColors.featherGreen;
          bgColor = AppColors.featherGreen.withValues(alpha: 0.15);
          textColor = AppColors.featherGreen;
          glowColor = AppColors.featherGreen.withValues(alpha: 0.4);
        } else if (status == 'wrong') {
          borderColor = AppColors.cardinal;
          bgColor = AppColors.cardinal.withValues(alpha: 0.15);
          textColor = AppColors.cardinal;
          glowColor = AppColors.cardinal.withValues(alpha: 0.4);
        }

        Widget content = AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor, width: status == 'idle' ? 1 : 3),
            boxShadow: status == 'idle' ? [
              BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.swan, blurRadius: 10, offset: const Offset(0, 4)),
            ] : [
              BoxShadow(color: glowColor, blurRadius: 20, spreadRadius: 2),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: status == 'idle' ? FontWeight.w800 : FontWeight.w900,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );

        return GestureDetector(
          onTap: status != 'idle' ? null : onTap,
          child: content,
        );
      },
    );
  }
}
