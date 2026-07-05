import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('İş Fırsatı')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          requestAsync.when(
            data: (request) {
              if (request == null) {
                return const Text('Talep bulunamadı.');
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.title,
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 4),
                  Text('${request.category} · ${request.neighborhood}'),
                  if (request.preferredDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Tercih edilen tarih: ${request.preferredDate!.day}.${request.preferredDate!.month}.${request.preferredDate!.year}',
                    ),
                  ],
                  if (request.description != null &&
                      request.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(request.description!),
                  ],
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Hata: $error'),
          ),
          const Divider(height: 32),
          if (_submitted)
            const Text('Bu iş fırsatına teklif verdiniz.')
          else
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Teklif Ver', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Fiyat gerekli';
                      if (num.tryParse(value.trim()) == null) return 'Geçerli bir sayı girin';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Not (opsiyonel)'),
                  ),
                  const SizedBox(height: 20),
                  FilledButton(
                    onPressed: _isLoading ? null : _submitOffer,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Teklifi Gönder'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
