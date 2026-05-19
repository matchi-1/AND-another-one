import 'dart:async';

import 'package:and_another_one/core/audio/sfx_controller.dart';
import 'package:flutter/material.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/beveled_menu_button.dart';
import '../../../../shared/widgets/game_menu_background.dart';

class MechanicsOneOrNonePage extends StatelessWidget {
  const MechanicsOneOrNonePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.purpleBg,
        child: SafeArea(
          child: Column(
            children: [
              const _TopBar(
                title: 'HOW TO PLAY',
                subtitle: 'One or None Mode',
                accentColor: AppColors.orangeButton,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _ModeIntroCard(
                        title: 'WHAT IS ONE OR NONE?',
                        body:
                            'One or None is the mode where you analyze the shown logic circuit and decide whether the final output is 1 or 0.',
                        color: AppColors.orangeButton,
                        icon: Icons.toggle_on_rounded,
                      ),
                      const SizedBox(height: 16),

                      const _SectionBanner('HOW IT WORKS'),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '1',
                        title: 'Read the circuit',
                        body:
                            'Observe the gates, inputs, and flow of logic from left to right.',
                      ),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '2',
                        title: 'Evaluate the final output',
                        body:
                            'Determine whether the overall result of the circuit becomes 1 or 0.',
                      ),
                      const SizedBox(height: 10),
                      const _StepCard(
                        number: '3',
                        title: 'Protect your lives',
                        body:
                            'Tap the correct answer to keep your lives intact, because wrong answers cost a heart.',
                      ),
                      const SizedBox(height: 18),

                      const _SectionBanner('SCREEN GUIDE'),
                      const SizedBox(height: 10),
                      const _OneOrNoneMockScreen(),
                      const SizedBox(height: 18),

                      const _SectionBanner('DIFFICULTIES'),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final bool stackCards = constraints.maxWidth < 560;
                          final double cardWidth = stackCards
                              ? constraints.maxWidth
                              : (constraints.maxWidth - 20) / 3;

                          return Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: const [
                              _DifficultyCard(
                                title: 'BASIC',
                                color: AppColors.yellowButton,
                                body:
                                    'Introductory recognition tasks with simpler circuits.',
                              ),
                              _DifficultyCard(
                                title: 'LOGIC',
                                color: AppColors.pinkButton,
                                body:
                                    'Moderate circuit analysis with more reasoning required.',
                              ),
                              _DifficultyCard(
                                title: 'MANIC',
                                color: AppColors.redButton,
                                body:
                                    'Harder circuit structures with faster pressure.',
                              ),
                            ]
                                .map(
                                  (card) => SizedBox(
                                    width: cardWidth,
                                    child: card,
                                  ),
                                )
                                .toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 18),

                      const _SectionBanner('SCORING AND FEEDBACK'),
                      const SizedBox(height: 10),
                      Row(
                        children: const [
                          Expanded(
                            child: _FeedbackCard(
                              title: 'CORRECT',
                              scoreText: '+POINTS',
                              color: AppColors.greenButton,
                              body:
                                  'A green feedback screen confirms the right answer instantly.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _FeedbackCard(
                              title: 'INCORRECT',
                              scoreText: '-POINTS',
                              color: AppColors.redButton,
                              body:
                                  'A red feedback screen clearly shows that the answer was wrong.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      const SizedBox(height: 10),

                      // External header bar matching top image (outside the card)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                        decoration: BoxDecoration(
                          color: AppColors.pinkButton,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.orangeButton, width: 4),
                        ),
                        child: const Text(
                          'MULTIPLIER SYSTEM',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Multiplier panel matching in-game style (header + body)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.orangeButton, width: 4),
                        ),
                        child: Column(
                          children: [
                            // Body (fills full rounded area so no blank header shows)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: AppColors.beigeBg,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Responsive: full-size on wide screens (tablets), scale down on phones
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      final bool isWide = constraints.maxWidth >= 600;
                                      final EdgeInsets chipPadding = isWide
                                          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                                          : const EdgeInsets.symmetric(horizontal: 10, vertical: 6);
                                      final double labelFontSize = isWide ? 16 : 15;
                                      // Build the row once and either render it flat (wide) or scale it down (narrow)
                                      Widget row = Row(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.star, color: AppColors.orangeButton, size: isWide ? 20 : 18),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Base score:',
                                            style: TextStyle(
                                              fontSize: labelFontSize,
                                              fontFamily: 'Nunito',
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF333333),
                                            ),
                                          ),
                                          SizedBox(width: isWide ? 16 : 12),

                                          // 100 - Basic
                                          Container(
                                            padding: chipPadding,
                                            decoration: BoxDecoration(
                                              color: AppColors.yellowButton,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: Text('100', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: labelFontSize - 1)),
                                          ),
                                          SizedBox(width: isWide ? 10 : 8),
                                          Text('= Basic', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: labelFontSize)),
                                          SizedBox(width: isWide ? 18 : 12),

                                          // 200 - Logic
                                          Container(
                                            padding: chipPadding,
                                            decoration: BoxDecoration(
                                              color: AppColors.pinkButton,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: Text('200', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: labelFontSize - 1)),
                                          ),
                                          SizedBox(width: isWide ? 10 : 8),
                                          Text('= Logic', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: labelFontSize)),
                                          SizedBox(width: isWide ? 18 : 12),

