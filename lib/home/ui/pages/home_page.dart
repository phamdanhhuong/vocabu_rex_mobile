import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/widgets/current_currency_widget.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/streak/ui/widgets/current_streak_widget.dart';
import 'package:vocabu_rex_mobile/home/ui/widgets/learning_map.dart';
import 'package:vocabu_rex_mobile/constants/app_colors.dart';

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
    });
  }

  Widget _buildLearningMapPage() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeSuccess && state.skillEntity != null) {
          return LearningMap(
            skillEntity: state.skillEntity!,
            userProgressEntity: state.userProgressEntity,
          );
        } else {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textWhite),
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
            backgroundColor: AppColors.backgroundColor,
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(100),
              child: Column(
                children: [
                  CurrentCurrencyWidget(),
                  CurrentStreakWidget(),
                ],
              ),
            ),
            body: _buildLearningMapPage(),
          );
        },
      ),
    );
  }
}
