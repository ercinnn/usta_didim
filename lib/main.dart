import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.publishableKey,
  );

  runApp(const ProviderScope(child: UstaDidimApp()));
}

SupabaseClient get supabase => Supabase.instance.client;

class UstaDidimApp extends StatelessWidget {
  const UstaDidimApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Didim Usta',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
