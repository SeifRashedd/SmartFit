import 'dart:developer';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      log('User signed in: ${response.user?.email}');
    } on AuthApiException catch (e) {
      log('Auth error: ${e.message}');

      throw _mapAuthError(e);
    } catch (e) {
      log('Unknown error: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      log('User signed up: ${response.user?.email}');
    } on AuthApiException catch (e) {
      log('Auth error: ${e.message}');
      throw _mapAuthError(e);
    } catch (e) {
      log('Unknown error: $e');
      throw 'Something went wrong. Please try again.';
    }
  }

  String _mapAuthError(AuthApiException e) {
    switch (e.code) {
      case 'invalid_credentials':
        return 'Email or password is incorrect';

      case 'email_not_confirmed':
        return 'Please verify your email first';

      case 'user_not_found':
        return 'No account found with this email';

      case 'email_address_invalid':
        return 'Invalid email format';

      case 'weak_password':
        return 'Password should be at least 6 characters';

      case 'email_exists':
        return 'This email is already registered';

      default:
        return 'An unknown error occurred';
    }
  }

  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      log('User signed out');
    } catch (e) {
      log('Sign out error: $e');
      throw 'Failed to sign out. Please try again.';
    }
  }
}