import 'package:vocabu_rex_mobile/home/data/models/user_roadmap_model.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';

class UserRoadmapEntity {
  final String userId;
  final String roadmapId;
  final String status;
  final RoadmapEntity roadmap;

  UserRoadmapEntity({
    required this.userId,
    required this.roadmapId,
    required this.status,
    required this.roadmap,
  });

  factory UserRoadmapEntity.fromModel(UserRoadmapModel model) {
    return UserRoadmapEntity(
      userId: model.userId,
      roadmapId: model.roadmapId,
      status: model.status,
      roadmap: RoadmapEntity.fromModel(model.roadmap),
    );
  }
}

class RoadmapEntity {
  final String id;
  final String title;
  final String? description;
  final String targetGoal;
  final List<MilestoneEntity> milestones;

  RoadmapEntity({
    required this.id,
    required this.title,
    this.description,
    required this.targetGoal,
    required this.milestones,
  });

  factory RoadmapEntity.fromModel(RoadmapModel model) {
    return RoadmapEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      targetGoal: model.targetGoal,
      milestones: model.milestones.map((m) => MilestoneEntity.fromModel(m)).toList(),
    );
  }
}

class MilestoneEntity {
  final String id;
  final String title;
  final int order;
  final List<SkillEntity> skills;

  MilestoneEntity({
    required this.id,
    required this.title,
    required this.order,
    required this.skills,
  });

  factory MilestoneEntity.fromModel(MilestoneModel model) {
    return MilestoneEntity(
      id: model.id,
      title: model.title,
      order: model.order,
      skills: model.skills.map((s) => SkillEntity.fromModel(s)).toList(),
    );
  }
}
