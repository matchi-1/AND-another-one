import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin {
  late final AnimationController _star1Controller;
  late final AnimationController _star2Controller;
  late final AnimationController _star3Controller;
  late final AnimationController _star4Controller;

  @override
  void initState() {
    super.initState();

    _star1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _star2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();

    _star3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _star4Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 24),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(AppAssets.bgMenu), context);
    precacheImage(const AssetImage(AppAssets.homeLogo), context);
    precacheImage(const AssetImage(AppAssets.star1), context);
    precacheImage(const AssetImage(AppAssets.star2), context);
    precacheImage(const AssetImage(AppAssets.star3), context);
    precacheImage(const AssetImage(AppAssets.star4), context);
  }

  @override
  void dispose() {
    _star1Controller.dispose();
    _star2Controller.dispose();
    _star3Controller.dispose();
    _star4Controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    const double btnWidth = 300;
    const double btnHeight = 75;
    const double btnFontSize = 28;
    const double btnGap = 10;
    const Color btnTextColor = Colors.white;

    return Scaffold(
      body: Stack(
        children: [
          // 1) BACK-MOST: rotating stars
          Positioned.fill(
            child: IgnorePointer(
              child: Stack(
                children: [
                  // Rotating stars / halftone decorations
                  Positioned(
                    top: -200,
                    left: -200,
                    child: _RotatingStar(
                      controller: _star1Controller,
                      imagePath: AppAssets.star1,
                      width: 500,
                    ),
                  ),

                  Positioned(
                    top: 75,
                    right: -300,
                    child: _RotatingStar(
                      controller: _star2Controller,
                      imagePath: AppAssets.star2,
                      width: 530,
                    ),
                  ),

                  Positioned(
                    bottom: 120,
                    left: -280,
                    child: _RotatingStar(
                      controller: _star3Controller,
                      imagePath: AppAssets.star3,
                      width: 500,
                    ),
                  ),

                  Positioned(
                    bottom: -220,
                    right: -180,
                    child: _RotatingStar(
                      controller: _star4Controller,
                      imagePath: AppAssets.star4,
                      width: 500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2) Background image on top of stars
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                AppAssets.bgMenu,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 3) Foreground content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      Image.asset(
                        AppAssets.homeLogo,
                        width: size.width * 0.8,
                      ),
                    
                      BeveledMenuButton(
                        label: 'PLAY',
                        color: AppColors.yellowButton,
                        width: btnWidth,
                        height: btnHeight,
                        textColor: btnTextColor,
                        fontSize: btnFontSize,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.play);
                        },
                      ),
                      const SizedBox(height: btnGap),

                      BeveledMenuButton(
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
                        label: 'SETTINGS',
                        color: AppColors.greenButton,
                        width: btnWidth,
                        height: btnHeight,
                        textColor: btnTextColor,
                        fontSize: btnFontSize,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.settings);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingStar extends StatelessWidget {
  final AnimationController controller;
  final String imagePath;
  final double width;

  const _RotatingStar({
    required this.controller,
    required this.imagePath,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: controller,
        child: Image.asset(
          imagePath,
          width: width,
          filterQuality: FilterQuality.low,
        ),
        builder: (context, child) {
          return Transform.rotate(
            angle: controller.value * 2 * math.pi,
            child: child,
          );
        },
      ),
    );
  }
}
