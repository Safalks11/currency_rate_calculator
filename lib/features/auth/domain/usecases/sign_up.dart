import 'package:firebase_auth/firebase_auth.dart';
import '../repositories/auth_repository.dart';

class SignUp {
  final AuthRepository repository;
  const SignUp(this.repository);

  Future<UserCredential> call({required String email, required String password}) {
    return repository.signUp(email: email, password: password);
  }
}
