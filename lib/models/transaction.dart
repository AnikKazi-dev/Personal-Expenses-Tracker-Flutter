final String tableTransactions = "transactions";

class TransactionFields {
  static final List<String> values = [
    id,
    title,
    amount,
    date,
  ];

  static final String id = "_id";
  static final String title = "title";
  static final String amount = "amount";
  static final String date = "date";
}

class Transaction {
  final int? id;
  final String title;
  final double amount;
  final DateTime date;

  const Transaction({
    this.id,
    required this.title,
    required this.amount,
    required this.date,
  });

  Transaction copy({
    int? id,
    String? title,
    double? amount,
    DateTime? date,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  static Transaction fromJson(Map<String, Object?> json) => Transaction(
        id: json[TransactionFields.id] as int?,
        title: json[TransactionFields.title] as String,
        amount: double.parse(json[TransactionFields.amount] as String),
        date: DateTime.parse(json[TransactionFields.date] as String),
      );

  get length => null;

  Map<String, Object?> toJson() => {
        TransactionFields.id: id,
        TransactionFields.title: title,
        TransactionFields.amount: amount,
        TransactionFields.date: date.toIso8601String(),
      };
}
