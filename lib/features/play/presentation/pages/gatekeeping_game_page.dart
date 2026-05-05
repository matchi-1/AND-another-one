import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../data/models/gatekeeping_question.dart';
import '../../data/repositories/gatekeeping_question_repository.dart';
import '../../../leaderboards/util/leaderboard_service.dart';
//import '../../../tutorial/gameplay_tutorial_overlay.dart';
//import '../../../tutorial/gameplay_tutorial_service.dart';
import 'dart:async';
import '../../../../core/audio/bgm_controller.dart';
import '../../../../core/audio/sfx_controller.dart';
import '../widgets/gameplay_overlays.dart';


class GatekeepingGamePage extends StatefulWidget {
  const GatekeepingGamePage({super.key, this.difficulty = Difficulty.basic});

  final Difficulty difficulty;

  @override
  State<GatekeepingGamePage> createState() => _GatekeepingGamePageState();
}

class _GatekeepingGamePageState extends State<GatekeepingGamePage> {
  @override
  void initState() {
    super.initState();
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

  @override
  void dispose() {
    //_tutorialEntry?.remove();
    gameplayTimer?.cancel();
    super.dispose();
  }

  bool showBackConfirmOverlay = false;

  void _onBackPressed() {
  if (gameFinished) {
    Navigator.pop(context);
    return;
  }

  setState(() {
    roundLocked = true;
    showBackConfirmOverlay = true;
  });
}

void _closeBackOverlay() {
  if (!mounted) return;

  setState(() {
    showBackConfirmOverlay = false;
    roundLocked = false;
  });
}

void _confirmExitGame() {
  if (!mounted) return;
  Navigator.pop(context);
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

String get _pregameReminderText =>
    '<placeholder reminder for $_modeLabel on $_difficultyLabel>';

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
  await Future<void>.delayed(const Duration(milliseconds: 16));
  if (!mounted) return;

  // Zoom in: 100 ms
  setState(() {
    preGameSpriteScale = 1.0;
    preGameSpriteScaleDuration = const Duration(milliseconds: 100);
  });

  await Future<void>.delayed(const Duration(milliseconds: 100));
  if (!mounted) return;

  // Stay visible at normal size: 700 ms
  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (!mounted) return;

  // Fade out only: 200 ms
  setState(() {
    preGameSpriteOpacity = 0.0;
    preGameSpriteFadeDuration = const Duration(milliseconds: 200);
  });

  await Future<void>.delayed(const Duration(milliseconds: 200));
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

  await Future<void>.delayed(const Duration(milliseconds: 16));
  if (!mounted) return;

  setState(() {
    flashOpacity = 0.55;
    reactionScale = 1.0;
    reactionScaleDuration = const Duration(milliseconds: 100);
    reactionScaleCurve = Curves.easeOutCubic;
  });

  await Future<void>.delayed(const Duration(milliseconds: 100));
  if (!mounted) return;

  setState(() {
    reactionScale = 1.04;
    reactionScaleDuration = const Duration(milliseconds: 600);
    reactionScaleCurve = Curves.easeInOutCubic;
  });

  await Future<void>.delayed(const Duration(milliseconds: 450));
  if (!mounted) return;

  setState(() {
    flashOpacity = 0.0;
    reactionScale = 0.005;
    reactionScaleDuration = const Duration(milliseconds: 100);
    reactionScaleCurve = Curves.easeInCubic;
  });

  await Future<void>.delayed(const Duration(milliseconds: 100));
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

  bool roundLocked = false;
  bool gameFinished = false;

  Color flashColor = Colors.transparent;
  double flashOpacity = 0.0;

  String? scoreDeltaText;
  Color scoreDeltaColor = Colors.white;
  double scoreDeltaOpacity = 0.0;
  double scoreDeltaYOffset = 0.0;
  double scoreDeltaXOffset = 0.0;

  String? centerPopupText;
  Color centerPopupColor = Colors.white;
  double centerPopupOpacity = 0.0;
  double centerPopupScale = 0.9;

  void initializeSharedRun() {
    scoreSubmitted = false;
    gameplayTimer?.cancel();

    currentQuestionIndex = 0;
    score = 0;
    passesLeft = startingPasses;
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

    await SfxController.instance.playPass();

    HapticFeedback.mediumImpact();

    setState(() {
      passesLeft--;
    });

    //showCenterPopup('PASS', const Color(0xFFFFB347));

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
    if (gameFinished) return;

    HapticFeedback.heavyImpact();

    setState(() {
      gameFinished = true;
      roundLocked = true;
      timeLeft = 0;
    });

    gameplayTimer?.cancel();
    await submitFinalScoreOnce();

    if (!mounted) return;

    await SfxController.instance.playGameOver();
    
    showEndDialog();
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

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted || gameFinished) return;

    // if (advanceQuestion && currentQuestionIndex >= questionCount - 1) {
    //   await submitFinalScoreOnce();
    //   if (!mounted) return;
    //   showEndDialog();
    //   return;
    // }

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

  Future<void> playFlash({bool isCorrect = false}) async {
    if (!mounted) return;
    setState(() {
      flashColor = isCorrect ? Colors.green : Colors.red;
      flashOpacity = isCorrect ? 0.65 : 0.75;
    });

    await Future.delayed(Duration(milliseconds: isCorrect ? 300 : 135));
    if (!mounted) return;

    setState(() {
      flashOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 135));
  }

  Future<void> playWrongDamageFlash() async {
    await playFlash();
    await Future.delayed(const Duration(milliseconds: 40));
    await playFlash();
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

    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      scoreDeltaYOffset = -15.0;
      scoreDeltaXOffset = -10.0;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      scoreDeltaOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      scoreDeltaText = null;
      scoreDeltaYOffset = 0.0;
      scoreDeltaXOffset = 0.0;
    });
  }

