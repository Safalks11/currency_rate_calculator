import 'package:dio/dio.dart';
import '../../../core/storage/cache_service.dart';
import '../domain/entities/conversion_result.dart';
import '../domain/repositories/currency_repository.dart' as domain;

class CurrencyRepositoryImpl implements domain.CurrencyRepository {
  final Dio dio;
  final CacheService cache;

  CurrencyRepositoryImpl({required this.dio, required this.cache});

  static const _cacheKey = 'last_convert_result_v1';

  @override
  Future<ConversionResult> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    final qp = {'from': from, 'to': to, 'amount': amount};
    try {
      final res = await dio.get('/convert', queryParameters: qp);
      final data = res.data as Map<String, dynamic>;
      await cache.writeJson(_cacheKey, data);
      return ConversionResult.fromMap(data);
    } on DioException {
      final cached = await cache.readJson(_cacheKey);
      if (cached != null) return ConversionResult.fromMap(cached);
      rethrow;
    }
  }
}
