import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../data/models/gatekeeping_question.dart';
import '../../data/repositories/gatekeeping_question_repository.dart';

class GatekeepingGamePage extends StatefulWidget {
  const GatekeepingGamePage({
    super.key,
    this.difficulty = GatekeepingDifficulty.basic,
  });

  final GatekeepingDifficulty difficulty;

  @override
  State<GatekeepingGamePage> createState() => _GatekeepingGamePageState();
}

class _GatekeepingGamePageState extends State<GatekeepingGamePage> {
  static const int _timePerQuestion = 60;
  static const int _startingPasses = 5;



  late List<GatekeepingQuestion> _questions;
  late List<_ExpressionPart> _parsedExpression;
  late List<String?> _playerAnswers;

  Timer? _timer;

  int _currentQuestionIndex = 0;
  int _timeLeft = _timePerQuestion;
  int _score = 0;
  int _passesLeft = _startingPasses;
  int _activeSlotIndex = 0;

  bool _roundLocked = false;
  bool _gameFinished = false;

  Color _flashColor = Colors.transparent;
  double _flashOpacity = 0.0;

  String? _scoreDeltaText;
  Color _scoreDeltaColor = Colors.white;
  double _scoreDeltaOpacity = 0.0;
  double _scoreDeltaYOffset = 0.0;
  double _scoreDeltaXOffset = 0.0;

  String? _centerPopupText;
  Color _centerPopupColor = Colors.white;
  double _centerPopupOpacity = 0.0;
  double _centerPopupScale = 0.9;

  static const Color _operatorBlue = Color(0xFF00D0FF);
  static const Color _operatorYellow = Color(0xFFEDB600);
  static const Color _operatorGreen = Color(0xFF08C90A);
  static const Color _operatorCoral = Color(0xFFF4553F);
  static const Color _passOrange = Color(0xFFFF6B00);
  static const Color _backspaceGrey = Color(0xFFA8A8A8);
  static const Color _scoreGreen = Color(0xFF129D1C);
  static const Color _brownText = Color(0xFF8A5200);
  static const Color _lineBrown = Color(0xFF7B5A2A);

  GatekeepingQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();
    _resetWholeGame();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _resetWholeGame() {
    _timer?.cancel();

    _questions = GatekeepingQuestionRepository.getShuffledByDifficulty(
      widget.difficulty,
    );

    _currentQuestionIndex = 0;
    _score = 0;
    _passesLeft = _startingPasses;
    _gameFinished = false;

    _loadCurrentQuestion();
    _startTimer();
    setState(() {});
  }

  void _loadCurrentQuestion() {
    _parsedExpression = _parseExpression(_currentQuestion.expression);
    final slotCount = _parsedExpression.where((part) => part.isSlot).length;

    _playerAnswers = List<String?>.filled(slotCount, null);
    _activeSlotIndex = 0;
    _timeLeft = _timePerQuestion;
    _roundLocked = false;

  }

  List<_ExpressionPart> _parseExpression(String expression) {
    final regex = RegExp(r'__(AND|OR|NOT|XOR)');
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

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _roundLocked || _gameFinished) return;

