import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import '../../../core/widgets/role_card.dart';
import '../../profile/presentation/profile_providers.dart';
import '../domain/app_role.dart';
import 'auth_providers.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AppRole _role = AppRole.customer;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (_isLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authResponse = await ref.read(authRepositoryProvider).signUp(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
      final userId = authResponse.user?.id;
      if (userId == null) {
        throw const AuthException('Kayıt tamamlanamadı, lütfen tekrar deneyin.');
      }
      await ref.read(profileRepositoryProvider).createProfile(
            id: userId,
            fullName: _fullNameController.text.trim(),
            phone: _phoneController.text.trim(),
            role: _role,
          );
      ref.invalidate(currentProfileProvider);
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } on AuthException catch (e) {
      _showError(e.message);
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

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Kayıt Ol')),
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
                      controller: _fullNameController,
                      labelText: 'Ad Soyad',
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.name],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Ad soyad gerekli'
                          : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    GlassTextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      labelText: 'Telefon',
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'Telefon gerekli'
                          : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    GlassTextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'E-posta',
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      validator: (value) => (value == null || value.isEmpty)
                          ? 'E-posta gerekli'
                          : null,
                    ),
                    const SizedBox(height: GlassSpacing.md),
                    GlassTextField(
                      controller: _passwordController,
                      obscureText: true,
                      labelText: 'Şifre',
                      enabled: !_isLoading,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.newPassword],
                      onFieldSubmitted: (_) => _signUp(),
                      validator: (value) => (value == null || value.length < 6)
                          ? 'En az 6 karakter'
                          : null,
                    ),
                    const SizedBox(height: GlassSpacing.lg),
                    Semantics(
                      header: true,
                      child: Text(
                        'Hesap Türü',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                    ),
                    const SizedBox(height: GlassSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: RoleCard(
                            label: 'Müşteri',
                            icon: Icons.search_rounded,
                            selected: _role == AppRole.customer,
                            onTap: () {
                              if (_isLoading) return;
                              setState(() => _role = AppRole.customer);
                            },
                          ),
                        ),
                        const SizedBox(width: GlassSpacing.sm),
                        Expanded(
                          child: RoleCard(
                            label: 'Usta / Firma',
                            icon: Icons.handyman_rounded,
                            selected: _role == AppRole.provider,
                            onTap: () {
                              if (_isLoading) return;
                              setState(() => _role = AppRole.provider);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GlassSpacing.lg),
                    GlassButton(
                      label: 'Kayıt Ol',
                      loading: _isLoading,
                      onPressed: _isLoading ? null : _signUp,
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
