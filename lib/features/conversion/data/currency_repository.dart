import 'package:dio/dio.dart';
import '../../../core/storage/cache_service.dart';

class CurrencyRepository {
  final Dio dio;
  final CacheService cache;

  CurrencyRepository({required this.dio, required this.cache});

  static const _cacheKey = 'last_convert_result_v1';

  Future<Map<String, dynamic>> convert({
    required String from,
    required String to,
    required double amount,
  }) async {
    final qp = {'from': from, 'to': to, 'amount': amount};
    try {
      final res = await dio.get('/convert', queryParameters: qp);
      final data = res.data as Map<String, dynamic>;
      await cache.writeJson(_cacheKey, data);
      return data;
    } on DioException catch (e) {
      final cached = await cache.readJson(_cacheKey);
      if (cached != null) return cached;
      rethrow;
    }
  }
}
