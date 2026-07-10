import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/didim_neighborhoods.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/theme/glass_colors.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import 'request_providers.dart';

class CreateRequestScreen extends ConsumerStatefulWidget {
  const CreateRequestScreen({super.key});

  @override
  ConsumerState<CreateRequestScreen> createState() => _CreateRequestScreenState();
}

class _CreateRequestScreenState extends ConsumerState<CreateRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _category;
  String? _neighborhood;
  DateTime? _preferredDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _preferredDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final customerId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      await ref.read(serviceRequestRepositoryProvider).createRequest(
            customerId: customerId,
            category: _category!,
            title: _titleController.text.trim(),
            neighborhood: _neighborhood!,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            preferredDate: _preferredDate,
          );
      ref.invalidate(myRequestsProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
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
    final brightness = Theme.of(context).brightness;

    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Hizmet Talebi Oluştur')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Hizmet Kategorisi'),
                items: serviceCategories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (value) => setState(() => _category = value),
                validator: (value) => value == null ? 'Kategori seçin' : null,
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: _titleController,
                labelText: 'Başlık',
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Başlık gerekli' : null,
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: _descriptionController,
                maxLines: 3,
                labelText: 'Açıklama (opsiyonel)',
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _neighborhood,
                decoration: const InputDecoration(labelText: 'Mahalle (Didim)'),
                items: didimNeighborhoods
                    .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                    .toList(),
                onChanged: (value) => setState(() => _neighborhood = value),
                validator: (value) => value == null ? 'Mahalle seçin' : null,
              ),
              const SizedBox(height: 12),
              GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                onTap: _pickDate,
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    _preferredDate == null
                        ? 'Tercih edilen tarih (opsiyonel)'
                        : 'Tercih edilen tarih: ${_preferredDate!.day}.${_preferredDate!.month}.${_preferredDate!.year}',
                    style: TextStyle(color: GlassColors.textPrimary(brightness)),
                  ),
                  trailing: Icon(Icons.calendar_today, color: GlassColors.primary),
                ),
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: 'Talebi Oluştur',
                loading: _isLoading,
                onPressed: _isLoading ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
