import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_service_card.dart';
import '../../messages/presentation/chat_screen.dart';
import '../domain/offer_status.dart';
import 'offer_providers.dart';
import 'offer_status_label.dart';

class MyActiveJobsTab extends ConsumerWidget {
  const MyActiveJobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);
    final brightness = Theme.of(context).brightness;

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myOffersProvider),
      child: offersAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(GlassSpacing.xl),
                  child: Column(
                    children: [
                      const SizedBox(height: GlassSpacing.xxl),
                      Icon(
                        Icons.assignment_outlined,
                        size: 64,
                        color: GlassColors.textSecondary(brightness),
                      ),
                      const SizedBox(height: GlassSpacing.md),
                      Text(
                        'Henüz teklif vermediniz.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: GlassSpacing.xs),
                      Text(
                        'İlan havuzundan bir işe teklif verdiğinde burada görünecek.',
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
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final statusColor = offerStatusColor(offer.status);
              return GlassServiceCard(
                eyebrow: offer.requestCategory ?? 'Talep',
                accentColor: statusColor,
                onTap: offer.status == OfferStatus.accepted
                    ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(requestId: offer.requestId),
                          ),
                        )
                    : null,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.requestTitle ?? 'Talep',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          if (offer.requestNeighborhood != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              offer.requestNeighborhood!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${offer.price} ₺',
                          style: AppTextStyles.mono(
                            fontSize: 14,
                            color: GlassColors.textPrimary(brightness),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          offerStatusLabel(offer.status),
                          style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
                        ),
                      ],
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
                    'Teklifleriniz yüklenirken bir hata oluştu.',
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
                    onPressed: () => ref.invalidate(myOffersProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tekrar Dene'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
