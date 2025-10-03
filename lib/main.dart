import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vocabu_rex_mobile/auth/ui/blocs/auth_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/blocs/exercise_bloc.dart';
import 'package:vocabu_rex_mobile/exercise/ui/pages/exercise_page.dart';
import 'package:vocabu_rex_mobile/home/ui/blocs/home_bloc.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/home_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/intro.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/login_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/onboarding_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/register_page.dart';
import 'package:vocabu_rex_mobile/auth/ui/pages/welcome_page.dart';
import 'package:vocabu_rex_mobile/core/injection.dart';
import 'package:vocabu_rex_mobile/core/token_manager.dart';
import 'package:vocabu_rex_mobile/home/ui/pages/profile_page.dart';

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
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authBloc),
        BlocProvider.value(value: homeBloc),
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
          home: hasToken ? const HomePage() : const WelcomePage(),
          routes: <String, WidgetBuilder>{
            '/intro': (BuildContext context) => const Intro(),
            '/welcome': (BuildContext context) => const WelcomePage(),
            '/onboarding': (BuildContext context) => const OnboardingPage(),
            '/home': (BuildContext context) => const HomePage(),
            '/register': (BuildContext context) => const RegisterPage(),
            '/login': (BuildContext context) => const LoginPage(),
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
                ),
              );
            },
          },
        );
      },
    );
  }
}
