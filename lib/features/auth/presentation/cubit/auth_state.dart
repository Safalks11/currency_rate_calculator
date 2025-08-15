part of 'auth_cubit.dart';

class AuthState extends Equatable {
  final bool loading;
  final User? user;
  final String? error;
  final bool unknown;

  const AuthState({required this.loading, required this.user, required this.error, required this.unknown});

  const AuthState.unknown() : this(loading: false, user: null, error: null, unknown: true);
  const AuthState.loading() : this(loading: true, user: null, error: null, unknown: false);
  const AuthState.unauthenticated() : this(loading: false, user: null, error: null, unknown: false);
  const AuthState.error(String e) : this(loading: false, user: null, error: e, unknown: false);
  const AuthState.authenticated(User u) : this(loading: false, user: u, error: null, unknown: false);

  @override
  List<Object?> get props => [loading, user?.uid, error, unknown];
}
