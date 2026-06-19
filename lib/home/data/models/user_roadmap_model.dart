import 'package:vocabu_rex_mobile/home/data/models/skill_model.dart';

class UserRoadmapModel {
  final String userId;
  final String roadmapId;
  final String status;
  final RoadmapModel roadmap;

  UserRoadmapModel({
    required this.userId,
    required this.roadmapId,
    required this.status,
    required this.roadmap,
  });

  factory UserRoadmapModel.fromJson(Map<String, dynamic> json) {
    return UserRoadmapModel(
      userId: json['userId'] ?? '',
      roadmapId: json['roadmapId'] ?? '',
      status: json['status'] ?? '',
      roadmap: RoadmapModel.fromJson(json['roadmap'] ?? {}),
    );
  }
}

class RoadmapModel {
  final String id;
  final String title;
  final String? description;
  final String targetGoal;
  final List<MilestoneModel> milestones;

  RoadmapModel({
    required this.id,
    required this.title,
    this.description,
    required this.targetGoal,
    required this.milestones,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    var milestonesList = json['milestones'] as List? ?? [];
    return RoadmapModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      targetGoal: json['targetGoal'] ?? '',
      milestones: milestonesList.map((m) => MilestoneModel.fromJson(m)).toList(),
    );
  }
}

class MilestoneModel {
  final String id;
  final String title;
  final int order;
  final List<SkillModel> skills;

  MilestoneModel({
    required this.id,
    required this.title,
    required this.order,
    required this.skills,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    var milestoneSkills = json['milestoneSkills'] as List? ?? [];
    List<SkillModel> parsedSkills = [];
    for (var ms in milestoneSkills) {
      if (ms['skill'] != null) {
        parsedSkills.add(SkillModel.fromJson(ms['skill']));
      }
    }
    return MilestoneModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      order: json['order'] ?? 0,
      skills: parsedSkills,
    );
  }
}
