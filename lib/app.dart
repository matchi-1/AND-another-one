import 'dart:async';

import 'package:and_another_one/core/audio/bgm_controller.dart';
import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:and_another_one/core/navigation/route_observer.dart';
import 'package:flutter/material.dart';

import 'core/navigation/app_router.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';

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
      initialRoute: AppRoutes.splash,
      navigatorObservers: [appRouteObserver],
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}