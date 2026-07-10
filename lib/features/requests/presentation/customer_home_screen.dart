import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_service_card.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../notifications/presentation/notification_bell.dart';
import 'create_request_screen.dart';
import 'request_detail_screen.dart';
import 'request_providers.dart';
import 'request_status_label.dart';

class CustomerHomeScreen extends ConsumerWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestsAsync = ref.watch(myRequestsProvider);
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: const Text('Taleplerim'),
        actions: [
          const NotificationBell(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(myRequestsProvider),
        child: requestsAsync.when(
          data: (requests) {
            if (requests.isEmpty) {
              return ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Henüz bir talebin yok.',
                        style: TextStyle(
                          color: GlassColors.textSecondary(brightness),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final request = requests[index];
                return GlassServiceCard(
                  eyebrow: request.category,
                  accentColor: serviceRequestStatusColor(request.status),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RequestDetailScreen(requestId: request.id),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              request.title,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              request.neighborhood,
                              style: TextStyle(
                                color: GlassColors.textSecondary(brightness),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        serviceRequestStatusLabel(request.status),
                        style: TextStyle(
                          color: serviceRequestStatusColor(request.status),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(child: Text('Hata: $error')),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CreateRequestScreen()),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Talep'),
      ),
    );
  }
}
