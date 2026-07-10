import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../profile/presentation/profile_gate.dart';
import 'auth_providers.dart';
import 'login_screen.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return authState.when(
      data: (state) {
        if (state.session == null) {
          return const LoginScreen();
        }
        return const ProfileGate();
      },
      loading: () => const GlassScaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => GlassScaffold(
        body: Center(
          child: GlassContainer(
            child: Text(
              'Hata: $error',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: GlassColors.textPrimary(Theme.of(context).brightness),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
