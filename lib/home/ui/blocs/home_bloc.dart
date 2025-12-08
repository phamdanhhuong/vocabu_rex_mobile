import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_by_id_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_skill_part_usecase.dart';
import 'package:vocabu_rex_mobile/home/domain/usecases/get_user_progress_usecase.dart';

//Event
abstract class HomeEvent {}

class GetUserProgressEvent extends HomeEvent {}

class GetSkillEvent extends HomeEvent {
  String id;
  GetSkillEvent({required this.id});
}

class LoadSkillPartEvent extends HomeEvent {
  final String skillPartId;
  LoadSkillPartEvent({required this.skillPartId});
}

//State
abstract class HomeState {}

class HomeInit extends HomeState {}

class HomeUnauthen extends HomeState {}

class HomeLoading extends HomeState {}

class HomeSuccess extends HomeState {
  final UserProgressEntity userProgressEntity;
  final SkillEntity? skillEntity;
  final List<SkillEntity>? skillEntities; // Changed from single skill to list
  final List<SkillPartEntity>? skillPartEntities;
  final bool isLoadingSkillPart; // Flag để hiển thị loading overlay khi switch skill part
  
  HomeSuccess({
    required this.userProgressEntity,
    this.skillEntity,
    this.skillEntities,
    this.skillPartEntities,
    this.isLoadingSkillPart = false,
  });

  HomeSuccess copyWith({
    UserProgressEntity? userProgressEntity,
    SkillEntity? skillEntity,
    List<SkillEntity>? skillEntities,
    List<SkillPartEntity>? skillPartEntities,
    bool? isLoadingSkillPart,
  }) {
    return HomeSuccess(
      userProgressEntity: userProgressEntity ?? this.userProgressEntity,
      skillEntity: skillEntity ?? this.skillEntity,
      skillEntities: skillEntities ?? this.skillEntities,
      skillPartEntities: skillPartEntities ?? this.skillPartEntities,
      isLoadingSkillPart: isLoadingSkillPart ?? this.isLoadingSkillPart,
    );
  }
}

//Bloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetUserProgressUsecase getUserProgressUsecase;
  final GetSkillByIdUsecase getSkillByIdUsecase;
  final GetSkillPartUsecase getSkillPartUsecase;

  HomeBloc({
    required this.getUserProgressUsecase,
    required this.getSkillByIdUsecase,
    required this.getSkillPartUsecase,
  }) : super(HomeInit()) {
    on<GetUserProgressEvent>((event, emit) async {
      emit(HomeLoading());
      try {
        // Load skill parts first
        final skillParts = await getSkillPartUsecase();
        print('🔍 HomeBloc: Got ${skillParts.length} skill parts');
        
        // Try to get user progress
        UserProgressEntity progress;
        try {
          progress = await getUserProgressUsecase();
          print('🔍 HomeBloc: Got user progress - skillId: ${progress.skillId}');
        } catch (e) {
          print('⚠️ No user progress found. Creating default for new user...');
          // Create default progress for new user - start from first skill
          if (skillParts.isEmpty || skillParts.first.skills == null || skillParts.first.skills!.isEmpty) {
            print('❌ No skills available to create default progress');
            emit(HomeUnauthen());
            return;
          }
          final firstSkillId = skillParts.first.skills!.first.id;
          progress = UserProgressEntity(
            userId: '', // Will be filled by backend
            skillId: firstSkillId,
            levelReached: 1,
            lessonPosition: 1,
            lastPracticed: DateTime.now(),
            completionPercentage: 0,
          );
          print('✅ Created default progress for skill: $firstSkillId');
        }
        
        // Find current skill part and extract all skills from it
        List<SkillEntity>? skillsToDisplay;
        
        if (skillParts.isNotEmpty) {
          // Find the skill part containing the current skill
          for (final skillPart in skillParts) {
            print('🔍 Checking skill part ${skillPart.position}: ${skillPart.name}, has ${skillPart.skills?.length ?? 0} skills');
            if (skillPart.skills != null) {
              final hasSkill = skillPart.skills!.any(
                (skill) => skill.id == progress.skillId,
              );
              if (hasSkill) {
                // Load full skill details with levels for each skill
                print('📥 Loading full details for ${skillPart.skills!.length} skills...');
                final List<SkillEntity> detailedSkills = [];
                for (final skill in skillPart.skills!) {
                  try {
                    final detailedSkill = await getSkillByIdUsecase(skill.id);
                    detailedSkills.add(detailedSkill);
                    print('   ✓ Loaded ${detailedSkill.title} with ${detailedSkill.levels?.length ?? 0} levels');
                  } catch (e) {
                    print('   ✗ Failed to load skill ${skill.id}: $e');
                  }
                }
                skillsToDisplay = detailedSkills;
                print('✅ Found current skill part: ${skillPart.name} with ${skillsToDisplay.length} detailed skills');
                break;
              }
            }
          }
        }
        
        if (skillsToDisplay == null || skillsToDisplay.isEmpty) {
          print('⚠️ No skills to display! Using first skill part as fallback');
          if (skillParts.isNotEmpty && skillParts.first.skills != null) {
            final List<SkillEntity> detailedSkills = [];
            for (final skill in skillParts.first.skills!) {
              try {
                final detailedSkill = await getSkillByIdUsecase(skill.id);
                detailedSkills.add(detailedSkill);
              } catch (e) {
                print('   ✗ Failed to load skill ${skill.id}: $e');
              }
            }
            skillsToDisplay = detailedSkills;
          }
        }
        
        print('🎯 Final skillsToDisplay count: ${skillsToDisplay?.length ?? 0}');
        
        emit(
          HomeSuccess(
            userProgressEntity: progress,
            skillEntities: skillsToDisplay,
            skillPartEntities: skillParts,
          ),
        );
      } catch (e) {
        print('❌ HomeBloc Error: $e');
        emit(HomeUnauthen());
      }
    });

    on<GetSkillEvent>((event, emit) async {
      if (state is HomeSuccess) {
        final currentState = state as HomeSuccess;
        emit(HomeLoading());

        try {
          final skill = await getSkillByIdUsecase(event.id);
          emit(
            currentState.copyWith(
              skillEntity: skill,
              skillEntities: currentState.skillEntities,
              skillPartEntities:
                  currentState.skillPartEntities, // Preserve existing data
            ),
          );
        } catch (e) {
          print(e);
          emit(HomeUnauthen());
        }
      } else {
        // Nếu chưa có dữ liệu user, cần fetch trước
        emit(HomeLoading());
        try {
          final progress = await getUserProgressUsecase();
          final skill = await getSkillByIdUsecase(event.id);
          final skillParts = await getSkillPartUsecase();

          // Find current skill part and extract all skills
          List<SkillEntity>? skillsToDisplay;
          if (skillParts.isNotEmpty) {
            for (final skillPart in skillParts) {
              if (skillPart.skills != null) {
                final hasSkill = skillPart.skills!.any(
                  (s) => s.id == progress.skillId,
                );
                if (hasSkill) {
                  skillsToDisplay = skillPart.skills;
                  break;
                }
              }
            }
          }
          
          if (skillsToDisplay == null || skillsToDisplay.isEmpty) {
            skillsToDisplay = skillParts.isNotEmpty ? skillParts.first.skills : null;
          }

          emit(
            HomeSuccess(
              userProgressEntity: progress,
              skillEntity: skill,
              skillEntities: skillsToDisplay,
              skillPartEntities: skillParts,
            ),
          );
        } catch (e) {
          print(e);
          emit(HomeUnauthen());
        }
      }
    });

    on<LoadSkillPartEvent>((event, emit) async {
      if (state is HomeSuccess) {
        final currentState = state as HomeSuccess;
        
        // Emit loading state với flag isLoadingSkillPart = true
        emit(currentState.copyWith(isLoadingSkillPart: true));

        try {
          // Find the skill part to load
          final skillPart = currentState.skillPartEntities?.firstWhere(
            (sp) => sp.id == event.skillPartId,
          );

          if (skillPart?.skills == null || skillPart!.skills!.isEmpty) {
            print('❌ No skills found in skill part ${event.skillPartId}');
            emit(currentState.copyWith(isLoadingSkillPart: false));
            return;
          }

          print('📥 Loading skills for skill part: ${skillPart.name}');
          
          // Load full details for all skills in this part
          final List<SkillEntity> detailedSkills = [];
          for (final skill in skillPart.skills!) {
            try {
              final detailedSkill = await getSkillByIdUsecase(skill.id);
              detailedSkills.add(detailedSkill);
              print('   ✓ Loaded ${detailedSkill.title}');
            } catch (e) {
              print('   ✗ Failed to load skill ${skill.id}: $e');
            }
          }

          print('✅ Loaded ${detailedSkills.length} skills from part ${skillPart.position}');

          emit(
            currentState.copyWith(
              skillEntities: detailedSkills,
              skillPartEntities: currentState.skillPartEntities,
              isLoadingSkillPart: false, // Reset loading flag
            ),
          );
        } catch (e) {
          print('❌ LoadSkillPartEvent Error: $e');
          emit(currentState.copyWith(isLoadingSkillPart: false));
        }
      }
    });
  }
}
