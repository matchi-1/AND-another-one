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
        backgroundColor: AppColors.purpleButton,
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                title: 'HOW TO PLAY',
                subtitle: 'One or None Mode',
                accentColor: AppColors.yellowButton,
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
                        color: AppColors.yellowButton,
                        icon: Icons.toggle_on_rounded,
                      ),
                      const SizedBox(height: 16),

                      const _SectionTitle('HOW IT WORKS'),
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
                        title: 'Choose fast and accurately',
                        body:
                        'Tap the correct answer before the timer runs out to score more points.',
                      ),
                      const SizedBox(height: 18),

                      const _SectionTitle('SCREEN GUIDE'),
                      const SizedBox(height: 10),
                      const _OneOrNoneMockScreen(),
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
                              'Introductory recognition tasks with simpler circuits.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _DifficultyCard(
                              title: 'LOGIC',
                              color: AppColors.pinkButton,
                              body:
                              'Moderate circuit analysis with more reasoning required.',
                            ),
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: _DifficultyCard(
                              title: 'MANIC',
                              color: AppColors.redButton,
                              body:
                              'Harder circuit structures with faster pressure.',
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
                      const SizedBox(height: 18),

                      const _SectionTitle('OTHER FEATURES'),
                      const SizedBox(height: 10),
                      const _InfoBulletCard(
                        items: [
                          'A timer adds urgency and rewards quick reasoning.',
                          'You can Pass a question when needed, depending on your remaining passes.',
                          'The interface keeps the answer choice simple: just 1 or 0.',
                          'Each difficulty and mode has its own leaderboard because score multipliers vary.',
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
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.8,
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.22), width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 14,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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
        color: Colors.white.withOpacity(0.09),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: AppColors.yellowButton,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
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
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.88),
                    fontSize: 13.5,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
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

class _OneOrNoneMockScreen extends StatelessWidget {
  const _OneOrNoneMockScreen();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.20), width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: const [
              Expanded(
                child: _HudPill(
                  label: 'TIMER',
                  value: '07',
                  color: AppColors.orangeButton,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _HudPill(
                  label: 'SCORE',
                  value: '920',
                  color: AppColors.pinkButton,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 185,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 18,
                  top: 55,
                  child: Text(
                    'A',
                    style: _inputStyle,
                  ),
                ),
                Positioned(
                  left: 18,
                  top: 115,
                  child: Text(
                    'B',
                    style: _inputStyle,
                  ),
                ),
                const Positioned(
                  left: 88,
                  top: 78,
                  child: _MiniGate(label: 'XOR'),
                ),
                const Positioned(
                  left: 188,
                  top: 78,
                  child: _MiniGate(label: 'NOT'),
                ),
                Positioned(
                  right: 22,
                  top: 88,
                  child: Text(
                    'FINAL',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
                const Positioned.fill(child: _CircuitLines()),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.greenButton,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Final Output = ?',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(
                child: _ControlChip(label: '0', color: AppColors.redButton),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ControlChip(label: '1', color: AppColors.greenButton),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _ControlChip(label: 'PASS', color: AppColors.greyButton),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const TextStyle _inputStyle = TextStyle(
    color: Colors.white,
    fontSize: 18,
    fontWeight: FontWeight.w900,
  );
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
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            body,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.90),
              fontSize: 12.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
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
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scoreText,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              height: 1.35,
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.circle,
                    size: 8,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.92),
                      fontSize: 13.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
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
    return IgnorePointer(
      child: CustomPaint(
        painter: _CircuitPainter(),
      ),
    );
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

class _ControlChip extends StatelessWidget {
  final String label;
  final Color color;

  const _ControlChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 16,
        ),
      ),
    );
  }
}