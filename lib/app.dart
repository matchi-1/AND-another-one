import 'package:and_another_one/features/play/presentation/pages/one_or_none_game_page.dart';
import 'package:flutter/material.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/guide/presentation/pages/logic_guide_page.dart';
import 'features/play/presentation/pages/gatekeeping_select_page.dart';
import 'features/play/presentation/pages/gatekeeping_game_page.dart';
import 'features/play/presentation/pages/one_or_none_select_page.dart';
import 'features/play/presentation/pages/mode_select_page.dart';
import 'features/leaderboards/presentation/pages/leaderboards_page.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/play/presentation/pages/mechanics_gatekeeping.dart';
import 'features/play/presentation/pages/mechanics_one_or_none.dart';


class AndAnotherOneApp extends StatelessWidget {
  const AndAnotherOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AND Another One',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.selectMode: (_) => const ModeSelectPage(),
        AppRoutes.logicGuide: (_) => const LogicGuidePage(),
        AppRoutes.leaderboards: (_) => const LeaderboardsPage(),
        AppRoutes.gatekeepingSelect: (_) => const GatekeepingSelectPage(),
        AppRoutes.oneOrNoneSelect:(_) => const OneOrNoneSelectPage(),
        AppRoutes.oneOrNoneGame: (_) => const OneOrNoneGamePage(),
        AppRoutes.mechanicsGatekeeping: (_) => const MechanicsGatekeepingPage(),
        AppRoutes.mechanicsOneOrNone: (_) => const MechanicsOneOrNonePage(),
        AppRoutes.gatekeepingGame: (_) => const GatekeepingGamePage(),
      },
    );
  }
}

