import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'core/di/injection.dart';
import 'core/router/app_route.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await initDependencies();
  } catch (e, st) {
    debugPrint('Initialization error: $e\n$st');
    rethrow;
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final material = MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Currency Rate Calculator',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      routerConfig: AppRouter.router,
      builder: (context, child) => child ?? const SizedBox.shrink(),
    );

    return MultiBlocProvider(
      providers: [BlocProvider<AuthCubit>(create: (_) => AuthCubit(sl<AuthRepository>()))],
      child: material,
    );
  }
}
