import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/glass_colors.dart';
import '../../../core/theme/glass_spacing.dart';
import '../../../core/widgets/glass_button.dart';
import '../../../core/widgets/glass_container.dart';
import '../../../core/widgets/glass_text_field.dart';
import '../../../core/widgets/responsive_scaffold.dart';
import 'auth_providers.dart';
import 'sign_up_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading || _isGoogleLoading) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          );
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    if (_isLoading || _isGoogleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      await ref.read(authRepositoryProvider).signInWithGoogle();
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Bir hata oluştu: $e');
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: GlassSpacing.lg,
            vertical: GlassSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Wordmark(),
                const SizedBox(height: GlassSpacing.xl),
                GlassContainer(
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
                        Text(
                          'Giriş Yap',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: GlassSpacing.lg),
                        GlassTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          labelText: 'E-posta',
                          enabled: !(_isLoading || _isGoogleLoading),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.username,
                            AutofillHints.email,
                          ],
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
                          enabled: !(_isLoading || _isGoogleLoading),
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.password],
                          onFieldSubmitted: (_) => _signIn(),
                          validator: (value) => (value == null || value.length < 6)
                              ? 'En az 6 karakter'
                              : null,
                        ),
                        const SizedBox(height: GlassSpacing.lg),
                        GlassButton(
                          label: 'Giriş Yap',
                          loading: _isLoading,
                          onPressed: _isLoading ? null : _signIn,
                        ),
                        const SizedBox(height: GlassSpacing.lg),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: GlassColors.glassBorder(
                                  Theme.of(context).brightness,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: GlassSpacing.sm,
                              ),
                              child: Text(
                                'veya',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: GlassColors.textSecondary(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: GlassColors.glassBorder(
                                  Theme.of(context).brightness,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GlassSpacing.lg),
                        GlassButton(
                          label: 'Google ile Giriş Yap',
                          variant: GlassButtonVariant.secondary,
                          loading: _isGoogleLoading,
                          onPressed: (_isLoading || _isGoogleLoading)
                              ? null
                              : _signInWithGoogle,
                        ),
                        const SizedBox(height: GlassSpacing.xs),
                        TextButton(
                          onPressed: (_isLoading || _isGoogleLoading)
                              ? null
                              : () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  ),
                          child: const Text('Hesabın yok mu? Kayıt ol'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final displayStyle = Theme.of(context).textTheme.displaySmall?.copyWith(
          color: GlassColors.textPrimary(brightness),
          height: 1,
        );
    return Column(
      children: [
        Text(
          'DİDİM\'DE GÜVENİLİR USTA AĞI',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: GlassColors.textSecondary(brightness),
                fontWeight: FontWeight.w600,
                letterSpacing: 2.2,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('USTA', style: displayStyle),
            const SizedBox(width: 10),
            Container(
              width: 10,
              height: 10,
              margin: const EdgeInsets.only(bottom: 6),
              decoration: const BoxDecoration(
                color: GlassColors.accent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text('DİDİM', style: displayStyle?.copyWith(color: GlassColors.primary)),
          ],
        ),
      ],
    );
  }
}
