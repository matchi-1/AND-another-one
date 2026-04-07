import '../models/gatekeeping_question.dart';

class GatekeepingQuestionRepository {
  static final List<GatekeepingQuestion> _allQuestions = [
    // =========================
    // BASIC
    // =========================
    GatekeepingQuestion(
      id: 'basic_1',
      imagePath: 'assets/images/diagrams/basic/basic_1.png',
      expression: 'A __AND B',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_2',
      imagePath: 'assets/images/diagrams/basic/basic_2.png',
      expression: 'A __OR B',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_3',
      imagePath: 'assets/images/diagrams/basic/basic_3.png',
      expression: 'B __AND C',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_4',
      imagePath: 'assets/images/diagrams/basic/basic_4.png',
      expression: 'B __OR C',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_5',
      imagePath: 'assets/images/diagrams/basic/basic_5.png',
      expression: 'A __AND C',
      answers: ['AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_6',
      imagePath: 'assets/images/diagrams/basic/basic_6.png',
      expression: 'A __OR C',
      answers: ['OR'],
      difficulty: GatekeepingDifficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_7',
      imagePath: 'assets/images/diagrams/basic/basic_7.png',
      expression: '__NOT A __AND B',
      answers: ['NOT', 'AND'],
      difficulty: GatekeepingDifficulty.basic,
    ),

    // =========================
    // LOGIC
    // =========================
    GatekeepingQuestion(
      id: 'logic_1',
      imagePath: 'assets/images/diagrams/logic/logic_1.png',
      expression: '( A __AND B ) __OR C',
      answers: ['AND', 'OR'],
      difficulty: GatekeepingDifficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_2',
      imagePath: 'assets/images/diagrams/logic/logic_2.png',
      expression: '__NOT ( A __OR B )',
      answers: ['NOT', 'OR'],
      difficulty: GatekeepingDifficulty.logic,
    ),

    // =========================
    // MANIC
    // =========================
    GatekeepingQuestion(
      id: 'manic_1',
      imagePath: 'assets/images/diagrams/manic/manic_1.png',
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