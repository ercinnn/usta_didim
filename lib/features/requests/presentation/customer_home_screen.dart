import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
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
            tooltip: 'Çıkış Yap',
            onPressed: () => _confirmSignOut(context, ref),
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
                    padding: const EdgeInsets.all(GlassSpacing.xl),
                    child: Column(
                      children: [
                        const SizedBox(height: GlassSpacing.xxl),
                        Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: GlassColors.textSecondary(brightness),
                        ),
                        const SizedBox(height: GlassSpacing.md),
                        Text(
                          'Henüz bir talebin yok.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: GlassSpacing.xs),
                        Text(
                          '“Yeni Talep” butonuna dokunarak ilk talebini oluştur.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: GlassSpacing.sm),
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
                              style: Theme.of(context).textTheme.bodyMedium,
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
          error: (error, _) => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(GlassSpacing.xl),
                child: Column(
                  children: [
                    const SizedBox(height: GlassSpacing.xxl),
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: GlassColors.error,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    Text(
                      'Talepler yüklenirken bir hata oluştu.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: GlassSpacing.xs),
                    Text(
                      '$error',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    TextButton.icon(
                      onPressed: () => ref.invalidate(myRequestsProvider),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Oturumu kapatmak istediğine emin misin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
    if (shouldSignOut ?? false) {
      await ref.read(authRepositoryProvider).signOut();
    }
  }
}
