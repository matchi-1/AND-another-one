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

class GatekeepingGamePage extends StatefulWidget {
  const GatekeepingGamePage({
    super.key,
    this.difficulty = Difficulty.basic,
  });

  final Difficulty difficulty;

  @override
  State<GatekeepingGamePage> createState() => _GatekeepingGamePageState();
}

class _GatekeepingGamePageState extends State<GatekeepingGamePage>
    with GameplayHelpers {
  static const int _startingRoundTimeValue = 60;
  static const int _startingPassesValue = 5;

  static const Color _operatorOr = Color(0xFFFD8900);
  static const Color _operatorAnd = Color(0xFF006CFF);
  static const Color _operatorNot = Color(0xFFFA2626);
  static const Color _operatorNor = Color(0xFFE43AE2);
  static const Color _operatorNand = Color(0xFF9822F2);
  static const Color _operatorXor = Color(0xFF33B300);
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

    setState(() {
      _playerAnswers[lastFilled] = null;
      _activeSlotIndex = lastFilled;
    });
  }

  Future<void> _checkCurrentAnswer() async {
    if (roundLocked || gameFinished) return;

    final correctAnswers = _correctAnswersForCurrentQuestion();
    final isCorrect = _listEquals(
      _playerAnswers.map((e) => e ?? '').toList(),
      correctAnswers,
    );

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: children,
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
                                  left: w * 0.12,
                                  right: w * 0.12,
                                  bottom: h * 0.08,
                                  height: h * 0.08,
                                  child: _buildExpressionBar(),
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
                                  const SizedBox(width: 8),
                                  BeveledMenuButton(
                                    label: '‹',
                                    color: _backspaceGrey,
                                    width: 80,
                                    height: 50,
                                    textColor: Colors.white,
                                    fontSize: 34,
                                    onTap: _handleBackspace,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              _buildChoiceGrid(
                                buttonWidth: operatorButtonWidth,
                                buttonHeight: operatorButtonHeight,
                                gap: gap,
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

class _ExpressionPart {
  const _ExpressionPart.text(this.text)
      : answer = null,
        isSlot = false;

  const _ExpressionPart.slot(this.answer)
      : text = null,
        isSlot = true;

  final String? text;
  final String? answer;
  final bool isSlot;
}

class _OperatorConfig {
  final String symbol;
  final Color color;

  const _OperatorConfig({
    required this.symbol,
    required this.color,
  });
}

const Map<String, _OperatorConfig> _operatorConfigs = {
  'OR': _OperatorConfig(symbol: '+', color: _GatekeepingGamePageState._operatorOr),
  'AND': _OperatorConfig(symbol: '•', color: _GatekeepingGamePageState._operatorAnd),
  'NOT': _OperatorConfig(symbol: '¬', color: _GatekeepingGamePageState._operatorNot),
  'NOR': _OperatorConfig(symbol: '↓', color: _GatekeepingGamePageState._operatorNor),
  'NAND': _OperatorConfig(symbol: '↑', color: _GatekeepingGamePageState._operatorNand),
  'XOR': _OperatorConfig(symbol: '⊕', color: _GatekeepingGamePageState._operatorXor),
  'XNOR': _OperatorConfig(symbol: '⊙', color: _GatekeepingGamePageState._operatorXnor),
};