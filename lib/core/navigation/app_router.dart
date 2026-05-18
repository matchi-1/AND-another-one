import 'package:flutter/material.dart';

import 'app_routes.dart';
import 'auth_gate.dart';
import 'flashy_page_route.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/guide/presentation/pages/logic_guide_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/leaderboards/presentation/pages/leaderboards_page.dart';
import '../../features/play/presentation/pages/gatekeeping_game_page.dart';
import '../../features/play/presentation/pages/gatekeeping_select_page.dart';
import '../../features/play/presentation/pages/gatekeeping_tutorial_preview_page.dart';
import '../../features/play/presentation/pages/mechanics_gatekeeping.dart';
import '../../features/play/presentation/pages/mechanics_one_or_none.dart';
import '../../features/play/presentation/pages/mode_select_page.dart';
import '../../features/play/presentation/pages/one_or_none_game_page.dart';
import '../../features/play/presentation/pages/one_or_none_select_page.dart';
import '../../features/splash/presentation/pages/animated_andy_splash_page.dart';

class AppRouter {
  const AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _flash(
          settings,
              (_) => const AnimatedAndySplashPage(),
          flashColor: const Color(0xFF00AEEF),
        );

      case AppRoutes.authGate:
        return _flash(
          settings,
              (_) => const AuthGate(),
          flashColor: const Color(0xFF00AEEF),
        );

      case AppRoutes.login:
        return _flash(
          settings,
              (_) => const LoginPage(),
          flashColor: const Color(0xFF00AEEF),
        );

      case AppRoutes.register:
        return _flash(
          settings,
              (_) => const RegisterPage(),
          flashColor: const Color(0xFFFF5DAA),
        );

      case AppRoutes.home:
        return _flash(
          settings,
              (_) => const HomePage(),
          flashColor: const Color(0xFFFFD84D),
        );

      case AppRoutes.selectMode:
        return _flash(
          settings,
              (_) => const ModeSelectPage(),
          flashColor: const Color(0xFFFF6B00),
        );

      case AppRoutes.logicGuide:
        return _flash(
          settings,
              (_) => const LogicGuidePage(),
          flashColor: const Color(0xFFFF5DAA),
        );

      case AppRoutes.leaderboards:
        return _flash(
          settings,
              (_) => const LeaderboardsPage(),
          flashColor: const Color(0xFFFFC107),
        );

      case AppRoutes.gatekeepingSelect:
        return _flash(
          settings,
              (_) => const GatekeepingSelectPage(),
          flashColor: const Color(0xFFFF8A00),
        );

      case AppRoutes.oneOrNoneSelect:
        return _flash(
          settings,
              (_) => const OneOrNoneSelectPage(),
          flashColor: const Color(0xFF9C6BFF),
        );

      case AppRoutes.gatekeepingGame:
        return _flash(
          settings,
              (_) => const GatekeepingGamePage(),
          flashColor: const Color(0xFFFF8A00),
        );

      case AppRoutes.oneOrNoneGame:
        return _flash(
          settings,
              (_) => const OneOrNoneGamePage(),
          flashColor: const Color(0xFF9C6BFF),
        );

      case AppRoutes.mechanicsGatekeeping:
        return _flash(
          settings,
              (_) => const MechanicsGatekeepingPage(),
          flashColor: const Color(0xFFFF8A00),
        );

      case AppRoutes.mechanicsOneOrNone:
        return _flash(
          settings,
              (_) => const MechanicsOneOrNonePage(),
          flashColor: const Color(0xFF9C6BFF),
        );

      case AppRoutes.gatekeepingTutorialPreview:
        return _flash(
          settings,
              (_) => const GatekeepingTutorialPreviewPage(),
          flashColor: const Color(0xFFFFD84D),
        );

      default:
        return _flash(
          settings,
              (_) => const AnimatedAndySplashPage(),
          flashColor: const Color(0xFF00AEEF),
        );
    }
  }

  static Route<dynamic> _flash(
      RouteSettings settings,
      WidgetBuilder builder, {
        Color flashColor = Colors.white,
      }) {
    return FlashyPageRoute(
      settings: settings,
      builder: builder,
      flashColor: flashColor,
    );
  }
}