import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Registers this device's FCM token against the signed-in user so the
/// send-push-notification Edge Function (supabase/functions/) knows where to
/// push. Only wired up for Android + web, matching the platforms this app is
/// actually distributed to per CLAUDE.md (APK build, GitHub Pages).
class PushTokenRepository {
  const PushTokenRepository(this._client);

  final SupabaseClient _client;

  // Web push requires a VAPID key from the Firebase project's Cloud
  // Messaging settings; pass it at build time once that project exists, e.g.
  // `flutter build web --dart-define=FCM_VAPID_KEY=...`.
  static const _webVapidKey = String.fromEnvironment('FCM_VAPID_KEY');

  Future<void> registerCurrentDevice(String userId) async {
    if (!kIsWeb && defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    final messaging = FirebaseMessaging.instance;
    final settings = await messaging.requestPermission();
    final authorized = settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
    if (!authorized) return;

    final token = kIsWeb
        ? await messaging.getToken(vapidKey: _webVapidKey)
        : await messaging.getToken();
    if (token == null) return;

    await _client.from('device_tokens').upsert(
      {
        'user_id': userId,
        'token': token,
        'platform': kIsWeb ? 'web' : 'android',
      },
      onConflict: 'token',
    );
  }
}
