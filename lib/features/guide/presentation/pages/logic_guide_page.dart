import 'dart:async';
import 'dart:math' as math;

import 'package:and_another_one/core/audio/sfx_controller.dart';
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
    unawaited(SfxController.instance.playMenuPress());
    setState(() {
      _currentLessonIndex =
          (_currentLessonIndex + 1) % LogicLessonData.lessons.length;
    });
  }

  void _previousLesson() {
    unawaited(SfxController.instance.playMenuPress());
    setState(() {
      _currentLessonIndex =
          (_currentLessonIndex - 1 + LogicLessonData.lessons.length) %
          LogicLessonData.lessons.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final scale = _scaleForSize(size);
    final currentLesson = LogicLessonData.lessons[_currentLessonIndex];

    return Scaffold(
      body: GameMenuBackground(
        backgroundColor: AppColors.pinkBg,
        useGrid: false,
        child: Column(
          children: [
            // row with Back, pagination, and Sound buttons
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _scaled(10, scale)),
              child: Row(
                children: [
                  SizedBox(
                    width: _scaled(48, scale),
                    child: IconButton(
                      icon: Image.asset(
                        AppAssets.backBtn,
                        width: _scaled(30, scale),
                      ),
                      onPressed: () {
                        unawaited(SfxController.instance.playMenuBack());
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: _buildPaginationBar(scale: scale),
                    ),
                  ),
                  SizedBox(
                    width: _scaled(48, scale),
                    child: Center(
                      child: MusicButton(size: _scaled(32, scale)),
                    ),
                  ),
                ],
              ),
            ),

            // diagram container for logic guide
            SizedBox(
              height: size.height * _topPanelHeightFactor(size),
              child: Stack(
                children: [
                  Image.asset(
                    AppAssets.diagramContainerPink,
                    width: size.width,
                    height: size.height * _topPanelHeightFactor(size),
                    fit: BoxFit.fill,
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: _getDiagramPadding(size.width, currentLesson.id),
                      child: _buildTopDiagram(currentLesson, scale),
                    ),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment(
                        0,
                        _getTitleAlignmentY(currentLesson.id),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: _scaled(20, scale),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getDisplayTitle(currentLesson.id, currentLesson.title),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: _getTitleFontSize(currentLesson.id) * scale,
                              height: 1.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: _scaled(7, scale)),

            // beige rectangle container for explanation content
            Expanded(
              child: _buildBottomSectionWithNav(currentLesson, scale),
            ),

            SizedBox(height: _scaled(7, scale)),
          ],
        ),
      ),
    );
  }

  double _scaleForSize(Size size) {
    final scale = size.width / 360;
    return scale.clamp(0.85, 1.2);
  }

  double _topPanelHeightFactor(Size size) {
    final aspect = size.width / size.height;
    if (aspect < 0.42) {
      return 0.58;
    }
    if (aspect < 0.5) {
      return 0.54;
    }
    return 0.5;
  }

  double _scaled(double value, double scale) => value * scale;

  String _getFormulaLine(String formulas, int lineIndex) {
    final lines = formulas
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lineIndex >= lines.length) return '';
    return lines[lineIndex];
  }

  Widget _buildBottomSectionWithNav(LogicLesson lesson, double scale) {
    final navYOffset = lesson.id == 'demorgans_law'
      ? 0.0
      : lesson.id == 'symbol_names'
        ? 0.0
        : 0.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: _scaled(20, scale)),
          child: Container(
            height: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: _scaled(16, scale),
              vertical: lesson.id == 'symbol_names'
                  ? _scaled(4, scale)
                  : _scaled(8, scale),
            ),
            decoration: BoxDecoration(
              color: AppColors.beigeBg,
              borderRadius: BorderRadius.circular(_scaled(8, scale)),
            ),
            child: _buildBottomSectionContent(lesson, scale),
          ),
        ),
        Positioned(
          left: _scaled(4, scale),
          child: Transform.translate(
            offset: Offset(0, navYOffset),
            child: _buildNavButton(isNext: false, scale: scale),
          ),
        ),
        Positioned(
          right: _scaled(4, scale),
          child: Transform.translate(
            offset: Offset(0, navYOffset),
            child: _buildNavButton(isNext: true, scale: scale),
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({required bool isNext, required double scale}) {
    return GestureDetector(
      onTap: isNext ? _nextLesson : _previousLesson,
      child: Transform.rotate(
        angle: isNext ? 3.14159 : 0,
        child: Image.asset(
          AppAssets.backBtn,
          width: _scaled(30, scale),
          opacity: const AlwaysStoppedAnimation(1.0),
        ),
      ),
    );
  }

  Widget _buildPaginationBar({required double scale}) {
    final current = _currentLessonIndex + 1;
    final total = LogicLessonData.lessons.length;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _scaled(8, scale),
        vertical: _scaled(3, scale),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF196EEA),
        borderRadius: BorderRadius.circular(_scaled(10, scale)),
        border: Border.all(
          color: const Color(0xFFFF9F00),
          width: _scaled(1.4, scale),
        ),
      ),
      child: Text(
        '$current / $total',
        style: TextStyle(
          fontSize: _scaled(13, scale),
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomSectionContent(LogicLesson lesson, double scale) {
    if (lesson.id == 'symbol_names') {
      return LayoutBuilder(
        builder: (context, constraints) {
          return _buildSymbolNamesTable(scale, constraints);
        },
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Formula box 1
        Align(
          child: FractionallySizedBox(
            widthFactor: _getFormulaBoxWidthFactor(lesson.id),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: _scaled(16, scale),
                vertical: _scaled(3, scale),
              ),
              decoration: BoxDecoration(
                color: AppColors.pinkButton,
                borderRadius: BorderRadius.circular(_scaled(8, scale)),
                border: Border.all(
                  color: const Color(0xFFFF9F00),
                  width: _scaled(3, scale),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getFormulaLine(lesson.formulas, 0),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: _scaled(15, scale),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'Nunito',
                    ),
                  ),
                  if (_getFormulaLine(lesson.formulas, 1).isNotEmpty) ...[
                    SizedBox(height: _scaled(6, scale)),
                    Text(
                      'will be equivalent to',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _scaled(14, scale),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: _scaled(6, scale)),
                    Text(
                      _getFormulaLine(lesson.formulas, 1),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: _scaled(15, scale),
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

        SizedBox(height: _scaled(12, scale)),

        // Explanation box
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: _scaled(16, scale),
            vertical: _scaled(3, scale),
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1B6B3D),
            borderRadius: BorderRadius.circular(_scaled(8, scale)),
            border: Border.all(
              color: const Color(0xFFFF9F00),
              width: _scaled(3, scale),
            ),
          ),
          child: Text(
            lesson.explanation,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _scaled(13, scale),
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopDiagram(LogicLesson lesson, double scale) {
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
              scale: scale,
              imageXOffset: -10,
            ),
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_or.png',
              'OR',
              const Color(0xFFFF9800),
              scale: scale,
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
              scale: scale,
              imageXOffset: -3,
            ),
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_nor.png',
              'NOR',
              const Color(0xFFD13ED6),
              scale: scale,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_nand.png',
              'NAND',
              const Color(0xFF8B2DE2),
              scale: scale,
            ),
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_xor.png',
              'XOR',
              const Color(0xFF2FAF1D),
              scale: scale,
              imageXOffset: 3,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildGateLegendItem(
              'assets/images/logic_guide/symbols_xnor.png',
              'XNOR',
              const Color(0xFF14AFA7),
              scale: scale,
            ),
            SizedBox(width: _scaled(132, scale)),
          ],
        ),
      ],
    );
  }

  Widget _buildSymbolNamesImage(
    String assetPath,
    Alignment alignment,
    double xOffset,
  ) {
    return OverflowBox(
      alignment: alignment,
      maxWidth: double.infinity,
      child: Transform.translate(
        offset: Offset(xOffset, 0),
        child: Image.asset(
          assetPath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildSymbolNamesTable(double scale, BoxConstraints constraints) {
    final rows = [
      ('AND', 'assets/images/logic_guide/symbol_dot.png'),
      ('OR', 'assets/images/logic_guide/symbol_plus.png'),
      ('NOT', 'assets/images/logic_guide/symbol_tilde.png'),
      ('NOR', 'assets/images/logic_guide/symbol_down.png'),
      ('NAND', 'assets/images/logic_guide/symbol_up.png'),
      ('XOR', 'assets/images/logic_guide/symbol_xor.png'),
      ('XAND', 'assets/images/logic_guide/symbol_xand.png'),
      ('XNOR', 'assets/images/logic_guide/symbol_xnor.png'),
    ];
    final maxHeight = constraints.maxHeight;
    final maxWidth = constraints.maxWidth;
    final baselineHeight = _scaled(240, scale);
    final baselineWidth = _scaled(230, scale);
    final aspect = maxWidth / maxHeight;
    final isNarrow = aspect < 0.5;
    final narrowBoost = isNarrow ? (0.5 - aspect).clamp(0.0, 0.2) + 1.0 : 1.0;
    final heightScale = (maxHeight / baselineHeight)
      .clamp(isNarrow ? 1.15 : 0.9, isNarrow ? 2.4 : 1.45);
    final widthScale = (maxWidth / baselineWidth)
      .clamp(isNarrow ? 0.9 : 0.95, isNarrow ? 1.7 : 1.25);
    final density = math.min(heightScale, widthScale)
      .clamp(isNarrow ? 1.2 : 0.9, isNarrow ? 2.3 : 1.2);
    final tableScale = (0.72 * scale * density * narrowBoost)
      .clamp(isNarrow ? 0.8 : 0.6, isNarrow ? 1.6 : 1.0);

    return Center(
      child: Transform.scale(
        scale: tableScale,
        child: Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder.all(
            color: const Color(0xFFD66AA9),
            width: _scaled(1.7, scale),
          ),
          columnWidths: const {
            0: FlexColumnWidth(1.2),
            1: FlexColumnWidth(1),
          },
          children: rows
              .map(
                (row) => TableRow(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _scaled(1, scale),
                      ),
                      child: Center(
                        child: Text(
                          row.$1,
                          style: TextStyle(
                            fontSize: _scaled(19, scale),
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFCF6AA5),
                            fontFamily: 'Nunito',
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: _scaled(1, scale),
                      ),
                      child: Center(
                        child: Image.asset(
                          row.$2,
                          height: _getSymbolRowHeight(row.$1, scale * density),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  double _getSymbolRowHeight(String label, double scale) {
    if (label == 'AND' || label == 'NOT') {
      return _scaled(10, scale);
    }
    return _scaled(19, scale);
  }

  Widget _buildGateLegendItem(
    String imagePath,
    String label,
    Color color, {
    required double scale,
    double imageXOffset = 0,
  }) {
    return SizedBox(
      width: _scaled(132, scale),
      child: Row(
        children: [
          Transform.translate(
            offset: Offset(_scaled(imageXOffset, scale), 0),
            child: Image.asset(
              imagePath,
              width: _scaled(56, scale),
              height: _scaled(56, scale),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: _scaled(10, scale)),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: _scaled(20, scale),
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
      return 16;
    }
    if (lessonId == 'symbol_names') {
      return 18;
    }
    return 18;
  }

  double _getTitleAlignmentY(String lessonId) {
    if (lessonId == 'distributive_associative') {
      return 0.84;
    }

    if (lessonId == 'symbol_names') {
      return 0.82;
    }

    if (lessonId == 'double_negation' ||
        lessonId == 'idempotent_law' ||
        lessonId == 'absorption_law' ||
        lessonId == 'demorgans_law') {
      return 0.82;
    }
    return 0.82;
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

