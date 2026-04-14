import '../models/gatekeeping_question.dart';

class GatekeepingQuestionRepository {
  static const String _diagramBasePath = 'assets/images/diagrams';

  static String _difficultyFolder(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.basic:
        return 'basic';
      case Difficulty.logic:
        return 'logic';
      case Difficulty.manic:
        return 'manic';
    }
  }

  static String _diagramPath(
      Difficulty difficulty,
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
      imagePath: _diagramPath(Difficulty.basic, 'basic_1.png'),
      expression: 'A __AND B',
      answers: ['AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_2',
      imagePath: _diagramPath(Difficulty.basic, 'basic_2.png'),
      expression: 'A __OR B',
      answers: ['OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_3',
      imagePath: _diagramPath(Difficulty.basic, 'basic_3.png'),
      expression: 'B __AND C',
      answers: ['AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_4',
      imagePath: _diagramPath(Difficulty.basic, 'basic_4.png'),
      expression: 'B __OR C',
      answers: ['OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_5',
      imagePath: _diagramPath(Difficulty.basic, 'basic_5.png'),
      expression: 'A __AND C',
      answers: ['AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_6',
      imagePath: _diagramPath(Difficulty.basic, 'basic_6.png'),
      expression: 'A __OR C',
      answers: ['OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_7',
      imagePath: _diagramPath(Difficulty.basic, 'basic_7.png'),
      expression: '__NOT A __AND B',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_8',
      imagePath: _diagramPath(Difficulty.basic, 'basic_8.png'),
      expression: 'A __OR __NOT B',
      answers: ['OR', 'NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_9',
      imagePath: _diagramPath(Difficulty.basic, 'basic_9.png'),
      expression: '__NOT B __AND C',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_10',
      imagePath: _diagramPath(Difficulty.basic, 'basic_10.png'),
      expression: 'B __OR __NOT C',
      answers: ['OR', 'NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_11',
      imagePath: _diagramPath(Difficulty.basic, 'basic_11.png'),
      expression: '__NOT A __OR __NOT C',
      answers: ['NOT', 'OR', 'NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_12',
      imagePath: _diagramPath(Difficulty.basic, 'basic_12.png'),
      expression: '__NOT A __AND __NOT B',
      answers: ['NOT', 'AND', 'NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_13',
      imagePath: _diagramPath(Difficulty.basic, 'basic_13.png'),
      expression: '(A __AND B) __OR C',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_14',
      imagePath: _diagramPath(Difficulty.basic, 'basic_14.png'),
      expression: 'A __AND (B __AND C)',
      answers: ['AND', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_15',
      imagePath: _diagramPath(Difficulty.basic, 'basic_15.png'),
      expression: '(A __OR B) __AND C',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_16',
      imagePath: _diagramPath(Difficulty.basic, 'basic_16.png'),
      expression: 'A __OR (B __AND C)',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_17',
      imagePath: _diagramPath(Difficulty.basic, 'basic_17.png'),
      expression: '(A __AND C) __OR B',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_18',
      imagePath: _diagramPath(Difficulty.basic, 'basic_18.png'),
      expression: '(B __AND C) __OR A',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_19',
      imagePath: _diagramPath(Difficulty.basic, 'basic_19.png'),
      expression: '(A __OR C) __AND B',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_20',
      imagePath: _diagramPath(Difficulty.basic, 'basic_20.png'),
      expression: '(B __OR C) __AND A',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_21',
      imagePath: _diagramPath(Difficulty.basic, 'basic_21.png'),
      expression: '__NOT(A __AND B)',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_22',
      imagePath: _diagramPath(Difficulty.basic, 'basic_22.png'),
      expression: '__NOT(A __OR B)',
      answers: ['NOT', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_23',
      imagePath: _diagramPath(Difficulty.basic, 'basic_23.png'),
      expression: '__NOT(B __AND C)',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_24',
      imagePath: _diagramPath(Difficulty.basic, 'basic_24.png'),
      expression: '__NOT(B __OR C)',
      answers: ['NOT', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_25',
      imagePath: _diagramPath(Difficulty.basic, 'basic_25.png'),
      expression: '__NOT(A __AND C)',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_26',
      imagePath: _diagramPath(Difficulty.basic, 'basic_26.png'),
      expression: '__NOT(A __OR C)',
      answers: ['NOT', 'OR'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_27',
      imagePath: _diagramPath(Difficulty.basic, 'basic_27.png'),
      expression: '__NOT(__NOT A __AND B)',
      answers: ['NOT', 'NOT', 'AND'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_28',
      imagePath: _diagramPath(Difficulty.basic, 'basic_28.png'),
      expression: '__NOT A',
      answers: ['NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_29',
      imagePath: _diagramPath(Difficulty.basic, 'basic_29.png'),
      expression: '__NOT B',
      answers: ['NOT'],
      difficulty: Difficulty.basic,
    ),
    GatekeepingQuestion(
      id: 'basic_30',
      imagePath: _diagramPath(Difficulty.basic, 'basic_30.png'),
      expression: '__NOT C',
      answers: ['NOT'],
      difficulty: Difficulty.basic,
    ),
    // =========================
    // LOGIC
    // =========================
    GatekeepingQuestion(
      id: 'logic_1',
      imagePath: _diagramPath(Difficulty.logic, 'logic_1.png'),
      expression: 'A __NAND B',
      answers: ['NAND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_2',
      imagePath: _diagramPath(Difficulty.logic, 'logic_2.png'),
      expression: '__NOT(A __AND B)',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_3',
      imagePath: _diagramPath(Difficulty.logic, 'logic_3.png'),
      expression: 'A __NOR B',
      answers: ['NOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_4',
      imagePath: _diagramPath(Difficulty.logic, 'logic_4.png'),
      expression: '__NOT A __AND __NOT B',
      answers: ['NOT', 'AND', 'NOT'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_5',
      imagePath: _diagramPath(Difficulty.logic, 'logic_5.png'),
      expression: 'A __XOR B __AND C',
      answers: ['XOR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_6',
      imagePath: _diagramPath(Difficulty.logic, 'logic_6.png'),
      expression: 'A __AND B __XOR C',
      answers: ['AND', 'XOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_7',
      imagePath: _diagramPath(Difficulty.logic, 'logic_7.png'),
      expression: '__NOT A __OR __NOT B',
      answers: ['NOT', 'OR', 'NOT'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_8',
      imagePath: _diagramPath(Difficulty.logic, 'logic_8.png'),
      expression: '__NOT A __AND __NOT B',
      answers: ['NOT', 'AND', 'NOT'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_9',
      imagePath: _diagramPath(Difficulty.logic, 'logic_9.png'),
      expression: '(A __AND B) __OR (A __AND C)',
      answers: ['AND', 'OR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_10',
      imagePath: _diagramPath(Difficulty.logic, 'logic_10.png'),
      expression: '(A __OR B) __AND (A __OR C)',
      answers: ['OR', 'AND', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_11',
      imagePath: _diagramPath(Difficulty.logic, 'logic_11.png'),
      expression: '__NOT(A __XOR B)',
      answers: ['NOT', 'XOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_12',
      imagePath: _diagramPath(Difficulty.logic, 'logic_12.png'),
      expression: 'A __XNOR B',
      answers: ['XNOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_13',
      imagePath: _diagramPath(Difficulty.logic, 'logic_13.png'),
      expression: 'A __AND (B __OR C)',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_14',
      imagePath: _diagramPath(Difficulty.logic, 'logic_14.png'),
      expression: 'A __OR (B __AND C)',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_15',
      imagePath: _diagramPath(Difficulty.logic, 'logic_15.png'),
      expression: '__NOT(A __AND B) __OR C',
      answers: ['NOT', 'AND', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_16',
      imagePath: _diagramPath(Difficulty.logic, 'logic_16.png'),
      expression: '__NOT(A __OR B) __AND C',
      answers: ['NOT', 'OR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_17',
      imagePath: _diagramPath(Difficulty.logic, 'logic_17.png'),
      expression: 'A __XOR (B __AND C)',
      answers: ['XOR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_18',
      imagePath: _diagramPath(Difficulty.logic, 'logic_18.png'),
      expression: 'A __XNOR (B __OR C)',
      answers: ['XNOR', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_19',
      imagePath: _diagramPath(Difficulty.logic, 'logic_19.png'),
      expression: '__NOT A __XOR B',
      answers: ['NOT', 'XOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_20',
      imagePath: _diagramPath(Difficulty.logic, 'logic_20.png'),
      expression: 'A __XOR __NOT B',
      answers: ['XOR', 'NOT'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_21',
      imagePath: _diagramPath(Difficulty.logic, 'logic_21.png'),
      expression: '__NOT(A __NAND B)',
      answers: ['NOT', 'NAND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_22',
      imagePath: _diagramPath(Difficulty.logic, 'logic_22.png'),
      expression: '__NOT(A __NOR B)',
      answers: ['NOT', 'NOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_23',
      imagePath: _diagramPath(Difficulty.logic, 'logic_23.png'),
      expression: '(A __NAND B) __AND C',
      answers: ['NAND', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_24',
      imagePath: _diagramPath(Difficulty.logic, 'logic_24.png'),
      expression: '(A __NOR B) __OR C',
      answers: ['NOR', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_25',
      imagePath: _diagramPath(Difficulty.logic, 'logic_25.png'),
      expression: 'A __AND __NOT(B __XOR C)',
      answers: ['AND', 'NOT', 'XOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_26',
      imagePath: _diagramPath(Difficulty.logic, 'logic_26.png'),
      expression: 'A __OR __NOT(B __XNOR C)',
      answers: ['OR', 'NOT', 'XNOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_27',
      imagePath: _diagramPath(Difficulty.logic, 'logic_27.png'),
      expression: '__NOT A __AND (B __OR C)',
      answers: ['NOT', 'AND', 'OR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_28',
      imagePath: _diagramPath(Difficulty.logic, 'logic_28.png'),
      expression: '__NOT A __OR (B __AND C)',
      answers: ['NOT', 'OR', 'AND'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_29',
      imagePath: _diagramPath(Difficulty.logic, 'logic_29.png'),
      expression: '(A __XOR B) __XNOR C',
      answers: ['XOR', 'XNOR'],
      difficulty: Difficulty.logic,
    ),
    GatekeepingQuestion(
      id: 'logic_30',
      imagePath: _diagramPath(Difficulty.logic, 'logic_30.png'),
      expression: '(A __XNOR B) __XOR C',
      answers: ['XNOR', 'XOR'],
      difficulty: Difficulty.logic,
    ),

    // =========================
    // MANIC
    // =========================
    GatekeepingQuestion(
      id: 'manic_1',
      imagePath: _diagramPath(Difficulty.manic, 'manic_1.png'),
      expression: '¬A __AND ¬B',
      answers: ['AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_2',
      imagePath: _diagramPath(Difficulty.manic, 'manic_2.png'),
      expression: 'C __AND (A __XOR B)',
      answers: ['AND', 'XOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_3',
      imagePath: _diagramPath(Difficulty.manic, 'manic_3.png'),
      expression: '(¬A __AND ¬B) __AND (¬A __OR ¬C)',
      answers: ['AND', 'AND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_4',
      imagePath: _diagramPath(Difficulty.manic, 'manic_4.png'),
      expression: 'A __XNOR B',
      answers: ['XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_5',
      imagePath: _diagramPath(Difficulty.manic, 'manic_5.png'),
      expression: '(¬A __OR ¬B) __XOR C',
      answers: ['OR', 'XOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_6',
      imagePath: _diagramPath(Difficulty.manic, 'manic_6.png'),
      expression: '(¬A __OR ¬B) __AND (¬B __OR ¬C) __AND A',
      answers: ['OR', 'AND', 'OR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_7',
      imagePath: _diagramPath(Difficulty.manic, 'manic_7.png'),
      expression: 'A __AND B',
      answers: ['AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_8',
      imagePath: _diagramPath(Difficulty.manic, 'manic_8.png'),
      expression: '(¬A __AND ¬B) __AND (¬C __OR ¬D)',
      answers: ['AND', 'AND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_9',
      imagePath: _diagramPath(Difficulty.manic, 'manic_9.png'),
      expression: '(¬A __AND ¬B) __OR C',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_10',
      imagePath: _diagramPath(Difficulty.manic, 'manic_10.png'),
      expression: '(A __XNOR B) __AND C',
      answers: ['XNOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_11',
      imagePath: _diagramPath(Difficulty.manic, 'manic_11.png'),
      expression: '(¬A __AND ¬B) __XOR (A __XNOR C)',
      answers: ['AND', 'XOR', 'XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_12',
      imagePath: _diagramPath(Difficulty.manic, 'manic_12.png'),
      expression: 'C __XOR (¬A __AND ¬B)',
      answers: ['XOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_13',
      imagePath: _diagramPath(Difficulty.manic, 'manic_13.png'),
      expression: '¬A __OR ¬B',
      answers: ['OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_14',
      imagePath: _diagramPath(Difficulty.manic, 'manic_14.png'),
      expression: '(¬A __OR ¬B) __AND ¬C',
      answers: ['OR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_15',
      imagePath: _diagramPath(Difficulty.manic, 'manic_15.png'),
      expression: '(¬A __OR ¬B) __XOR (¬B __AND ¬C __AND A)',
      answers: ['OR', 'XOR', 'AND', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_16',
      imagePath: _diagramPath(Difficulty.manic, 'manic_16.png'),
      expression: 'A __OR B',
      answers: ['OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_17',
      imagePath: _diagramPath(Difficulty.manic, 'manic_17.png'),
      expression: 'B __XOR C',
      answers: ['XOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_18',
      imagePath: _diagramPath(Difficulty.manic, 'manic_18.png'),
      expression: 'A __OR B',
      answers: ['OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_19',
      imagePath: _diagramPath(Difficulty.manic, 'manic_19.png'),
      expression: 'A __OR __NOT B',
      answers: ['OR', 'NOT'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_20',
      imagePath: _diagramPath(Difficulty.manic, 'manic_20.png'),
      expression: '__NOT A __AND B',
      answers: ['NOT', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_21',
      imagePath: _diagramPath(Difficulty.manic, 'manic_21.png'),
      expression: 'A __AND B',
      answers: ['AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_22',
      imagePath: _diagramPath(Difficulty.manic, 'manic_22.png'),
      expression: 'A __AND (B __OR __NOT C)',
      answers: ['AND', 'OR', 'NOT'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_23',
      imagePath: _diagramPath(Difficulty.manic, 'manic_23.png'),
      expression: 'A __AND B __AND C',
      answers: ['AND', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_24',
      imagePath: _diagramPath(Difficulty.manic, 'manic_24.png'),
      expression: 'A __OR B __OR C __OR D',
      answers: ['OR', 'OR', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_25',
      imagePath: _diagramPath(Difficulty.manic, 'manic_25.png'),
      expression: 'A __AND (B __OR C)',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_26',
      imagePath: _diagramPath(Difficulty.manic, 'manic_26.png'),
      expression: 'A __AND B __AND C',
      answers: ['AND', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_27',
      imagePath: _diagramPath(Difficulty.manic, 'manic_27.png'),
      expression: 'A __OR C',
      answers: ['OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_28',
      imagePath: _diagramPath(Difficulty.manic, 'manic_28.png'),
      expression: 'A __XOR C',
      answers: ['XOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_29',
      imagePath: _diagramPath(Difficulty.manic, 'manic_29.png'),
      expression: '(A __OR B) __OR (C __AND D)',
      answers: ['OR', 'OR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_30',
      imagePath: _diagramPath(Difficulty.manic, 'manic_30.png'),
      expression: '(A __AND B) __OR C',
      answers: ['AND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_31',
      imagePath: _diagramPath(Difficulty.manic, 'manic_31.png'),
      expression: '(A __XNOR B) __OR __NOT C',
      answers: ['XNOR', 'OR', 'NOT'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_32',
      imagePath: _diagramPath(Difficulty.manic, 'manic_32.png'),
      expression: '(A __XOR B) __AND C',
      answers: ['XOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_33',
      imagePath: _diagramPath(Difficulty.manic, 'manic_33.png'),
      expression: 'A __NAND (B __OR C)',
      answers: ['NAND', 'OR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_34',
      imagePath: _diagramPath(Difficulty.manic, 'manic_34.png'),
      expression: 'A __NOR (B __AND C)',
      answers: ['NOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_35',
      imagePath: _diagramPath(Difficulty.manic, 'manic_35.png'),
      expression: '(A __XOR B) __NAND C',
      answers: ['XOR', 'NAND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_36',
      imagePath: _diagramPath(Difficulty.manic, 'manic_36.png'),
      expression: '(A __XNOR B) __NOR C',
      answers: ['XNOR', 'NOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_37',
      imagePath: _diagramPath(Difficulty.manic, 'manic_37.png'),
      expression: '(A __AND B) __XNOR C',
      answers: ['AND', 'XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_38',
      imagePath: _diagramPath(Difficulty.manic, 'manic_38.png'),
      expression: '(A __XNOR B) __OR (A __XNOR C)',
      answers: ['XNOR', 'OR', 'XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_39',
      imagePath: _diagramPath(Difficulty.manic, 'manic_39.png'),
      expression: 'A __XNOR C',
      answers: ['XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_40',
      imagePath: _diagramPath(Difficulty.manic, 'manic_40.png'),
      expression: '¬A __NAND C',
      answers: ['NAND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_41',
      imagePath: _diagramPath(Difficulty.manic, 'manic_41.png'),
      expression: '(A __XOR B) __AND (A __XOR C)',
      answers: ['XOR', 'AND', 'XOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_42',
      imagePath: _diagramPath(Difficulty.manic, 'manic_42.png'),
      expression: '(A __NAND B) __NAND (C __XNOR D)',
      answers: ['NAND', 'NAND', 'XNOR'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_43',
      imagePath: _diagramPath(Difficulty.manic, 'manic_43.png'),
      expression: 'A __NOR ¬(B __AND C)',
      answers: ['NOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_44',
      imagePath: _diagramPath(Difficulty.manic, 'manic_44.png'),
      expression: '(¬A __OR B) __XOR (C __AND D)',
      answers: ['OR', 'XOR', 'AND'],
      difficulty: Difficulty.manic,
    ),
    GatekeepingQuestion(
      id: 'manic_45',
      imagePath: _diagramPath(Difficulty.manic, 'manic_45.png'),
      expression: 'A __XNOR ((B __AND C) __OR D)',
      answers: ['XNOR', 'AND', 'OR'],
      difficulty: Difficulty.manic,
    ),

  ];

  static List<GatekeepingQuestion> getAll() {
    return List<GatekeepingQuestion>.from(_allQuestions);
  }

  static List<GatekeepingQuestion> getByDifficulty(
      Difficulty difficulty,
      ) {
    return _allQuestions
        .where((question) => question.difficulty == difficulty)
        .toList();
  }

  static List<GatekeepingQuestion> getShuffledByDifficulty(
      Difficulty difficulty,
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