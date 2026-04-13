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
import '../../util/gameplay_helpers.dart';

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
    with GameplayHelpers {
  static const int _startingRoundTimeValue = 60;
  static const int _startingPassesValue = 5;

  static const Color _passOrange = Color(0xFFFF6B00);
  static const Color _brownText = Color(0xFF8A5200);
  static const Color _lineBrown = Color(0xFF7B5A2A);

  static const Color _choiceOne = Color(0xFF00D3FF);
  static const Color _choiceZero = Color(0xFFFFBC19);
  static const Color _valuesGreen = Color(0xFF0BAE22);

  final Random _random = Random();

  late List<GatekeepingQuestion> _questions;
  late String _normalizedExpression;
  late List<String> _currentVariables;
  late Map<String, int> _currentVariableValues;

  int _correctOutput = 0;

  GatekeepingQuestion get _currentQuestion => _questions[currentQuestionIndex];

  @override
  int get startingRoundTime => _startingRoundTimeValue;

  @override
  int get startingPasses => _startingPassesValue;

  @override
  String get modeId => 'one_or_none';

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
  void initState() {
    super.initState();
    resetWholeGame();
  }

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
  void loadCurrentQuestion() {
    _normalizedExpression = _normalizeExpression(_currentQuestion.expression);
    _currentVariables = _extractVariables(_normalizedExpression);
    _rerollCurrentVariableValues(avoidSame: false);
    roundLocked = false;
  }

  @override
  void onRetryCurrentQuestion() {
    _rerollCurrentVariableValues();
  }

  void _rerollCurrentVariableValues({bool avoidSame = true}) {
    final previous = avoidSame ? Map<String, int>.from(_currentVariableValues) : null;

    do {
      _currentVariableValues = {
        for (final variable in _currentVariables)
          variable: _random.nextBool() ? 1 : 0,
      };
    } while (
        avoidSame &&
        previous != null &&
        _mapsEqual(previous, _currentVariableValues)
    );

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
    if (roundLocked || gameFinished) return;

    HapticFeedback.selectionClick();
    await _checkCurrentAnswer(selectedValue);
  }

  Future<void> _checkCurrentAnswer(int selectedValue) async {
    if (roundLocked || gameFinished) return;

    final isCorrect = selectedValue == _correctOutput;

    if (isCorrect) {
      const gainedScore = 20;
      const gainedTime = 2;

      playFlash(isCorrect: true);
      showScoreDelta('+$gainedTime', Colors.greenAccent);

      await finishRound(
        scoreDelta: gainedScore,
        timeDelta: gainedTime,
        advanceQuestion: true,
      );
    } else {
      const lostScore = 20;
      const lostTime = -1;

      playWrongDamageFlash();
      showScoreDelta('$lostTime', Colors.redAccent);

      await finishRound(
        scoreDelta: -lostScore,
        timeDelta: lostTime,
        advanceQuestion: false,
      );
    }
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

  Widget _buildScoreText(double width) {
    return Center(
      child: Text(
        '$score',
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
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
      child: Text(
        _valuesText(),
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildPassStrip() {
    return Container(
      height: 30,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFFD8C6B5),
          width: 2,
        ),
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
    const double choiceButtonHeight = 140;

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
                                    AppAssets.diagramContainerGreen1,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                Positioned(
                                  left: w * 0.055,
                                  top: h * 0.045,
                                  width: w * 0.18,
                                  height: h * 0.10,
                                  child: _buildTimerText(w),
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
                                      duration: const Duration(milliseconds: 250),
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
                                                ..color = scoreDeltaText!.startsWith('-')
                                                    ? const Color(0xFFD50000)
                                                    : const Color(0xFF0FAF2A),
                                            ),
                                          ),
                                          Text(
                                            scoreDeltaText!,
                                            style: TextStyle(
                                              fontSize: w * 0.09,
                                              fontWeight: FontWeight.w900,
                                              color: scoreDeltaText!.startsWith('-')
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
                                  bottom: h * 0.05,
                                  height: h * 0.10,
                                  child: _buildValuesBar(),
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
                                    onTap: () {
                                      handlePass();
                                    },
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
                                      onTap: () {
                                        _handleChoiceTap(1);
                                      },
                                    ),
                                  ),
                                  SizedBox(width: gap),
                                  Expanded(
                                    child: _buildBinaryChoiceButton(
                                      label: '0',
                                      color: _choiceZero,
                                      width: choiceButtonWidth,
                                      height: choiceButtonHeight,
                                      onTap: () {
                                        _handleChoiceTap(0);
                                      },
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
                    opacity: flashOpacity,
                    child: ColoredBox(color: flashColor),
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
            ],
          ),
        ),
      ),
    );
  }
}