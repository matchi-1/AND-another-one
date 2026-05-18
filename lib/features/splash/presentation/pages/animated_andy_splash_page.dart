import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';

class AnimatedAndySplashPage extends StatefulWidget {
  const AnimatedAndySplashPage({super.key});

  @override
  State<AnimatedAndySplashPage> createState() => _AnimatedAndySplashPageState();
}

class _AnimatedAndySplashPageState extends State<AnimatedAndySplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _scaleAnimation;

  bool _startedRedirect = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.4, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _rotationAnimation = Tween<double>(
      begin: -1.5,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.82,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startSplashFlow();
    });
  }

  Future<void> _startSplashFlow() async {
    if (_startedRedirect) return;
    _startedRedirect = true;

    unawaited(_controller.forward());

    // Minimum splash duration so Andy animation is visible.
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    await _redirectAfterAuthCheck();
  }

  Future<void> _redirectAfterAuthCheck() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      Navigator.pushReplacementNamed(context, AppRoutes.login);
      return;
    }

    String username = 'Player';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      final storedUsername = data?['username'] as String?;

      if (storedUsername != null && storedUsername.isNotEmpty) {
        username = storedUsername;
      }
    } catch (_) {
      // fallback stays "Player"
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.home,
      arguments: 'Welcome back, $username!',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueBg,
      body: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotationAnimation.value * pi,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: Image.asset(
              AppAssets.andyBasic,
              width: 145,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}