import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/auth_repository.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repo;
  StreamSubscription<User?>? _sub;

  AuthCubit(this._repo) : super(const AuthState.unknown()) {
    _sub = _repo.authStateChanges().listen((user) {
      if (user == null) {
        emit(const AuthState.unauthenticated());
      } else {
        emit(AuthState.authenticated(user));
      }
    });
  }

  Future<void> signIn(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repo.signIn(email: email, password: password);
      final u = _repo.currentUser;
      if (u != null) emit(AuthState.authenticated(u));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Auth error'));
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signUp(String email, String password) async {
    emit(const AuthState.loading());
    try {
      await _repo.signUp(email: email, password: password);
      final u = _repo.currentUser;
      if (u != null) emit(AuthState.authenticated(u));
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Auth error'));
      emit(const AuthState.unauthenticated());
    } catch (e) {
      emit(AuthState.error(e.toString()));
      emit(const AuthState.unauthenticated());
    }
  }

  Future<void> signOut() async {
    emit(const AuthState.loading());
    try {
      await _repo.signOut();
      emit(const AuthState.unauthenticated());
    } on FirebaseAuthException catch (e) {
      emit(AuthState.error(e.message ?? 'Sign out failed'));
      final u = _repo.currentUser;
      if (u != null) {
        emit(AuthState.authenticated(u));
      } else {
        emit(const AuthState.unauthenticated());
      }
    } catch (e) {
      emit(AuthState.error(e.toString()));
      final u = _repo.currentUser;
      if (u != null) {
        emit(AuthState.authenticated(u));
      } else {
        emit(const AuthState.unauthenticated());
      }
    }
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
