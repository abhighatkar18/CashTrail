class FinanceTransaction {
  const FinanceTransaction({
    this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.note = '',
  });

  final int? id;
  final String title;
  final double amount;
  final String type;
  final String category;
  final DateTime date;
  final String paymentMethod;
  final String note;

  bool get isIncome => type == 'income';

  Map<String, Object?> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date.toIso8601String(),
      'payment_method': paymentMethod,
      'note': note,
    };
  }

  factory FinanceTransaction.fromMap(
      Map<String, Object?> map) {
    return FinanceTransaction(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      type: map['type'] as String,
      category: map['category'] as String,
      date: DateTime.parse(map['date'] as String),
      paymentMethod: map['payment_method'] as String,
      note: (map['note'] as String?) ?? '',
    );
  }
}