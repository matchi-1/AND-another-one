import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class GatekeepingGamePage extends StatefulWidget {
  const GatekeepingGamePage({
    super.key,
    this.difficultyLabel = 'BASIC',
  });

  final String difficultyLabel;

  @override
  State<GatekeepingGamePage> createState() => _GatekeepingGamePageState();
}

class _GatekeepingGamePageState extends State<GatekeepingGamePage> {
  static const int _maxTimePerQuestion = 25;
  static const int _startingPasses = 3;

  late final List<_GatekeepingQuestion> _questions;

  Timer? _timer;

  int _currentQuestionIndex = 0;
  int _score = 0;
  int _timeLeft = _maxTimePerQuestion;
  int _passesLeft = _startingPasses;
  int _activeSlotIndex = 0;

  bool _isLocked = false;
  bool _gameEnded = false;

  String? _feedbackMessage;
  Color _feedbackColor = AppColors.greenButton;

  List<String> _selectedOperators = [];

  _GatekeepingQuestion get _currentQuestion => _questions[_currentQuestionIndex];

  @override
  void initState() {
    super.initState();

    _questions = [
      _GatekeepingQuestion(
        circuitDiagram: '''
A ─────┐
       AND ─────┐
B ─────┘        OR ── OUT
C ──────────────┘
''',
        expressionSegments: ['A ', ' B ', ' C'],
        correctOperators: ['AND', 'OR'],
      ),
      _GatekeepingQuestion(
        circuitDiagram: '''
A ── NOT ─────┐
              OR ── OUT
B ────────────┘
''',
        expressionSegments: ['', ' A ', ' B'],
        correctOperators: ['NOT', 'OR'],
      ),
      _GatekeepingQuestion(
        circuitDiagram: '''
A ─────┐
       OR ──────┐
B ─────┘        AND ── OUT
C ──────────────┘
''',
        expressionSegments: ['( A ', ' B ) ', ' C'],
        correctOperators: ['OR', 'AND'],
      ),
      _GatekeepingQuestion(
        circuitDiagram: '''
A ─────┐
       XOR ─────┐
B ─────┘         AND ── OUT
C ───────────────┘
''',
        expressionSegments: ['A ', ' B ', ' C'],
        correctOperators: ['XOR', 'AND'],
      ),
      _GatekeepingQuestion(
        circuitDiagram: '''
A ── NOT ─────┐
              AND ── OUT
B ─────┐      │
       OR ────┘
C ─────┘
''',
        expressionSegments: ['', ' A ', ' ( B ', ' C )'],
        correctOperators: ['NOT', 'AND', 'OR'],
      ),
      _GatekeepingQuestion(
        circuitDiagram: '''
B ── NOT ─────┐
              OR ── OUT
A ────────────┘
''',
        expressionSegments: ['A ', ' ', ' B'],
        correctOperators: ['OR', 'NOT'],
      ),
    ];

    _questions.shuffle();
    _prepareQuestion();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _prepareQuestion() {
    _selectedOperators =
    List<String>.filled(_currentQuestion.correctOperators.length, '');
    _activeSlotIndex = 0;
    _timeLeft = _maxTimePerQuestion;
    _feedbackMessage = null;
    _isLocked = false;
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || _isLocked || _gameEnded) return;

      if (_timeLeft > 0) {
        setState(() {
          _timeLeft--;
        });
      } else {
        _handleTimeout();
      }
    });
  }

  void _assignOperator(String operator) {
    if (_isLocked || _gameEnded) return;

    setState(() {
      _selectedOperators[_activeSlotIndex] = operator;

      final nextEmpty = _findNextEmptySlot(startFrom: _activeSlotIndex + 1);
      if (nextEmpty != -1) {
        _activeSlotIndex = nextEmpty;
      }
    });
  }

  void _clearAnswer() {
    if (_isLocked || _gameEnded) return;

    setState(() {
      if (_selectedOperators[_activeSlotIndex].isNotEmpty) {
        _selectedOperators[_activeSlotIndex] = '';
        return;
      }

      for (int i = _activeSlotIndex - 1; i >= 0; i--) {
        if (_selectedOperators[i].isNotEmpty) {
          _selectedOperators[i] = '';
          _activeSlotIndex = i;
          break;
        }
      }
    });
  }

  int _findNextEmptySlot({required int startFrom}) {
    for (int i = startFrom; i < _selectedOperators.length; i++) {
      if (_selectedOperators[i].isEmpty) return i;
    }
    return -1;
  }

  bool _allSlotsFilled() {
    return !_selectedOperators.contains('');
  }

  Future<void> _handleSubmit() async {
    if (_isLocked || _gameEnded) return;

    if (!_allSlotsFilled()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fill in all missing operators first.'),
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }

    final isCorrect = _selectedOperators.join('|') ==
        _currentQuestion.correctOperators.join('|');

    if (isCorrect) {
      await _finishRound(
        message: 'Correct! +15',
        feedbackColor: AppColors.greenButton,
        scoreDelta: 15,
      );
    } else {
      await _finishRound(
        message: 'Wrong! -5',
        feedbackColor: AppColors.redButton,
        scoreDelta: -5,
      );
    }
  }

  Future<void> _handlePass() async {
    if (_isLocked || _gameEnded) return;

    if (_passesLeft <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No passes left.'),
          duration: Duration(milliseconds: 900),
        ),
      );
      return;
    }

    setState(() {
      _passesLeft--;
    });

    await _finishRound(
      message: 'Passed! -2',
      feedbackColor: AppColors.darkOrangeButton,
      scoreDelta: -2,
    );
  }

  Future<void> _handleTimeout() async {
    if (_isLocked || _gameEnded) return;

    await _finishRound(
      message: 'Time up! -5',
      feedbackColor: AppColors.redButton,
      scoreDelta: -5,
    );
  }

  Future<void> _finishRound({
    required String message,
    required Color feedbackColor,
    required int scoreDelta,
  }) async {
    setState(() {
      _isLocked = true;
      _score += scoreDelta;
      _feedbackMessage = message;
      _feedbackColor = feedbackColor;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    if (_currentQuestionIndex >= _questions.length - 1) {
      _showEndDialog();
      return;
    }

    setState(() {
      _currentQuestionIndex++;
      _prepareQuestion();
    });
  }

  void _restartGame() {
    _questions.shuffle();

    setState(() {
      _gameEnded = false;
      _currentQuestionIndex = 0;
      _score = 0;
      _passesLeft = _startingPasses;
      _prepareQuestion();
    });

    _startTimer();
  }

  void _showEndDialog() {
    _timer?.cancel();
    _gameEnded = true;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Final Score: $_score',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Difficulty: ${widget.difficultyLabel}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _restartGame();
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

  List<Widget> _buildExpressionWidgets() {
    final List<Widget> children = [];

    for (int i = 0; i < _currentQuestion.expressionSegments.length; i++) {
      children.add(
        Text(
          _currentQuestion.expressionSegments[i],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      );

      if (i < _selectedOperators.length) {
        children.add(
          GestureDetector(
            onTap: () {
              if (_isLocked) return;
              setState(() {
                _activeSlotIndex = i;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              alignment: Alignment.center,
              constraints: const BoxConstraints(
                minWidth: 78,
                minHeight: 44,
              ),
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _activeSlotIndex == i
                    ? Colors.white
                    : Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: Text(
                _selectedOperators[i].isEmpty ? '?' : _selectedOperators[i],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _activeSlotIndex == i
                      ? AppColors.greenButton
                      : Colors.white,
                ),
              ),
            ),
          ),
        );
      }
    }

    return children;
  }

  Widget _buildHudChip({
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white70,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOperatorButton({
    required String label,
    required Color color,
  }) {
    return BeveledMenuButton(
      label: label,
      color: color,
      width: 140,
      height: 52,
      textColor: Colors.white,
      fontSize: 20,
      onTap: () => _assignOperator(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.orangeBg,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                    child: Row(
                      children: [
                        BeveledMenuButton(
                          label: 'BACK',
                          color: AppColors.greyButton,
                          width: 92,
                          height: 38,
                          textColor: Colors.white,
                          fontSize: 16,
                          onTap: () => Navigator.pop(context),
                        ),
                        const Spacer(),
                        Image.asset(
                          AppAssets.homeLogo,
                          width: 42,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'GATEKEEPING',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHudChip(label: 'TIME', value: '$_timeLeft'),
                        _buildHudChip(
                          label: 'QUESTION',
                          value:
                          '${_currentQuestionIndex + 1}/${_questions.length}',
                        ),
                        _buildHudChip(label: 'SCORE', value: '$_score'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_feedbackMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _feedbackColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          _feedbackMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 12),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: Colors.black.withOpacity(0.08),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${widget.difficultyLabel} CIRCUIT',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black.withOpacity(0.55),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _currentQuestion.circuitDiagram.trim(),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.greenButton,
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'FILL IN THE MISSING OPERATORS',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white70,
                                    letterSpacing: 0.9,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: _buildExpressionWidgets(),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              _buildOperatorButton(
                                label: 'AND',
                                color: AppColors.yellowButton,
                              ),
                              _buildOperatorButton(
                                label: 'OR',
                                color: AppColors.purpleButton,
                              ),
                              _buildOperatorButton(
                                label: 'NOT',
                                color: AppColors.darkOrangeButton,
                              ),
                              _buildOperatorButton(
                                label: 'XOR',
                                color: AppColors.redButton,
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            alignment: WrapAlignment.center,
                            children: [
                              BeveledMenuButton(
                                label: 'BACKSPACE',
                                color: AppColors.greyButton,
                                width: 140,
                                height: 52,
                                textColor: Colors.white,
                                fontSize: 16,
                                onTap: _clearAnswer,
                              ),
                              BeveledMenuButton(
                                label: 'PASS (${_passesLeft})',
                                color: _passesLeft > 0
                                    ? AppColors.darkOrangeButton
                                    : AppColors.greyButton,
                                width: 130,
                                height: 52,
                                textColor: Colors.white,
                                fontSize: 16,
                                onTap: _handlePass,
                              ),
                              BeveledMenuButton(
                                label: 'SUBMIT',
                                color: AppColors.greenButton,
                                width: 130,
                                height: 52,
                                textColor: Colors.white,
                                fontSize: 18,
                                onTap: _handleSubmit,
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          BeveledMenuButton(
                            label: 'HOW TO PLAY?',
                            color: AppColors.purpleButton,
                            width: 190,
                            height: 42,
                            textColor: Colors.white,
                            fontSize: 16,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.mechanicsGatekeeping,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GatekeepingQuestion {
  const _GatekeepingQuestion({
    required this.circuitDiagram,
    required this.expressionSegments,
    required this.correctOperators,
  });

  final String circuitDiagram;
  final List<String> expressionSegments;
  final List<String> correctOperators;
}