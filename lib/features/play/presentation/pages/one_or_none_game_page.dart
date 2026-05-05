import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../../leaderboards/util/leaderboard_service.dart';
import '../../data/models/gatekeeping_question.dart';
import '../../data/repositories/gatekeeping_question_repository.dart';
import 'dart:async';
import '../../../../core/audio/bgm_controller.dart';

class OneOrNoneGamePage extends StatefulWidget {
  const OneOrNoneGamePage({
    super.key,
    this.difficulty = Difficulty.basic,
  });

  final Difficulty difficulty;

  @override
  State<OneOrNoneGamePage> createState() => _OneOrNoneGamePageState();
}

class _OneOrNoneGamePageState extends State<OneOrNoneGamePage> {

  bool showPreGameOverlay = false;
  bool waitingForStartTap = false;
  bool countdownRunning = false;
  String? preGameSpriteAsset;

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

  bool _roundLocked = false;
  bool _gameFinished = false;
  bool _scoreSubmitted = false;

  String _endDialogTitle = 'ROUND COMPLETE';

  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0.0;

  String? _scoreDeltaText;
  double _scoreDeltaOpacity = 0.0;
  double _scoreDeltaYOffset = 0.0;
  double _scoreDeltaXOffset = 0.0;

  int? _losingHeartIndex;
  bool _lostHeartAnimating = false;

  String? _centerPopupText;
  Color _centerPopupColor = Colors.white;
  double _centerPopupOpacity = 0.0;
  double _centerPopupScale = 0.9;

  GatekeepingQuestion get _currentQuestion => _questions[_currentQuestionIndex];

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

  @override
  void initState() {
    super.initState();
    _resetWholeGame();
    final scene = switch (widget.difficulty) {
      Difficulty.basic => BgmScene.basic,
      Difficulty.logic => BgmScene.logic,
      Difficulty.manic => BgmScene.manic,
    };

    unawaited(BgmController.instance.playScene(scene));
  }

  String? reactionAssetPath;
  double reactionOpacity = 0.0;
  double reactionScale = 0.005;
  Duration reactionScaleDuration = Duration.zero;
  Curve reactionScaleCurve = Curves.easeInOutCubic;
  Color flashColor = Colors.transparent;
  double flashOpacity = 0.0;

