import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import '../domain/repositories/auth_repository.dart' as domain;

class AuthRepositoryImpl implements domain.AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  @override
  User? get currentUser => _auth.currentUser;

  @override
  Future<UserCredential> signIn({required String email, required String password}) async {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<UserCredential> signUp({required String email, required String password}) async {
    return _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _auth.signOut();
}
