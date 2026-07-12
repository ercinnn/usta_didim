import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/didim_neighborhoods.dart';
import '../../../core/constants/service_categories.dart';
import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';
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
    if (_isLoading) return;
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
      _showError('Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: GlassColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  InputDecoration _dropdownDecoration(
    BuildContext context, {
    required String label,
    required bool enabled,
  }) {
    final brightness = Theme.of(context).brightness;
    final radius = BorderRadius.circular(GlassSpacing.radiusSm);
    final border = OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: GlassColors.glassBorder(brightness)),
    );
    return InputDecoration(
      labelText: label,
      enabled: enabled,
      filled: true,
      fillColor: GlassColors.glassFill(brightness),
      border: border,
      enabledBorder: border,
      disabledBorder: border,
      focusedBorder: border.copyWith(
        borderSide: const BorderSide(color: GlassColors.primary, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: const BorderSide(color: GlassColors.error),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: const BorderSide(color: GlassColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: GlassSpacing.md,
        vertical: GlassSpacing.md,
      ),
      labelStyle: TextStyle(color: GlassColors.textSecondary(brightness)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return GlassScaffold(
      appBar: GlassAppBar(
        title: Text(
          widget.isEditing ? 'Profili Düzenle' : 'Usta Profilini Tamamla',
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: GlassSpacing.lg,
            vertical: GlassSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassContainer(
              padding: const EdgeInsets.fromLTRB(
                GlassSpacing.lg,
                GlassSpacing.lg,
                GlassSpacing.lg,
                GlassSpacing.md,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GlassTextField(
                      controller: _businessNameController,
                      labelText: 'İşletme Adı',
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'İşletme adı gerekli'
                          : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: _dropdownDecoration(
                        context,
                        label: 'Hizmet Kategorisi',
                        enabled: !_isLoading,
                      ),
                      style:
                          TextStyle(color: GlassColors.textPrimary(brightness)),
                      items: serviceCategories
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _category = value),
                      validator: (value) =>
                          value == null ? 'Kategori seçin' : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    DropdownButtonFormField<String>(
                      initialValue: _neighborhood,
                      decoration: _dropdownDecoration(
                        context,
                        label: 'Mahalle (Didim)',
                        enabled: !_isLoading,
                      ),
                      style:
                          TextStyle(color: GlassColors.textPrimary(brightness)),
                      items: didimNeighborhoods
                          .map((n) => DropdownMenuItem(value: n, child: Text(n)))
                          .toList(),
                      onChanged: _isLoading
                          ? null
                          : (value) => setState(() => _neighborhood = value),
                      validator: (value) =>
                          value == null ? 'Mahalle seçin' : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    GlassTextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      labelText: 'Açıklama (opsiyonel)',
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: GlassSpacing.lg),
                    GlassButton(
                      label: widget.isEditing ? 'Kaydet' : 'Kaydet ve Devam Et',
                      loading: _isLoading,
                      onPressed: _isLoading ? null : _submit,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
