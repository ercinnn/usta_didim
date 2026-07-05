import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/domain/app_role.dart';
import '../../offers/presentation/provider_home_screen.dart';
import '../../requests/presentation/customer_home_screen.dart';
import 'profile_providers.dart';
import 'provider_profile_screen.dart';

class ProfileGate extends ConsumerWidget {
  const ProfileGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          return const _CenteredLoader(message: 'Profil hazırlanıyor...');
        }
        if (profile.role == AppRole.provider) {
          return const _ProviderGate();
        }
        return const CustomerHomeScreen();
      },
      loading: () => const _CenteredLoader(),
      error: (error, _) => _CenteredError(message: '$error'),
    );
  }
}

class _ProviderGate extends ConsumerWidget {
  const _ProviderGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerProfileAsync = ref.watch(currentProviderProfileProvider);

    return providerProfileAsync.when(
      data: (providerProfile) {
        if (providerProfile == null) {
          return const ProviderProfileScreen();
        }
        return const ProviderHomeScreen();
      },
      loading: () => const _CenteredLoader(),
      error: (error, _) => _CenteredError(message: '$error'),
    );
  }
}

class _CenteredLoader extends StatelessWidget {
  const _CenteredLoader({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(message!),
            ],
          ],
        ),
      ),
    );
  }
}

class _CenteredError extends StatelessWidget {
  const _CenteredError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Hata: $message')));
  }
}
