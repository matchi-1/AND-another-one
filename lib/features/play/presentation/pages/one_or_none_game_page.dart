import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/audio/bgm_controller.dart';
import '../../../../core/audio/sfx_controller.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../../shared/widgets/pause_icon_button.dart';
import '../../../leaderboards/util/leaderboard_service.dart';
import '../../data/models/gatekeeping_question.dart';
import '../../data/repositories/gatekeeping_question_repository.dart';
import '../widgets/gameplay_overlays.dart';

class OneOrNoneGamePage extends StatefulWidget {
  const OneOrNoneGamePage({
    super.key,
    this.difficulty = Difficulty.basic,
  });

  final Difficulty difficulty;

  @override
  State<OneOrNoneGamePage> createState() => _OneOrNoneGamePageState();
}

class _OneOrNoneGamePageState extends State<OneOrNoneGamePage>
    with WidgetsBindingObserver {
  bool _didPrecacheOverlayImages = false;

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
        _multiplierTierIndex >= _multiplierTiers.length - 1;

    setState(() {
      _showComboOverlay = true;

      _comboOverlayTitle = multiplierWentUp
          ? isMaxMultiplier
          ? 'MAX MULTIPLIER!'
          : 'MULTIPLIER UP!'
          : 'HOT STREAK!';

      _comboOverlaySubtitle = '$_hotstreakCount IN A ROW';

      _comboOverlayMultiplier = _multiplierLabel;
      _comboOverlayAccent = _comboAccentForTier(_multiplierTierIndex);

      _comboOverlayOpacity = 0.0;
      _comboOverlayScale = 0.45;
      _comboOverlayRingScale = 0.0;
      _comboOverlayPixelSpread = 0.0;
      _comboOverlayTilt = -0.10;
      _comboOverlaySlideY = 28.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted || runId != _comboOverlayRunId) return;

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

    setState(() {
      _comboOverlayScale = 1.0;
      _comboOverlayRingScale = 1.15;
      _comboOverlayPixelSpread = 1.0;
      _comboOverlayTilt = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 680));
    if (!mounted || runId != _comboOverlayRunId) return;

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
      accent: _comboOverlayAccent,
      opacity: _comboOverlayOpacity,
      scale: _comboOverlayScale,
      ringScale: _comboOverlayRingScale,
      pixelSpread: _comboOverlayPixelSpread,
      tilt: _comboOverlayTilt,
      slideY: _comboOverlaySlideY,
    );
  }

  int _hotstreakCount = 0;
  int _multiplierTierIndex = 0;
  int _multiplierStepProgress = 0; // 2 correct answers = tier up

  bool _showComboOverlay = false;
  int _comboOverlayRunId = 0;

  String _comboOverlayTitle = '';
  String _comboOverlaySubtitle = '';
  String _comboOverlayMultiplier = '';

  Color _comboOverlayAccent = const Color(0xFFFFE45C);

  double _comboOverlayOpacity = 0.0;
  double _comboOverlayScale = 0.55;
  double _comboOverlayRingScale = 0.0;
  double _comboOverlayPixelSpread = 0.0;
  double _comboOverlayTilt = 0.0;
  double _comboOverlaySlideY = 20.0;

  static const List<double> _multiplierTiers = [
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
    3.0,
  ];

  static const List<Color> _comboTierColors = [
    Color(0xFFFFE45C), // x1.0
    Color(0xFFFFB000), // x1.25
    Color(0xFFFF6B00), // x1.5
    Color(0xFFFF3D81), // x1.75
    Color(0xFFB85CFF), // x2.0
    Color(0xFF00E5FF), // x3.0
  ];

  double get _currentMultiplier => _multiplierTiers[_multiplierTierIndex];

  String get _multiplierLabel {
    final value = _currentMultiplier;
    return 'x${value.toStringAsFixed(value % 1 == 0 ? 1 : 2)}';
  }

  int get _baseScore {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 100;
      case Difficulty.logic:
        return 200;
      case Difficulty.manic:
        return 300;
    }
  }

  static const int _startingPasses = 5;
  static const int _startingLives = 3;

  static const Color _passOrange = Color(0xFFFF6B00);
  static const Color _brownText = Color(0xFF8A5200);
  static const Color _lineBrown = Color(0xFF7B5A2A);

  static const Color _choiceOne = Color(0xFF00D3FF);
  static const Color _choiceZero = Color(0xFFFFBC19);
  static const Color _valuesGreen = Color(0xFF0BAE22);

  final LeaderboardService _leaderboardService = LeaderboardService();
  final Random _random = Random();

  late List<GatekeepingQuestion> _questions;
  late String _normalizedExpression;
  late List<String> _currentVariables;
  late Map<String, int> _currentVariableValues;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _passesLeft = _startingPasses;
  int _livesLeft = _startingLives;
  int _correctOutput = 0;

  int _correctCount = 0;
  int _wrongAttempts = 0;
  int _highestHotstreakCount = 0;

  bool _roundLocked = false;
  bool _gameFinished = false;
  bool _scoreSubmitted = false;

  bool _showBackConfirmOverlay = false;
  bool _showGameResultOverlay = false;

  bool _pausedByLifecycle = false;
  bool _wasRoundLockedBeforeLifecyclePause = false;
  Completer<void>? _lifecycleResumeCompleter;
  bool _wasRoundLockedBeforePauseOverlay = false;

  String _gameResultTitle = 'ROUND COMPLETE';

  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0.0;

  String? _reactionAssetPath;
  double _reactionOpacity = 0.0;
  double _reactionScale = 0.005;
  Duration _reactionScaleDuration = Duration.zero;
  Curve _reactionScaleCurve = Curves.easeInOutCubic;

  String? _scoreDeltaText;
  double _scoreDeltaOpacity = 0.0;
  double _scoreDeltaYOffset = 0.0;
  double _scoreDeltaXOffset = 0.0;

  String? _livesDeltaText;
  double _livesDeltaOpacity = 0.0;
  double _livesDeltaYOffset = 0.0;

  int? _losingHeartIndex;
  bool _lostHeartAnimating = false;

  bool _showPreGameOverlay = false;
  bool _waitingForStartTap = false;
  bool _countdownRunning = false;
  String? _preGameSpriteAsset;
  double _preGameSpriteOpacity = 0.0;
  double _preGameSpriteScale = 0.005;
  Duration _preGameSpriteScaleDuration = Duration.zero;
  Duration _preGameSpriteFadeDuration = Duration.zero;

  GatekeepingQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  String get _modeLabel => 'ONE OR NONE';

  String get _difficultyId {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 'basic';
      case Difficulty.logic:
        return 'logic';
      case Difficulty.manic:
        return 'manic';
    }
  }

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

  String get _difficultyDescription {
    switch (widget.difficulty) {
      case Difficulty.basic:
        return 'Solve the shown circuit by deciding whether its final output is 1 or 0 using the displayed input values.';
      case Difficulty.logic:
        return 'The final output still depends on the shown input values, but more advanced logic gates are used.';
      case Difficulty.manic:
        return 'Use the shown values and more complex logic combinations to determine whether the final output is 1 or 0.';
    }
  }

  int get _passesUsed => _startingPasses - _passesLeft;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _resetWholeGame();

    final scene = switch (widget.difficulty) {
      Difficulty.basic => BgmScene.basic,
      Difficulty.logic => BgmScene.logic,
      Difficulty.manic => BgmScene.manic,
    };

    unawaited(BgmController.instance.playScene(scene));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_didPrecacheOverlayImages) return;
    _didPrecacheOverlayImages = true;

    final overlayAssets = <String>[
      AppAssets.andyPauseGame,
      _gameOverOverlayAsset,
      _guideOverlayAsset,
      _difficultyAndyAsset,
      AppAssets.thumbsUp,
      AppAssets.thumbsDown,
      AppAssets.handPass,
    ];

    for (final asset in overlayAssets) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lifecycleResumeCompleter?.complete();
    super.dispose();
  }

  void _onPausePressed() {
    unawaited(SfxController.instance.playMenuPress());

    if (_gameFinished) {
      if (!_showGameResultOverlay && mounted) {
        setState(() {
          _showGameResultOverlay = true;
          _showBackConfirmOverlay = false;
        });
      }
      return;
    }

    if (!_showBackConfirmOverlay) {
      _wasRoundLockedBeforePauseOverlay = _roundLocked;
    }

    if (_countdownRunning) {
      unawaited(
        SfxController.instance.pauseCountdownForGamePause(force: true),
      );
    }

    setState(() {
      _roundLocked = true;
      _showBackConfirmOverlay = true;
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
    _wasRoundLockedBeforeLifecyclePause = _roundLocked;

    if (!_showBackConfirmOverlay) {
      _wasRoundLockedBeforePauseOverlay = _roundLocked;
    }

    if (_countdownRunning) {
      unawaited(
        SfxController.instance.pauseCountdownForGamePause(force: true),
      );
    }

    if (!mounted) return;

    setState(() {
      _roundLocked = true;

      if (!_gameFinished && !_showGameResultOverlay) {
        _showBackConfirmOverlay = true;
      }

      _preGameSpriteScaleDuration = Duration.zero;
      _preGameSpriteFadeDuration = Duration.zero;
      _reactionScaleDuration = Duration.zero;
    });
  }

  void _resumeGameFromLifecycle() {
    if (!_pausedByLifecycle) return;

    _pausedByLifecycle = false;

    _lifecycleResumeCompleter?.complete();
    _lifecycleResumeCompleter = null;

    if (!mounted) return;

    setState(() {
      if (_showBackConfirmOverlay ||
          _showGameResultOverlay ||
          _showPreGameOverlay ||
          _gameFinished) {
        _roundLocked = true;
      } else {
        _roundLocked = _wasRoundLockedBeforeLifecyclePause;
      }
    });
  }

  void _exitToHome() {
    unawaited(SfxController.instance.playMenuBack());

    if (!mounted) return;

    _lifecycleResumeCompleter?.complete();
    _lifecycleResumeCompleter = null;

    setState(() {
      _showBackConfirmOverlay = false;
      _showGameResultOverlay = false;
      _showPreGameOverlay = false;
      _roundLocked = true;
      _resetComboOverlayState();
    });

    unawaited(BgmController.instance.playScene(BgmScene.home));

    Navigator.of(context).popUntil(
          (route) => route.settings.name == AppRoutes.home || route.isFirst,
    );
  }

  Future<void> _waitWhilePausedByLifecycle() async {
    while (_pausedByLifecycle || _showBackConfirmOverlay) {
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

      if (!_pausedByLifecycle && !_showBackConfirmOverlay) {
        remaining -= step;
      }
    }
  }

  void _closeBackOverlay() {
    unawaited(SfxController.instance.playMenuBack());
    if (!mounted) return;

    final shouldResumeCountdownSfx = _countdownRunning;

    setState(() {
      _showBackConfirmOverlay = false;

      if (_showGameResultOverlay ||
          _showPreGameOverlay ||
          _countdownRunning ||
          _gameFinished) {
        _roundLocked = true;
      } else {
        _roundLocked = _wasRoundLockedBeforePauseOverlay;
      }
    });

    _lifecycleResumeCompleter?.complete();
    _lifecycleResumeCompleter = null;

    if (shouldResumeCountdownSfx) {
      unawaited(SfxController.instance.resumeCountdownFromGamePause());
    }
  }

  void _resetWholeGame() {
    unawaited(SfxController.instance.playPlaySelect());
    _questions = GatekeepingQuestionRepository.getShuffledByDifficulty(
      widget.difficulty,
    );

    if (_questions.isEmpty) {
      setState(() {
        _gameFinished = true;
      });
      return;
    }
    _resetComboOverlayState();
    _hotstreakCount = 0;
    _multiplierTierIndex = 0;
    _multiplierStepProgress = 0;
    _scoreSubmitted = false;
    _currentQuestionIndex = 0;
    _score = 0;
    _passesLeft = _startingPasses;
    _livesLeft = _startingLives;
    _correctCount = 0;
    _wrongAttempts = 0;
    _highestHotstreakCount = 0;
    _roundLocked = false;
    _gameFinished = false;
    _showBackConfirmOverlay = false;
    _showGameResultOverlay = false;
    _gameResultTitle = 'ROUND COMPLETE';

    _loadCurrentQuestion();
    _preparePreGameIntro();
    setState(() {});
  }

  void _preparePreGameIntro() {
    setState(() {
      _roundLocked = true;
      _showPreGameOverlay = true;
      _waitingForStartTap = true;
      _countdownRunning = false;
      _preGameSpriteAsset = null;
      _preGameSpriteOpacity = 0.0;
      _preGameSpriteScale = 0.005;
      _preGameSpriteScaleDuration = Duration.zero;
      _preGameSpriteFadeDuration = Duration.zero;
    });
  }

  Future<void> _playCountdownSprite(String assetPath) async {
    if (!mounted) return;

    setState(() {
      _preGameSpriteAsset = assetPath;
      _preGameSpriteOpacity = 1.0;
      _preGameSpriteScale = 0.005;
      _preGameSpriteScaleDuration = Duration.zero;
      _preGameSpriteFadeDuration = Duration.zero;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted) return;

    setState(() {
      _preGameSpriteScale = 1.0;
      _preGameSpriteScaleDuration = const Duration(milliseconds: 100);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    await _pauseAwareDelay(const Duration(milliseconds: 700));
    if (!mounted) return;

    setState(() {
      _preGameSpriteOpacity = 0.0;
      _preGameSpriteFadeDuration = const Duration(milliseconds: 200);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 200));
  }

  Future<void> _handlePreGameTap() async {
    if (!_showPreGameOverlay || !_waitingForStartTap || _countdownRunning) {
      return;
    }

    setState(() {
      _waitingForStartTap = false;
      _countdownRunning = true;
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
      _showPreGameOverlay = false;
      _waitingForStartTap = false;
      _countdownRunning = false;
      _preGameSpriteAsset = null;
      _preGameSpriteOpacity = 0.0;
      _preGameSpriteScale = 0.005;
      _preGameSpriteScaleDuration = Duration.zero;
      _preGameSpriteFadeDuration = Duration.zero;
      _roundLocked = false;
    });
  }

  Future<void> _showActionFeedback({
    required Color flash,
    required String asset,
  }) async {
    if (!mounted) return;

    setState(() {
      _flashColor = flash;
      _flashOpacity = 0.0;

      _reactionAssetPath = asset;
      _reactionOpacity = 1.0;
      _reactionScale = 0.005;
      _reactionScaleDuration = Duration.zero;
      _reactionScaleCurve = Curves.easeInOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 16));
    if (!mounted) return;

    setState(() {
      _flashOpacity = 0.55;
      _reactionScale = 1.0;
      _reactionScaleDuration = const Duration(milliseconds: 100);
      _reactionScaleCurve = Curves.easeOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      _reactionScale = 1.04;
      _reactionScaleDuration = const Duration(milliseconds: 600);
      _reactionScaleCurve = Curves.easeInOutCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _flashOpacity = 0.0;
      _reactionScale = 0.005;
      _reactionScaleDuration = const Duration(milliseconds: 100);
      _reactionScaleCurve = Curves.easeInCubic;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      _reactionAssetPath = null;
      _reactionOpacity = 0.0;
      _reactionScale = 0.005;
      _reactionScaleDuration = Duration.zero;
      _reactionScaleCurve = Curves.easeInOutCubic;
    });
  }

  void _advanceToNextQuestion() {
    if (_questions.isEmpty) return;

    setState(() {
      _currentQuestionIndex++;

      if (_currentQuestionIndex >= _questions.length) {
        _questions.shuffle();
        _currentQuestionIndex = 0;
      }

      _loadCurrentQuestion();
    });
  }

  void _loadCurrentQuestion() {
    _normalizedExpression = _normalizeExpression(_currentQuestion.expression);
    _currentVariables = _extractVariables(_normalizedExpression);
    _rerollCurrentVariableValues(avoidSame: false);
    _roundLocked = false;
  }

  void _rerollCurrentVariableValues({bool avoidSame = true}) {
    final previous = avoidSame
        ? Map<String, int>.from(_currentVariableValues)
        : <String, int>{};

    do {
      _currentVariableValues = {
        for (final variable in _currentVariables)
          variable: _random.nextBool() ? 1 : 0,
      };
    } while (
    avoidSame &&
        previous.isNotEmpty &&
        _mapsEqual(previous, _currentVariableValues));

    _correctOutput = _evaluateExpression(
      _normalizedExpression,
      _currentVariableValues,
    );
  }

  bool _mapsEqual(Map<String, int> a, Map<String, int> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }

  String _normalizeExpression(String expression) {
    return expression
        .toUpperCase()
        .replaceAll('__', '')
        .replaceAll('¬', ' NOT ')
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])NOT(?![A-Z])'),
          (_) => ' NOT ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])AND(?![A-Z])'),
          (_) => ' AND ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])OR(?![A-Z])'),
          (_) => ' OR ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])XOR(?![A-Z])'),
          (_) => ' XOR ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])XNOR(?![A-Z])'),
          (_) => ' XNOR ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])NAND(?![A-Z])'),
          (_) => ' NAND ',
    )
        .replaceAllMapped(
      RegExp(r'(?<![A-Z])NOR(?![A-Z])'),
          (_) => ' NOR ',
    )
        .replaceAll('(', ' ( ')
        .replaceAll(')', ' ) ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  List<String> _extractVariables(String expression) {
    final matches = RegExp(r'(?<![A-Z])[A-D](?![A-Z])').allMatches(expression);
    return matches.map((m) => m.group(0)!).toSet().toList()..sort();
  }

  List<String> _tokenize(String expression) {
    return expression
        .replaceAll('(', ' ( ')
        .replaceAll(')', ' ) ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim()
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
  }

  bool _isOperator(String token) {
    return const {
      'NOT',
      'AND',
      'OR',
      'XOR',
      'XNOR',
      'NAND',
      'NOR',
    }.contains(token);
  }

  int _precedence(String token) {
    switch (token) {
      case 'NOT':
        return 4;
      case 'AND':
      case 'NAND':
        return 3;
      case 'XOR':
      case 'XNOR':
        return 2;
      case 'OR':
      case 'NOR':
        return 1;
      default:
        return 0;
    }
  }

  bool _isRightAssociative(String token) => token == 'NOT';

  List<String> _toRpn(List<String> tokens) {
    final output = <String>[];
    final stack = <String>[];

    for (final token in tokens) {
      if (RegExp(r'^[A-D]$').hasMatch(token) || token == '0' || token == '1') {
        output.add(token);
      } else if (_isOperator(token)) {
        while (stack.isNotEmpty &&
            _isOperator(stack.last) &&
            ((_isRightAssociative(token) &&
                _precedence(token) < _precedence(stack.last)) ||
                (!_isRightAssociative(token) &&
                    _precedence(token) <= _precedence(stack.last)))) {
          output.add(stack.removeLast());
        }
        stack.add(token);
      } else if (token == '(') {
        stack.add(token);
      } else if (token == ')') {
        while (stack.isNotEmpty && stack.last != '(') {
          output.add(stack.removeLast());
        }
        if (stack.isNotEmpty && stack.last == '(') {
          stack.removeLast();
        }
      }
    }

    while (stack.isNotEmpty) {
      output.add(stack.removeLast());
    }

    return output;
  }

  int _evaluateExpression(String expression, Map<String, int> values) {
    final tokens = _tokenize(expression);
    final rpn = _toRpn(tokens);
    final stack = <bool>[];

    for (final token in rpn) {
      if (RegExp(r'^[A-D]$').hasMatch(token)) {
        stack.add((values[token] ?? 0) == 1);
      } else if (token == '0' || token == '1') {
        stack.add(token == '1');
      } else if (token == 'NOT') {
        if (stack.isEmpty) {
          throw StateError('Invalid expression: NOT missing operand');
        }
        final a = stack.removeLast();
        stack.add(!a);
      } else {
        if (stack.length < 2) {
          throw StateError('Invalid expression: $token missing operands');
        }
        final b = stack.removeLast();
        final a = stack.removeLast();

        switch (token) {
          case 'AND':
            stack.add(a && b);
            break;
          case 'OR':
            stack.add(a || b);
            break;
          case 'XOR':
            stack.add(a != b);
            break;
          case 'XNOR':
            stack.add(a == b);
            break;
          case 'NAND':
            stack.add(!(a && b));
            break;
          case 'NOR':
            stack.add(!(a || b));
            break;
          default:
            throw StateError('Unsupported operator: $token');
        }
      }
    }

    if (stack.length != 1) {
      throw StateError('Invalid expression evaluation');
    }

    return stack.single ? 1 : 0;
  }

  String _valuesText() {
    final entries = _currentVariableValues.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return entries.map((e) => '${e.key} = ${e.value}').join('  |  ');
  }

  Future<void> _handleChoiceTap(int selectedValue) async {
    if (_roundLocked || _gameFinished) return;

    HapticFeedback.selectionClick();
    await _checkCurrentAnswer(selectedValue);
  }

  Future<void> _handlePass() async {
    if (_roundLocked || _gameFinished) return;
    if (_passesLeft <= 0) return;

    setState(() {
      _roundLocked = true;
      _passesLeft--;
    });

    unawaited(SfxController.instance.playPass());
    HapticFeedback.mediumImpact();

    await _showActionFeedback(
      flash: const Color(0xFFFFB347),
      asset: AppAssets.handPass,
    );

    await _finishRound(
      scoreDelta: 0,
      livesDelta: 0,
      advanceQuestion: true,
    );
  }

  Future<void> _animateLostHeart() async {
    if (!mounted || _livesLeft <= 0) return;

    setState(() {
      _losingHeartIndex = _livesLeft - 1;
      _lostHeartAnimating = true;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 320));
    if (!mounted) return;

    setState(() {
      _losingHeartIndex = null;
      _lostHeartAnimating = false;
    });
  }

  Widget _buildAnimatedHeart({
    required bool isActive,
    required bool isLosing,
    required double size,
  }) {
    const activeFill = Color(0xFFFF4D6D);
    const activeOutline = Color(0xFFFFB3C1);

    const lostFill = Color(0xFF9E9E9E);
    const lostOutline = Color(0xFFBDBDBD);

    final inactiveOutline = Colors.white.withOpacity(0.28);

    if (!isActive && !isLosing) {
      return Icon(
        Icons.favorite_border_rounded,
        size: size,
        color: inactiveOutline,
        shadows: const [
          Shadow(
            color: Colors.black38,
            offset: Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      );
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: 0,
        end: (isLosing && _lostHeartAnimating) ? 1 : 0,
      ),
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOutCubic,
      builder: (context, t, child) {
        final fillColor = Color.lerp(activeFill, lostFill, t)!;
        final outlineColor = Color.lerp(activeOutline, lostOutline, t)!;

        final dropOffset = 14.0 * Curves.easeIn.transform(t);
        final opacity = 1.0 - (0.85 * t);

        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, dropOffset),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.favorite_rounded,
                  size: size * 0.92,
                  color: fillColor,
                  shadows: const [
                    Shadow(
                      color: Colors.black38,
                      offset: Offset(0, 2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                Icon(
                  Icons.favorite_border_rounded,
                  size: size,
                  color: outlineColor,
                ),
              ],
            ),
          ),
        );
      },
    );
  }



  Future<void> _checkCurrentAnswer(int selectedValue) async {
    if (_roundLocked || _gameFinished) return;

    setState(() {
      _roundLocked = true;
    });

    final isCorrect = selectedValue == _correctOutput;

    if (isCorrect) {
      final previousMultiplierTierIndex = _multiplierTierIndex;

      _correctCount++;
      _hotstreakCount++;
      _multiplierStepProgress++;

      if (_hotstreakCount > _highestHotstreakCount) {
        _highestHotstreakCount = _hotstreakCount;
      }

      if (_multiplierStepProgress >= 2 &&
          _multiplierTierIndex < _multiplierTiers.length - 1) {
        _multiplierTierIndex++;
        _multiplierStepProgress = 0;
      }

      final multiplierWentUp =
          _multiplierTierIndex > previousMultiplierTierIndex;

      final shouldShowHotStreakOverlay =
          !multiplierWentUp &&
              _hotstreakCount >= 3 &&
              _hotstreakCount % 3 == 0;

      if (multiplierWentUp || shouldShowHotStreakOverlay) {
        HapticFeedback.heavyImpact();

        unawaited(
          _playComboMultiplierOverlay(
            multiplierWentUp: multiplierWentUp,
          ),
        );
      }

      final gainedScore = (_baseScore * _currentMultiplier).round();

      unawaited(SfxController.instance.playCorrect());
      await _showActionFeedback(
        flash: Colors.green,
        asset: AppAssets.thumbsUp,
      );

      _showScoreDelta('+$gainedScore', Colors.greenAccent);

      await _finishRound(
        scoreDelta: gainedScore,
        livesDelta: 0,
        advanceQuestion: true,
      );
    } else {
      const lostLives = 1;

      _wrongAttempts++;

      _hotstreakCount = 0;
      _multiplierStepProgress = 0;
      _comboOverlayRunId++;
      _showComboOverlay = false;

      if (_multiplierTierIndex > 0) {
        _multiplierTierIndex--;
      }

      unawaited(SfxController.instance.playWrong());
      await _showActionFeedback(
        flash: Colors.red,
        asset: AppAssets.thumbsDown,
      );

      //_showLivesDelta('-$lostLives', Colors.redAccent);
      await _animateLostHeart();

      await _finishRound(
        scoreDelta: -_baseScore,
        livesDelta: -lostLives,
        advanceQuestion: false,
      );
    }
  }

  Future<void> _finishRound({
    required int scoreDelta,
    required int livesDelta,
    required bool advanceQuestion,
  }) async {
    setState(() {
      _roundLocked = true;
      _score = (_score + scoreDelta).clamp(0, 999999);
      _livesLeft = (_livesLeft + livesDelta).clamp(0, 999999);
    });

    await _pauseAwareDelay(const Duration(milliseconds: 850));

    if (!mounted || _gameFinished) return;

    if (_livesLeft <= 0) {
      await _handleGameOver();
      return;
    }

    if (advanceQuestion) {
      _advanceToNextQuestion();
    } else {
      setState(() {
        _rerollCurrentVariableValues();
        _roundLocked = false;
      });
    }
  }

  Future<void> _handleGameOver() async {
    if (_gameFinished && _showGameResultOverlay) return;

    if (!mounted) return;

    setState(() {
      _gameFinished = true;
      _roundLocked = true;

      _showBackConfirmOverlay = false;
      _showPreGameOverlay = false;
      _countdownRunning = false;

      _gameResultTitle = 'GAME OVER';
      _showGameResultOverlay = true;
    });

    unawaited(SfxController.instance.playGameOver());

    try {
      await _submitFinalScoreOnce();
    } catch (e, st) {
      debugPrint('Failed to submit final score: $e');
      debugPrintStack(stackTrace: st);
    }
  }

  Future<void> _submitFinalScoreOnce() async {
    if (_scoreSubmitted) return;
    _scoreSubmitted = true;

    await _leaderboardService.submitScore(
      modeId: 'one_or_none',
      difficultyId: _difficultyId,
      score: _score,
    );
  }

  Future<void> _showScoreDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      _scoreDeltaText = text;
      _scoreDeltaOpacity = 1.0;
      _scoreDeltaYOffset = 0.0;
      _scoreDeltaXOffset = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      _scoreDeltaYOffset = -15.0;
      _scoreDeltaXOffset = -10.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _scoreDeltaOpacity = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      _scoreDeltaText = null;
      _scoreDeltaYOffset = 0.0;
      _scoreDeltaXOffset = 0.0;
    });
  }


  Future<void> _showLivesDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      _livesDeltaText = text;
      _livesDeltaOpacity = 1.0;
      _livesDeltaYOffset = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      _livesDeltaYOffset = -15.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _livesDeltaOpacity = 0.0;
    });

    await _pauseAwareDelay(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      _livesDeltaText = null;
      _livesDeltaYOffset = 0.0;
    });
  }



  Widget _buildLivesDisplay(double width) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(_startingLives, (index) {
            final isActive = index < _livesLeft;
            final isLosing = index == _losingHeartIndex;

            return Padding(
              padding: EdgeInsets.only(right: width * 0.01),
              child: _buildAnimatedHeart(
                isActive: isActive,
                isLosing: isLosing,
                size: width * 0.07,
              ),
            );
          }),
        ),
        SizedBox(height: width * 0.008),
        Text(
          '  LIVES $_livesLeft/$_startingLives',
          style: TextStyle(
            fontSize: width * 0.028,
            fontWeight: FontWeight.w900,
            color: _brownText,
            letterSpacing: 0.8,
            shadows: const [
              Shadow(
                color: Colors.black26,
                offset: Offset(0, 1.5),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreText(double width) {
    return Center(
      child: Text(
        '$_score',
        style: TextStyle(
          fontSize: width * 0.085,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFE6F7D9),
          shadows: const [
            Shadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 2,
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

  Widget _buildValuesBar() {
    return SizedBox(
      height: 72,
      child: Container(
        width: double.infinity,
        alignment: Alignment.center,
        child: Text(
          _valuesText(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
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
        border: Border.all(
          color: const Color(0xFFD8C6B5),
          width: 2,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Text(
          'PASSES LEFT: $_passesLeft',
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.visible,
          style: const TextStyle(
            color: _passOrange,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _buildBinaryChoiceButton({
    required String label,
    required Color color,
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return BeveledMenuButton(
      label: label,
      color: color,
      width: width,
      height: height,
      textColor: Colors.white,
      fontSize: 72,
      onTap: onTap,
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
          children: [
            Text(
              'Mult: $_multiplierLabel',
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: const Color(0xFFFFE28A),
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Streak: $_hotstreakCount',
              style: TextStyle(
                fontSize: width * 0.035,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        body: GameMenuBackground(
          backgroundColor: AppColors.purpleBg,
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
    final double gap = 12;
    final double choiceButtonWidth =
        (size.width - (sidePadding * 2) - gap) / 2;
    const double choiceButtonHeight = 180;

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.purpleBg,
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
                            PauseIconButton(
                              onTap: _onPausePressed,
                            ),

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
                                    AppAssets.diagramContainerGreen2,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  left: w * 0.055,
                                  top: h * 0.04,
                                  width: w * 0.28,
                                  height: h * 0.13,
                                  child: _buildLivesDisplay(w),
                                ),
                                if (_livesDeltaText != null)
                                  Positioned(
                                    left: w * 0.11,
                                    top: h * 0.13 + _livesDeltaYOffset,
                                    child: AnimatedOpacity(
                                      duration:
                                      const Duration(milliseconds: 250),
                                      opacity: _livesDeltaOpacity,
                                      child: Text(
                                        _livesDeltaText!,
                                        style: TextStyle(
                                          fontSize: w * 0.08,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFFFFD0D0),
                                          shadows: const [
                                            Shadow(
                                              color: Colors.black38,
                                              offset: Offset(0, 2),
                                              blurRadius: 3,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                Positioned(
                                  left: w * 0.315,
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
                                if (_scoreDeltaText != null)
                                  Positioned(
                                    right: w * 0.11,
                                    top: h * 0.13 + _scoreDeltaYOffset,
                                    child: AnimatedOpacity(
                                      duration:
                                      const Duration(milliseconds: 250),
                                      opacity: _scoreDeltaOpacity,
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Text(
                                            _scoreDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.09,
                                              fontWeight: FontWeight.w900,
                                              foreground: Paint()
                                                ..style = PaintingStyle.stroke
                                                ..strokeWidth = 4
                                                ..color = _scoreDeltaText!
                                                    .startsWith('-')
                                                    ? const Color(0xFFD50000)
                                                    : const Color(0xFF0FAF2A),
                                            ),
                                          ),
                                          Text(
                                            _scoreDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.09,
                                              fontWeight: FontWeight.w900,
                                              color: _scoreDeltaText!
                                                  .startsWith('-')
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
                                  child: _buildDiagramPlaceholder(),
                                ),
                                Positioned(
                                  left: w * 0.07,
                                  right: w * 0.07,
                                  bottom: h * 0.035,
                                  height: h * 0.16,
                                  child: Center(
                                    child: _buildValuesBar(),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 10),
                      IgnorePointer(
                        ignoring: _roundLocked || _gameFinished,
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
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  BeveledMenuButton(
                                    label: 'PASS',
                                    color: _passOrange,
                                    width: 120,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 20,
                                    enabled: _passesLeft > 0,
                                    onTap: _handlePass,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(child: _buildPassStrip()),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildBinaryChoiceButton(
                                      label: '1',
                                      color: _choiceOne,
                                      width: choiceButtonWidth,
                                      height: choiceButtonHeight,
                                      onTap: () => _handleChoiceTap(1),
                                    ),
                                  ),
                                  SizedBox(width: gap),
                                  Expanded(
                                    child: _buildBinaryChoiceButton(
                                      label: '0',
                                      color: _choiceZero,
                                      width: choiceButtonWidth,
                                      height: choiceButtonHeight,
                                      onTap: () => _handleChoiceTap(0),
                                    ),
                                  ),
                                ],
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
                    opacity: _flashOpacity,
                    child: ColoredBox(color: _flashColor),
                  ),
                ),
              ),

              if (_reactionAssetPath != null)
                ReactionSpriteLayer(
                  assetPath: _reactionAssetPath!,
                  opacity: _reactionOpacity,
                  scale: _reactionScale,
                  scaleDuration: _reactionScaleDuration,
                  scaleCurve: _reactionScaleCurve,
                ),

              if (_showComboOverlay)
                _buildComboMultiplierOverlay(),

              if (_showGameResultOverlay)
                _GameOverPixelRevealEntrance(
                  key: ValueKey('game-over-pixel-reveal-$_gameOverOverlayAsset'),
                  child: GameResultOverlay(
                    backgroundAssetPath: _gameOverOverlayAsset,
                    modeLabel: 'One or None',
                    difficultyLabel: _difficultyLabel,
                    score: _score,
                    correctCount: _correctCount,
                    wrongAttempts: _wrongAttempts,
                    passesUsed: _passesUsed,
                    onRetry: _resetWholeGame,
                    highestStreak: _highestHotstreakCount,
                    onLeaderboards: () {
                      unawaited(SfxController.instance.playMenuPress());
                      Navigator.pushNamed(context, AppRoutes.leaderboards);
                    },
                    onBackToMenu: () {
                      unawaited(SfxController.instance.playMenuBack());
                      _exitToHome();
                    },
                  ),
                ),

              if (_showPreGameOverlay)
                PreGameOverlay(
                  modeLabel: _modeLabel,
                  difficultyLabel: _difficultyLabel,
                  difficultyDescription: _difficultyDescription,
                  guideOverlayAssetPath: _guideOverlayAsset,
                  waitingForTap: _waitingForStartTap,
                  spriteAssetPath: _preGameSpriteAsset,
                  onTap: _handlePreGameTap,
                  spriteOpacity: _preGameSpriteOpacity,
                  spriteScale: _preGameSpriteScale,
                  spriteScaleDuration: _preGameSpriteScaleDuration,
                  spriteFadeDuration: _preGameSpriteFadeDuration,
                ),

              if (_showBackConfirmOverlay)
                _OverlayEntrance(
                  key: const ValueKey('pause-overlay'),
                  child: PauseOverlay(
                    backgroundAssetPath: AppAssets.andyPauseGame,
                    onResume: _closeBackOverlay,
                    onRetry: () {
                      setState(() {
                        _showBackConfirmOverlay = false;
                      });

                      _resetWholeGame();
                    },
                    onExitToMenu: () {
                      unawaited(SfxController.instance.playGameOver());
                      _exitToHome();
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComboMultiplierOverlay extends StatelessWidget {
  final String title;
  final String subtitle;
  final String multiplier;
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


class _OverlayEntrance extends StatelessWidget {
  const _OverlayEntrance({
    super.key,
    required this.child,
    this.isGameOver = false,
  });

  final Widget child;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: isGameOver ? 520 : 360),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        final safeOpacity = value.clamp(0.0, 1.0);
        final scale = isGameOver
            ? 0.72 + (0.28 * value)
            : 0.86 + (0.14 * value);

        final yOffset = isGameOver
            ? 42 * (1 - value)
            : -28 * (1 - value);

        final angle = isGameOver
            ? -0.035 * (1 - value)
            : 0.025 * (1 - value);

        return Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: safeOpacity,
              child: Transform.translate(
                offset: Offset(0, yOffset),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: child,
                  ),
                ),
              ),
            ),
            IgnorePointer(
              child: Opacity(
                opacity: (1 - safeOpacity).clamp(0.0, 1.0),
                child: const ColoredBox(
                  color: Color(0x3300E5FF),
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }
}

class _GameOverPixelRevealEntrance extends StatefulWidget {
  const _GameOverPixelRevealEntrance({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<_GameOverPixelRevealEntrance> createState() =>
      _GameOverPixelRevealEntranceState();
}

class _GameOverPixelRevealEntranceState
    extends State<_GameOverPixelRevealEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _revealAnimation;
  late final Animation<double> _contentOpacityAnimation;
  late final Animation<double> _contentScaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1250),
    );

    _revealAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );

    _contentOpacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(
        0.28,
        1.00,
        curve: Curves.easeOutCubic,
      ),
    );

    _contentScaleAnimation = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.36,
          1.00,
          curve: Curves.easeOutBack,
        ),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _flashOpacity(double t) {
    if (t < 0.08) {
      return t / 0.08 * 0.65;
    }

    if (t < 0.24) {
      return 0.65 * (1.0 - ((t - 0.08) / 0.16));
    }

    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final rawT = _controller.value;
        final revealT = _revealAnimation.value;

        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black.withOpacity(0.36),
              ),
            ),
            ClipRect(
              clipper: _GameOverTopToBottomRevealClipper(
                progress: revealT,
              ),
              child: Opacity(
                opacity: _contentOpacityAnimation.value,
                child: Transform.scale(
                  scale: _contentScaleAnimation.value,
                  child: child,
                ),
              ),
            ),
            IgnorePointer(
              child: CustomPaint(
                painter: _GameOverPixelTricklePainter(
                  progress: rawT,
                  revealProgress: revealT,
                  color: const Color(0xFFFF1E1E),
                ),
              ),
            ),
            IgnorePointer(
              child: ColoredBox(
                color: const Color(0xFFFF1E1E).withOpacity(
                  _flashOpacity(rawT),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _GameOverTopToBottomRevealClipper extends CustomClipper<Rect> {
  const _GameOverTopToBottomRevealClipper({
    required this.progress,
  });

  final double progress;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(
      0,
      0,
      size.width,
      size.height * progress.clamp(0.0, 1.0),
    );
  }

  @override
  bool shouldReclip(
      covariant _GameOverTopToBottomRevealClipper oldClipper,
      ) {
    return oldClipper.progress != progress;
  }
}

class _GameOverPixelTricklePainter extends CustomPainter {
  _GameOverPixelTricklePainter({
    required this.progress,
    required this.revealProgress,
    required this.color,
  });

  final double progress;
  final double revealProgress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1.0) return;

    const double blockSize = 24;
    final cols = (size.width / blockSize).ceil();
    final rows = (size.height / blockSize).ceil();

    final waveY = size.height * revealProgress;
    final waveBand = blockSize * 5.8;

    final paint = Paint();

    final washHeight = size.height * revealProgress;
    if (washHeight > 0) {
      paint.color = const Color(0xFF8B0000).withOpacity(0.18);
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, washHeight),
        paint,
      );
    }

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final centerX = (col * blockSize) + blockSize / 2;
        final centerY = (row * blockSize) + blockSize / 2;

        final distanceFromWave = (centerY - waveY).abs();

        if (distanceFromWave > waveBand) continue;

        final noise = _noise(col, row);
        final stagger = (noise - 0.5) * blockSize * 4.0;
        final adjustedDistance = (centerY + stagger - waveY).abs();

        if (adjustedDistance > waveBand) continue;

        final closeness = 1.0 - (adjustedDistance / waveBand).clamp(0.0, 1.0);
        final pulse = sin(closeness * pi);

        final alpha = (pulse * 0.95).clamp(0.0, 0.95);

        final isWhiteBlock = (col + row) % 7 == 0;
        final isHotRedBlock = (col * 3 + row * 7) % 9 == 0;
        final isDarkBlock = (col * 5 + row * 11) % 13 == 0;

        final blockColor = isWhiteBlock
            ? Colors.white
            : isHotRedBlock
            ? const Color(0xFFFF5A5A)
            : isDarkBlock
            ? const Color(0xFF5A0000)
            : color;

        final fallAmount = blockSize * 1.8 * (1.0 - closeness) * noise;
        final rectSize = blockSize * (0.58 + (0.55 * closeness));

        final dx = centerX - rectSize / 2;
        final dy = centerY - rectSize / 2 + fallAmount;

        paint.color = blockColor.withOpacity(alpha);

        canvas.drawRect(
          Rect.fromLTWH(dx, dy, rectSize, rectSize),
          paint,
        );
      }
    }

    _paintRedScanlines(canvas, size);
  }

  void _paintRedScanlines(Canvas canvas, Size size) {
    if (progress > 0.78) return;

    final opacity = 0.16 * (1.0 - (progress / 0.78).clamp(0.0, 1.0));

    final paint = Paint()
      ..color = const Color(0xFFFFD0D0).withOpacity(opacity);

    const gap = 8.0;

    for (double y = 0; y < size.height; y += gap) {
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, 1.4),
        paint,
      );
    }
  }

  double _noise(int x, int y) {
    final value = (x * 73 + y * 151 + x * y * 17) % 100;
    return value / 100.0;
  }

  @override
  bool shouldRepaint(covariant _GameOverPixelTricklePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.revealProgress != revealProgress ||
        oldDelegate.color != color;
  }
}

