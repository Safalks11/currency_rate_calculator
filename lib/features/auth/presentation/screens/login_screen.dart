import 'dart:ui';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_route.dart';
import '../cubit/auth_cubit.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  late final AnimationController _shake;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _shake.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      _shake.forward(from: 0);
      return;
    }
    if (_isLogin) {
      context.read<AuthCubit>().signIn(_email.text.trim(), _password.text.trim());
    } else {
      context.read<AuthCubit>().signUp(_email.text.trim(), _password.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasAuth = true;
    try {
      context.read<AuthCubit>();
    } catch (_) {
      hasAuth = false;
    }

    Widget contentWithState(AuthState? state) {
      final loading = state?.loading ?? false;

      return Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Icon(
                            _isLogin
                                ? Icons.currency_exchange_rounded
                                : Icons.person_add_alt_1_rounded,
                            key: ValueKey(_isLogin), // ensures AnimatedSwitcher runs
                            size: 64,
                            color: _isLogin
                                ? Theme.of(context).colorScheme.primary
                                : Colors.tealAccent,
                          ),
                        ),

                        const SizedBox(height: 16),
                        AutoSizeText(
                          'Currency Rate Calculator',
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _isLogin
                              ? 'Welcome back! Please log in to continue.'
                              : 'Create your account to get started.',
                          textAlign: TextAlign.center,
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 28),

                        _Shake(
                          controller: _shake,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _email,
                                decoration: _modernInputDecoration('Email', Icons.email_outlined),
                                style: const TextStyle(color: Colors.white),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
                                enabled: hasAuth && !loading,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _password,
                                decoration: _modernInputDecoration('Password', Icons.lock_outline),
                                style: const TextStyle(color: Colors.white),
                                obscureText: true,
                                validator: (v) =>
                                    (v == null || v.length < 6) ? 'Min 6 chars' : null,
                                enabled: hasAuth && !loading,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: (!hasAuth || loading) ? null : _submit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: (loading)
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(_isLogin ? 'Login' : 'Register'),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: (!hasAuth || loading)
                              ? null
                              : () => setState(() => _isLogin = !_isLogin),
                          child: Text(
                            _isLogin ? 'No account? Register' : 'Have an account? Login',
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0f2027), Color(0xFF203a43), Color(0xFF2c5364)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: hasAuth
                ? BlocConsumer<AuthCubit, AuthState>(
                    listener: (context, state) {
                      if (state.error != null) {
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(SnackBar(content: Text(state.error!)));
                      }
                      if (state.user != null) {
                        context.go(AppRouter.homeRoute);
                      }
                    },
                    builder: (context, state) => contentWithState(state),
                  )
                : contentWithState(null),
          ),
        ],
      ),
    );
  }
}

InputDecoration _modernInputDecoration(String label, IconData icon) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white70),
    prefixIcon: Icon(icon, color: Colors.white70),
    filled: true,
    fillColor: Colors.white.withValues(alpha: 0.1),
    errorStyle: TextStyle(color: Colors.red),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide.none,
    ),
  );
}

class _Shake extends StatelessWidget {
  final Widget child;
  final AnimationController controller;
  const _Shake({required this.child, required this.controller});

  @override
  Widget build(BuildContext context) {
    final offset = Tween(
      begin: 0.0,
      end: 8.0,
    ).chain(CurveTween(curve: Curves.elasticIn)).animate(controller);
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Transform.translate(
        offset: Offset(controller.isAnimating ? offset.value : 0, 0),
        child: child,
      ),
    );
  }
}
