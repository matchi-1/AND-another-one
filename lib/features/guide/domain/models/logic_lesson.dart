class LogicLesson {
  final String id;
  final String title;
  final String formulas;
  final String explanation;

  LogicLesson({
    required this.id,
    required this.title,
    required this.formulas,
    required this.explanation,
  });
}

class LogicLessonData {
  static final List<LogicLesson> lessons = [
    LogicLesson(
      id: 'double_negation',
      title: 'Double Negation',
      formulas: '~(~A) • ~(~B)\n\nA • B',
      explanation: 'Two NOT gates cancel out each other',
    ),
    LogicLesson(
      id: 'idempotent_law',
      title: 'Idempotent Law',
      formulas: '(A • B) • (A • B)\n\nA • B',
      explanation: 'Two identical things is equal to the same thing',
    ),
    LogicLesson(
      id: 'absorption_law',
      title: 'Absorption Law',
      formulas: 'A + (A • B)\n\nA',
      explanation: 'A simpler term absorbs the complex term into itself',
    ),
    LogicLesson(
      id: 'distributive_associative',
      title: 'Distributive / Associative Simplification',
      formulas: '(A • B) • C = A • (B • C)\n(A + B) + C = A + (B + C)',
      explanation: 'Order of operation doesn\'t change the result',
    ),
    LogicLesson(
      id: 'demorgans_law',
      title: 'De Morgan\'s Law',
      formulas: '~(A • B) = ~A + ~B\n\n~(A + B) = ~A • ~B',
      explanation: 'Adding/Removing a NOT gate flips the operation, AND becomes OR, vice versa.',
    ),
    LogicLesson(
      id: 'symbol_names',
      title: 'SYMBOL NAMES',
      formulas: '',
      explanation: '',
    ),
  ];
}
