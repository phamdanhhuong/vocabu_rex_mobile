import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/header_section.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/skill_divider.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/grammar_guide_page.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/skill_parts_overview_page.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';

/// Màn hình chính hiển thị bản đồ học tập (learning map).
/// Sử dụng CustomScrollView để có header dính (sticky header)
/// và danh sách các node bài học từ nhiều skills (giống Duolingo).
class LearningMapView extends StatefulWidget {
  final List<SkillEntity> skills;
  final UserProgressEntity userProgressEntity;
  final SkillPartEntity? skillPartEntity;
  final List<SkillPartEntity>? allSkillParts;

  const LearningMapView({
    super.key,
    required this.skills,
    required this.userProgressEntity,
    this.skillPartEntity,
    this.allSkillParts,
  });

  @override
  State<LearningMapView> createState() => _LearningMapViewState();
}

class _LearningMapViewState extends State<LearningMapView> {
  final ScrollController _scrollController = ScrollController();
  int _currentSkillIndex = 0;
  final Map<int, GlobalKey> _skillKeys = {};

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Create keys for each skill divider
    for (int i = 0; i < widget.skills.length; i++) {
      _skillKeys[i] = GlobalKey();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check which skill section is currently visible
    for (int i = widget.skills.length - 1; i >= 0; i--) {
      final key = _skillKeys[i];
      if (key?.currentContext != null) {
        final RenderBox? renderBox =
            key!.currentContext!.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          final position = renderBox.localToGlobal(Offset.zero);
          // If divider is above or near the header area (top 100px)
          if (position.dy <= 100) {
            if (_currentSkillIndex != i) {
              setState(() {
                _currentSkillIndex = i;
              });
            }
            break;
          }
        }
      }
    }
  }

  SkillEntity get _currentSkill => widget.skills[_currentSkillIndex];

  Color get _currentSectionColor {
    final palette = AppColors.lessonHeaderPalette;
    return (_currentSkill.position >= 0 && palette.isNotEmpty)
        ? palette[_currentSkill.position % palette.length]
        : AppColors.primary;
  }

  Color? get _currentSectionShadowColor {
    final shadowPalette = AppColors.lessonHeaderShadowPalette;
    return (_currentSkill.position >= 0 && shadowPalette.isNotEmpty)
        ? shadowPalette[_currentSkill.position % shadowPalette.length]
        : null;
  }
  /// Trả về NodeStatus dựa trên vị trí của skill và level so với progress.
  ///
  /// Logic:
  /// - Skill trước skillId hiện tại → completed
  /// - Skill sau skillId hiện tại → locked
  /// - Skill hiện tại:
  ///   - Level trước levelReached → completed
  ///   - Level tại levelReached → inProgress
  ///   - Level sau levelReached → locked
  NodeStatus _getNodeStatus(
    SkillEntity skill,
    int levelIndex,
    UserProgressEntity progress,
    SkillLevelEntity level,
  ) {
    // So sánh skill ID
    final isCurrentSkill = skill.id == progress.skillId;
    
    if (!isCurrentSkill) {
      // Xác định xem skill này nằm trước hay sau skill hiện tại
      // Dùng position để so sánh
      final currentSkillPosition = widget.skills.firstWhere(
        (s) => s.id == progress.skillId,
        orElse: () => skill,
      ).position;
      
      if (skill.position < currentSkillPosition) {
        return NodeStatus.completed;
      } else {
        // Skill sau skill hiện tại
        // Node đầu tiên (levelIndex == 0 && level.level == 1) hiển thị jumpAhead
        if (levelIndex == 0 && level.level == 1) {
          return NodeStatus.jumpAhead;
        }
        return NodeStatus.locked;
      }
    }
    
    // Skill hiện tại - kiểm tra level
    final int currentLevelIndex = progress.levelReached - 1;

    if (levelIndex > currentLevelIndex) return NodeStatus.locked;
    if (levelIndex < currentLevelIndex) return NodeStatus.completed;

    return NodeStatus.inProgress;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.skills.isEmpty) {
      return const Center(
        child: Text(
          'No skills available',
          style: TextStyle(color: AppColors.bodyText),
        ),
      );
    }

    final GlobalKey nodeKey = GlobalKey();
    context.read<ShowCaseCubit>().registerKey('node', nodeKey);

    // Build list of slivers for all skills
    List<Widget> slivers = [];
    bool isFirstNode = true;

    // Add single header at the top
    slivers.add(
      SliverPersistentHeader(
        delegate: SectionHeaderDelegate(
          title: 'PHẦN ${widget.skillPartEntity?.position ?? 1}, CỬA ${_currentSkill.position}',
          subtitle: _currentSkill.title,
          onPressed: () {
            if (widget.allSkillParts != null && widget.allSkillParts!.isNotEmpty) {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SkillPartsOverviewPage(
                    skillParts: widget.allSkillParts!,
                    currentSkillId: _currentSkill.id,
                  ),
                ),
              );
            }
          },
          onListPressed: () {
            // Find the skill with grammars from skillPartEntity
            SkillEntity? skillWithGrammars;
            if (widget.skillPartEntity?.skills != null) {
              try {
                skillWithGrammars = widget.skillPartEntity!.skills!.firstWhere(
                  (s) => s.id == _currentSkill.id,
                );
              } catch (e) {
                skillWithGrammars = _currentSkill;
              }
            } else {
              skillWithGrammars = _currentSkill;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => GrammarGuidePage(
                  skillEntity: skillWithGrammars ?? _currentSkill,
                  skillTitle: _currentSkill.title,
                  partPosition: widget.skillPartEntity?.position,
                ),
              ),
            );
          },
          buttonColor: _currentSectionColor,
          shadowColor: _currentSectionShadowColor,
        ),
        pinned: true,
      ),
    );

    for (int skillIndex = 0; skillIndex < widget.skills.length; skillIndex++) {
      final skill = widget.skills[skillIndex];
      if (skill.levels == null || skill.levels!.isEmpty) continue;

      // Determine section colors by skill position
      final palette = AppColors.lessonHeaderPalette;
      final Color sectionColor = (skill.position >= 0 && palette.isNotEmpty)
          ? palette[skill.position % palette.length]
          : AppColors.primary;
      
      final shadowPalette = AppColors.lessonHeaderShadowPalette;
      final Color? sectionShadowColor =
          (skill.position >= 0 && shadowPalette.isNotEmpty)
          ? shadowPalette[skill.position % shadowPalette.length]
          : null;

      // Add divider before skill (except first one)
      if (skillIndex > 0) {
        slivers.add(
          SliverToBoxAdapter(
            child: Container(
              key: _skillKeys[skillIndex],
              child: SkillDivider(
                title: skill.title,
                color: sectionColor,
              ),
            ),
          ),
        );
      } else {
        // Add invisible key container for first skill
        slivers.add(
          SliverToBoxAdapter(
            child: Container(
              key: _skillKeys[skillIndex],
              height: 0,
            ),
          ),
        );
      }

      // Add levels for this skill
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final level = skill.levels![index];
              final status = _getNodeStatus(skill, index, widget.userProgressEntity, level);

              // Wave alignment
              final double amplitude = AppTokens.nodeWaveAmplitude;
              final int wavePhase = index % 4;
              final double alignment = (wavePhase == 1)
                  ? -amplitude
                  : (wavePhase == 3)
                      ? amplitude
                      : 0.0;

              final isCurrentSkill = skill.id == widget.userProgressEntity.skillId;
              final node = LessonNode(
                skillLevel: level,
                status: status,
                sectionColor: sectionColor,
                sectionShadowColor: sectionShadowColor,
                lessonPosition: (status == NodeStatus.inProgress && isCurrentSkill)
                    ? widget.userProgressEntity.lessonPosition
                    : 0,
                totalLessons: level.lessons?.length ?? 0,
              );

              // Add showcase to first node only
              if (isFirstNode && level.level == 1) {
                isFirstNode = false;
                final nodeShowCase = Showcase(
                  key: nodeKey,
                  description: "Bấm vào đây để xem bài học",
                  disableDefaultTargetGestures: true,
                  onTargetClick: () {
                    ShowCaseWidget.of(context).next();
                  },
                  disposeOnTap: true,
                  child: node,
                );
                return Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTokens.nodeVerticalPadding,
                    horizontal: AppTokens.nodeHorizontalPadding,
                  ),
                  alignment: Alignment(alignment, 0.0),
                  child: nodeShowCase,
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.nodeVerticalPadding,
                  horizontal: AppTokens.nodeHorizontalPadding,
                ),
                alignment: Alignment(alignment, 0.0),
                child: node,
              );
            },
            childCount: skill.levels!.length,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: slivers,
      ),
    );
  }
}
