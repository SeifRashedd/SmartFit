import 'package:bloc/bloc.dart';
import 'package:smartfit/features/auth/service/auth_service.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthInitial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(SignInLoading());

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(SignInSuccess());
    } catch (e) {
      emit(SignInFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(SignUpLoading());

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    emit(AuthInitial());
  }
}