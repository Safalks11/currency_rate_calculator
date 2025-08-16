import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class SignIn {
  final AuthRepository repository;
  const SignIn(this.repository);

  Future<UserCredential> call({required String email, required String password}) {
    return repository.signIn(email: email, password: password);
  }
}
