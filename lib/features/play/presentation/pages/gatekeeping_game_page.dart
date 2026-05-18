import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../../shared/widgets/pause_icon_button.dart';
import '../../data/models/gatekeeping_question.dart';
import '../../data/repositories/gatekeeping_question_repository.dart';
import '../../../leaderboards/util/leaderboard_service.dart';
//import '../../../tutorial/gameplay_tutorial_overlay.dart';
//import '../../../tutorial/gameplay_tutorial_service.dart';
import 'dart:async';
import '../../../../core/audio/bgm_controller.dart';
import '../../../../core/audio/sfx_controller.dart';
import '../widgets/gameplay_overlays.dart';
import '../../../../core/navigation/app_routes.dart';

class GatekeepingGamePage extends StatefulWidget {
  const GatekeepingGamePage({super.key, this.difficulty = Difficulty.basic});

  final Difficulty difficulty;

  @override
  State<GatekeepingGamePage> createState() => _GatekeepingGamePageState();
}

class _GatekeepingGamePageState extends State<GatekeepingGamePage>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    resetWholeGame();

    final scene = switch (widget.difficulty) {
      Difficulty.basic => BgmScene.basic,
      Difficulty.logic => BgmScene.logic,
      Difficulty.manic => BgmScene.manic,
    };

    unawaited(BgmController.instance.playScene(scene));

    //WidgetsBinding.instance.addPostFrameCallback((_) {
    // _maybeShowTutorial();
    //});
  }

  Color _comboAccentForTier(int tierIndex) {
    final safeIndex = tierIndex.clamp(0, _comboTierColors.length - 1).toInt();
    return _comboTierColors[safeIndex];
  }

  void _resetComboOverlayState() {
    _comboOverlayRunId++;

    _showComboOverlay = false;
    _comboOverlayOpacity = 0.0;
    _comboOverlayScale = 0.55;
    _comboOverlayRingScale = 0.0;
    _comboOverlayPixelSpread = 0.0;
    _comboOverlayTilt = 0.0;
    _comboOverlaySlideY = 20.0;
  }

  Future<void> _playComboMultiplierOverlay({
    required bool multiplierWentUp,
  }) async {
    if (!mounted) return;

    final runId = ++_comboOverlayRunId;

    final isMaxMultiplier =
        multiplierTierIndex >= _multiplierTiers.length - 1;

    setState(() {
      _showComboOverlay = true;

      _comboOverlayTitle = multiplierWentUp
          ? isMaxMultiplier
          ? 'MAX MULTIPLIER!'
          : 'MULTIPLIER UP!'
          : 'HOT STREAK!';

      _comboOverlaySubtitle = multiplierWentUp
          ? '$hotstreakCount ANSWER STREAK'
          : '$hotstreakCount IN A ROW';

      _comboOverlayMultiplier = multiplierLabel;
      _comboOverlayStreak = hotstreakCount;
      _comboOverlayAccent = _comboAccentForTier(multiplierTierIndex);

      _comboOverlayOpacity = 0.0;
      _comboOverlayScale = 0.45;
      _comboOverlayRingScale = 0.0;
      _comboOverlayPixelSpread = 0.0;
      _comboOverlayTilt = -0.10;
      _comboOverlaySlideY = 28.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted || runId != _comboOverlayRunId) return;

    // Big entrance hit.
    setState(() {
      _comboOverlayOpacity = 1.0;
      _comboOverlayScale = 1.18;
      _comboOverlayRingScale = 0.72;
      _comboOverlayPixelSpread = 0.55;
      _comboOverlayTilt = 0.06;
      _comboOverlaySlideY = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 150));
    if (!mounted || runId != _comboOverlayRunId) return;

    // Settle while pixels keep spreading.
    setState(() {
      _comboOverlayScale = 1.0;
      _comboOverlayRingScale = 1.15;
      _comboOverlayPixelSpread = 1.0;
      _comboOverlayTilt = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 680));
    if (!mounted || runId != _comboOverlayRunId) return;

    // Exit burst.
    setState(() {
      _comboOverlayOpacity = 0.0;
      _comboOverlayScale = 1.24;
      _comboOverlayRingScale = 1.55;
      _comboOverlayPixelSpread = 1.25;
      _comboOverlaySlideY = -24.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 260));
    if (!mounted || runId != _comboOverlayRunId) return;

    setState(() {
      _showComboOverlay = false;
    });
  }

  Widget _buildComboMultiplierOverlay() {
    return _ComboMultiplierOverlay(
      title: _comboOverlayTitle,
      subtitle: _comboOverlaySubtitle,
      multiplier: _comboOverlayMultiplier,
      streak: _comboOverlayStreak,
      accent: _comboOverlayAccent,
      opacity: _comboOverlayOpacity,
      scale: _comboOverlayScale,
      ringScale: _comboOverlayRingScale,
      pixelSpread: _comboOverlayPixelSpread,
      tilt: _comboOverlayTilt,
      slideY: _comboOverlaySlideY,
    );
  }

  @override
  void dispose() {
    //_tutorialEntry?.remove();
    WidgetsBinding.instance.removeObserver(this);
    gameplayTimer?.cancel();
    super.dispose();
  }

  bool showBackConfirmOverlay = false;

void _onPausePressed() {
  unawaited(SfxController.instance.playMenuPress());

  if (gameFinished) {
    if (!showGameResultOverlay && mounted) {
      setState(() {
        showGameResultOverlay = true;
        showBackConfirmOverlay = false;
      });
    }
    return;
  }

  if (!showBackConfirmOverlay) {
    _wasRoundLockedBeforePauseOverlay = roundLocked;
  }

  if (countdownRunning) {
    unawaited(
      SfxController.instance.pauseCountdownForGamePause(force: true),
    );
  }

  setState(() {
    roundLocked = true;
    showBackConfirmOverlay = true;
  });
}
  
  @override
void didChangeAppLifecycleState(AppLifecycleState state) {
  switch (state) {
    case AppLifecycleState.resumed:
      _resumeGameFromLifecycle();
      break;

    case AppLifecycleState.inactive:
    case AppLifecycleState.hidden:
    case AppLifecycleState.paused:
    case AppLifecycleState.detached:
      _pauseGameForLifecycle();
      break;
  }
}

void _pauseGameForLifecycle() {
  if (_pausedByLifecycle) return;

  _pausedByLifecycle = true;
  _wasRoundLockedBeforeLifecyclePause = roundLocked;

  if (!showBackConfirmOverlay) {
    _wasRoundLockedBeforePauseOverlay = roundLocked;
  }

  if (countdownRunning) {
    unawaited(
      SfxController.instance.pauseCountdownForGamePause(force: true),
    );
  }

  if (!mounted) return;

  setState(() {
    roundLocked = true;

    if (!gameFinished && !showGameResultOverlay) {
      showBackConfirmOverlay = true;
    }

    preGameSpriteScaleDuration = Duration.zero;
    preGameSpriteFadeDuration = Duration.zero;
    reactionScaleDuration = Duration.zero;
  });
}

void _resumeGameFromLifecycle() {
  if (!_pausedByLifecycle) return;

  _pausedByLifecycle = false;

  _lifecycleResumeCompleter?.complete();
  _lifecycleResumeCompleter = null;

  if (!mounted) return;

  setState(() {
    if (showBackConfirmOverlay ||
        showGameResultOverlay ||
        showPreGameOverlay ||
        gameFinished) {
      roundLocked = true;
    } else {
      roundLocked = _wasRoundLockedBeforeLifecyclePause;
    }
  });
}

Future<void> _waitWhilePausedByLifecycle() async {
  while (_pausedByLifecycle || showBackConfirmOverlay) {
    _lifecycleResumeCompleter ??= Completer<void>();
    await _lifecycleResumeCompleter!.future;
  }
}

Future<void> _pauseAwareDelay(Duration duration) async {
  const tick = Duration(milliseconds: 50);
  var remaining = duration;

  while (mounted && remaining > Duration.zero) {
    await _waitWhilePausedByLifecycle();

    final step = remaining < tick ? remaining : tick;
    await Future<void>.delayed(step);

    if (!_pausedByLifecycle && !showBackConfirmOverlay) {
      remaining -= step;
    }
  }
}

void _closeBackOverlay() {
  unawaited(SfxController.instance.playMenuBack());
  if (!mounted) return;

  final shouldResumeCountdownSfx = countdownRunning;

  setState(() {
    showBackConfirmOverlay = false;

    if (showGameResultOverlay ||
        showPreGameOverlay ||
        countdownRunning ||
        gameFinished) {
      roundLocked = true;
    } else {
      roundLocked = _wasRoundLockedBeforePauseOverlay;
    }
  });

  _lifecycleResumeCompleter?.complete();
  _lifecycleResumeCompleter = null;

  if (shouldResumeCountdownSfx) {
    unawaited(SfxController.instance.resumeCountdownFromGamePause());
  }
}

  bool _pausedByLifecycle = false;
  bool _wasRoundLockedBeforeLifecyclePause = false;
  Completer<void>? _lifecycleResumeCompleter;
  bool _wasRoundLockedBeforePauseOverlay = false;

  bool showGameResultOverlay = false;
  String gameResultTitle = 'ROUND COMPLETE';

  

  int hotstreakCount = 0;
  int multiplierTierIndex = 0;
  int multiplierStepProgress = 0; // 0 or 1; 2 correct answers = tier up
  bool _showComboOverlay = false;
  int _comboOverlayRunId = 0;

  String _comboOverlayTitle = '';
  String _comboOverlaySubtitle = '';
  String _comboOverlayMultiplier = '';
  int _comboOverlayStreak = 0;

  Color _comboOverlayAccent = const Color(0xFFFFE45C);

  double _comboOverlayOpacity = 0.0;
  double _comboOverlayScale = 0.55;
  double _comboOverlayRingScale = 0.0;
  double _comboOverlayPixelSpread = 0.0;
  double _comboOverlayTilt = 0.0;
  double _comboOverlaySlideY = 20.0;

  static const List<Color> _comboTierColors = [
    Color(0xFFFFE45C), // x1.0
    Color(0xFFFFB000), // x1.25
    Color(0xFFFF6B00), // x1.5
    Color(0xFFFF3D81), // x1.75
    Color(0xFFB85CFF), // x2.0
    Color(0xFF00E5FF), // x3.0
  ];


  static const List<double> _multiplierTiers = [1.0, 1.25, 1.5, 1.75, 2.0, 3.0];

  double get currentMultiplier => _multiplierTiers[multiplierTierIndex];

  String get multiplierLabel {
    final value = currentMultiplier;
    return 'x${value.toStringAsFixed(value % 1 == 0 ? 1 : 2)}';
  }

  int get baseScore {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 100;
      case Difficulty.logic:
        return 200;
      case Difficulty.manic:
        return 300;
    }
  }

  final LeaderboardService leaderboardService = LeaderboardService();

  double preGameSpriteOpacity = 0.0;
  double preGameSpriteScale = 0.005;
  Duration preGameSpriteScaleDuration = Duration.zero;
  Duration preGameSpriteFadeDuration = Duration.zero;

  bool showPreGameOverlay = false;
  bool waitingForStartTap = false;
  bool countdownRunning = false;
  String? preGameSpriteAsset;

  String? reactionAssetPath;
  double reactionOpacity = 0.0;
  double reactionScale = 0.005;
  Duration reactionScaleDuration = Duration.zero;
  Curve reactionScaleCurve = Curves.easeInOutCubic;

  String get _modeLabel => 'GATEKEEPING';

  String get _difficultyLabel {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 'BASIC';
      case Difficulty.logic:
        return 'LOGIC';
      case Difficulty.manic:
        return 'MANIC';
    }
  }

  String get _guideOverlayAsset {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return AppAssets.andyGuideGameBasic;
      case Difficulty.logic:
        return AppAssets.andyGuideGameLogic;
      case Difficulty.manic:
        return AppAssets.andyGuideGameManic;
    }
  }

  String get _difficultyDescription {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 'Expressions are as shown. This level focuses on the basic gates: NOT, AND, and OR.';

      case Difficulty.logic:
        return 'Expression are as shown but uses other logic gates like NAND, NOR, XNOR, XAND, and XOR symbols.';

      case Difficulty.manic:
        return 'Uses all logic gates, but expressions may be simplified using Boolean laws like double negation, absorption, and distributive laws.';
    }
  }

  String get _difficultyAndyAsset {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return AppAssets.andyBasic;
      case Difficulty.logic:
        return AppAssets.andyLogic;
      case Difficulty.manic:
        return AppAssets.andyManic;
    }
  }

  String get _gameOverOverlayAsset {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return AppAssets.andyGameOverBasic;
      case Difficulty.logic:
        return AppAssets.andyGameOverLogic;
      case Difficulty.manic:
        return AppAssets.andyGameOverManic;
    }
  }

  int get passesUsed => startingPasses - passesLeft;

  void _preparePreGameIntro({bool notify = true}) {
    roundLocked = true;
    showPreGameOverlay = true;
    waitingForStartTap = true;
    countdownRunning = false;
    preGameSpriteAsset = null;
    preGameSpriteOpacity = 0.0;
    preGameSpriteScale = 0.005;
    preGameSpriteScaleDuration = Duration.zero;
    preGameSpriteFadeDuration = Duration.zero;

    if (notify && mounted) {
      setState(() {});
    }
  }

  Future<void> _playCountdownSprite(String assetPath) async {
    if (!mounted) return;

    // Start tiny and visible
    setState(() {
      preGameSpriteAsset = assetPath;
      preGameSpriteOpacity = 1.0;
      preGameSpriteScale = 0.005;
      preGameSpriteScaleDuration = Duration.zero;
      preGameSpriteFadeDuration = Duration.zero;
    });

    // Let Flutter paint the tiny starting state first
    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted) return;

    // Zoom in: 100 ms
    setState(() {
      preGameSpriteScale = 1.0;
      preGameSpriteScaleDuration = const Duration(milliseconds: 100);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    // Stay visible at normal size: 700 ms
    await _pauseAwareDelay(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Fade out only: 200 ms
    setState(() {
      preGameSpriteOpacity = 0.0;
      preGameSpriteFadeDuration = const Duration(milliseconds: 200);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 200));
    if (!mounted) return;
  }

  Future<void> _handlePreGameTap() async {
    if (!showPreGameOverlay || !waitingForStartTap || countdownRunning) return;

    setState(() {
      waitingForStartTap = false;
      countdownRunning = true;
    });

    unawaited(SfxController.instance.playCountdown());

    await _runPreGameCountdown();
  }

  Future<void> _runPreGameCountdown() async {
    final sequence = <String>[
      AppAssets.handThree,
      AppAssets.handTwo,
      AppAssets.handOne,
      _difficultyAndyAsset,
    ];

    for (final asset in sequence) {
      await _playCountdownSprite(asset);
      if (!mounted) return;
    }

    if (!mounted) return;

    setState(() {
      showPreGameOverlay = false;
      waitingForStartTap = false;
      countdownRunning = false;
      preGameSpriteAsset = null;
      preGameSpriteOpacity = 0.0;
      preGameSpriteScale = 0.005;
      preGameSpriteScaleDuration = Duration.zero;
      preGameSpriteFadeDuration = Duration.zero;
      roundLocked = false;
    });
  }

  Future<void> showActionFeedback({
    required Color flash,
    required String asset,
  }) async {
    if (!mounted) return;

    setState(() {
      flashColor = flash;
      flashOpacity = 0.0;

      reactionAssetPath = asset;
      reactionOpacity = 1.0;
      reactionScale = 0.005;
      reactionScaleDuration = Duration.zero;
      reactionScaleCurve = Curves.easeInOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted) return;

    setState(() {
      flashOpacity = 0.55;
      reactionScale = 1.0;
      reactionScaleDuration = const Duration(milliseconds: 100);
      reactionScaleCurve = Curves.easeOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      reactionScale = 1.04;
      reactionScaleDuration = const Duration(milliseconds: 600);
      reactionScaleCurve = Curves.easeInOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      flashOpacity = 0.0;
      reactionScale = 0.005;
      reactionScaleDuration = const Duration(milliseconds: 100);
      reactionScaleCurve = Curves.easeInCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      reactionAssetPath = null;
      reactionOpacity = 0.0;
      reactionScale = 0.005;
      reactionScaleDuration = Duration.zero;
      reactionScaleCurve = Curves.easeInOutCubic;
    });
  }

  Timer? gameplayTimer;

  bool scoreSubmitted = false;

  int currentQuestionIndex = 0;
  int timeLeft = 0;
  int score = 0;
  int passesLeft = 0;
  int correctCount = 0;
  int wrongAttempts = 0;

  bool roundLocked = false;
  bool gameFinished = false;

  Color flashColor = Colors.transparent;
  double flashOpacity = 0.0;

  String? scoreDeltaText;
  Color scoreDeltaColor = Colors.white;
  double scoreDeltaOpacity = 0.0;
  double scoreDeltaYOffset = 0.0;
  double scoreDeltaXOffset = 0.0;

  String? timeDeltaText;
  Color timeDeltaColor = Colors.white;
  double timeDeltaOpacity = 0.0;
  double timeDeltaYOffset = 0.0;

  String? centerPopupText;
  Color centerPopupColor = Colors.white;
  double centerPopupOpacity = 0.0;
  double centerPopupScale = 0.9;

  void initializeSharedRun() {
    _resetComboOverlayState();
    hotstreakCount = 0;
    multiplierTierIndex = 0;
    multiplierStepProgress = 0;
    scoreSubmitted = false;
    gameplayTimer?.cancel();

    currentQuestionIndex = 0;
    score = 0;
    passesLeft = startingPasses;
    correctCount = 0;
    wrongAttempts = 0;

    showGameResultOverlay = false;
    gameFinished = false;
    roundLocked = false;
    timeLeft = startingRoundTime;

    loadCurrentQuestion();
    startGameplayTimer();
    setState(() {});
  }

  void startGameplayTimer() {
    gameplayTimer?.cancel();

    gameplayTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || roundLocked || gameFinished) return;

      if (timeLeft <= 1) {
        setState(() {
          timeLeft = 0;
        });
        handleTimeout();
      } else {
        setState(() {
          timeLeft--;
        });
      }
    });
  }

  Future<void> handlePass() async {
    if (roundLocked || gameFinished) return;
    if (passesLeft <= 0) return;

    setState(() {
      roundLocked = true;
      passesLeft--;
    });

    unawaited(SfxController.instance.playPass());
    HapticFeedback.mediumImpact();

    await showActionFeedback(
      flash: const Color(0xFFFFB347),
      asset: AppAssets.handPass,
    );

    await finishRound(scoreDelta: -10, timeDelta: 0, advanceQuestion: true);
  }

  Future<void> handleTimeout() async {
    if (gameFinished) return;
    await _performTimeout();
  }

