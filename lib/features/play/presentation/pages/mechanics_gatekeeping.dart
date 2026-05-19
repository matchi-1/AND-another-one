import 'dart:async';

import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class MechanicsGatekeepingPage extends StatelessWidget {
  const MechanicsGatekeepingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.blueBg,
        child: SafeArea(
          child: Column(
            children: [
              const _TopBar(
                title: 'HOW TO PLAY',
                subtitle: 'Gatekeeping Mode',
                accentColor: AppColors.orangeButton,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _ModeIntroCard(
                        title: 'WHAT IS GATEKEEPING?',
                        body:
                        'Gatekeeping is the mode where you fill in the missing logical operators in an incomplete Boolean expression based on the circuit shown on screen.',
                        color: AppColors.orangeButton,
                        icon: Icons.account_tree_rounded,
                      ),
                      const SizedBox(height: 16),

                      const _SectionTitle('HOW IT WORKS'),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '1',
                        title: 'Study the circuit',
                        body:
                        'Look at the logic gate diagram and trace how inputs such as A, B, and C flow through the gates.',
                      ),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '2',
                        title: 'Complete the expression',
                        body:
                        'Use the answer buttons to fill in the missing operators in the green answer strip.',
                      ),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '3',
                        title: 'Beat the timer',
                        body:
                        'Answer before time runs out to earn points and maintain momentum.',
                      ),
                      const SizedBox(height: 18),

                      const _SectionTitle('SCREEN GUIDE'),
                      const SizedBox(height: 10),
                      const _GatekeepingMockScreen(),
                      const SizedBox(height: 18),

                      const _SectionTitle('DIFFICULTIES'),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            child: _DifficultyCard(
                              title: 'BASIC',
                              color: AppColors.yellowButton,
                              body:
                              'Simple circuits and beginner recognition tasks.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _DifficultyCard(
                              title: 'LOGIC',
                              color: AppColors.pinkButton,
                              body:
                              'Moderately complex circuits and equivalence recognition.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _DifficultyCard(
                              title: 'MANIC',
                              color: AppColors.redButton,
                              body:
                              'Faster timing and more demanding logical structure.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const _SectionTitle('SCORING AND FEEDBACK'),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            child: _FeedbackCard(
                              title: 'CORRECT',
                              scoreText: '+POINTS',
                              color: AppColors.greenButton,
                              body:
                              'A green result screen appears and your score increases.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeedbackCard(
                              title: 'INCORRECT',
                              scoreText: '-POINTS',
                              color: AppColors.redButton,
                              body:
                              'A red result screen appears and your score is reduced.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      const _SectionTitle('MULTIPLIER SYSTEM'),
                      const SizedBox(height: 10),
                      const _MultiplierSystemCard(),
                      const SizedBox(height: 18),

                      const _SectionTitle('OTHER FEATURES'),
                      const SizedBox(height: 10),
                      const _InfoBulletCard(
                        items: [
                          'A timer increases urgency and quick reasoning.',
                          'You can Pass if you want to skip a difficult question.',
                          'A backspace button lets you revise your answer.',
                          'Each mode and difficulty has its own leaderboard.',
                        ],
                      ),
                      const SizedBox(height: 22),
                    ],
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

class _TopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color accentColor;

  const _TopBar({
    required this.title,
    required this.subtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              unawaited(SfxController.instance.playMenuBack());
            Navigator.pop(context);
            },
            
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.pinkButton,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Center(
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            fontFamily: 'Nunito',
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}

class _ModeIntroCard extends StatelessWidget {
  final String title;
  final String body;
  final Color color;
  final IconData icon;

  const _ModeIntroCard({
    required this.title,
    required this.body,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF9F00), width: 2),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 15,
                    height: 1.35,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String body;

  const _StepCard({
    required this.number,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.orangeButton,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Nunito',
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.orangeButton,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Nunito',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF333333),
                    fontSize: 14.5,
                    height: 1.35,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GatekeepingMockScreen extends StatefulWidget {
  const _GatekeepingMockScreen();

  @override
  State<_GatekeepingMockScreen> createState() => _GatekeepingMockScreenState();
}

class _GatekeepingMockScreenState extends State<_GatekeepingMockScreen> {
  int _timeLeft = 60;
  final double  _scoreMultiplier = 3.0;
  String _difficultyLevel = 'BASIC';

  void _handleCorrectAnswer() {
    setState(() {
      _timeLeft += 2;
    });
  }

  void _handleIncorrectAnswer() {
    setState(() {
      _timeLeft -= 1;
    });
  }

  String get _diagramDescription {
    switch (_difficultyLevel) {
      case 'BASIC':
        return 'As is expression';
      case 'LOGIC':
        return 'Simplified';
      case 'MANIC':
        return 'Expanded';
      default:
        return 'As is expression';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                'assets/images/how_to_play/how_to_play_gatekeeping_screen_guide_2.png',
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
            Positioned.fill(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final w = constraints.maxWidth;
                  final h = constraints.maxHeight;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // A: Timer
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.027, top: 0.01, width: 0.24, height: 0.108,
                        label: 'A',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(16, -16),
                      ),
                      // B: Score
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.28, top: 0.01, width: 0.715, height: 0.108,
                        label: 'B',
                        badgeAlign: Alignment.topRight,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // C: Diagram
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.04, top: 0.12, width: 0.92, height: 0.40,
                        label: 'C',
                        badgeAlign: Alignment.bottomRight,
                        badgeOffset: const Offset(16, 16),
                      ),
                      // D: Equation Display
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.12, top: 0.555, width: 0.76, height: 0.06 ,
                        label: 'D',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // E: Action Buttons
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.035, top: 0.665, width: 0.93, height: 0.076 ,
                        label: 'E',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // F: Choice Buttons
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.035, top: 0.742, width: 0.93, height: 0.23,
                        label: 'F',
                        badgeAlign: Alignment.bottomRight,
                        badgeOffset: const Offset(16, 16),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.beigeBg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFFF9F00), width: 3),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendRow('A', 'Timer'),
              const SizedBox(height: 8),
              const Text(
                'You start the round with exactly 60 seconds.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.orangeButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.orangeButton, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.timer_outlined, color: AppColors.orangeButton, size: 22),
                      const SizedBox(width: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return ScaleTransition(scale: animation, child: child);
                        },
                        child: Text(
                          '$_timeLeft s',
                          key: ValueKey<int>(_timeLeft),
                          style: const TextStyle(
                            fontSize: 22,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            color: AppColors.orangeButton,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                    height: 1.8,
                  ),
                  children: [
                    const TextSpan(text: 'If your answer is correct, you gain '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: _handleCorrectAnswer,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.greenButton,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
                            ],
                          ),
                          child: const Text(
                            '+2s',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Nunito',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '.\nIf your answer is wrong, you lose '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: _handleIncorrectAnswer,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.redButton,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 2),
                            ],
                          ),
                          child: const Text(
                            '-1s',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'Nunito',
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('B', 'Score'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Maximum Score Multiplier:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.yellowButton,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'x3.0',
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('C', 'Diagram'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Difficulty:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Row(
                    children: ['BASIC', 'LOGIC', 'MANIC'].map((level) {
                      final isSelected = _difficultyLevel == level;
                      Color activeColor;
                      switch(level) {
                        case 'BASIC': activeColor = AppColors.yellowButton; break;
                        case 'LOGIC': activeColor = AppColors.purpleButton; break;
                        case 'MANIC': activeColor = AppColors.redButton; break;
                        default: activeColor = AppColors.purpleButton;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _difficultyLevel = level;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected ? activeColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isSelected ? activeColor : const Color(0xFFCCCCCC),
                                width: 2,
                              ),
                            ),
                            child: Text(
                              level,
                              style: TextStyle(
                                fontFamily: 'Nunito',
                                fontWeight: FontWeight.w900,
                                color: isSelected ? Colors.white : const Color(0xFF666666),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  'Diagram Type: $_diagramDescription',
                  key: ValueKey<String>(_diagramDescription),
                  style: const TextStyle(
                    fontSize: 15,
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF333333),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('D', 'Expression Display'),
              const SizedBox(height: 8),
              const Text(
                'Shows the current logical expression to solve.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('E', 'Action Buttons'),
              const SizedBox(height: 8),
              const Text(
                'Use Pass to skip, or Backspace to undo your last input.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('F', 'Choice Buttons'),
              const SizedBox(height: 8),
              const Text(
                'Interactive buttons to fill in the missing logic operators.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHighlight({
    required double w,
    required double h,
    required double left,
    required double top,
    required double width,
    required double height,
    required String label,
    required Alignment badgeAlign,
    required Offset badgeOffset,
  }) {
    return Positioned(
      left: w * left,
      top: h * top,
      width: w * width,
      height: h * height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.redButton, width: 4),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          Align(
            alignment: badgeAlign,
            child: Transform.translate(
              offset: badgeOffset,
              child: _LegendBadge(label),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendRow(String letter, String label) {
    return Row(
      children: [
        _LegendBadge(letter),
        const SizedBox(width: 12),
        Text(
          '=  $label',
          style: const TextStyle(
            color: Color(0xFF333333),
            fontSize: 18,
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LegendBadge extends StatelessWidget {
  final String letter;
  const _LegendBadge(this.letter);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.redButton,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black45,
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          letter,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
            fontFamily: 'Nunito',
            height: 1.1,
          ),
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  final String title;
  final Color color;
  final String body;

  const _DifficultyCard({
    required this.title,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 13,
              height: 1.35,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final String title;
  final String scoreText;
  final Color color;
  final String body;

  const _FeedbackCard({
    required this.title,
    required this.scoreText,
    required this.color,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            scoreText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13.5,
              height: 1.35,
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBulletCard extends StatelessWidget {
  final List<String> items;
  const _InfoBulletCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Icon(
                    Icons.circle,
                    size: 10,
                    color: AppColors.orangeButton,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      color: Color(0xFF333333),
                      fontSize: 14.5,
                      height: 1.35,
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
            .toList(),
      ),
    );
  }
}

class _MultiplierSystemCard extends StatelessWidget {
  const _MultiplierSystemCard();

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontFamily: 'Nunito',
          fontSize: 13,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      color: Color(0xFF333333),
      fontSize: 14.5,
      height: 1.35,
      fontFamily: 'Nunito',
      fontWeight: FontWeight.w800,
    );

    Widget buildTierRow(String range, String mult) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFFF2A00), Color(0xFFFF8C00), Color(0xFFFFD700)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Text(
                'Streak',
                style: textStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 36,
              child: Text(range, style: textStyle),
            ),
            const Text(' =  ', style: textStyle),
            _buildBadge(mult, AppColors.orangeButton),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.beigeBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFF9F00), width: 3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Base Score
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.star_rounded, size: 14, color: AppColors.orangeButton),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    const Text('Base score:', style: textStyle),
                    _buildBadge('100', AppColors.yellowButton),
                    const Text('= Basic,', style: textStyle),
                    _buildBadge('200', AppColors.pinkButton),
                    const Text('= Logic,', style: textStyle),
                    _buildBadge('300', AppColors.redButton),
                    const Text('= Manic.', style: textStyle),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Multiplier Tiers
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 6),
                child: Icon(Icons.rocket_launch_rounded, size: 14, color: AppColors.orangeButton),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Multiplier Tiers:', style: textStyle),
                    const SizedBox(height: 8),
                    buildTierRow('0-1', 'x1'),
                    buildTierRow('2-3', 'x1.25'),
                    buildTierRow('4-5', 'x1.5'),
                    buildTierRow('6-7', 'x1.75'),
                    buildTierRow('8-9', 'x2'),
                    buildTierRow('10+', 'x3'),
                    const SizedBox(height: 2),
                    Text(
                      '(Two correct answers = +1 multiplier tier, up to x3 multiplier)',
                      style: textStyle.copyWith(fontStyle: FontStyle.italic, color: const Color(0xFF666666), fontSize: 13.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Wrong Answer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.close_rounded, size: 18, color: AppColors.redButton),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: textStyle,
                    children: [
                      TextSpan(
                        text: 'Wrong answer',
                        style: TextStyle(color: AppColors.redButton, fontWeight: FontWeight.w900),
                      ),
                      TextSpan(text: ' = -1 multiplier tier only.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Pass
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: Icon(Icons.fast_forward_rounded, size: 16, color: Color(0xFF666666)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style: textStyle,
                    children: [
                      TextSpan(
                        text: 'Pass',
                        style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF666666)),
                      ),
                      TextSpan(text: ' = no change in multiplier or streak.'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


