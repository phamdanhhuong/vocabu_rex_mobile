import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/learning_map.dart';
import 'package:vocabu_rex_mobile/home/domain/entities/skill_part_entity.dart';
import 'package:vocabu_rex_mobile/theme/colors.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/home_app_bar.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_event.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/home_loading_skeleton.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/smooth_loading_wrapper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    super.initState();
    context.read<HomeBloc>().add(GetUserProgressEvent());
    // Gửi event lấy currency balance cho CurrencyBloc
    Future.microtask(() {
      context.read<CurrencyBloc>().add(GetCurrencyBalanceEvent(''));
      context.read<StreakBloc>().add(GetStreakHistoryEvent());
      context.read<EnergyBloc>().add(GetEnergyStatusEvent());
      context.read<FabCubit>().show();
    });
  }

  Widget _buildLearningMapPage() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final isLoading = state is HomeLoading || 
                         (state is! HomeSuccess) ||
                         (state is HomeSuccess && (state.skillEntities == null || state.skillEntities!.isEmpty));
        
        // Widget content khi đã load xong
        Widget contentWidget = const HomeLoadingSkeleton(); // Fallback
        
        if (state is HomeSuccess && state.skillEntities != null && state.skillEntities!.isNotEmpty) {
          // Find the SkillPartEntity that contains the current skill
          SkillPartEntity? currentSkillPart;
          if (state.skillPartEntities != null) {
            for (final skillPart in state.skillPartEntities!) {
              if (skillPart.skills != null) {
                final hasSkill = skillPart.skills!.any(
                  (skill) => skill.id == state.userProgressEntity.skillId,
                );
                if (hasSkill) {
                  currentSkillPart = skillPart;
                  break;
                }
              }
            }
          }

          // Nếu đang load skill part, chỉ hiển thị loading overlay
          if (state.isLoadingSkillPart) {
            contentWidget = Container(
              color: AppColors.background,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.macaw),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải phần học...',
                      style: TextStyle(
                        color: AppColors.bodyText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            // Chỉ render LearningMapView khi không loading
            contentWidget = LearningMapView(
              skills: state.skillEntities!,
              userProgressEntity: state.userProgressEntity,
              skillPartEntity: currentSkillPart,
              allSkillParts: state.skillPartEntities,
            );
          }
        }
        
        // Wrap toàn bộ với SmoothLoadingWrapper
        return SmoothLoadingWrapper(
          isLoading: isLoading,
          loadingWidget: const HomeLoadingSkeleton(),
          contentWidget: contentWidget,
          minimumLoadingDuration: const Duration(milliseconds: 1000), // 1 giây tối thiểu
          fadeDuration: const Duration(milliseconds: 500), // 0.5 giây fade
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          current is HomeSuccess &&
          previous is! HomeSuccess &&
          current.skillEntities == null,
      listener: (context, state) {
        if (state is HomeSuccess && state.skillEntities == null) {
          // Lấy skillId từ userProgress và gọi GetSkillEvent
          final skillId = state.userProgressEntity.skillId;
          context.read<HomeBloc>().add(GetSkillEvent(id: skillId));
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          return Scaffold(
            backgroundColor: AppColors.polar,
            appBar: HomeAppBar(),
            body: _buildLearningMapPage(),
          );
        },
      ),
    );
  }
}
