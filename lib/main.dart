import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/router/app_route.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {}
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

    return material;
  }
}