                                          // 300 - Manic
                                          Container(
                                            padding: chipPadding,
                                            decoration: BoxDecoration(
                                              color: AppColors.redButton,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white, width: 2),
                                            ),
                                            child: Text('300', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: labelFontSize - 1)),
                                          ),
                                          SizedBox(width: isWide ? 10 : 8),
                                          Text('= Manic', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800, fontSize: labelFontSize)),
                                        ],
                                      );

                                      if (isWide) {
                                        return row;
                                      }

                                      return Align(
                                        alignment: Alignment.centerLeft,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: row,
                                        ),
                                      );
                                    },
                                  ),

                                  const SizedBox(height: 12),

                                  const Text(
                                    'Multiplier Tiers:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'Nunito',
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF333333),
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Tiers list with purple 'Streak' and orange multiplier chips
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      _TierRow(label: 'Streak 0-1', multiplier: 'x1', labelColor: AppColors.purpleButton),
                                      _TierRow(label: 'Streak 2-3', multiplier: 'x1.25', labelColor: AppColors.purpleButton),
                                      _TierRow(label: 'Streak 4-5', multiplier: 'x1.5', labelColor: AppColors.purpleButton),
                                      _TierRow(label: 'Streak 6-7', multiplier: 'x1.75', labelColor: AppColors.purpleButton),
                                      _TierRow(label: 'Streak 8-9', multiplier: 'x2', labelColor: AppColors.purpleButton),
                                      _TierRow(label: 'Streak 10+', multiplier: 'x3', labelColor: AppColors.purpleButton),
                                    ],
                                  ),

                                  const SizedBox(height: 8),
                                  const Text(
                                    '(Two correct answers = +1 multiplier tier, up to x3 multiplier)',
                                    style: TextStyle(fontStyle: FontStyle.italic, color: Color(0xFF555555)),
                                  ),
                                  const SizedBox(height: 8),

                                  // Wrong answer and Pass rows with icons
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Icon(Icons.close, color: AppColors.redButton, size: 18),
                                      SizedBox(width: 8),
                                      Expanded(child: Text('Wrong answer = -1 multiplier tier only.', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w800))),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Icon(Icons.double_arrow, color: AppColors.greyButton, size: 18),
                                      SizedBox(width: 8),
                                      Expanded(child: Text('Pass = no change in multiplier or streak.', style: TextStyle(color: Color(0xFF333333), fontWeight: FontWeight.w800))),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      const _SectionBanner('OTHER FEATURES'),
                      const SizedBox(height: 10),
                      const _InfoBulletCard(
                        items: [
                          'Each wrong answer removes one heart.',
                          'You can Pass a question when needed, depending on your remaining passes.',
                          'The interface keeps the answer choice simple: just 1 or 0.',
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
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30,
            ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
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
    return Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        fontFamily: 'Nunito',
        letterSpacing: 1,
      ),
    );
  }
}

class _SectionBanner extends StatelessWidget {
  final String text;

