import '../models/gatekeeping_question.dart';

class GatekeepingQuestionRepository {
  static const String _diagramBasePath = 'assets/images/diagrams';

  static String _difficultyFolder(GatekeepingDifficulty difficulty) {
    switch (difficulty) {
      case GatekeepingDifficulty.basic:
        return 'basic';
      case GatekeepingDifficulty.logic:
        return 'logic';
      case GatekeepingDifficulty.manic:
        return 'manic';
    }
  }

  static String _diagramPath(
      GatekeepingDifficulty difficulty,
      String fileName,
      ) {
    return '$_diagramBasePath/${_difficultyFolder(difficulty)}/$fileName';
  }

  static final List<GatekeepingQuestion> _allQuestions = [
    // =========================
    // BASIC
    // =========================
    GatekeepingQuestion(
      id: 'basic_1',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_1.png'),
      expression: 'A __AND B',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_2',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_2.png'),
      expression: 'A __OR B',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_3',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_3.png'),
      expression: 'B __AND C',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_4',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_4.png'),
      expression: 'B __OR C',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_5',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_5.png'),
      expression: 'A __AND C',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_6',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_6.png'),
      expression: 'A __OR C',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_7',
      imagePath: _diagramPath(GatekeepingDifficulty.basic, 'basic_7.png'),
      expression: '__NOT A __AND B',
      answers: ['NOT', 'AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),

    // =========================
    // LOGIC
    // =========================
    GatekeepingQuestion(
      id: 'logic_1',
      imagePath: _diagramPath(GatekeepingDifficulty.logic, 'logic_1.png'),
      expression: '( A __AND B ) __OR C',
      answers: ['AND', 'OR'],
      difficulty: GatekeepingDifficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_2',
      imagePath: _diagramPath(GatekeepingDifficulty.logic, 'logic_2.png'),
      expression: '__NOT ( A __OR B )',
      answers: ['NOT', 'OR'],
      difficulty: GatekeepingDifficulty.logic,
    ),

    // =========================
    // MANIC
    // =========================
    GatekeepingQuestion(
      id: 'manic_1',
      imagePath: _diagramPath(GatekeepingDifficulty.manic, 'manic_1.png'),
      expression: '( __NOT A __AND B ) __XOR C',
      answers: ['NOT', 'AND', 'XOR'],
      difficulty: GatekeepingDifficulty.manic,
    ),
  ];

  static List<GatekeepingQuestion> getAll() {
    return List<GatekeepingQuestion>.from(_allQuestions);
  }

  static List<GatekeepingQuestion> getByDifficulty(
      GatekeepingDifficulty difficulty,
      ) {
    return _allQuestions
        .where((question) => question.difficulty == difficulty)
        .toList();
  }

  static List<GatekeepingQuestion> getShuffledByDifficulty(
      GatekeepingDifficulty difficulty,
      ) {
    final questions = getByDifficulty(difficulty);
    questions.shuffle();
    return questions;
  }

  static GatekeepingQuestion? getById(String id) {
    try {
      return _allQuestions.firstWhere((question) => question.id == id);
    } catch (_) {
      return null;
    }
  }
}