  Future<void> showCenterPopup(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      centerPopupText = text;
      centerPopupColor = color;
      centerPopupOpacity = 1.0;
      centerPopupScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      centerPopupOpacity = 0.0;
      centerPopupScale = 1.08;
    });

    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      centerPopupText = null;
      centerPopupScale = 0.9;
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

  void showEndDialog() {
    
    gameplayTimer?.cancel();
    gameFinished = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'ROUND COMPLETE',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
          ),
          content: Text(
            'Final Score: $score',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                resetWholeGame();
              },
              child: const Text(
                'PLAY AGAIN',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text(
                'EXIT',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
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
      Future.delayed(const Duration(milliseconds: 150), () {
        if (!mounted || roundLocked) return;
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
      const gainedScore = 20;
      const gainedTime = 2;

      //playFlash(isCorrect: true);
      unawaited(SfxController.instance.playCorrect());
      await showActionFeedback(
        flash: Colors.green,
        asset: AppAssets.thumbsUp,
      );
      showScoreDelta('+$gainedScore', Colors.greenAccent);

      await finishRound(
        scoreDelta: gainedScore,
        timeDelta: gainedTime,
        advanceQuestion: true,
      );
    } else {
      const lostScore = 20;
      const lostTime = -1;

      //playWrongDamageFlash();
      unawaited(SfxController.instance.playWrong());
      await showActionFeedback(
        flash: Colors.red,
        asset: AppAssets.thumbsDown,
      );
      showScoreDelta('-$lostScore', Colors.redAccent);

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
    final double operatorButtonHeight = 100;

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
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              visualDensity: VisualDensity.compact,
                              iconSize: 24,
                              icon: Image.asset(
                                AppAssets.backBtn,
                                width: 24,
                                height: 24,
                              ),
                              onPressed: _onBackPressed,
                            ),

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
                                    label: '←',
                                    color: _backspaceGrey,
                                    width: 80,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 30,
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

                if (showBackConfirmOverlay)
                  Positioned.fill(
                    child: Material(
                      color: Colors.black.withOpacity(0.72),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2B1B10),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.16),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black45,
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'PAUSED',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                '<placeholder textbox overlay>',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  BeveledMenuButton(
                                    label: 'RESUME',
                                    color: AppColors.greenButton,
                                    width: 130,
                                    height: 48,
                                    textColor: Colors.white,
                                    fontSize: 18,
                                    onTap: _closeBackOverlay,
                                  ),
                                  const SizedBox(width: 12),
                                  BeveledMenuButton(
                                    label: 'EXIT',
                                    color: AppColors.redButton,
                                    width: 130,
                                    height: 48,
                                    textColor: Colors.white,
                                    fontSize: 18,
                                    onTap: _confirmExitGame,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                if (showPreGameOverlay)
                  PreGameOverlay(
                    modeLabel: _modeLabel,
                    difficultyLabel: _difficultyLabel,
                    reminderText: _pregameReminderText,
                    waitingForTap: waitingForStartTap,
                    spriteAssetPath: preGameSpriteAsset,
                    onTap: _handlePreGameTap,
                    spriteOpacity: preGameSpriteOpacity,
                    spriteScale: preGameSpriteScale,
                    spriteScaleDuration: preGameSpriteScaleDuration,
                    spriteFadeDuration: preGameSpriteFadeDuration,
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