  const _SectionBanner(this.text);

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
                  style: const TextStyle(
                    color: AppColors.orangeButton,
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
              fontWeight: FontWeight.w600,
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

class _HudPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _HudPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniGate extends StatelessWidget {
  final String label;
  const _MiniGate({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _CircuitLines extends StatelessWidget {
  const _CircuitLines();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(child: CustomPaint(painter: _CircuitPainter()));
  }
}

class _CircuitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(const Offset(34, 88), const Offset(88, 88), paint);
    canvas.drawLine(const Offset(34, 138), const Offset(88, 138), paint);
    canvas.drawLine(const Offset(158, 99), const Offset(188, 99), paint);
    canvas.drawLine(const Offset(258, 99), const Offset(300, 99), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OneOrNoneMockScreen extends StatefulWidget {
  const _OneOrNoneMockScreen();

  @override
  State<_OneOrNoneMockScreen> createState() => _OneOrNoneMockScreenState();
}

class _OneOrNoneMockScreenState extends State<_OneOrNoneMockScreen> {
  int _timeLeft = 60;
  final double _scoreMultiplier = 3.0;
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
        return 'Simple logic circuits';
      case 'LOGIC':
        return 'Moderate complexity';
      case 'MANIC':
        return 'Complex circuits';
      default:
        return 'Simple logic circuits';
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
                'assets/images/how_to_play/oneornonemode2.png',
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
                      // A: Lives
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.020, top: 0.01, width: 0.32, height: 0.108,
                        label: 'A',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(16, -16),
                      ),
                      // B: Score
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.35, top: 0.01, width: 0.635, height: 0.108,
                        label: 'B',
                        badgeAlign: Alignment.topRight,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // C: Diagram
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.04, top: 0.13, width: 0.92, height: 0.35,
                        label: 'C',
                        badgeAlign: Alignment.bottomRight,
                        badgeOffset: const Offset(16, 16),
                      ),
                      // D: Difficulty
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.05, top: 0.525, width: 0.92, height: 0.09 ,
                        label: 'D',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // E: Action Buttons
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.035, top: 0.655, width: 0.93, height: 0.06,
                        label: 'E',
                        badgeAlign: Alignment.topLeft,
                        badgeOffset: const Offset(-16, -16),
                      ),
                      // F: Choice Buttons
                      _buildHighlight(
                        w: w, h: h,
                        left: 0.035, top: 0.750, width: 0.93, height: 0.245,
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
              _buildLegendRow('A', 'Lives'),
              const SizedBox(height: 8),
              const Text(
                'You start the round with exactly 3 lives.',
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
                    color: AppColors.redButton.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.redButton, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded, color: AppColors.redButton, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        '3 LIVES',
                        style: TextStyle(
                          fontSize: 22,
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          color: AppColors.redButton,
                          letterSpacing: 1.0,
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
                    const TextSpan(text: 'If your answer is correct, you keep your current lives.'),
                    const TextSpan(text: '.\nIf your answer is wrong, you lose '),
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
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
                          '1 LIFE',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontFamily: 'Nunito',
                            fontSize: 14,
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
              const Text(
                'Shows the logic circuit you need to evaluate.',
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              
              _buildLegendRow('D', 'Difficulty'),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text(
                    'Level:',
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
                  'Circuit Type: $_diagramDescription',
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
              
              _buildLegendRow('E', 'Action Buttons'),
              const SizedBox(height: 8),
              const Text(
                'Use Pass to skip a question, or Backspace to undo your last input.',
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
                'Interactive buttons to choose the answer: tap 1 if the circuit output is true, or 0 if it is false.',
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

class _TierRow extends StatelessWidget {
  final String label;
  final String multiplier;
  final Color labelColor;
  const _TierRow({required this.label, required this.multiplier, this.labelColor = const Color(0xFF333333)});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 6,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: labelColor),
          ),
          const Text(' = ', style: TextStyle(fontSize: 14, fontFamily: 'Nunito', fontWeight: FontWeight.w900, color: Color(0xFF333333))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppColors.orangeButton, borderRadius: BorderRadius.circular(8)),
            child: Text(
              multiplier,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final String? resultLabel;
  final Color? resultColor;

  const _ControlChip({
    required this.label,
    required this.color,
    required this.onTap,
    this.resultLabel,
    this.resultColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              if (resultLabel != null && resultColor != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: resultColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    resultLabel!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
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
