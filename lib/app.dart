import 'dart:async';

import 'package:and_another_one/core/audio/bgm_controller.dart';
import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:and_another_one/core/navigation/auth_gate.dart';
import 'package:and_another_one/core/navigation/route_observer.dart';
import 'package:and_another_one/features/play/presentation/pages/gatekeeping_tutorial_preview_page.dart';
import 'package:and_another_one/features/play/presentation/pages/one_or_none_game_page.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/register_page.dart';
import 'features/guide/presentation/pages/logic_guide_page.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/leaderboards/presentation/pages/leaderboards_page.dart';
import 'features/play/presentation/pages/gatekeeping_game_page.dart';
import 'features/play/presentation/pages/gatekeeping_select_page.dart';
import 'features/play/presentation/pages/mechanics_gatekeeping.dart';
import 'features/play/presentation/pages/mechanics_one_or_none.dart';
import 'features/play/presentation/pages/mode_select_page.dart';
import 'features/play/presentation/pages/one_or_none_select_page.dart';

class AndAnotherOneApp extends StatefulWidget {
  const AndAnotherOneApp({super.key});

  @override
  State<AndAnotherOneApp> createState() => _AndAnotherOneAppState();
}

class _AndAnotherOneAppState extends State<AndAnotherOneApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(BgmController.instance.resumeFromAppLifecycle());
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        unawaited(BgmController.instance.pauseForAppLifecycle());
        unawaited(SfxController.instance.stopAllForLifecycle());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AND Another One',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.authGate,
      navigatorObservers: [appRouteObserver],
      routes: {
        AppRoutes.authGate: (_) => const AuthGate(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.selectMode: (_) => const ModeSelectPage(),
        AppRoutes.logicGuide: (_) => const LogicGuidePage(),
        AppRoutes.leaderboards: (_) => const LeaderboardsPage(),
        AppRoutes.gatekeepingSelect: (_) => const GatekeepingSelectPage(),
        AppRoutes.oneOrNoneSelect: (_) => const OneOrNoneSelectPage(),
        AppRoutes.oneOrNoneGame: (_) => const OneOrNoneGamePage(),
        AppRoutes.mechanicsGatekeeping: (_) => const MechanicsGatekeepingPage(),
        AppRoutes.mechanicsOneOrNone: (_) => const MechanicsOneOrNonePage(),
        AppRoutes.gatekeepingGame: (_) => const GatekeepingGamePage(),
        AppRoutes.gatekeepingTutorialPreview: (_) =>
            const GatekeepingTutorialPreviewPage(),
      },
    );
  }
}