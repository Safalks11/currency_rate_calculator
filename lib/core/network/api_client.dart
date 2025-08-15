import 'package:dio/dio.dart';
import 'dart:async';

class ApiClient {
  static Dio buildDio({
    required String? baseUrl,
    required String? accessKey,
    int retryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final qp = Map<String, dynamic>.from(options.queryParameters);
          if (!qp.containsKey('access_key')) {
            qp['access_key'] = accessKey;
          }
          options.queryParameters = qp;
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException err, handler) async {
          if (_shouldRetry(err)) {
            int attempt = err.requestOptions.extra["retryAttempt"] ?? 0;
            if (attempt < retryCount) {
              attempt++;
              err.requestOptions.extra["retryAttempt"] = attempt;

              await Future.delayed(retryDelay);

              try {
                final response = await dio.fetch(err.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(err);
              }
            }
          }
          return handler.next(err);
        },
      ),
    );
    return dio;
  }

  static bool _shouldRetry(DioException err) {
    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}
