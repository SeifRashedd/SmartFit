part of 'auth_cubit.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

class SignInSuccess extends AuthState {}

class SignInFailure extends AuthState {
  final String errorMessage;

  SignInFailure({required this.errorMessage});
}

class SignInLoading extends AuthState {}

class SignInCustomError extends AuthState {
  final String errorMessage;

  SignInCustomError({required this.errorMessage});
}

class SignUpSuccess extends AuthState {}

class SignUpFailure extends AuthState {
  final String errorMessage;

  SignUpFailure({required this.errorMessage});
}

class SignUpLoading extends AuthState {}
