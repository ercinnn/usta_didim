import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
            itemCount: offers.length,
            itemBuilder: (context, index) {
              final offer = offers[index];
              return ListTile(
                title: Text(offer.requestTitle ?? 'Talep'),
                subtitle: Text(
                  [
                    if (offer.requestCategory != null) offer.requestCategory,
                    if (offer.requestNeighborhood != null) offer.requestNeighborhood,
                  ].join(' · '),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${offer.price} TL'),
                    Text(offerStatusLabel(offer.status)),
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
