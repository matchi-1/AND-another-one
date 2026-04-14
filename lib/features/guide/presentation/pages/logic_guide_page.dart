import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/game_menu_background.dart';
import '../../../../shared/widgets/music_button.dart';
import '../../domain/models/logic_lesson.dart';

class LogicGuidePage extends StatefulWidget {
  const LogicGuidePage({super.key});

  @override
  State<LogicGuidePage> createState() => _LogicGuidePageState();
}

class _LogicGuidePageState extends State<LogicGuidePage> {
  late int _currentLessonIndex;

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = 0;
  }

  void _nextLesson() {
    if (_currentLessonIndex < LogicLessonData.lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
    }
  }

  void _previousLesson() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final currentLesson = LogicLessonData.lessons[_currentLessonIndex];

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.pinkBg,
        useGrid: false,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // row with Back and Sound buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Image.asset(AppAssets.backBtn, width: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const MusicButton(size: 32),
                  ],
                ),
              ),

              // diagram container for logic guide
              Stack(
                children: [
                  Image.asset(
                    AppAssets.diagramContainerPink,
                    width: size.width,
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: size.width * 0.06,
                        bottom: size.width * 0.18,
                        left: size.width * 0.12,
                        right: size.width * 0.12,
                      ),
                      child: Image.asset(
                        _getImagePath(currentLesson.id),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: size.width * 0.08,
                    left: 20,
                    right: 20,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          currentLesson.title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: currentLesson.title.contains('Distributive') ? 24 : 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // beige rectangle container for explanation content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.beigeBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Formula box 1
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.pinkButton,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF9F00),
                            width: 3,
                          ),
                        ),
                        child: Text(
                          _getFormulaLine(currentLesson.formulas, 0),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Formula box 2 (if exists)
                      if (_getFormulaLine(currentLesson.formulas, 1)
                          .isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.pinkButton,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: const Color(0xFFFF9F00),
                              width: 3,
                            ),
                          ),
                          child: Text(
                            _getFormulaLine(currentLesson.formulas, 1),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                            ),
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Explanation box
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B6B3D),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFF9F00),
                            width: 3,
                          ),
                        ),
                        child: Text(
                          currentLesson.explanation,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Nunito',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Navigation buttons
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous button
                    GestureDetector(
                      onTap: _currentLessonIndex > 0 ? _previousLesson : null,
                      child: Image.asset(
                        AppAssets.backBtn,
                        width: 40,
                        opacity: AlwaysStoppedAnimation(
                          _currentLessonIndex > 0 ? 1.0 : 0.5,
                        ),
                      ),
                    ),

                    // Lesson counter
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.pinkButton,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_currentLessonIndex + 1} / ${LogicLessonData.lessons.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Next button
                    GestureDetector(
                      onTap: _currentLessonIndex <
                              LogicLessonData.lessons.length - 1
                          ? _nextLesson
                          : null,
                      child: Transform.rotate(
                        angle: 3.14159, // 180 degrees in radians
                        child: Image.asset(
                          AppAssets.backBtn,
                          width: 40,
                          opacity: AlwaysStoppedAnimation(
                            _currentLessonIndex <
                                    LogicLessonData.lessons.length - 1
                                ? 1.0
                                : 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  String _getFormulaLine(String formulas, int lineIndex) {
    final lines = formulas.split('\n');
    if (lineIndex >= lines.length) return '';
    return lines[lineIndex].trim();
  }

  String _getImagePath(String id) {
    switch (id) {
      case 'double_negation':
        return 'assets/images/logic_guide/double_negation.png';
      case 'idempotent_law':
        return 'assets/images/logic_guide/idempotent.png';
      case 'absorption_law':
        return 'assets/images/logic_guide/absorption.png';
      case 'distributive_associative':
        return 'assets/images/logic_guide/distributive.png';
      case 'demorgans_law':
        return 'assets/images/logic_guide/demorgan.png';
      default:
        return 'assets/images/logic_guide/double_negation.png';
    }
  }
}

