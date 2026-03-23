import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';

class GameMenuBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final bool useSafeArea;
  final bool useGrid;

  const GameMenuBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
    this.useSafeArea = true,
    this.useGrid = true,
  });

  @override
  State<GameMenuBackground> createState() => _GameMenuBackgroundState();
}

class _GameMenuBackgroundState extends State<GameMenuBackground>
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

    if (widget.useGrid) {
      precacheImage(const AssetImage(AppAssets.bgMenu), context);
    }
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
    final content = widget.useSafeArea
        ? SafeArea(child: widget.child)
        : widget.child;

    return Stack(
      children: [
        // 1) Base color
        Positioned.fill(
          child: ColoredBox(
            color: widget.backgroundColor,
          ),
        ),

        // 2) Back-most rotating stars
        Positioned.fill(
          child: IgnorePointer(
            child: Stack(
              children: [
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

        // 3) Background overlay image on top of stars
        if (widget.useGrid)
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                AppAssets.bgMenu,
                fit: BoxFit.cover,
              ),
            ),
          ),

        // 4) Foreground page content
        Positioned.fill(child: content),
      ],
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
