import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_service_card.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../requests/presentation/request_photo_gallery.dart';
import '../../requests/presentation/request_providers.dart';
import 'offer_providers.dart';

class JobOpportunityDetailScreen extends ConsumerStatefulWidget {
  const JobOpportunityDetailScreen({required this.requestId, super.key});

  final String requestId;

  @override
  ConsumerState<JobOpportunityDetailScreen> createState() =>
      _JobOpportunityDetailScreenState();
}

class _JobOpportunityDetailScreenState
    extends ConsumerState<JobOpportunityDetailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  bool _isLoading = false;
  bool _submitted = false;

  @override
  void dispose() {
    _priceController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _submitOffer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final providerId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      await ref.read(offerRepositoryProvider).createOffer(
            requestId: widget.requestId,
            providerId: providerId,
            price: num.parse(_priceController.text.trim()),
            note: _noteController.text.trim().isEmpty
                ? null
                : _noteController.text.trim(),
          );
      ref.invalidate(myOffersProvider);
      ref.invalidate(jobPoolProvider);
      if (!mounted) return;
      setState(() => _submitted = true);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Teklifiniz gönderildi.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final requestAsync = ref.watch(requestByIdProvider(widget.requestId));
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('İş Fırsatı')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          requestAsync.when(
            data: (request) {
              if (request == null) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Talep bulunamadı.'),
                );
              }
              return GlassServiceCard(
                eyebrow: request.category,
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
                    if (request.preferredDate != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Tercih edilen tarih: ${request.preferredDate!.day}.${request.preferredDate!.month}.${request.preferredDate!.year}',
                        style: TextStyle(color: GlassColors.textSecondary(brightness)),
                      ),
                    ],
                    if (request.description != null &&
                        request.description!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text(
                        request.description!,
                        style: TextStyle(color: GlassColors.textPrimary(brightness)),
                      ),
                    ],
                    if (request.photoUrls.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      RequestPhotoGallery(photoUrls: request.photoUrls),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Hata: $error'),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _submitted
                ? Text(
                    'Bu iş fırsatına teklif verdiniz.',
                    style: TextStyle(color: GlassColors.textPrimary(brightness)),
                  )
                : Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Teklif Ver',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(decimal: true),
                          labelText: 'Fiyat (TL)',
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Fiyat gerekli';
                            if (num.tryParse(value.trim()) == null) {
                              return 'Geçerli bir sayı girin';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        GlassTextField(
                          controller: _noteController,
                          maxLines: 3,
                          labelText: 'Not (opsiyonel)',
                        ),
                        const SizedBox(height: 20),
                        GlassButton(
                          label: 'Teklifi Gönder',
                          loading: _isLoading,
                          onPressed: _isLoading ? null : _submitOffer,
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
