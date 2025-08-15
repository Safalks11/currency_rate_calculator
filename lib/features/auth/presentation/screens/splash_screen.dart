import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_route.dart';
import '../cubit/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  StreamSubscription<AuthState>? _sub;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);

    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      final cubit = context.read<AuthCubit>();

      void navigate(AuthState s) {
        if (!mounted) return;
        if (s.unknown || s.loading) return;
        if (s.user != null) {
          context.go(AppRouter.homeRoute);
        } else {
          context.go(AppRouter.loginRoute);
        }
      }

      final current = cubit.state;
      if (!current.unknown && !current.loading) {
        navigate(current);
        return;
      }
      _sub = cubit.stream.listen((s) {
        if (!s.unknown && !s.loading) {
          navigate(s);
          _sub?.cancel();
          _sub = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.primary.withValues(alpha: 0.12 + _controller.value * 0.05),
                  color.secondary.withValues(alpha: 0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.primary.withValues(alpha: 0.15),
                    ),
                    child: Icon(Icons.currency_exchange_rounded, size: 60, color: color.primary),
                  ),
                  const SizedBox(height: 20),

                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 700),
                    builder: (context, value, child) => Opacity(opacity: value, child: child),
                    child: Text(
                      'Currency Rate Calculator',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    builder: (context, value, child) => Opacity(opacity: value, child: child),
                    child: Text(
                      'Fast • Accurate • Global',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: color.primary.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(color.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
