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
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Column(
                  key: ValueKey(loading),
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AutoSizeText(
                      'Currency Rate Calculator',
                      maxLines: 1,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    if (!hasAuth)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: const [
                            Icon(Icons.info_outline, size: 18),
                            SizedBox(width: 6),
                            Expanded(child: Text('Firebase not configured. Form is disabled.')),
                          ],
                        ),
                      ),
                    const SizedBox(height: 16),
                    _Shake(
                      controller: _shake,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _email,
                            decoration: const InputDecoration(labelText: 'Email'),
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => (v == null || v.isEmpty || !v.contains('@'))
                                ? 'Enter a valid email'
                                : null,
                            enabled: hasAuth && !loading,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _password,
                            decoration: const InputDecoration(labelText: 'Password'),
                            obscureText: true,
                            validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                            enabled: hasAuth && !loading,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: (!hasAuth || loading) ? null : _submit,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: (loading)
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_isLogin ? 'Login' : 'Register'),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: (!hasAuth || loading)
                          ? null
                          : () => setState(() => _isLogin = !_isLogin),
                      child: Text(_isLogin ? 'No account? Register' : 'Have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: hasAuth
          ? BlocConsumer<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state.error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.error!)));
                }
                if (state.user != null) {
                  context.go(AppRouter.homeRoute);
                }
              },
              builder: (context, state) => contentWithState(state),
            )
          : contentWithState(null),
    );
  }
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
