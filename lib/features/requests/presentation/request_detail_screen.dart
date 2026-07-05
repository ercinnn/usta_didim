import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_status.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../offers/presentation/offer_status_label.dart';
import 'request_providers.dart';
import 'request_status_label.dart';

class RequestDetailScreen extends ConsumerWidget {
  const RequestDetailScreen({required this.requestId, super.key});

  final String requestId;

  Future<void> _acceptOffer(BuildContext context, WidgetRef ref, Offer offer) async {
    try {
      await ref.read(offerRepositoryProvider).acceptOffer(
            offerId: offer.id,
            requestId: requestId,
          );
      ref.invalidate(offersForRequestProvider(requestId));
      ref.invalidate(requestByIdProvider(requestId));
      ref.invalidate(myRequestsProvider);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requestAsync = ref.watch(requestByIdProvider(requestId));
    final offersAsync = ref.watch(offersForRequestProvider(requestId));

    return Scaffold(
      appBar: AppBar(title: const Text('Talep Detayı')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(requestByIdProvider(requestId));
          ref.invalidate(offersForRequestProvider(requestId));
        },
        child: ListView(
          children: [
            requestAsync.when(
              data: (request) {
                if (request == null) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Talep bulunamadı.'),
                  );
                }
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text('${request.category} · ${request.neighborhood}'),
                      const SizedBox(height: 4),
                      Text('Durum: ${serviceRequestStatusLabel(request.status)}'),
                      if (request.description != null &&
                          request.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(request.description!),
                      ],
                    ],
                  ),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Hata: $error'),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Teklifler', style: Theme.of(context).textTheme.titleMedium),
            ),
            offersAsync.when(
              data: (offers) {
                if (offers.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Henüz teklif yok.'),
                  );
                }
                return Column(
                  children: offers
                      .map((offer) => _OfferTile(
                            offer: offer,
                            onAccept: offer.status == OfferStatus.pending
                                ? () => _acceptOffer(context, ref, offer)
                                : null,
                          ))
                      .toList(),
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text('Hata: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OfferTile extends StatelessWidget {
  const _OfferTile({required this.offer, this.onAccept});

  final Offer offer;
  final VoidCallback? onAccept;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              offer.providerBusinessName ?? 'İsimsiz Usta',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (offer.providerRating != null)
              Text('Puan: ${offer.providerRating}'),
            const SizedBox(height: 4),
            Text('${offer.price} TL',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            if (offer.note != null && offer.note!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(offer.note!),
            ],
            const SizedBox(height: 4),
            Text('Durum: ${offerStatusLabel(offer.status)}'),
            if (onAccept != null) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: onAccept,
                child: const Text('Teklifi Kabul Et'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
