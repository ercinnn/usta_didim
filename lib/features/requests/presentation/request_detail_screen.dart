import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_service_card.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../core/widgets/star_rating.dart';
import '../../../core/widgets/verified_stamp.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../messages/presentation/chat_screen.dart';
import '../../offers/domain/offer.dart';
import '../../offers/domain/offer_status.dart';
import '../../offers/presentation/offer_providers.dart';
import '../../offers/presentation/offer_status_label.dart';
import '../../reviews/presentation/review_providers.dart';
import '../domain/service_request_status.dart';
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

  Future<void> _markCompleted(BuildContext context, WidgetRef ref) async {
    try {
      await ref.read(serviceRequestRepositoryProvider).markCompleted(requestId);
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
    final brightness = Theme.of(context).brightness;
    final request = requestAsync.value;
    final offers = offersAsync.value;
    Offer? acceptedOffer;
    if (offers != null) {
      for (final offer in offers) {
        if (offer.status == OfferStatus.accepted) {
          acceptedOffer = offer;
          break;
        }
      }
    }

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Talep Detayı')),
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
                return GlassServiceCard(
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
                      Text(
                        request.neighborhood,
                        style: TextStyle(color: GlassColors.textSecondary(brightness)),
                      ),
                      if (request.description != null &&
                          request.description!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          request.description!,
                          style: TextStyle(color: GlassColors.textPrimary(brightness)),
                        ),
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
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Henüz teklif yok.',
                      style: TextStyle(color: GlassColors.textSecondary(brightness)),
                    ),
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
            if (acceptedOffer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: GlassButton(
                  variant: GlassButtonVariant.secondary,
                  icon: Icons.chat_bubble_outline_rounded,
                  label: 'Mesajlar',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(requestId: requestId),
                    ),
                  ),
                ),
              ),
            if (request?.status == ServiceRequestStatus.pending)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: GlassButton(
                  variant: GlassButtonVariant.secondary,
                  icon: Icons.task_alt_rounded,
                  label: 'İşi Tamamlandı Olarak İşaretle',
                  onPressed: () => _markCompleted(context, ref),
                ),
              ),
            if (request?.status == ServiceRequestStatus.completed &&
                acceptedOffer != null)
              _ReviewSection(
                requestId: requestId,
                providerId: acceptedOffer.providerId,
                providerName: acceptedOffer.providerBusinessName ?? 'Usta',
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
    final brightness = Theme.of(context).brightness;
    final statusColor = offerStatusColor(offer.status);
    return GlassServiceCard(
      eyebrow: offer.providerBusinessName ?? 'İsimsiz Usta',
      accentColor: statusColor,
      trailing: offer.providerIsVerified ? const VerifiedStamp() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${offer.price} ₺',
                style: AppTextStyles.mono(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: GlassColors.textPrimary(brightness),
                ),
              ),
              const SizedBox(width: 12),
              if (offer.providerRating != null)
                Text(
                  'Puan: ${offer.providerRating}',
                  style: TextStyle(color: GlassColors.textSecondary(brightness)),
                ),
              const Spacer(),
              Text(
                offerStatusLabel(offer.status),
                style: TextStyle(color: statusColor, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          if (offer.note != null && offer.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              offer.note!,
              style: TextStyle(color: GlassColors.textPrimary(brightness)),
            ),
          ],
          if (onAccept != null) ...[
            const SizedBox(height: 12),
            GlassButton(label: 'Teklifi Kabul Et', onPressed: onAccept),
          ],
        ],
      ),
    );
  }
}

class _ReviewSection extends ConsumerStatefulWidget {
  const _ReviewSection({
    required this.requestId,
    required this.providerId,
    required this.providerName,
  });

  final String requestId;
  final String providerId;
  final String providerName;

  @override
  ConsumerState<_ReviewSection> createState() => _ReviewSectionState();
}

class _ReviewSectionState extends ConsumerState<_ReviewSection> {
  final _commentController = TextEditingController();
  int _rating = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Lütfen bir puan seçin.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final customerId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      await ref.read(reviewRepositoryProvider).submitReview(
            requestId: widget.requestId,
            providerId: widget.providerId,
            customerId: customerId,
            rating: _rating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
      ref.invalidate(reviewForRequestProvider(widget.requestId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviewAsync = ref.watch(reviewForRequestProvider(widget.requestId));
    final brightness = Theme.of(context).brightness;

    return reviewAsync.when(
      data: (review) {
        if (review != null) {
          return GlassServiceCard(
            eyebrow: 'Değerlendirmeniz',
            accentColor: GlassColors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StarRating(rating: review.rating),
                if (review.comment != null && review.comment!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    review.comment!,
                    style: TextStyle(color: GlassColors.textPrimary(brightness)),
                  ),
                ],
              ],
            ),
          );
        }
        return GlassServiceCard(
          eyebrow: '${widget.providerName} · Değerlendir',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRating(
                rating: _rating,
                onChanged: (value) => setState(() => _rating = value),
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: _commentController,
                maxLines: 3,
                labelText: 'Yorumunuz (opsiyonel)',
              ),
              const SizedBox(height: 16),
              GlassButton(
                label: 'Değerlendirmeyi Gönder',
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
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
    );
  }
}
