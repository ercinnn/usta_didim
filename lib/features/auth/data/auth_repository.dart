import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Deep link Supabase redirects back into the app after completing the
/// Google OAuth flow. Must also be registered in the Supabase Dashboard
/// under Authentication > URL Configuration > Redirect URLs, and matches
/// the intent-filter scheme declared in AndroidManifest.xml.
const _googleRedirectUrl = 'io.supabase.ustadidim://login-callback/';

class AuthRepository {
  const AuthRepository(this._client);

  final SupabaseClient _client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) {
    return _client.auth.signUp(email: email, password: password);
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  /// Kicks off the browser-based Google OAuth flow. On web this redirects
  /// the current tab; the resulting session is picked up automatically by
  /// [authStateChanges] once Supabase completes the callback. On Android it
  /// opens an external browser tab and returns via [_googleRedirectUrl].
  ///
  /// On web, `redirectTo` is derived from the page's own URL rather than
  /// left null, because a null value falls back to the Supabase project's
  /// dashboard-configured Site URL -- which only matches one environment
  /// (e.g. production) and breaks local/dev testing on any other origin.
  Future<bool> signInWithGoogle() {
    return _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? _webRedirectUrl() : _googleRedirectUrl,
    );
  }

  String _webRedirectUrl() {
    final uri = Uri.base;
    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.port,
      path: uri.path,
    ).toString();
  }

  Future<void> signOut() => _client.auth.signOut();
}
