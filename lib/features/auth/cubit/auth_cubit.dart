import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartfit/features/auth/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService = AuthService();

  AuthCubit() : super(AuthInitial());

  Future<void> signIn({required String email, required String password}) async {
    emit(SignInLoading());

    try {
      await _authService.signInWithEmailAndPassword(email: email, password: password);

      await _saveSession();

      emit(SignInSuccess());
    } catch (e) {
      emit(SignInFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    emit(SignUpLoading());

    try {
      await _authService.signUpWithEmailAndPassword(email: email, password: password);

      await _saveSession();

      emit(SignUpSuccess());
    } catch (e) {
      emit(SignUpFailure(errorMessage: e.toString()));
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');

    emit(AuthInitial());
  }

  Future<void> _saveSession() async {
    final session = Supabase.instance.client.auth.currentSession;

    if (session != null) {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('access_token', session.accessToken);
      if (session.refreshToken != null) {
        await prefs.setString('refresh_token', session.refreshToken!);
      }
    }
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }
}
