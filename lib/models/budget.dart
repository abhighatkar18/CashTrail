class Budget {
  const Budget({
    this.id,
    required this.category,
    required this.amount,
    required this.month,
  });

  final int? id;
  final String category;
  final double amount;
  final String month;

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'amount': amount,
      'month': month,
    };
  }

  factory Budget.fromMap(Map<String, Object?> map) {
    return Budget(
      id: map['id'] as int?,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      month: map['month'] as String,
    );
  }
}