import 'package:flutter/material.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';

class LearningMap extends StatefulWidget {
  final SkillEntity skillEntity;
  const LearningMap({super.key, required this.skillEntity});

  @override
  State<LearningMap> createState() => _LearningMapState();
}

class _LearningMapState extends State<LearningMap> {
  SkillEntity get _skillEntity => widget.skillEntity;
  @override
  Widget build(BuildContext context) {
    if (_skillEntity.levels == null || _skillEntity.levels!.isEmpty) {
      return const Center(
        child: Text(
          'No levels available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: _skillEntity.levels!.length,
      itemBuilder: (context, index) {
        double offset = 40;
        // chẵn lệch trái, lẻ lệch phải (40px)
        return SizedBox(
          height: 100,
          width: 100,
          child: Center(
            child: Container(
              padding: index.isEven
                  ? EdgeInsets.only(left: offset)
                  : EdgeInsets.only(right: offset),
              child: Node(skillLevel: _skillEntity.levels![index]),
            ),
          ),
        );
      },
    );
  }
}
