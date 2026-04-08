enum GatekeepingDifficulty {
  basic,
  logic,
  manic,
}

class GatekeepingQuestion {
  final String id;
  final String imagePath;
  final String expression;
  final List<String> answers;
  final GatekeepingDifficulty difficulty;

  const GatekeepingQuestion({
    required this.id,
    required this.imagePath,
    required this.expression,
    required this.answers,
    required this.difficulty,
  });

  int get blankCount => answers.length;
}