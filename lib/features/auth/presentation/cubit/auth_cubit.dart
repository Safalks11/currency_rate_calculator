import 'dart:async';

import 'package:currency_rate_calculator/core/router/app_route.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/repositories/auth_repository.dart' as domain;
import '../../domain/usecases/sign_in.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/sign_up.dart';
import '../../domain/usecases/watch_auth_state.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SignIn _signIn;
  final SignUp _signUp;
  final SignOut _signOut;
  final WatchAuthState _watchAuth;
  final domain.AuthRepository _repo;
  StreamSubscription<User?>? _sub;

  AuthCubit(this._signIn, this._signUp, this._signOut, this._watchAuth, this._repo)
    : super(const AuthState.unknown()) {
    _sub = _watchAuth().listen((user) {
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
      await _signIn(email: email, password: password);
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
      await _signUp(email: email, password: password);
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
      await _signOut();
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
