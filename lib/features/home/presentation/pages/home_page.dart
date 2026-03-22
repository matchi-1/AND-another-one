import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/primary_menu_button.dart';

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
      duration: const Duration(seconds: 16),
    )..repeat();

    _star2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: false);

    _star3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();

    _star4Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22),
    )..repeat();
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

    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Positioned.fill(
            child: Image.asset(
              AppAssets.bgMenu,
              fit: BoxFit.cover,
            ),
          ),

          // Rotating stars / halftone decorations
          Positioned(
            top: size.height * 0.03,
            left: -25,
            child: _RotatingStar(
              controller: _star1Controller,
              imagePath: AppAssets.star1,
              width: 120,
            ),
          ),

          Positioned(
            top: size.height * 0.28,
            right: -35,
            child: _RotatingStar(
              controller: _star2Controller,
              imagePath: AppAssets.star2,
              width: 150,
            ),
          ),

          Positioned(
            bottom: size.height * 0.18,
            left: -40,
            child: _RotatingStar(
              controller: _star3Controller,
              imagePath: AppAssets.star3,
              width: 170,
            ),
          ),

          Positioned(
            bottom: -20,
            right: -20,
            child: _RotatingStar(
              controller: _star4Controller,
              imagePath: AppAssets.star4,
              width: 180,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    children: [
                      SizedBox(height: size.height * 0.06),

                      // Logo image
                      Image.asset(
                        AppAssets.homeLogo,
                        width: size.width * 0.62,
                      ),

                      SizedBox(height: size.height * 0.08),

                      PrimaryMenuButton(
                        label: 'PLAY',
                        color: AppColors.yellowButton,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.play);
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryMenuButton(
                        label: 'LOGIC GUIDE',
                        color: AppColors.pinkButton,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.logicGuide);
                        },
                      ),
                      const SizedBox(height: 24),

                      PrimaryMenuButton(
                        label: 'SETTINGS',
                        color: AppColors.greenButton,
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
    return RotationTransition(
      turns: controller,
      child: Image.asset(
        imagePath,
        width: width,
        fit: BoxFit.contain,
      ),
    );
  }
}