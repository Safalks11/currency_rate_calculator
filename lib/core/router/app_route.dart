import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/conversion/presentation/screens/home_screen.dart';

class AppRouter {
  static const String splashRoute = '/';
  static const String loginRoute = '/login';
  static const String homeRoute = '/home';

  static final GoRouter router = GoRouter(
    initialLocation: splashRoute,
    routes: [
      GoRoute(path: splashRoute, name: 'splash', builder: (context, state) => const SplashScreen()),
      GoRoute(path: loginRoute, name: 'login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: homeRoute, name: 'home', builder: (context, state) => const HomeScreen()),
    ],
  );
}
