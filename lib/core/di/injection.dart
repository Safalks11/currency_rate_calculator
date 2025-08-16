import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/repositories/auth_repository.dart' as auth_domain;
import '../../features/auth/domain/usecases/sign_in.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/sign_out.dart';
import '../../features/auth/domain/usecases/watch_auth_state.dart';
import '../../features/conversion/data/currency_repository.dart';
import '../../features/conversion/domain/repositories/currency_repository.dart' as domain;
import '../../features/conversion/domain/usecases/convert_currency.dart';
import '../config/app_config.dart';
import '../network/api_client.dart';
import '../storage/cache_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<Dio>(
    () => ApiClient.buildDio(baseUrl: AppConfig.baseUrl, accessKey: AppConfig.accessKey),
  );
  sl.registerLazySingleton<auth_domain.AuthRepository>(() => AuthRepositoryImpl());
  sl.registerLazySingleton<SignIn>(() => SignIn(sl<auth_domain.AuthRepository>()));
  sl.registerLazySingleton<SignUp>(() => SignUp(sl<auth_domain.AuthRepository>()));
  sl.registerLazySingleton<SignOut>(() => SignOut(sl<auth_domain.AuthRepository>()));
  sl.registerLazySingleton<WatchAuthState>(() => WatchAuthState(sl<auth_domain.AuthRepository>()));
  sl.registerLazySingleton<CacheService>(() => CacheService());
  sl.registerLazySingleton<domain.CurrencyRepository>(
    () => CurrencyRepositoryImpl(dio: sl<Dio>(), cache: sl<CacheService>()),
  );
  sl.registerLazySingleton<ConvertCurrency>(() => ConvertCurrency(sl<domain.CurrencyRepository>()));
}
