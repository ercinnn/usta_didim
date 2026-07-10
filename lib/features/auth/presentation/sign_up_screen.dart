import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_app_bar.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
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
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassScaffold(
      appBar: const GlassAppBar(title: Text('Kayıt Ol')),
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
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    labelText: 'E-posta',
                    validator: (value) =>
                        (value == null || value.isEmpty) ? 'E-posta gerekli' : null,
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: _passwordController,
                    obscureText: true,
                    labelText: 'Şifre',
                    validator: (value) => (value == null || value.length < 6)
                        ? 'En az 6 karakter'
                        : null,
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
                        child: _RoleCard(
                          label: 'Müşteri',
                          icon: Icons.search_rounded,
                          selected: _role == AppRole.customer,
                          onTap: () => setState(() => _role = AppRole.customer),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _RoleCard(
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
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final foreground = selected ? Colors.white : GlassColors.textPrimary(brightness);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
      child: AnimatedContainer(
        duration: GlassSpacing.animationDuration,
        curve: GlassSpacing.animationCurve,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: selected
              ? const LinearGradient(
                  colors: [GlassColors.primary, GlassColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: selected ? null : GlassColors.glassFill(brightness),
          borderRadius: BorderRadius.circular(GlassSpacing.radiusSm),
          border: Border.all(
            color: selected ? Colors.transparent : GlassColors.glassBorder(brightness),
            width: selected ? 0 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: foreground),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: foreground, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
