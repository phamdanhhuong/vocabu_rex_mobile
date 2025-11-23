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
        if (state is HomeSuccess && state.skillEntity != null) {
          // Find the SkillPartEntity that contains the current skill
          SkillPartEntity? currentSkillPart;
          if (state.skillPartEntities != null) {
            for (final skillPart in state.skillPartEntities!) {
              if (skillPart.skills != null) {
                final hasSkill = skillPart.skills!.any(
                  (skill) => skill.id == state.skillEntity!.id,
                );
                if (hasSkill) {
                  currentSkillPart = skillPart;
                  break;
                }
              }
            }
          }

          return LearningMapView(
            skillEntity: state.skillEntity!,
            userProgressEntity: state.userProgressEntity,
            skillPartEntity: currentSkillPart,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.snow),
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) =>
          current is HomeSuccess &&
          previous is! HomeSuccess &&
          current.skillEntity == null,
      listener: (context, state) {
        if (state is HomeSuccess && state.skillEntity == null) {
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