Future<void> _performTimeout() async {
  if (gameFinished && showGameResultOverlay) return;

  gameplayTimer?.cancel();
  HapticFeedback.heavyImpact();

  if (!mounted) return;

  setState(() {
    gameFinished = true;
    roundLocked = true;
    timeLeft = 0;

    showBackConfirmOverlay = false;
    showPreGameOverlay = false;
    countdownRunning = false;

    gameResultTitle = 'ROUND COMPLETE';
    showGameResultOverlay = true;
  });

  unawaited(SfxController.instance.playGameOver());

  try {
    await submitFinalScoreOnce();
  } catch (e, st) {
    debugPrint('Failed to submit final score: $e');
    debugPrintStack(stackTrace: st);
  }
}

  Future<void> finishRound({
    required int scoreDelta,
    required int timeDelta,
    required bool advanceQuestion,
  }) async {
    setState(() {
      roundLocked = true;
      score = (score + scoreDelta).clamp(0, 999999);
      timeLeft = (timeLeft + timeDelta).clamp(0, 999999);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 850));

    if (!mounted || gameFinished) return;

    if (timeLeft <= 0) {
      await _performTimeout();
      return;
    }

    if (advanceQuestion) {
      setState(() {
        roundLocked = false;
        goToNextQuestion();
      });
    } else {
      setState(() {
        onRetryCurrentQuestion();
        roundLocked = false;
      });
    }
  }

  Future<void> showScoreDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      scoreDeltaText = text;
      scoreDeltaColor = color;
      scoreDeltaOpacity = 1.0;
      scoreDeltaYOffset = 0.0;
      scoreDeltaXOffset = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      scoreDeltaYOffset = -15.0;
      scoreDeltaXOffset = -10.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      scoreDeltaOpacity = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      scoreDeltaText = null;
      scoreDeltaYOffset = 0.0;
      scoreDeltaXOffset = 0.0;
    });
  }

  Future<void> showTimeDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      timeDeltaText = text;
      timeDeltaColor = color;
      timeDeltaOpacity = 1.0;
      timeDeltaYOffset = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      timeDeltaYOffset = -15.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      timeDeltaOpacity = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      timeDeltaText = null;
      timeDeltaYOffset = 0.0;
    });
  }

  Future<void> submitFinalScoreOnce() async {
    if (scoreSubmitted) return;
    scoreSubmitted = true;

    await leaderboardService.submitScore(
      modeId: modeId,
      difficultyId: difficultyId,
      score: score,
    );
  }

  static const int _startingRoundTimeValue = 60;
  static const int _startingPassesValue = 5;

  static const Color _operatorOr = Color(0xFFFD8900);
  static const Color _operatorAnd = Color(0xFF006CFF);
  static const Color _operatorNot = Color(0xFFFA2626);
  static const Color _operatorXor = Color(0xFFE43AE2);
  static const Color _operatorNand = Color(0xFF9822F2);
  static const Color _operatorNor = Color(0xFF33B300);
  static const Color _operatorXnor = Color(0xFF00CEB4);

  static const Color _operatorBlue = Color(0xFF00D0FF);
  static const Color _operatorYellow = Color(0xFFEDB600);
  static const Color _operatorGreen = Color(0xFF08C90A);
  static const Color _operatorCoral = Color(0xFFF4553F);
  static const Color _operatorPurple = Color(0xFF9C6BFF);
  static const Color _operatorOrange = Color(0xFFFF8A00);

  static const Color _passOrange = Color(0xFFFF6B00);
  static const Color _backspaceGrey = Color(0xFFA8A8A8);
  static const Color _brownText = Color(0xFF8A5200);
  static const Color _lineBrown = Color(0xFF7B5A2A);

  final Random _random = Random();

  late List<GatekeepingQuestion> _questions;
  late List<_ExpressionPart> _parsedExpression;
  late List<String?> _playerAnswers;
  late List<String> _currentChoiceOperators;

  int _activeSlotIndex = 0;

  GatekeepingQuestion get _currentQuestion => _questions[currentQuestionIndex];

  @override
  int get startingRoundTime => _startingRoundTimeValue;

  @override
  int get startingPasses => _startingPassesValue;

  @override
  String get modeId => 'gatekeeping';

  @override
  String get difficultyId {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 'basic';
      case Difficulty.logic:
        return 'logic';
      case Difficulty.manic:
        return 'manic';
    }
  }

  @override
  int get questionCount => _questions.length;

  @override
  void resetWholeGame() {
    unawaited(SfxController.instance.playPlaySelect());
    _questions = GatekeepingQuestionRepository.getShuffledByDifficulty(
      widget.difficulty,
    );

    if (_questions.isEmpty) {
      gameFinished = true;
      setState(() {});
      return;
    }

    initializeSharedRun();
    _preparePreGameIntro();
  }

  @override
  void goToNextQuestion() {
    if (_questions.isEmpty) return;

    setState(() {
      currentQuestionIndex++;

      if (currentQuestionIndex >= _questions.length) {
        _questions.shuffle();
        currentQuestionIndex = 0;
      }

      loadCurrentQuestion();
    });
  }

  @override
  void onRetryCurrentQuestion() {
    _playerAnswers = List<String?>.filled(_playerAnswers.length, null);
    _activeSlotIndex = 0;
  }

  @override
  void loadCurrentQuestion() {
    _parsedExpression = _parseExpression(_currentQuestion.expression);
    final slotCount = _parsedExpression.where((part) => part.isSlot).length;

    _playerAnswers = List<String?>.filled(slotCount, null);
    _activeSlotIndex = 0;
    _currentChoiceOperators = _buildChoiceOperatorsForCurrentQuestion();
    roundLocked = false;
  }

  List<_ExpressionPart> _parseExpression(String expression) {
    final regex = RegExp(r'__(XNOR|XOR|NAND|NOR|AND|OR|NOT)\b');
    final parts = <_ExpressionPart>[];

    int lastEnd = 0;

    for (final match in regex.allMatches(expression)) {
      if (match.start > lastEnd) {
        final text = expression.substring(lastEnd, match.start);
        if (text.isNotEmpty) {
          parts.add(_ExpressionPart.text(text));
        }
      }

      parts.add(_ExpressionPart.slot(match.group(1)!));
      lastEnd = match.end;
    }

    if (lastEnd < expression.length) {
      final tail = expression.substring(lastEnd);
      if (tail.isNotEmpty) {
        parts.add(_ExpressionPart.text(tail));
      }
    }

    return parts;
  }

  List<String> _correctAnswersForCurrentQuestion() {
    return _currentQuestion.answers;
  }

  List<String> _availableOperatorsForDifficulty() {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return ['AND', 'OR', 'NOT', 'XOR'];
      case Difficulty.logic:
      case Difficulty.manic:
        return ['AND', 'OR', 'NOT', 'XOR', 'XNOR', 'NAND', 'NOR'];
    }
  }

  List<String> _buildChoiceOperatorsForCurrentQuestion() {
    final required = _currentQuestion.answers.toSet().toList();
    final pool = _availableOperatorsForDifficulty();

    final extras = pool.where((op) => !required.contains(op)).toList()
      ..shuffle(_random);

    final choices = <String>[...required];
    final targetButtonCount = required.length > 4 ? required.length : 4;

    for (final op in extras) {
      if (choices.length >= targetButtonCount) break;
      choices.add(op);
    }

    choices.shuffle(_random);
    return choices;
  }

  void _handleOperatorTap(String operator) {
    if (roundLocked || gameFinished) return;
    if (_activeSlotIndex >= _playerAnswers.length) return;

    HapticFeedback.selectionClick();
    unawaited(SfxController.instance.playOperatorTap());

    setState(() {
      _playerAnswers[_activeSlotIndex] = operator;

      final nextEmpty = _findNextEmptySlot(start: _activeSlotIndex + 1);
      if (nextEmpty != null) {
        _activeSlotIndex = nextEmpty;
      }
    });

    if (_playerAnswers.every((value) => value != null)) {
      Future(() async {
        await _pauseAwareDelay(const Duration(milliseconds: 150));
        if (!mounted || roundLocked || gameFinished) return;
        _checkCurrentAnswer();
      });
    }
  }

  int? _findNextEmptySlot({int start = 0}) {
    for (int i = start; i < _playerAnswers.length; i++) {
      if (_playerAnswers[i] == null) return i;
    }
    return null;
  }

  int? _findLastFilledSlot() {
    for (int i = _playerAnswers.length - 1; i >= 0; i--) {
      if (_playerAnswers[i] != null) return i;
    }
    return null;
  }

  void _handleBackspace() {
    if (roundLocked || gameFinished) return;

    final lastFilled = _findLastFilledSlot();
    if (lastFilled == null) return;

    HapticFeedback.selectionClick();
    unawaited(SfxController.instance.playBackspace());

    setState(() {
      _playerAnswers[lastFilled] = null;
      _activeSlotIndex = lastFilled;
    });
  }

  Future<void> _checkCurrentAnswer() async {
    if (roundLocked || gameFinished) return;

    setState(() {
      roundLocked = true;
    });

    final correctAnswers = _correctAnswersForCurrentQuestion();
    final isCorrect = _listEquals(
      _playerAnswers.map((e) => e ?? '').toList(),
      correctAnswers,
    );

    if (isCorrect) {
      const gainedTime = 2;

      final previousMultiplierTierIndex = multiplierTierIndex;

      correctCount++;
      hotstreakCount++;
      multiplierStepProgress++;

      if (multiplierStepProgress >= 2 &&
          multiplierTierIndex < _multiplierTiers.length - 1) {
        multiplierTierIndex++;
        multiplierStepProgress = 0;
      }

      final multiplierWentUp = multiplierTierIndex > previousMultiplierTierIndex;

      // Shows a smaller celebration every 3 correct answers if the multiplier
      // did not already trigger a bigger celebration.
      final shouldShowHotStreakOverlay =
          !multiplierWentUp && hotstreakCount >= 3 && hotstreakCount % 3 == 0;

      if (multiplierWentUp || shouldShowHotStreakOverlay) {
        HapticFeedback.heavyImpact();

        unawaited(
          _playComboMultiplierOverlay(
            multiplierWentUp: multiplierWentUp,
          ),
        );
      }

      final gainedScore = (baseScore * currentMultiplier).round();

      //playFlash(isCorrect: true);
      unawaited(SfxController.instance.playCorrect());
      await showActionFeedback(flash: Colors.green, asset: AppAssets.thumbsUp);
      showScoreDelta('+$gainedScore', Colors.greenAccent);
      showTimeDelta('+$gainedTime s', Colors.greenAccent);

      await finishRound(
        scoreDelta: gainedScore,
        timeDelta: gainedTime,
        advanceQuestion: true,
      );
    } else {
      const lostTime = -1;

      wrongAttempts++;
      hotstreakCount = 0;
      multiplierStepProgress = 0;
      _comboOverlayRunId++;
      _showComboOverlay = false;

      if (multiplierTierIndex > 0) {
        multiplierTierIndex--;
      }

      final lostScore = baseScore;

      //playWrongDamageFlash();
      unawaited(SfxController.instance.playWrong());
      await showActionFeedback(flash: Colors.red, asset: AppAssets.thumbsDown);
      showScoreDelta('-$lostScore', Colors.redAccent);
      showTimeDelta('${lostTime}s', Colors.redAccent);

      await finishRound(
        scoreDelta: -lostScore,
        timeDelta: lostTime,
        advanceQuestion: false,
      );
    }
  }

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _symbolForOperator(String operator) {
    return _operatorConfigs[operator]?.symbol ?? '?';
  }

  Widget _buildTimerText(double width) {
    return Center(
      child: Text(
        '$timeLeft',
        style: TextStyle(
          fontSize: width * 0.10,
          fontWeight: FontWeight.w900,
          color: _brownText,
          shadows: const [
            Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreText(double width) {
    return Center(
      child: Text(
        '$score',
        style: TextStyle(
          fontSize: width * 0.085,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE6F7D9),
          shadows: const [
            Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildMultiplierText(double width) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.18),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFFFE28A).withOpacity(0.7),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              'Mult: $multiplierLabel',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: width * 0.040,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFE28A),
                height: 1.0,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 1.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Streak: $hotstreakCount',
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: width * 0.040,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
                shadows: const [
                  Shadow(
                    color: Colors.black38,
                    offset: Offset(0, 1.5),
                    blurRadius: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramPlaceholder() {
    return Container(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Image.asset(
          _currentQuestion.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Text(
                'Diagram image not found:\n${_currentQuestion.imagePath}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _lineBrown,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildExpressionBar() {
    int slotIndex = 0;
    final children = <Widget>[];

    for (final part in _parsedExpression) {
      if (!part.isSlot) {
        final text = part.text;
        if (text != null && text.isNotEmpty) {
          children.add(
            Text(
              text,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          );
        }
        continue;
      }

      final currentSlot = slotIndex;
      slotIndex++;

      final playerValue = _playerAnswers[currentSlot];
      final isActive = _activeSlotIndex == currentSlot && !roundLocked;

      children.add(
        GestureDetector(
          onTap: () {
            if (roundLocked || gameFinished) return;
            setState(() {
              _activeSlotIndex = currentSlot;
            });
          },
          child: Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(playerValue == null ? 0.85 : 1),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isActive ? const Color(0xFFFFE28A) : Colors.white,
                width: isActive ? 3 : 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              playerValue == null ? '' : _symbolForOperator(playerValue),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: playerValue == null ? Colors.transparent : _brownText,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildPassStrip() {
    return Container(
      height: 32,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFD8C6B5), width: 2),
      ),
      child: Text(
        'PASSES LEFT: $passesLeft',
        style: const TextStyle(
          color: _passOrange,
          fontSize: 14,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildChoiceButton({
    required String symbol,
    required Color color,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return BeveledMenuButton(
      label: symbol,
      color: color,
      width: width,
      height: height,
      textColor: _brownText,
      fontSize: 45,
      onTap: onTap,
    );
  }

  Widget _buildChoiceGrid({
    required double buttonWidth,
    required double buttonHeight,
    required double gap,
  }) {
    return Wrap(
      spacing: gap,
      runSpacing: 3,
      children: _currentChoiceOperators.map((operator) {
        final config = _operatorConfigs[operator]!;

        return SizedBox(
          width: buttonWidth,
          child: _buildChoiceButton(
            symbol: config.symbol,
            color: config.color,
            width: buttonWidth,
            height: buttonHeight,
            onTap: () => _handleOperatorTap(operator),
          ),
        );
      }).toList(),
    );
  }



  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: GameMenuBackground(
          backgroundColor: AppColors.blueBg,
          child: const Center(
            child: Text(
              'No questions available.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    final size = MediaQuery.of(context).size;
    final double sidePadding = 18;
    final double gap = 8;
    final double operatorButtonWidth =
        (size.width - (sidePadding * 2) - gap) / 2;
    final double operatorButtonHeight = 85;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        useGrid: false,
        child: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 2,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PauseIconButton(onTap: _onPausePressed),

                            /*
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              iconSize: 24,
                              icon: const Icon(
                                Icons.help_outline,
                                color: Colors.white,
                              ),
                              onPressed: () => (), //_showGatekeepingTutorial(),
                            ),

                            */
                            const MusicButton(size: 26),
                          ],
                        ),
                      ),
                      AspectRatio(
                        aspectRatio: 0.78,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final w = constraints.maxWidth;
                            final h = constraints.maxHeight;

                            return Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    AppAssets.diagramContainerGreen1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  left: w * 0.055,
                                  top: h * 0.045,
                                  width: w * 0.18,
                                  height: h * 0.10,
                                  child: Container(
                                    //key: _timerKey,
                                    child: _buildTimerText(w),
                                  ),
                                ),
                                if (timeDeltaText != null)
                                  Positioned(
                                    left: w * 0.15,
                                    top: h * 0.15 + timeDeltaYOffset,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      opacity: timeDeltaOpacity,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            timeDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.06,
                                              fontWeight: FontWeight.w900,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 3
                                                ..color =
                                                    timeDeltaText!.startsWith(
                                                      '-',
                                                    )
                                                    ? const Color(0xFFD50000)
                                                    : const Color(0xFF0FAF2A),
                                            ),
                                          ),
                                          Text(
                                            timeDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.06,
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  timeDeltaText!.startsWith('-')
                                                  ? const Color(0xFFFFD0D0)
                                                  : const Color(0xFFBEFFC9),
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black38,
                                                  offset: Offset(0, 2),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                Positioned(
                                  left: w * 0.24,
                                  right: w * 0.4,
                                  top: h * 0.02,
                                  height: h * 0.11,
                                  child: _buildMultiplierText(w),
                                ),

                                Positioned(
                                  right: w * 0.07,
                                  top: h * 0.055,
                                  width: w * 0.31,
                                  height: h * 0.09,
                                  child: _buildScoreText(w),
                                ),
                                if (scoreDeltaText != null)
                                  Positioned(
                                    right: w * 0.11,
                                    top: h * 0.13 + scoreDeltaYOffset,
                                    child: AnimatedOpacity(
                                      duration: const Duration(
                                        milliseconds: 250,
                                      ),
                                      opacity: scoreDeltaOpacity,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            scoreDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.09,
                                              fontWeight: FontWeight.w900,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 4
                                                ..color =
                                                    scoreDeltaText!.startsWith(
                                                      '-',
                                                    )
                                                    ? const Color(0xFFD50000)
                                                    : const Color(0xFF0FAF2A),
                                            ),
                                          ),
                                          Text(
                                            scoreDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.09,
                                              fontWeight: FontWeight.w900,
                                              color:
                                                  scoreDeltaText!.startsWith(
                                                    '-',
                                                  )
                                                  ? const Color(0xFFFFD0D0)
                                                  : const Color(0xFFBEFFC9),
                                              shadows: const [
                                                Shadow(
                                                  color: Colors.black38,
                                                  offset: Offset(0, 2),
                                                  blurRadius: 3,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  left: w * 0.12,
                                  right: w * 0.12,
                                  top: h * 0.18,
                                  height: h * 0.55,
                                  child: Container(
                                    //key: _diagramKey,
                                    child: _buildDiagramPlaceholder(),
                                  ),
                                ),
                                Positioned(
                                  left: w * 0.12,
                                  right: w * 0.12,
                                  bottom: h * 0.08,
                                  height: h * 0.08,
                                  child: Container(
                                    //key: _expressionKey,
                                    child: _buildExpressionBar(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      IgnorePointer(
                        ignoring: roundLocked || gameFinished,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            sidePadding,
                            0,
                            sidePadding,
                            0,
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  BeveledMenuButton(
                                    label: 'PASS',
                                    color: _passOrange,
                                    width: 120,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 20,
                                    enabled: passesLeft > 0,
                                    onTap: () {
                                      handlePass();
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildPassStrip()),
                                  const SizedBox(width: 8),
                                  BeveledMenuButton(
                                    label: '⌫',
                                    color: _backspaceGrey,
                                    width: 80,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 26,
                                    onTap: _handleBackspace,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                //key: _buttonsKey,
                                child: _buildChoiceGrid(
                                  buttonWidth: operatorButtonWidth,
                                  buttonHeight: operatorButtonHeight,
                                  gap: gap,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeInOut,
                    opacity: flashOpacity,
                    child: ColoredBox(color: flashColor),
                  ),
                ),
              ),

              if (reactionAssetPath != null)
                IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOutCubic,
                      opacity: reactionOpacity,
                      child: AnimatedScale(
                        duration: reactionScaleDuration,
                        curve: reactionScaleCurve,
                        scale: reactionScale,
                        child: Image.asset(
                          reactionAssetPath!,
                          width: 190,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),

              if (centerPopupText != null)
                IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: centerPopupOpacity,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        scale: centerPopupScale,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            centerPopupText!,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: centerPopupColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              if (_showComboOverlay)
                _buildComboMultiplierOverlay(),

             
              if (showGameResultOverlay)
                GameResultOverlay(
                  backgroundAssetPath: _gameOverOverlayAsset,
                  modeLabel: 'Gatekeeping',
                  difficultyLabel: _difficultyLabel,
                  score: score,
                  correctCount: correctCount,
                  wrongAttempts: wrongAttempts,
                  passesUsed: passesUsed,
                  onRetry: () {
                    resetWholeGame();
                  },
                  onLeaderboards: () {
                    unawaited(SfxController.instance.playMenuPress());
                    Navigator.pushNamed(context, AppRoutes.leaderboards);
                  },
                  onBackToMenu: () {
                    unawaited(SfxController.instance.playMenuBack());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                ),

              if (showPreGameOverlay)
                PreGameOverlay(
                  modeLabel: _modeLabel,
                  difficultyLabel: _difficultyLabel,
                  difficultyDescription: _difficultyDescription,
                  guideOverlayAssetPath: _guideOverlayAsset,
                  waitingForTap: waitingForStartTap,
                  spriteAssetPath: preGameSpriteAsset,
                  onTap: _handlePreGameTap,
                  spriteOpacity: preGameSpriteOpacity,
                  spriteScale: preGameSpriteScale,
                  spriteScaleDuration: preGameSpriteScaleDuration,
                  spriteFadeDuration: preGameSpriteFadeDuration,
                ),
              
               if (showBackConfirmOverlay)
                PauseOverlay(
                  backgroundAssetPath: AppAssets.andyPauseGame,
                  onResume: _closeBackOverlay,
                  onRetry: () {
                    setState(() {
                      showBackConfirmOverlay = false;
                    });

                    resetWholeGame();
                  },
                  onExitToMenu: () {
                    unawaited(SfxController.instance.playGameOver());
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.home,
                      (route) => false,
                    );
                  },
                ),


            ],
          ),
        ),
      ),
    );
  }
}

class _ExpressionPart {
  const _ExpressionPart.text(this.text) : answer = null, isSlot = false;

  const _ExpressionPart.slot(this.answer) : text = null, isSlot = true;

  final String? text;
  final String? answer;
  final bool isSlot;
}

class _OperatorConfig {
  final String symbol;
  final Color color;

  const _OperatorConfig({required this.symbol, required this.color});
}

const Map<String, _OperatorConfig> _operatorConfigs = {
  'OR': _OperatorConfig(
    symbol: '+',
    color: _GatekeepingGamePageState._operatorOr,
  ),
  'AND': _OperatorConfig(
    symbol: '•',
    color: _GatekeepingGamePageState._operatorAnd,
  ),
  'NOT': _OperatorConfig(
    symbol: '¬',
    color: _GatekeepingGamePageState._operatorNot,
  ),
  'NOR': _OperatorConfig(
    symbol: '↓',
    color: _GatekeepingGamePageState._operatorNor,
  ),
  'NAND': _OperatorConfig(
    symbol: '↑',
    color: _GatekeepingGamePageState._operatorNand,
  ),
  'XOR': _OperatorConfig(
    symbol: '⊕',
    color: _GatekeepingGamePageState._operatorXor,
  ),
  'XNOR': _OperatorConfig(
    symbol: '⊙',
    color: _GatekeepingGamePageState._operatorXnor,
  ),
};


class _ComboMultiplierOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final String multiplier;
  final int streak;
  final Color accent;

  final double opacity;
  final double scale;
  final double ringScale;
  final double pixelSpread;
  final double tilt;
  final double slideY;

  static const Color _comboBoxColor = Color(0xFFD114F7);
  static const Color _comboPurpleAccent = Color(0xFF7A1CFF);
  static const Color _comboMagentaGlow = Color(0xFFFF4DFF);
  static const Color _comboSoftPink = Color(0xFFFFB8FF);

  const _ComboMultiplierOverlay({
    required this.title,
    required this.subtitle,
    required this.multiplier,
    required this.streak,
    required this.accent,
    required this.opacity,
    required this.scale,
    required this.ringScale,
    required this.pixelSpread,
    required this.tilt,
    required this.slideY,
  });

  static const List<_ComboPixelParticle> _particles = [
    _ComboPixelParticle(direction: Offset(-0.95, -0.45), size: 10),
    _ComboPixelParticle(direction: Offset(-0.65, -0.75), size: 8),
    _ComboPixelParticle(direction: Offset(-0.25, -0.92), size: 11),
    _ComboPixelParticle(direction: Offset(0.25, -0.92), size: 8),
    _ComboPixelParticle(direction: Offset(0.70, -0.68), size: 10),
    _ComboPixelParticle(direction: Offset(0.98, -0.35), size: 9),
    _ComboPixelParticle(direction: Offset(0.95, 0.22), size: 12),
    _ComboPixelParticle(direction: Offset(0.62, 0.65), size: 8),
    _ComboPixelParticle(direction: Offset(0.20, 0.88), size: 10),
    _ComboPixelParticle(direction: Offset(-0.30, 0.88), size: 9),
    _ComboPixelParticle(direction: Offset(-0.72, 0.58), size: 11),
    _ComboPixelParticle(direction: Offset(-0.98, 0.15), size: 8),

    // inner sparkle layer
    _ComboPixelParticle(direction: Offset(-0.38, -0.28), size: 7),
    _ComboPixelParticle(direction: Offset(0.38, -0.25), size: 7),
    _ComboPixelParticle(direction: Offset(0.42, 0.30), size: 6),
    _ComboPixelParticle(direction: Offset(-0.45, 0.32), size: 6),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    final titleSize = (screenWidth * 0.095).clamp(30.0, 48.0).toDouble();
    final multiplierSize = (screenWidth * 0.155).clamp(54.0, 82.0).toDouble();

    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        opacity: opacity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Full-screen arcade glow.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 0.78,
                    colors: [
                      accent.withOpacity(0.34),
                      accent.withOpacity(0.16),
                      Colors.black.withOpacity(0.04),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.32, 0.62, 1.0],
                  ),
                ),
              ),
            ),

            // Pixel burst particles.
            for (int i = 0; i < _particles.length; i++)
              AnimatedAlign(
                duration: const Duration(milliseconds: 460),
                curve: Curves.easeOutBack,
                alignment: Alignment(
                  _particles[i].direction.dx * pixelSpread * 0.82,
                  _particles[i].direction.dy * pixelSpread * 0.58,
                ),
                child: Transform.rotate(
                  angle: pixelSpread * 0.8,
                  child: Container(
                    width: _particles[i].size,
                    height: _particles[i].size,
                    decoration: BoxDecoration(
                      color: _particleColor(i),
                      boxShadow: [
                        BoxShadow(
                          color: _particleColor(i).withOpacity(0.8),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Large square ring 1.
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 420),
                curve: Curves.easeOutCubic,
                scale: ringScale,
                child: Transform.rotate(
                  angle: 0.16,
                  child: Container(
                    width: 210,
                    height: 210,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white.withOpacity(0.72),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withOpacity(0.55),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Large square ring 2.
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 520),
                curve: Curves.easeOutCubic,
                scale: ringScale * 1.25,
                child: Transform.rotate(
                  angle: -0.22,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: accent.withOpacity(0.70),
                        width: 5,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Horizontal pixel slash.
            Center(
              child: AnimatedScale(
                duration: const Duration(milliseconds: 340),
                curve: Curves.easeOutExpo,
                scale: pixelSpread.clamp(0.0, 1.0),
                child: Container(
                  width: screenWidth * 0.82,
                  height: 9,
                  color: Colors.white.withOpacity(0.58),
                ),
              ),
            ),

            // Main arcade text card.
            Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutBack,
                transform: Matrix4.identity()
                  ..translate(0.0, slideY)
                  ..rotateZ(tilt),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: _comboBoxColor.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _comboSoftPink.withOpacity(0.95),
                        width: 4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _comboMagentaGlow.withOpacity(0.85),
                          blurRadius: 34,
                          spreadRadius: 6,
                        ),
                        BoxShadow(
                          color: _comboPurpleAccent.withOpacity(0.65),
                          blurRadius: 24,
                          spreadRadius: 3,
                        ),
                        const BoxShadow(
                          color: Colors.black45,
                          offset: Offset(0, 8),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _ArcadeStrokeText(
                          text: title,
                          fontSize: titleSize,
                          fillColor: Colors.white,
                          strokeColor: _comboPurpleAccent,
                          strokeWidth: 7,
                          letterSpacing: 1.4,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          multiplier,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: multiplierSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                            height: 0.95,
                            color: Colors.white,
                            shadows: const [
                              Shadow(
                                color: Color(0xFFFF4DFF),
                                offset: Offset(0, 0),
                                blurRadius: 16,
                              ),
                              Shadow(
                                color: Color(0xFF7A1CFF),
                                offset: Offset(0, 4),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _comboPurpleAccent.withOpacity(0.92),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            subtitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  offset: Offset(0, 2),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'STREAK $streak',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                            shadows: const [
                              Shadow(
                                color: Colors.black54,
                                offset: Offset(0, 2),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _particleColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.white;
      case 1:
        return accent;
      case 2:
        return const Color(0xFFFFF176);
      default:
        return const Color(0xFF00E5FF);
    }
  }
}

class _ComboPixelParticle {
  final Offset direction;
  final double size;

  const _ComboPixelParticle({
    required this.direction,
    required this.size,
  });
}

class _ArcadeStrokeText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color fillColor;
  final Color strokeColor;
  final double strokeWidth;
  final double letterSpacing;

  const _ArcadeStrokeText({
    required this.text,
    required this.fontSize,
    required this.fillColor,
    required this.strokeColor,
    required this.strokeWidth,
    required this.letterSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: letterSpacing,
            height: 0.95,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = strokeWidth
              ..color = strokeColor,
          ),
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w900,
            letterSpacing: letterSpacing,
            height: 0.95,
            color: fillColor,
            shadows: const [
              Shadow(
                color: Colors.black54,
                offset: Offset(0, 3),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}