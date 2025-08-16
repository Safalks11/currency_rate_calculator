import '../entities/conversion_result.dart';
import '../repositories/currency_repository.dart';

class ConvertCurrency {
  final CurrencyRepository repository;
  const ConvertCurrency(this.repository);

  Future<ConversionResult> call({required String from, required String to, required double amount}) {
    return repository.convert(from: from, to: to, amount: amount);
  }
}
