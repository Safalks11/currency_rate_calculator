class ConversionResult {
  final String base;
  final double amount;
  final Map<String, double> result;
  final double? rate;
  final int? ms;

  const ConversionResult({
    required this.base,
    required this.amount,
    required this.result,
    this.rate,
    this.ms,
  });

  double get targetValue => result.values.isNotEmpty ? result.values.first : 0.0;

  factory ConversionResult.fromMap(Map<String, dynamic> map) {
    final res = map['result'] as Map<String, dynamic>? ?? const {};
    return ConversionResult(
      base: (map['base'] as String?) ?? '',
      amount: double.tryParse((map['amount'] ?? '0').toString()) ?? 0,
      result: res.map((k, v) => MapEntry(k, (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0)),
      rate: (res['rate'] is num) ? (res['rate'] as num).toDouble() : double.tryParse('${res['rate']}'),
      ms: (map['ms'] is num) ? (map['ms'] as num).toInt() : int.tryParse('${map['ms']}'),
    );
  }
}
