import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/theme/tokens.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/header_section.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/skill_divider.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_level_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/user_progress_entity.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/grammar_guide_page.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/roadmap_overview_page.dart';
import 'aurora_map_background.dart';
import 'package:animate_do/animate_do.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/node_types.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/mini_game_node.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/chest_node.dart';
import 'package:vocabu_rex_mobile/quest/data/services/quest_service.dart';
import 'package:vocabu_rex_mobile/core/zoom_in_route.dart';
import 'package:vocabu_rex_mobile/minigame/ui/blocs/minigame_bloc.dart';
import 'package:vocabu_rex_mobile/minigame/ui/pages/minigame_play_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'dart:developer' as developer;

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
  List<String> claimedChestIds = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Create keys for each skill divider
    for (int i = 0; i < widget.skills.length; i++) {
      _skillKeys[i] = GlobalKey();
    }
    _loadClaimedChests();
  }

  Future<void> _loadClaimedChests() async {
    try {
      final ids = await QuestService().getClaimedMapChests(
        partId: widget.skillPartEntity?.id,
      );
      if (mounted) {
        setState(() {
          claimedChestIds = ids;
        });
      }
    } catch (e) {
      developer.log('Failed to load claimed chests: $e', name: 'LearningMap');
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
      final currentSkillPosition = widget.skills
          .firstWhere((s) => s.id == progress.skillId, orElse: () => skill)
          .position;

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
      return Center(
        child: Text(
          'No skills available',
          style: TextStyle(color: AppColors.bodyText),
        ),
      );
    }

    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    
    Widget content = _buildLearningMapContent(context);

    if (route != null && route.secondaryAnimation != null) {
      return ScaleTransition(
        scale: Tween<double>(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(
            parent: route.secondaryAnimation!,
            curve: Curves.easeInBack,
          ),
        ),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.0).animate(
            CurvedAnimation(
              parent: route.secondaryAnimation!,
              curve: Curves.easeOut,
            ),
          ),
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildLearningMapContent(BuildContext context) {
    final GlobalKey nodeKey = GlobalKey();
    context.read<ShowCaseCubit>().registerKey('node', nodeKey);

    // Build list of slivers for all skills
    List<Widget> slivers = [];
    bool isFirstNode = true;
    int globalLevelIndex = 0;

    // Add single header at the top
    slivers.add(
      SliverPersistentHeader(
        delegate: SectionHeaderDelegate(
          title:
              '${widget.skillPartEntity?.name?.toUpperCase() ?? "PHẦN ${widget.skillPartEntity?.position ?? 1}"}, CỬA ${_currentSkill.position}',
          subtitle: _currentSkill.title,
          onPressed: () {
            if (widget.allSkillParts != null &&
                widget.allSkillParts!.isNotEmpty) {
              Navigator.of(context).push<String>(
                PageRouteBuilder(
                  transitionDuration: const Duration(milliseconds: 1200),
                  reverseTransitionDuration: const Duration(milliseconds: 1200),
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      RoadmapOverviewPage(
                    milestones: widget.allSkillParts!,
                    currentSkillId: _currentSkill.id,
                  ),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    var fadeAnimation = CurvedAnimation(
                      parent: animation,
                      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut), // Wait for the old screen to shrink a bit
                    );
                    
                    // Zoom out effect: starts at 3.0x size (giant galaxy) and scales down to 1.0x (normal view)
                    var scaleAnimation = Tween<double>(begin: 3.0, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
                      ),
                    );

                    return FadeTransition(
                      opacity: fadeAnimation,
                      child: ScaleTransition(
                        scale: scaleAnimation,
                        child: child,
                      ),
                    );
                  },
                ),
              ).then((selectedMilestoneId) {
                if (selectedMilestoneId != null) {
                  // Mở bản đồ của chặng được chọn (nếu khác chặng hiện tại)
                  if (widget.skillPartEntity?.id != selectedMilestoneId) {
                    context.read<HomeBloc>().add(LoadSkillPartEvent(skillPartId: selectedMilestoneId));
                  }
                }
              });
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
              child: SkillDivider(title: skill.title, color: sectionColor),
            ),
          ),
        );
      } else {
        // Add invisible key container for first skill
        slivers.add(
          SliverToBoxAdapter(
            child: Container(key: _skillKeys[skillIndex], height: 0),
          ),
        );
      }

      final startGlobalIndex = globalLevelIndex;
      globalLevelIndex += skill.levels!.length;

      // Add levels for this skill
      slivers.add(
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final level = skill.levels![index];
            final status = _getNodeStatus(
              skill,
              index,
              widget.userProgressEntity,
              level,
            );

            // Continuous Wave alignment across skills
            final int currentGlobalIndex = startGlobalIndex + index;
            final double amplitude = AppTokens.nodeWaveAmplitude; 
            final double alignment = math.sin(currentGlobalIndex * math.pi / 4) * amplitude;

            final isCurrentSkill =
                skill.id == widget.userProgressEntity.skillId;
            final isPassedSkill = widget.skills
                    .indexWhere((s) => s.id == widget.userProgressEntity.skillId) >
                skillIndex;

            final node = LessonNode(
              skillLevel: level,
              status: status,
              sectionColor: sectionColor,
              sectionShadowColor: sectionShadowColor,
              lessonPosition:
                  (status == NodeStatus.inProgress && isCurrentSkill)
                  ? widget.userProgressEntity.lessonPosition
                  : 0,
              totalLessons: level.lessons?.length ?? 0,
              globalIndex: currentGlobalIndex,
            );

            Widget finalNode = node;
            if (isFirstNode && level.level == 1) {
              isFirstNode = false;
              finalNode = Showcase(
                key: nodeKey,
                description: "Bấm vào đây để xem bài học",
                disableDefaultTargetGestures: true,
                onTargetClick: () {
                  ShowCaseWidget.of(context).next();
                },
                disposeOnTap: true,
                child: node,
              );
            }

            // Inject MiniGameNode at the extremes of the sine wave
            Widget wrappedNode;
            if (currentGlobalIndex % 8 == 2) {
              wrappedNode = Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.nodeVerticalPadding,
                  horizontal: 0,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                       Positioned(
                        left: 40,
                        child: MiniGameNode(
                          type: MiniGameType.puzzle,
                          stars: 0, // TODO: load real stars from status
                          isLocked: status == NodeStatus.locked || status == NodeStatus.jumpAhead,
                          onTap: () {
                            Navigator.of(context).push(
                              ZoomInPageRoute(
                                page: BlocProvider(
                                  create: (_) => sl<MiniGameBloc>(),
                                  child: MiniGamePlayPage(
                                    partId: widget.skillPartEntity?.id ?? '',
                                    gameType: 'PUZZLE',
                                    milestoneName: widget.skillPartEntity?.name ?? 'Minigame',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment(alignment, 0.0),
                        child: finalNode,
                      ),
                    ],
                  ),
                ),
              );
            } else if (currentGlobalIndex % 8 == 6) {
              wrappedNode = Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.nodeVerticalPadding,
                  horizontal: 0,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                       Positioned(
                        right: 40,
                        child: MiniGameNode(
                          type: MiniGameType.arcade,
                          stars: 0, // TODO: load real stars from status
                          isLocked: status == NodeStatus.locked || status == NodeStatus.jumpAhead,
                          onTap: () {
                            Navigator.of(context).push(
                              ZoomInPageRoute(
                                page: BlocProvider(
                                  create: (_) => sl<MiniGameBloc>(),
                                  child: MiniGamePlayPage(
                                    partId: widget.skillPartEntity?.id ?? '',
                                    gameType: 'ARCADE',
                                    milestoneName: widget.skillPartEntity?.name ?? 'Minigame',
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Align(
                        alignment: Alignment(alignment, 0.0),
                        child: finalNode,
                      ),
                    ],
                  ),
                ),
              );
            } else {
              wrappedNode = Container(
                padding: const EdgeInsets.symmetric(
                  vertical: AppTokens.nodeVerticalPadding,
                  horizontal: AppTokens.nodeHorizontalPadding,
                ),
                alignment: Alignment(alignment, 0.0),
                child: finalNode,
              );
            }

            // Wrap in FadeInUp animation
            wrappedNode = FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: Duration(milliseconds: (currentGlobalIndex % 10) * 100),
              child: wrappedNode,
            );

            List<Widget> columnChildren = [wrappedNode];

            // Inject Chest Node after every 3 lessons or at the end of skill
            bool shouldInjectChest = (index + 1) % 3 == 0 || (index == skill.levels!.length - 1);
            if (shouldInjectChest) {
              final chestId = 'skill_${skill.id}_chest_${index}';
              final chestGlobalIndex = currentGlobalIndex + 0.5; // Offset phase slightly
              final chestAlignment = math.sin(chestGlobalIndex * math.pi / 4) * amplitude;

              ChestNodeStatus chestStatus;
              if (isPassedSkill || (isCurrentSkill && widget.userProgressEntity.levelReached > level.level)) {
                chestStatus = claimedChestIds.contains(chestId) ? ChestNodeStatus.opened : ChestNodeStatus.readyToOpen;
              } else if (isCurrentSkill && widget.userProgressEntity.levelReached == level.level && widget.userProgressEntity.lessonPosition > (level.lessons?.length ?? 0)) {
                chestStatus = claimedChestIds.contains(chestId) ? ChestNodeStatus.opened : ChestNodeStatus.readyToOpen;
              } else {
                chestStatus = ChestNodeStatus.locked;
              }

              columnChildren.add(
                FadeInUp(
                  duration: const Duration(milliseconds: 600),
                  delay: Duration(milliseconds: ((currentGlobalIndex + 1) % 10) * 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTokens.nodeVerticalPadding * 1.5,
                    ),
                    alignment: Alignment(chestAlignment, 0.0),
                    child: ChestNode(
                      status: chestStatus,
                    onOpen: () async {
                      try {
                        await QuestService().claimMapChest(
                          chestId, skill.id!, level.level,
                          partId: widget.skillPartEntity?.id,
                        );
                        setState(() {
                          claimedChestIds.add(chestId);
                        });
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Bạn nhận được 50 Vàng! 💰')),
                          );
                        }
                      } catch (e) {
                        developer.log('Lỗi khi mở rương: $e', name: 'LearningMap');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Rương này đã được mở hoặc có lỗi xảy ra!')),
                          );
                          setState(() {
                            claimedChestIds.add(chestId);
                          });
                        }
                      }
                    },
                  ),
                ),
              ),
            );
          }

            return Column(children: columnChildren);
          }, childCount: skill.levels!.length),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent, // Let aurora show through
      body: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: AuroraMapBackground(
                scrollController: _scrollController,
                sectionColor: _currentSectionColor,
                sectionShadowColor: _currentSectionShadowColor,
              ),
            ),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: CustomScrollView(controller: _scrollController, slivers: slivers),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
