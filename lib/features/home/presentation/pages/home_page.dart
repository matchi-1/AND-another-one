import 'dart:async';

import 'package:and_another_one/core/audio/home_bgm_route_mixin.dart';
import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../auth/data/auth_service.dart';
import '../../../../core/audio/bgm_controller.dart';
import '../../../tutorial/app_tutorial_controller.dart';
import '../../../tutorial/tutorial_targets.dart';
import '../../../../core/navigation/route_observer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with RouteAware, HomeBgmRouteMixin {
  final AuthService _authService = AuthService();

  bool _hasShownRouteMessage = false;

  @override
  void initState() {
    super.initState();
    debugPrint('HOME initState fired');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_prepareTutorial());
    });
  }

  Future<void> _prepareTutorial() async {
    final username = await _authService.currentUsername();

    if (!mounted) return;

    AppTutorialController.instance.setPlayerName(username);

    AppTutorialController.instance.onPageReady(context, AppRoutes.home);

    await AppTutorialController.instance.maybeStart(context);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }

    if (_hasShownRouteMessage) return;

    final message = ModalRoute.of(context)?.settings.arguments as String?;

    if (message != null && message.isNotEmpty) {
      _hasShownRouteMessage = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      });
    }
  }

  @override
  void dispose() {
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    unawaited(BgmController.instance.playScene(BgmScene.home));
  }

  Widget _buildMenuButtonWithAndy({
    required Key? key,
    required String label,
    required Color color,
    required double width,
    required double height,
    required double fontSize,
    required Color textColor,
    required VoidCallback onTap,
    required String andyAsset,
    required bool andyOnLeft,
    double andySize = 56,
    double andyAngle = 0.0,
    double andyBottom = 6,
    double andySideOffset = -6,
  }) {
    return SizedBox(
      width: width + 20,
      height: height + 18,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: BeveledMenuButton(
              key: key,
              label: label,
              color: color,
              width: width,
              height: height,
              textColor: textColor,
              fontSize: fontSize,
              onTap: onTap,
            ),
          ),
          Positioned(
            left: andyOnLeft ? andySideOffset : null,
            right: andyOnLeft ? null : andySideOffset,
            bottom: andyBottom,
            child: Transform.rotate(
              angle: andyAngle,
              child: Image.asset(
                andyAsset,
                width: andySize,
                height: andySize,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 70;
    const double btnFontSize = 27;
    const double btnGap = 8;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: Center(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const SizedBox(height: 50),

                  Image.asset(
                    AppAssets.homeLogo,
                    width: size.width * 0.8,
                  ),

                  const SizedBox(height: 30),

                  _buildMenuButtonWithAndy(
                    key: TutorialTargets.homePlay,
                    label: 'PLAY',
                    color: AppColors.yellowButton,
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFontSize,
                    textColor: btnTextColor,
                    andyAsset: AppAssets.andyPlay,
                    andyOnLeft: true,
                    andySize: 110,
                    andyAngle: -0.18,
                    andyBottom: -2,
                    andySideOffset: -20,
                    onTap: () {
                      unawaited(SfxController.instance.playMenuPress());
                      Navigator.pushNamed(context, AppRoutes.selectMode);
                    },
                  ),

                  const SizedBox(height: btnGap),

                  _buildMenuButtonWithAndy(
                    key: TutorialTargets.homeLogicGuide,
                    label: 'LOGIC GUIDE',
                    color: AppColors.pinkButton,
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFontSize,
                    textColor: btnTextColor,
                    andyAsset: AppAssets.andyLogicGuide,
                    andyOnLeft: false,
                    andySize: 105,
                    andyAngle: 0.30,
                    andyBottom: -10,
                    andySideOffset: -25,
                    onTap: () {
                      unawaited(SfxController.instance.playMenuPress());
                      Navigator.pushNamed(context, AppRoutes.logicGuide);
                    },
                  ),

                  const SizedBox(height: btnGap),

                  _buildMenuButtonWithAndy(
                    key: TutorialTargets.homeLeaderboards,
                    label: 'LEADERBOARDS',
                    color: AppColors.greenButton,
                    width: btnWidth,
                    height: btnHeight,
                    fontSize: btnFontSize-5,
                    textColor: btnTextColor,
                    andyAsset: AppAssets.andyLeaderboards,
                    andyOnLeft: true,
                    andySize: 100,
                    andyAngle: -0.30,
                    andyBottom: -25,
                    andySideOffset: -25,
                    onTap: () {
                      unawaited(SfxController.instance.playMenuPress());
                      Navigator.pushNamed(context, AppRoutes.leaderboards);
                    },
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    key: TutorialTargets.homeRestart,
                    onPressed: () async {
                      final username = await _authService.currentUsername();

                      if (!mounted) return;

                      AppTutorialController.instance.setPlayerName(username);
                      await AppTutorialController.instance.start(context);
                    },
                    child: const Text(
                      'Restart Tutorial',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: btnGap + 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BeveledMenuButton(
                        key: TutorialTargets.homeExit,
                        label: 'EXIT',
                        color: AppColors.greyButton,
                        width: 132,
                        height: 46,
                        textColor: btnTextColor,
                        fontSize: 18,
                        onTap: () {
                          SystemNavigator.pop();
                        },
                      ),
                      const SizedBox(width: 12),
                      BeveledMenuButton(
                        key: TutorialTargets.homeLogout,
                        label: 'LOGOUT',
                        color: AppColors.redButton,
                        width: 132,
                        height: 46,
                        textColor: btnTextColor,
                        fontSize: 18,
                        onTap: () async {
                          unawaited(SfxController.instance.playGameOver());
                          await _authService.logout();
                          if (!mounted) return;

                          Navigator.of(this.context).pushNamedAndRemoveUntil(
                            AppRoutes.login,
                                (route) => false,
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: btnGap + 20),

                  MusicButton(
                    size: size.width * 0.12,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}