part of 'auth_cubit.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAdmin extends AuthState {}

class AuthSuccess extends AuthState {
  final String message;
  final String userId;

  AuthSuccess(this.message, this.userId);
}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure(this.error);
}
