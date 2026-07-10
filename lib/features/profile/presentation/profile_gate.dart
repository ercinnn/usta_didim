import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/domain/app_role.dart';
import '../../notifications/presentation/notification_providers.dart';
import '../../offers/presentation/provider_home_screen.dart';
import '../../requests/presentation/customer_home_screen.dart';
import 'profile_providers.dart';
import 'provider_profile_screen.dart';

class ProfileGate extends ConsumerWidget {
  const ProfileGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    ref.listen(currentProfileProvider, (previous, next) {
      final profile = next.value;
      if (profile != null && previous?.value?.id != profile.id) {
        ref.read(pushTokenRepositoryProvider).registerCurrentDevice(profile.id);
      }
    });

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
    return GlassScaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: TextStyle(
                  color: GlassColors.textSecondary(Theme.of(context).brightness),
                ),
              ),
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
    return GlassScaffold(
      body: Center(
        child: GlassContainer(
          child: Text(
            'Hata: $message',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: GlassColors.textPrimary(Theme.of(context).brightness),
            ),
          ),
        ),
      ),
    );
  }
}