  Future<void> showReactionFeedback({required bool isCorrect}) async {
  if (!mounted) return;

  setState(() {
    flashColor = isCorrect ? Colors.green : Colors.red;
    flashOpacity = 0.0;

    reactionAssetPath =
        isCorrect ? AppAssets.thumbsUp : AppAssets.thumbsDown;
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
    reactionScaleDuration = const Duration(milliseconds: 300);
    reactionScaleCurve = Curves.easeInOutCubic;
  });

  await Future<void>.delayed(const Duration(milliseconds: 300));
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

  void _resetWholeGame() {
    _questions = GatekeepingQuestionRepository.getShuffledByDifficulty(
      widget.difficulty,
    );

    if (_questions.isEmpty) {
      setState(() {
        _gameFinished = true;
      });
      return;
    }

    _scoreSubmitted = false;
    _currentQuestionIndex = 0;
    _score = 0;
    _passesLeft = _startingPasses;
    _livesLeft = _startingLives;
    _roundLocked = false;
    _gameFinished = false;
    _endDialogTitle = 'ROUND COMPLETE';

    _loadCurrentQuestion();
    setState(() {});
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

    HapticFeedback.mediumImpact();

    setState(() {
      _passesLeft--;
    });

    _showCenterPopup('PASS', const Color(0xFFFFB347));

    await _finishRound(
      scoreDelta: -10,
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

    await Future.delayed(const Duration(milliseconds: 320));
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

    final isCorrect = selectedValue == _correctOutput;

    if (isCorrect) {
      const gainedScore = 20;

      showReactionFeedback(isCorrect: true);
      _showScoreDelta('+$gainedScore', Colors.greenAccent);

      await _finishRound(
        scoreDelta: gainedScore,
        livesDelta: 0,
        advanceQuestion: true,
      );
    } else {
      const lostLives = 1;

      setState(() {
        _roundLocked = true;
      });

      await showReactionFeedback(isCorrect: false);
      await _animateLostHeart();

      await _finishRound(
        scoreDelta: 0,
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

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted || _gameFinished) return;

    if (_livesLeft <= 0) {
      await _handleGameOver();
      return;
    }

    // if (advanceQuestion && _currentQuestionIndex >= _questions.length - 1) {
    //  _endDialogTitle = 'ROUND COMPLETE';
    //  await _submitFinalScoreOnce();
    //  if (!mounted) return;
    //  _showEndDialog();
    //  return;
    // }

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
    if (_gameFinished) return;

    setState(() {
      _gameFinished = true;
      _roundLocked = true;
      _endDialogTitle = 'GAME OVER';
    });

    await _submitFinalScoreOnce();

    if (!mounted) return;
    _showEndDialog();
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

  Future<void> _playFlash({bool isCorrect = false}) async {
    if (!mounted) return;
    setState(() {
      _flashColor = isCorrect ? Colors.green : Colors.red;
      _flashOpacity = isCorrect ? 0.65 : 0.75;
    });

    await Future.delayed(
      Duration(milliseconds: isCorrect ? 300 : 135),
    );
    if (!mounted) return;

    setState(() {
      _flashOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 135));
  }

  Future<void> _playWrongDamageFlash() async {
    await _playFlash();
    await Future.delayed(const Duration(milliseconds: 40));
    await _playFlash();
  }

  Future<void> _showScoreDelta(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      _scoreDeltaText = text;
      _scoreDeltaOpacity = 1.0;
      _scoreDeltaYOffset = 0.0;
      _scoreDeltaXOffset = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;

    setState(() {
      _scoreDeltaYOffset = -15.0;
      _scoreDeltaXOffset = -10.0;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    setState(() {
      _scoreDeltaOpacity = 0.0;
    });

    await Future.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;

    setState(() {
      _scoreDeltaText = null;
      _scoreDeltaYOffset = 0.0;
      _scoreDeltaXOffset = 0.0;
    });
  }

  Future<void> _showCenterPopup(String text, Color color) async {
    if (!mounted) return;

    setState(() {
      _centerPopupText = text;
      _centerPopupColor = color;
      _centerPopupOpacity = 1.0;
      _centerPopupScale = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() {
      _centerPopupOpacity = 0.0;
      _centerPopupScale = 1.08;
    });

    await Future.delayed(const Duration(milliseconds: 180));
    if (!mounted) return;

    setState(() {
      _centerPopupText = null;
      _centerPopupScale = 0.9;
    });
  }

  void _showEndDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            _endDialogTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
            ),
          ),
          content: Text(
            'Final Score: $_score',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 20,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetWholeGame();
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
        /*
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _valuesGreen,
          border: Border.all(
            color: Colors.white.withOpacity(0.35),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 2,
            ),
          ],
        ),
        */
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
      child: Text(
        'PASSES LEFT: $_passesLeft',
        style: const TextStyle(
          color: _passOrange,
          fontSize: 14,
          fontWeight: FontWeight.w900,
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
    const double choiceButtonHeight = 142;

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
                              onPressed: () => Navigator.pop(context),
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
                                    onTap: _handlePass,
                                    enabled: _passesLeft > 0,
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
                    duration: const Duration(milliseconds: 320),
                    opacity: _flashOpacity,
                    child: ColoredBox(color: _flashColor),
                  ),
                ),
              ),
              if (_centerPopupText != null)
                IgnorePointer(
                  child: Center(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 180),
                      opacity: _centerPopupOpacity,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 180),
                        scale: _centerPopupScale,
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
                            _centerPopupText!,
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: _centerPopupColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}