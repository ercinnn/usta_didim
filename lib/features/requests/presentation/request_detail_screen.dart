import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ticket_card.dart';
import '../../../core/widgets/verified_stamp.dart';
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
                return TicketCard(
                  eyebrow: request.category,
                  accentColor: serviceRequestStatusColor(request.status),
                  trailing: Text(
                    serviceRequestStatusLabel(request.status),
                    style: TextStyle(
                      color: serviceRequestStatusColor(request.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(request.title,
                          style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 4),
                      Text(request.neighborhood),
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
    final statusColor = offerStatusColor(offer.status);
    return TicketCard(
      eyebrow: offer.providerBusinessName ?? 'İsimsiz Usta',
      accentColor: statusColor,
      trailing: offer.providerIsVerified ? const VerifiedStamp() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${offer.price} ₺',
                  style: AppTextStyles.mono(fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(width: 12),
              if (offer.providerRating != null)
                Text('Puan: ${offer.providerRating}'),
              const Spacer(),
              Text(
                offerStatusLabel(offer.status),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (offer.note != null && offer.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(offer.note!),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onAccept,
              child: const Text('Teklifi Kabul Et'),
            ),
          ],
        ],
      ),
    );
  }
}
