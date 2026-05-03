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

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _authService = AuthService();

  bool _hasShownRouteMessage = false;

@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    BgmController.instance.playScene(BgmScene.home);

    //if (!mounted) return;
    //await AppTutorialController.instance.maybeStart(context);

    if (!mounted) return;
    AppTutorialController.instance.onPageReady(context, AppRoutes.home);
  });
}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

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

                  BeveledMenuButton(
                    key: TutorialTargets.homePlay,
                    label: 'PLAY',
                    color: AppColors.yellowButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.selectMode);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    key: TutorialTargets.homeLogicGuide,
                    label: 'LOGIC GUIDE',
                    color: AppColors.pinkButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.logicGuide);
                    },
                  ),
                  const SizedBox(height: btnGap),

                  BeveledMenuButton(
                    key: TutorialTargets.homeLeaderboards,
                    label: 'LEADERBOARDS',
                    color: AppColors.greenButton,
                    width: btnWidth,
                    height: btnHeight,
                    textColor: btnTextColor,
                    fontSize: btnFontSize,
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.leaderboards);
                    },
                  ),

                  const SizedBox(height: 8),

                  TextButton(
                    key: TutorialTargets.homeRestart,
                    onPressed: () async {
                      await AppTutorialController.instance.start(context, force: true);
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
