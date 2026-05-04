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
    setState(() {
      _currentLessonIndex =
          (_currentLessonIndex + 1) % LogicLessonData.lessons.length;
    });
  }

  void _previousLesson() {
    setState(() {
      _currentLessonIndex =
          (_currentLessonIndex - 1 + LogicLessonData.lessons.length) %
          LogicLessonData.lessons.length;
    });
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
                      child: _buildTopDiagram(currentLesson),
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
              _buildBottomSectionWithNav(currentLesson),

              const SizedBox(height: 20),

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

  Widget _buildBottomSectionWithNav(LogicLesson lesson) {
    final navYOffset = lesson.id == 'demorgans_law'
      ? -28.0
      : lesson.id == 'symbol_names'
        ? 4.0
        : 0.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _buildBottomSection(lesson),
        ),
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(0, navYOffset),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(isNext: false),
                  _buildNavButton(isNext: true),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({required bool isNext}) {
    return GestureDetector(
      onTap: isNext ? _nextLesson : _previousLesson,
      child: Transform.rotate(
        angle: isNext ? 3.14159 : 0,
        child: Image.asset(
          AppAssets.backBtn,
          width: 36,
          opacity: const AlwaysStoppedAnimation(1.0),
        ),
      ),
    );
  }

  Widget _buildBottomSection(LogicLesson lesson) {
    if (lesson.id == 'symbol_names') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.beigeBg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: SizedBox(
          height: 220,
          child: Row(
            children: [
              Expanded(
                child: Image.asset(
                  'assets/images/logic_guide/symbol_names_table.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Image.asset(
                  'assets/images/logic_guide/symbol_names_diagram.png',
                  fit: BoxFit.contain,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
              widthFactor: _getFormulaBoxWidthFactor(lesson.id),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getFormulaLine(lesson.formulas, 0),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nunito',
                      ),
                    ),
                    if (_getFormulaLine(lesson.formulas, 1).isNotEmpty) ...[
                      const SizedBox(height: 6),
                      const Text(
                        'will be equivalent to',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _getFormulaLine(lesson.formulas, 1),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Nunito',
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
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
              lesson.explanation,
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
    );
  }

  Widget _buildTopDiagram(LogicLesson lesson) {
    if (lesson.id != 'symbol_names') {
      return Image.asset(
        _getImagePath(lesson.id),
        fit: BoxFit.contain,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_and.png',
              'AND',
              const Color(0xFF196EEA),
              imageXOffset: -10,
            ),
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_or.png',
              'OR',
              const Color(0xFFFF9800),
              imageXOffset: -6,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_not.png',
              'NOT',
              const Color(0xFFFF2E2E),
              imageXOffset: -3,
            ),
            _buildGateLegendItem('assets/images/logic_guide/symbols_nor.png', 'NOR', const Color(0xFFD13ED6)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem('assets/images/logic_guide/symbols_nand.png', 'NAND', const Color(0xFF8B2DE2)),
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_xor.png',
              'XOR',
              const Color(0xFF2FAF1D),
              imageXOffset: 3,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem('assets/images/logic_guide/symbols_xnor.png', 'XNOR', const Color(0xFF14AFA7)),
            const SizedBox(width: 132),
          ],
        ),
      ],
    );
  }

  Widget _buildGateLegendItem(
    String imagePath,
    String label,
    Color color, {
    double imageXOffset = 0,
  }) {
    return SizedBox(
      width: 132,
      child: Row(
        children: [
          Transform.translate(
            offset: Offset(imageXOffset, 0),
            child: Image.asset(
              imagePath,
              width: 56,
              height: 56,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Nunito',
              ),
            ),
          ),
        ],
      ),
    );
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

    if (lessonId == 'symbol_names') {
      return EdgeInsets.only(
        top: width * 0.08,
        bottom: width * 0.25,
        left: width * 0.08,
        right: width * 0.08,
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
    if (lessonId == 'symbol_names') {
      return 28;
    }
    return 28;
  }

  double _getTitleBottomOffset(double width, String lessonId) {
    if (lessonId == 'distributive_associative') {
      return width * 0.07;
    }

    if (lessonId == 'symbol_names') {
      return width * 0.11;
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
      case 'symbol_names':
        return 'assets/images/logic_guide/symbol_names_diagram.png';
      default:
        return 'assets/images/logic_guide/double_negation.png';
    }
  }
}

