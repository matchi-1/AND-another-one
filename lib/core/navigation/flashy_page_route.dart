import 'package:flutter/material.dart';

class FlashyPageRoute<T> extends PageRouteBuilder<T> {
  FlashyPageRoute({
    required WidgetBuilder builder,
    required RouteSettings settings,
    Color flashColor = Colors.white,
    Duration duration = const Duration(milliseconds: 420),
    Duration reverseDuration = const Duration(milliseconds: 260),
  }) : super(
    settings: settings,
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    pageBuilder: (context, animation, secondaryAnimation) {
      return builder(context);
    },
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );

      final slide = Tween<Offset>(
        begin: const Offset(0.12, 0),
        end: Offset.zero,
      ).animate(curved);

      final scale = Tween<double>(
        begin: 0.96,
        end: 1.0,
      ).animate(curved);

      final fade = Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(curved);

      final flash = TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.0, end: 0.85),
          weight: 18,
        ),
        TweenSequenceItem(
          tween: Tween<double>(begin: 0.85, end: 0.0),
          weight: 82,
        ),
      ]).animate(
        CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        ),
      );

      return Stack(
        children: [
          FadeTransition(
            opacity: fade,
            child: SlideTransition(
              position: slide,
              child: ScaleTransition(
                scale: scale,
                child: child,
              ),
            ),
          ),

          IgnorePointer(
            child: FadeTransition(
              opacity: flash,
              child: ColoredBox(
                color: flashColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}