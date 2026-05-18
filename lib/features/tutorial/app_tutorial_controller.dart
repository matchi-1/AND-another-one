import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../core/navigation/app_routes.dart';
import 'gameplay_tutorial_overlay.dart';
import 'gameplay_tutorial_service.dart';
import 'tutorial_targets.dart';

class TutorialStepSpec {
  final String? targetId;
  final String text;
  final String andyAsset;

  final TutorialOverlayPlacement andyPlacement;
  final TutorialOverlayPlacement dialoguePlacement;

  final double andyWidthFactor;
  final double dialogueWidthFactor;

  const TutorialStepSpec({
    required this.targetId,
    required this.text,
    required this.andyAsset,
    this.andyPlacement = TutorialPositions.bottomLeft,
    this.dialoguePlacement = TutorialPositions.topCenter,
    this.andyWidthFactor = 0.60,
    this.dialogueWidthFactor = 0.90,
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

  String _playerName = 'Player';

  bool get isActive => _active;

  void setPlayerName(String playerName) {
    final cleaned = playerName.trim();

    if (cleaned.isEmpty) {
      _playerName = 'Player';
      return;
    }

    _playerName = cleaned;
  }

  List<TutorialPageSpec> get _flow => [
        TutorialPageSpec(
          routeName: AppRoutes.home,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Hey, $_playerName! I’m Andy. Welcome to AND Another One, where logic gates become a game!',
              andyAsset: AppAssets.tutorialAndy1,

                        // Andy appears at bottom-left.
              andyPlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(-20, 0),
              ),

              // Dialogue appears at top-center.
              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.topCenter,
                offset: Offset(0, 10),
              ),

              andyWidthFactor: 0.58,
              dialogueWidthFactor: 0.90,
            ),

            const TutorialStepSpec(
              targetId: null,
              text:
                  'This is your home base. From here, you can play, study logic gates, check rankings, or restart this tutorial anytime.',
              andyAsset: AppAssets.tutorialAndy1,
            ),
            const TutorialStepSpec(
              targetId: 'homePlay',
              text:
                  'Tap PLAY when you’re ready to jump into the logic challenges.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            const TutorialStepSpec(
              targetId: 'homeLogicGuide',
              text:
                  'Need a refresher? The LOGIC GUIDE explains the operators before you start solving.',
              andyAsset: AppAssets.tutorialAndy3,
            ),
            const TutorialStepSpec(
              targetId: 'homeLeaderboards',
              text:
                  'The LEADERBOARDS show who’s dominating the circuit board.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            const TutorialStepSpec(
              targetId: 'homeRestart',
              text:
                  'Forgot something? You can replay my tutorial here anytime.',
              andyAsset: AppAssets.tutorialAndy3,
              andyPlacement: TutorialOverlayPlacement(
              anchor: TutorialAnchor.topRight,
              offset: Offset(12, 0),
              ),

              dialoguePlacement: TutorialOverlayPlacement(
                anchor: TutorialAnchor.bottomLeft,
                offset: Offset(0, -24),
              ),

              andyWidthFactor: 0.42,
              dialogueWidthFactor: 0.78,
            ),
          ],
        ),
        const TutorialPageSpec(
          routeName: AppRoutes.selectMode,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Now choose your game mode. Each mode tests logic in a different way.',
              andyAsset: AppAssets.tutorialAndy1,
            ),
            TutorialStepSpec(
              targetId: 'modeGatekeeping',
              text:
                  'In Gatekeeping, you fill in the missing logic operator that completes the expression.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'modeOneOrNone',
              text:
                  'In One or None, you decide whether the whole circuit outputs a 1 or a 0.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'modeBack',
              text:
                  'Use BACK whenever you want to return to the previous screen.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
          ],
        ),
        const TutorialPageSpec(
          routeName: AppRoutes.gatekeepingSelect,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'This is the Gatekeeping difficulty screen. Pick the level that matches your confidence.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'gateHowToPlay',
              text:
                  'The HOW TO PLAY button gives a more detailed explanation of this mode.',
              andyAsset: AppAssets.tutorialAndy3,
            ),
            TutorialStepSpec(
              targetId: 'gateBasic',
              text:
                  'BASIC is the best place to start. It uses simpler gates and friendlier patterns.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'gateLogic',
              text:
                  'LOGIC adds more challenge, so expect trickier operator combinations.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'gateManic',
              text:
                  'MANIC is fast, chaotic, and definitely not for sleepy brains.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'gateBack',
              text:
                  'Not ready yet? This BACK button returns you to mode select.',
              andyAsset: AppAssets.tutorialAndy3,
            ),
          ],
        ),
        const TutorialPageSpec(
          routeName: AppRoutes.gatekeepingTutorialPreview,
          steps: [
            TutorialStepSpec(
              targetId: null,
              text:
                  'Before your first real round, let me show you how the game screen works.',
              andyAsset: AppAssets.tutorialAndy1,
            ),
            TutorialStepSpec(
              targetId: 'previewDiagram',
              text:
                  'This area shows the circuit diagram. Read the gates and follow how the signals connect.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'previewExpression',
              text:
                  'This expression is your main clue. The blank box is the missing operator you need to fill.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'previewButtons',
              text:
                  'Choose the operator button that correctly completes the expression.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'previewTimer',
              text:
                  'Here’s your timer and score. Correct answers help you keep momentum.',
              andyAsset: AppAssets.tutorialAndy2,
            ),
            TutorialStepSpec(
              targetId: 'previewPass',
              text:
                  'Stuck? Use PASS to skip a question, but you only get a limited number of passes.',
              andyAsset: AppAssets.tutorialAndy3,
            ),
            TutorialStepSpec(
              targetId: null,
              text:
                  'That’s it! Read the circuit, solve the blank, and keep your streak alive. Let’s play!',
              andyAsset: AppAssets.tutorialAndy1,
            ),
          ],
        ),
      ];

  Future<void> maybeStart(BuildContext context) async {
    if (_active) return;

    final seen = await _service.hasSeen(_flagName);
    if (seen) return;
    if (!context.mounted) return;

    await start(context);
  }

  Future<void> start(BuildContext context) async {
    _removeOverlay();
    _active = true;
    _pageIndex = 0;

    final firstRoute = _flow.first.routeName;
    final currentRoute = ModalRoute.of(context)?.settings.name;

    if (currentRoute == firstRoute) {
      onPageReady(context, firstRoute);
      return;
    }

    if (!context.mounted) return;

    Navigator.of(context).pushNamedAndRemoveUntil(
      firstRoute,
      (route) => false,
    );
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
          andyAsset: step.andyAsset,
          andyPlacement: step.andyPlacement,
          dialoguePlacement: step.dialoguePlacement,
          andyWidthFactor: step.andyWidthFactor,
          dialogueWidthFactor: step.dialogueWidthFactor,
        ),
      )
      .toList();

    _removeOverlay();

    _entry = OverlayEntry(
      builder: (_) => GameplayTutorialOverlay(
        steps: steps,

        // Normal tutorial progression.
        onFinish: () async {
          _removeOverlay();

          if (_pageIndex >= _flow.length - 1) {
            await _finishTutorial(context);
            return;
          }

          _pageIndex++;
          final nextRoute = _flow[_pageIndex].routeName;

          if (!context.mounted) return;

          Navigator.of(context).pushReplacementNamed(nextRoute);
        },

        // X button: skip the whole tutorial immediately.
        onSkip: () async {
          await stop(context, markSeen: true);
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

    final currentRoute = ModalRoute.of(context)?.settings.name;
    if (currentRoute == AppRoutes.home) return;

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

    final currentRoute = ModalRoute.of(context)?.settings.name;

    // Important:
    // If we are already on Home, do NOT push another Home page.
    // Pushing another Home causes duplicated GlobalKeys.
    if (currentRoute == AppRoutes.home) {
      return;
    }

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