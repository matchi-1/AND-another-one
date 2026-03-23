import 'package:flutter/material.dart';
import 'core/navigation/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/guide/presentation/pages/logic_guide_page.dart';
import 'features/play/presentation/pages/gatekeeping_select_page.dart';
import 'features/play/presentation/pages/mode_select_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

class AndAnotherOneApp extends StatelessWidget {
  const AndAnotherOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AND Another One',
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.home,
      routes: {
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.selectMode: (_) => const ModeSelectPage(),
        AppRoutes.logicGuide: (_) => const LogicGuidePage(),
        AppRoutes.settings: (_) => const SettingsPage(),
        AppRoutes.gatekeepingSelect: (_) => const GatekeepingSelectPage()
        //AppRoutes.oneOrNoneSelect:(_) => const OneOrNoneSelectPage()
      },
    );
  }
}