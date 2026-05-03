import 'package:flutter/material.dart';

import '../../core/navigation/app_routes.dart';
import 'gameplay_tutorial_overlay.dart';
import 'gameplay_tutorial_service.dart';
import 'tutorial_targets.dart';

class TutorialStepSpec {
  final String? targetId;
  final String text;

  const TutorialStepSpec({
    required this.targetId,
    required this.text,
  });
}

class TutorialPageSpec {
  final String routeName;
  final List<TutorialStepSpec> steps;

  const TutorialPageSpec({
    required this.routeName,
    required this.steps,
  });
}

class AppTutorialController {
  AppTutorialController._();
  static final AppTutorialController instance = AppTutorialController._();

  final GameplayTutorialService _service = GameplayTutorialService();

  static const String _flagName = 'hasSeenMainPlaceholderTutorial';

  bool _active = false;
  int _pageIndex = 0;
  OverlayEntry? _entry;

  final List<TutorialPageSpec> _flow = const [
    TutorialPageSpec(
      routeName: AppRoutes.home,
      steps: [
        TutorialStepSpec(targetId: 'homePlay', text: '<home play button>'),
        TutorialStepSpec(targetId: 'homeLogicGuide', text: '<home logic guide button>'),
        TutorialStepSpec(targetId: 'homeLeaderboards', text: '<home leaderboards button>'),
        TutorialStepSpec(targetId: 'homeRestart', text: '<home restart tutorial text link>'),
        TutorialStepSpec(targetId: 'homeExit', text: '<home exit button>'),
        TutorialStepSpec(targetId: 'homeLogout', text: '<home logout button>'),
      ],
    ),
    TutorialPageSpec(
      routeName: AppRoutes.selectMode,
      steps: [
        TutorialStepSpec(targetId: 'modeGatekeeping', text: '<mode select gatekeeping>'),
        TutorialStepSpec(targetId: 'modeOneOrNone', text: '<mode select one or none>'),
        TutorialStepSpec(targetId: 'modeBack', text: '<mode select back button>'),
      ],
    ),
    TutorialPageSpec(
      routeName: AppRoutes.gatekeepingSelect,
      steps: [
        TutorialStepSpec(targetId: 'gateHowToPlay', text: '<gatekeeping how to play>'),
        TutorialStepSpec(targetId: 'gateBasic', text: '<gatekeeping basic difficulty>'),
        TutorialStepSpec(targetId: 'gateLogic', text: '<gatekeeping logic difficulty>'),
        TutorialStepSpec(targetId: 'gateManic', text: '<gatekeeping manic difficulty>'),
        TutorialStepSpec(targetId: 'gateBack', text: '<gatekeeping back button>'),
      ],
    ),
    TutorialPageSpec(
      routeName: AppRoutes.gatekeepingTutorialPreview,
      steps: [
        TutorialStepSpec(targetId: 'previewDiagram', text: '<tutorial gameplay diagram>'),
        TutorialStepSpec(targetId: 'previewExpression', text: '<tutorial gameplay expression>'),
        TutorialStepSpec(targetId: 'previewButtons', text: '<tutorial gameplay answer buttons>'),
        TutorialStepSpec(targetId: 'previewTimer', text: '<tutorial gameplay timer and score>'),
        TutorialStepSpec(targetId: 'previewPass', text: '<tutorial gameplay pass area>'),
      ],
    ),
  ];

  bool get isActive => _active;

  Future<void> maybeStart(BuildContext context) async {
    if (_active) return;

    final seen = await _service.hasSeen(_flagName);
    if (seen) return;
    if (!context.mounted) return;

    await start(context, force: false);
  }

  Future<void> start(BuildContext context, {bool force = false}) async {
    _removeOverlay();
    _active = true;
    _pageIndex = 0;

    if (!force) {
      final seen = await _service.hasSeen(_flagName);
      if (seen) {
        _active = false;
        return;
      }
    }

    if (!context.mounted) return;

    final currentRoute = ModalRoute.of(context)?.settings.name;
    final firstRoute = _flow.first.routeName;

    if (currentRoute == firstRoute) {
      onPageReady(context, firstRoute);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil(
        firstRoute,
        (route) => false,
      );
    }
  }

  void onPageReady(BuildContext context, String currentRouteName) {
    if (!_active) return;
    if (_entry != null) return;
    if (_pageIndex >= _flow.length) return;

    final spec = _flow[_pageIndex];
    if (spec.routeName != currentRouteName) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted || !_active || _entry != null) return;
      _showPageOverlay(context, spec);
    });
  }

  void _showPageOverlay(BuildContext context, TutorialPageSpec spec) {
    final steps = spec.steps
        .map(
          (step) => GameplayTutorialStep(
            targetKey: tutorialTargetById(step.targetId),
            text: step.text,
          ),
        )
        .toList();

    _removeOverlay();

    _entry = OverlayEntry(
      builder: (_) => GameplayTutorialOverlay(
        steps: steps,
        onFinish: () async {
          _removeOverlay();

          if (_pageIndex >= _flow.length - 1) {
            await _finishTutorial(context);
            return;
          }

          _pageIndex++;
          final nextRoute = _flow[_pageIndex].routeName;

          if (!context.mounted) return;
          Navigator.of(context).pushNamed(nextRoute);
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  Future<void> _finishTutorial(BuildContext context) async {
    _removeOverlay();
    _active = false;
    _pageIndex = 0;

    await _service.markSeen(_flagName);

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> stop(BuildContext context, {bool markSeen = true}) async {
    _removeOverlay();
    _active = false;
    _pageIndex = 0;

    if (markSeen) {
      await _service.markSeen(_flagName);
    }

    if (!context.mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.home,
      (route) => false,
    );
  }

  void _removeOverlay() {
    _entry?.remove();
    _entry = null;
  }
}

class TutorialPageReady extends StatefulWidget {
  const TutorialPageReady({
    super.key,
    required this.routeName,
    required this.child,
  });

  final String routeName;
  final Widget child;

  @override
  State<TutorialPageReady> createState() => _TutorialPageReadyState();
}

class _TutorialPageReadyState extends State<TutorialPageReady> {
  bool _notified = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_notified) return;
    _notified = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppTutorialController.instance.onPageReady(context, widget.routeName);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}