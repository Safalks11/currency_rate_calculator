import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => ApiClient.buildDio(baseUrl: AppConfig.baseUrl, accessKey: AppConfig.accessKey),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository());
}
