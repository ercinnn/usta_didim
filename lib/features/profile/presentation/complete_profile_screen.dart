import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../core/widgets/role_card.dart';
import '../../auth/domain/app_role.dart';
import '../../auth/presentation/auth_providers.dart';
import 'profile_providers.dart';

/// Shown once, right after a user's first successful sign-in, when they have
/// an `auth.users` row but no matching `profiles` row yet -- the normal case
/// for Google OAuth sign-ins, which (unlike [SignUpScreen]) never collect a
/// role/phone number up front.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _fullNameController = TextEditingController(text: _initialFullName());
  final _phoneController = TextEditingController();
  AppRole _role = AppRole.customer;
  bool _isLoading = false;

  String? _initialFullName() {
    final metadata = ref.read(supabaseClientProvider).auth.currentUser?.userMetadata;
    return (metadata?['full_name'] ?? metadata?['name']) as String?;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final userId = ref.read(supabaseClientProvider).auth.currentUser!.id;
      await ref.read(profileRepositoryProvider).createProfile(
            id: userId,
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _role,
          );
      ref.invalidate(currentProfileProvider);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Profili Tamamla')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Devam etmek için birkaç bilgiye daha ihtiyacımız var.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  GlassTextField(
                    controller: _fullNameController,
                    labelText: 'Ad Soyad',
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Ad soyad gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    labelText: 'Telefon',
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'Telefon gerekli' : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hesap Türü',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: RoleCard(
                          label: 'Müşteri',
                          icon: Icons.search_rounded,
                          selected: _role == AppRole.customer,
                          onTap: () => setState(() => _role = AppRole.customer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RoleCard(
                          label: 'Usta / Firma',
                          icon: Icons.handyman_rounded,
                          selected: _role == AppRole.provider,
                          onTap: () => setState(() => _role = AppRole.provider),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GlassButton(
                    label: 'Kaydet ve Devam Et',
                    loading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
