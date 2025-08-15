import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => ApiClient.buildDio(baseUrl: AppConfig.baseUrl, accessKey: AppConfig.accessKey),
  );
}
