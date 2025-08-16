import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class WatchAuthState {
  final AuthRepository repository;
  const WatchAuthState(this.repository);

  Stream<User?> call() => repository.authStateChanges();
}
