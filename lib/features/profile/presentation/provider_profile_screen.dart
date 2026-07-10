import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/didim_neighborhoods.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/provider_profile.dart';
import 'profile_providers.dart';

class ProviderProfileScreen extends ConsumerStatefulWidget {
  const ProviderProfileScreen({super.key, this.existingProfile});

  final ProviderProfile? existingProfile;

  bool get isEditing => existingProfile != null;

  @override
  ConsumerState<ProviderProfileScreen> createState() =>
      _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends ConsumerState<ProviderProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _businessNameController = TextEditingController(
    text: widget.existingProfile?.businessName,
  );
  late final _descriptionController = TextEditingController(
    text: widget.existingProfile?.description,
  );
  late String? _category = widget.existingProfile?.category;
  late String? _neighborhood = widget.existingProfile?.neighborhood;
  bool _isLoading = false;

  @override
  void dispose() {
    _businessNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      final repository = ref.read(providerRepositoryProvider);
      final businessName = _businessNameController.text.trim();
      final description = _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();
      if (widget.isEditing) {
        await repository.updateProviderProfile(
          id: userId,
          businessName: businessName,
          category: _category!,
          neighborhood: _neighborhood!,
          description: description,
        );
      } else {
        await repository.createProviderProfile(
          id: userId,
          businessName: businessName,
          category: _category!,
          neighborhood: _neighborhood!,
          description: description,
        );
      }
      ref.invalidate(currentProviderProfileProvider);
      if (widget.isEditing && mounted) {
        Navigator.of(context).pop();
      }
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
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.isEditing ? 'Profili Düzenle' : 'Usta Profilini Tamamla',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GlassTextField(
                controller: _businessNameController,
                labelText: 'İşletme Adı',
                validator: (value) => (value == null || value.isEmpty)
                    ? 'İşletme adı gerekli'
                    : null,
              ),
              const SizedBox(height: 12),
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
              GlassTextField(
                controller: _descriptionController,
                maxLines: 3,
                labelText: 'Açıklama (opsiyonel)',
              ),
              const SizedBox(height: 20),
              GlassButton(
                label: widget.isEditing ? 'Kaydet' : 'Kaydet ve Devam Et',
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
