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
                      padding: _getDiagramPadding(size.width, currentLesson.id),
                      child: Image.asset(
                        _getImagePath(currentLesson.id),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: _getTitleBottomOffset(size.width, currentLesson.id),
                    left: 20,
                    right: 20,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          _getDisplayTitle(currentLesson.id, currentLesson.title),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: _getTitleFontSize(currentLesson.id),
                            height: 1.05,
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
                      Align(
                        child: FractionallySizedBox(
                          widthFactor: _getFormulaBoxWidthFactor(currentLesson.id),
                          child: Container(
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
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Formula box 2 (if exists)
                      if (_getFormulaLine(currentLesson.formulas, 1)
                          .isNotEmpty)
                        Align(
                          child: FractionallySizedBox(
                            widthFactor: _getFormulaBoxWidthFactor(currentLesson.id),
                            child: Container(
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
                          ),
                        ),

                      const SizedBox(height: 12),

                      // Explanation box
                      Container(
                        width: double.infinity,
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
    final lines = formulas
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lineIndex >= lines.length) return '';
    return lines[lineIndex];
  }

  EdgeInsets _getDiagramPadding(double width, String lessonId) {
    // Keep circuit images clear of the frame title and footer badge.
    final basePadding = EdgeInsets.only(
      top: width * 0.10,
      bottom: width * 0.25,
      left: width * 0.14,
      right: width * 0.14,
    );

    if (lessonId == 'double_negation') {
      // Nudge content slightly lower for better top-frame clearance.
      return EdgeInsets.only(
        top: width * 0.13,
        bottom: width * 0.26,
        left: width * 0.14,
        right: width * 0.14,
      );
    }

    if (lessonId == 'idempotent_law') {
      // Idempotent law artwork has taller vertical content and needs tighter bounds.
      return EdgeInsets.only(
        top: width * 0.17,
        bottom: width * 0.29,
        left: width * 0.16,
        right: width * 0.16,
      );
    }

    if (lessonId == 'distributive_associative') {
      // Distributive/associative art is also vertically dense, so constrain further.
      return EdgeInsets.only(
        top: width * 0.15,
        bottom: width * 0.30,
        left: width * 0.16,
        right: width * 0.16,
      );
    }

    if (lessonId == 'demorgans_law') {
      // De Morgan's art needs more top clearance and a mild lower lift.
      return EdgeInsets.only(
        top: width * 0.16,
        bottom: width * 0.30,
        left: width * 0.15,
        right: width * 0.15,
      );
    }

    return basePadding;
  }

  String _getDisplayTitle(String lessonId, String fallbackTitle) {
    if (lessonId == 'distributive_associative') {
      return 'Distributive / Associative\nSimplification';
    }
    return fallbackTitle;
  }

  double _getTitleFontSize(String lessonId) {
    if (lessonId == 'distributive_associative') {
      return 22;
    }
    return 28;
  }

  double _getTitleBottomOffset(double width, String lessonId) {
    if (lessonId == 'distributive_associative') {
      return width * 0.07;
    }

    if (lessonId == 'double_negation' ||
        lessonId == 'idempotent_law' ||
        lessonId == 'absorption_law' ||
        lessonId == 'demorgans_law') {
      return width * 0.11;
    }
    return width * 0.08;
  }

  double _getFormulaBoxWidthFactor(String lessonId) {
    if (lessonId == 'distributive_associative') {
      return 0.95;
    }
    return 0.9;
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

