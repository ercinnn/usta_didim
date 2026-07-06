import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../../profile/presentation/profile_providers.dart';
import '../../profile/presentation/provider_profile_screen.dart';
import 'job_pool_tab.dart';
import 'my_active_jobs_screen.dart';

class ProviderHomeScreen extends ConsumerWidget {
  const ProviderHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerProfile = ref.watch(currentProviderProfileProvider).value;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Usta Paneli'),
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              tooltip: 'Profilim',
              onPressed: providerProfile == null
                  ? null
                  : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ProviderProfileScreen(
                            existingProfile: providerProfile,
                          ),
                        ),
                      ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () => ref.read(authRepositoryProvider).signOut(),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'İlan Havuzu'),
              Tab(text: 'Aktif İşlerim'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            JobPoolTab(),
            MyActiveJobsTab(),
          ],
        ),
      ),
    );
  }
}