      if (_timeLeft <= 1) {
        setState(() {
          _timeLeft = 0;
        });
        _handleTimeout();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _handleOperatorTap(String operator) {
    if (_roundLocked || _gameFinished) return;
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
        if (!mounted || _roundLocked) return;
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
    if (_roundLocked || _gameFinished) return;

    final lastFilled = _findLastFilledSlot();
    if (lastFilled == null) return;

    HapticFeedback.selectionClick();

    setState(() {
      _playerAnswers[lastFilled] = null;
      _activeSlotIndex = lastFilled;
    });
  }

  Future<void> _handlePass() async {
    if (_roundLocked || _gameFinished) return;
    if (_passesLeft <= 0) return;

    HapticFeedback.mediumImpact();

    setState(() {
      _passesLeft--;
    });

    _showCenterPopup('PASS', const Color(0xFFFFB347));
    // _showScoreDelta('-10', const Color(0xFFFFB347));
    await _finishRound(
      feedbackText: 'PASS',
      feedbackColor: _passOrange,
      scoreDelta: -10,
    );
  }

  Future<void> _handleTimeout() async {
    if (_roundLocked || _gameFinished) return;

    HapticFeedback.heavyImpact();

    await _finishRound(
      feedbackText: 'TIME UP',
      feedbackColor: Colors.red,
      scoreDelta: -20,
    );
  }

  Future<void> _checkCurrentAnswer() async {
    if (_roundLocked || _gameFinished) return;

    final correctAnswers = _correctAnswersForCurrentQuestion();
    final isCorrect = _listEquals(
      _playerAnswers.map((e) => e ?? '').toList(),
      correctAnswers,
    );

    if (isCorrect) {
      final gained = 20; // or your multiplier logic

      _playFlash(isCorrect: true);
      _showScoreDelta('+$gained', Colors.greenAccent);

      await _finishRound(
        feedbackText: 'CORRECT  +$gained',
        feedbackColor: const Color(0xFF15B700),
        scoreDelta: gained,
      );
    } else {
      const lost = 20;

      _playWrongDamageFlash();
      _showScoreDelta('-$lost', Colors.redAccent);

      await _finishRound(
        feedbackText: 'WRONG  -$lost',
        feedbackColor: Colors.red,
        scoreDelta: -lost,
      );
    }
  }

  Future<void> _finishRound({
    required String feedbackText,
    required Color feedbackColor,
    required int scoreDelta,
  }) async {
    setState(() {
      _roundLocked = true;
      _score = (_score + scoreDelta).clamp(0, 999999);
    });

    await Future.delayed(const Duration(milliseconds: 850));

    if (!mounted) return;

    if (_currentQuestionIndex >= _questions.length - 1) {
      _showEndDialog();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _loadCurrentQuestion();
    });
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
      _scoreDeltaColor = color;
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
    _timer?.cancel();
    _gameFinished = true;

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
            style: TextStyle(
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

  bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  String _symbolForOperator(String operator) {
    switch (operator) {
      case 'AND':
        return '•';
      case 'OR':
        return '+';
      case 'NOT':
        return '¬';
      case 'XOR':
        return '⊕';
      default:
        return '?';
    }
  }

  Widget _buildTimerText(double width) {
    return Center(
      child: Text(
        '$_timeLeft',
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

  Widget _buildExpressionBar() {
    int slotIndex = 0;

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: _parsedExpression.map((part) {
          if (!part.isSlot) {
            return Text(
              part.text!,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            );
          }

          final currentSlot = slotIndex;
          slotIndex++;

          final playerValue = _playerAnswers[currentSlot];
          final isActive = _activeSlotIndex == currentSlot && !_roundLocked;

          return GestureDetector(
            onTap: () {
              if (_roundLocked || _gameFinished) return;
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
          );
        }).toList(),
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
        'PASSES LEFT: $_passesLeft',
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double sidePadding = 18;
    final double gap = 8;
    final double operatorButtonWidth = (size.width - (sidePadding * 2) - gap) / 2;
    final double operatorButtonHeight = 100;
    const double opBtnGap = 3;

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

                              if (_scoreDeltaText != null)
                                Positioned(
                                  right: w * 0.11,
                                  top: h * 0.13 + _scoreDeltaYOffset,
                                  child: AnimatedOpacity(
                                    duration: const Duration(milliseconds: 250),
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
                                              ..color = _scoreDeltaText!.startsWith('-')
                                                  ? const Color(0xFFD50000)
                                                  : const Color(0xFF0FAF2A),
                                          ),
                                        ),
                                        Text(
                                          _scoreDeltaText!,
                                          style: TextStyle(
                                            fontSize: w * 0.09,
                                            fontWeight: FontWeight.w900,
                                            color: _scoreDeltaText!.startsWith('-')
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

                    //_buildFeedbackText(),
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
                              children: [
                                BeveledMenuButton(
                                  label: 'PASS',
                                  color: _passOrange,
                                  width: 120,
                                  height: 50,
                                  textColor: Colors.white,
                                  fontSize: 20,
                                  onTap: _handlePass,
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

                            Row(
                              children: [
                                Expanded(
                                  child: _buildChoiceButton(
                                    symbol: '+',
                                    color: _operatorBlue,
                                    width: operatorButtonWidth,
                                    height: operatorButtonHeight,
                                    onTap: () => _handleOperatorTap('OR'),
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildChoiceButton(
                                    symbol: '•',
                                    color: _operatorYellow,
                                    width: operatorButtonWidth,
                                    height: operatorButtonHeight,
                                    onTap: () => _handleOperatorTap('AND'),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: opBtnGap),

                            Row(
                              children: [
                                Expanded(
                                  child: _buildChoiceButton(
                                    symbol: '¬',
                                    color: _operatorGreen,
                                    width: operatorButtonWidth,
                                    height: operatorButtonHeight,
                                    onTap: () => _handleOperatorTap('NOT'),
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildChoiceButton(
                                    symbol: '⊕',
                                    color: _operatorCoral,
                                    width: operatorButtonWidth,
                                    height: operatorButtonHeight,
                                    onTap: () => _handleOperatorTap('XOR'),
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
                    child: ColoredBox(
                      color: _flashColor,
                    ),
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
    ));
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