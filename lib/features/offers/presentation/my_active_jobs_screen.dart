import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ticket_card.dart';
import 'offer_providers.dart';
import 'offer_status_label.dart';

class MyActiveJobsTab extends ConsumerWidget {
  const MyActiveJobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(myOffersProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(myOffersProvider),
      child: offersAsync.when(
        data: (offers) {
          if (offers.isEmpty) {
            return ListView(
              children: const [
                Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: Text('Henüz teklif vermediniz.')),
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              final statusColor = offerStatusColor(offer.status);
              return TicketCard(
                eyebrow: offer.requestCategory ?? 'Talep',
                accentColor: statusColor,
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
                            Text(offer.requestNeighborhood!),
                          ],
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${offer.price} ₺', style: AppTextStyles.mono(fontSize: 14)),
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
        error: (error, _) => Center(child: Text('Hata: $error')),
      ),
    );
  }
}
