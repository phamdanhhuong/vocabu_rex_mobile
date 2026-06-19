import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:animate_do/animate_do.dart';
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

    // Check if correct
    final isCorrect = widget.meta.correctOrder.contains(order);
    
    // Submit answer to ExerciseBloc
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Prompt Container with Spotlight effect
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.macaw.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  offset: const Offset(0, 10),
                  blurRadius: 20,
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
                  color: Colors.white,
                  fontFamily: 'DuolingoFeather',
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 40.h),
          
          // Options Grid/List
          Expanded(
            child: ListView.separated(
              itemCount: widget.meta.options.length,
              separatorBuilder: (_, __) => SizedBox(height: 16.h),
              itemBuilder: (ctx, idx) {
                final option = widget.meta.options[idx];
                final isSelected = _selectedOrder == option.order;
                final isCorrect = widget.meta.correctOrder.contains(option.order);

                Widget btn = _BattleOptionButton(
                  text: option.text,
                  isSelected: isSelected,
                  isCorrect: isCorrect,
                  showResult: _submitted,
                  onTap: () => _onOptionSelected(option.order),
                );

                if (_submitted && isSelected) {
                  // If selected and correct -> Flash and Bounce
                  if (isCorrect) {
                    btn = Flash(duration: const Duration(milliseconds: 600), child: BounceInDown(child: btn));
                  } else {
                    // If selected and wrong -> Shake
                    btn = ShakeX(duration: const Duration(milliseconds: 400), child: btn);
                  }
                } else if (_submitted && isCorrect) {
                  // If not selected but it is the correct answer -> Pulse to show what it was
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
}

class _BattleOptionButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool showResult;
  final VoidCallback onTap;

  const _BattleOptionButton({
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.showResult,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.white24;
    Color bgColor = const Color(0xFF2A2A3C);
    Color textColor = Colors.white;
    List<BoxShadow> shadows = [];

    if (showResult) {
      if (isSelected) {
        if (isCorrect) {
          borderColor = AppColors.featherGreen;
          bgColor = AppColors.featherGreen.withValues(alpha: 0.2);
          textColor = AppColors.featherGreen;
          shadows = [
            BoxShadow(color: AppColors.featherGreen.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
          ];
        } else {
          borderColor = AppColors.cardinal;
          bgColor = AppColors.cardinal.withValues(alpha: 0.2);
          textColor = AppColors.cardinal;
          shadows = [
            BoxShadow(color: AppColors.cardinal.withValues(alpha: 0.4), blurRadius: 20, spreadRadius: 2),
          ];
        }
      } else if (isCorrect) {
        borderColor = AppColors.featherGreen;
        textColor = AppColors.featherGreen;
      }
    } else {
      // Hover/Idle state
      shadows = [
        BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4)),
      ];
    }

    Widget content = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: showResult && (isSelected || isCorrect) ? 3 : 1),
        boxShadow: shadows,
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: textColor,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );

    if (showResult && !isSelected && !isCorrect) {
      content = Opacity(opacity: 0.5, child: content);
    }

    return GestureDetector(
      onTap: showResult ? null : onTap,
      child: content,
    );
  }
}
