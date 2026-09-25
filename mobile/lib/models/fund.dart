class Fund {
  final String id;
  final String name;
  final String category;
  final double threeYearReturn;
  final double expenseRatio;
  final String riskLevel;

  const Fund({
    required this.id,
    required this.name,
    required this.category,
    required this.threeYearReturn,
    required this.expenseRatio,
    required this.riskLevel,
  });

  factory Fund.fromJson(Map<String, dynamic> json) {
    return Fund(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      threeYearReturn: (json['threeYearReturn'] as num).toDouble(),
      expenseRatio: (json['expenseRatio'] as num).toDouble(),
      riskLevel: json['riskLevel'] as String,
    );
  }
}
