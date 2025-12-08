import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/assistant/ui/blocs/chat_bloc.dart';
import 'package:vocabu_rex_mobile/assistant/ui/pages/assistant_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/currency/ui/blocs/currency_bloc.dart';
import 'package:vocabu_rex_mobile/energy/ui/blocs/energy_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/fab_cubit.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/show_case_cubit.dart';
import 'package:vocabu_rex_mobile/streak/ui/blocs/streak_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/exercise_page.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/pages/pronunciation_page.dart';
import 'package:vocabu_rex_mobile/friend/ui/blocs/friend_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/pronunciation/ui/blocs/pronunciation_bloc.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/intro.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/login_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/onboarding_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/register_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/welcome_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/forgot_password_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/reset_password_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/profile/ui/blocs/profile_bloc.dart';
import 'package:vocabu_rex_mobile/profile/ui/pages/profile_page.dart';
import 'package:vocabu_rex_mobile/feed/ui/blocs/feed_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/quest_chest_bloc.dart';
import 'package:vocabu_rex_mobile/quest/ui/blocs/friends_quest_bloc.dart';
import 'package:vocabu_rex_mobile/leaderboard/ui/blocs/leaderboard_bloc.dart';
import 'package:vocabu_rex_mobile/achievement/ui/blocs/achievement_bloc.dart';

import 'package:vocabu_rex_mobile/content/content_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo dependency injection
  init();

  await dotenv.load(fileName: ".env");

  // Khôi phục token nếu có
  final hasToken = await TokenManager.hasValidToken();
  if (hasToken) {
    final token = await TokenManager.getAccessToken();
    if (token != null) {
      // Cần gọi saveAccessToken để set token cho AuthInterceptor khi app khởi động lại
      await TokenManager.saveAccessToken(token);
    }
  }

  final authBloc = sl<AuthBloc>();
  final homeBloc = sl<HomeBloc>();
  final profileBloc = sl<ProfileBloc>();
  final currencyBloc = sl<CurrencyBloc>();
  final streakBloc = sl<StreakBloc>();
  final energyBloc = sl<EnergyBloc>();
  final chatBLoc = sl<ChatBloc>();
  final friendBloc = sl<FriendBloc>();
  final pronunciationBloc = sl<PronunciationBloc>();
  final feedBloc = sl<FeedBloc>();
  final questBloc = sl<QuestBloc>();
  final questChestBloc = sl<QuestChestBloc>();
  final friendsQuestBloc = sl<FriendsQuestBloc>();
  final leaderboardBloc = sl<LeaderboardBloc>();
  final achievementBloc = sl<AchievementBloc>();
  final showCaseCubit = ShowCaseCubit();
  final fabCubit = FabCubit();
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: homeBloc),
        BlocProvider.value(value: profileBloc),
        BlocProvider.value(value: currencyBloc),
        BlocProvider.value(value: streakBloc),
        BlocProvider.value(value: energyBloc),
        BlocProvider.value(value: chatBLoc),
        BlocProvider.value(value: friendBloc),
        BlocProvider.value(value: pronunciationBloc),
        BlocProvider.value(value: feedBloc),
        BlocProvider.value(value: questBloc),
        BlocProvider.value(value: questChestBloc),
        BlocProvider.value(value: friendsQuestBloc),
        BlocProvider.value(value: leaderboardBloc),
        BlocProvider.value(value: achievementBloc),
        BlocProvider.value(value: showCaseCubit),
        BlocProvider.value(value: fabCubit),
      ],
      child: MyApp(hasToken: hasToken),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool hasToken;

  const MyApp({super.key, this.hasToken = false});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812), // kích thước gốc (iPhone X)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'VocabuRex',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1F1F1F),
            ),
          ),
          home: hasToken ? const ContentPage() : const WelcomePage(),
          routes: <String, WidgetBuilder>{
            '/intro': (BuildContext context) => const Intro(),
            '/welcome': (BuildContext context) => const WelcomePage(),
            '/onboarding': (BuildContext context) => const OnboardingPage(),
            '/home': (BuildContext context) => const ContentPage(),
            '/register': (BuildContext context) => const RegisterPage(),
            '/login': (BuildContext context) => const LoginPage(),
            '/forgot-password': (BuildContext context) => const ForgotPasswordPage(),
            '/reset-password': (BuildContext context) {
              final userId = ModalRoute.of(context)!.settings.arguments as String;
              return ResetPasswordPage(userId: userId);
            },
            '/profile': (BuildContext context) => const ProfilePage(),
            '/exercise': (BuildContext context) {
              final args =
                  ModalRoute.of(context)!.settings.arguments
                      as Map<String, dynamic>;
              return BlocProvider(
                create: (_) => sl<ExerciseBloc>(),
                child: ExercisePage(
                  lessonId: args['lessonId'] as String,
                  lessonTitle: args['lessonTitle'] as String,
                  isPronun: args['isPronun'] as bool? ?? false,
                ),
              );
            },
            '/pronunciation': (BuildContext context) =>
                const PronunciationPage(),
            '/assistant': (BuildContext context) => const AssistantPage(),
          },
        );
      },
    );
  }
}
