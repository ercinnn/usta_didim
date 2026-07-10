import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/glass_theme.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  // Push notifications are optional: until the Firebase project for this app
  // exists and firebase_options.dart is generated (see CLAUDE.md / plan),
  // this throws and is swallowed on purpose -- in-app notifications keep
  // working via Supabase realtime regardless of Firebase being configured.
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // Firebase not configured yet.
  }

  runApp(const ProviderScope(child: UstaDidimApp()));
}

SupabaseClient get supabase => Supabase.instance.client;

class UstaDidimApp extends StatelessWidget {
  const UstaDidimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Didim Usta',
      theme: GlassTheme.light(),
      darkTheme: GlassTheme.dark(),
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}
