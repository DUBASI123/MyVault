import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the global Supabase client.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;
  static Session? get currentSession => client.auth.currentSession;

  static bool get isLoggedIn => currentSession != null;

  static bool get isAvailable => true;

  static Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) =>
      client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: '',   // empty = skip email confirmation; user can log in immediately
      );

  static Future<void> signOut() => client.auth.signOut();
}
