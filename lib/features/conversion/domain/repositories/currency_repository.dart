import '../entities/conversion_result.dart';

abstract class CurrencyRepository {
  Future<ConversionResult> convert({required String from, required String to, required double amount});
}
