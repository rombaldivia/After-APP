import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_controller.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../../neon_theme.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _showErr(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
        _showErr(next.error!);
        ref.read(authControllerProvider.notifier).clearError();
      }
    });

    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: NeonCard(
                  glowColor: NeonTheme.neonPink,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      const Text(
                        'BOLICHE XTREMO',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),

                      TextField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isLoading
                              ? null
                              : () {
                                  ref
                                      .read(authControllerProvider.notifier)
                                      .signInWithEmail(
                                        emailCtrl.text.trim(),
                                        passCtrl.text,
                                      );
                                },
                          child: state.isLoading
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Entrar'),
                        ),
                      ),

                      const SizedBox(height: 10),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: state.isLoading
                              ? null
                              : () => ref
                                  .read(authControllerProvider.notifier)
                                  .signInWithGoogle(),
                          icon: const Icon(Icons.g_mobiledata),
                          label: const Text('Entrar con Google'),
                        ),
                      ),

                      const SizedBox(height: 10),

                      TextButton(
                        onPressed: state.isLoading
                            ? null
                            : () {
                                final email = emailCtrl.text.trim();
                                if (email.isEmpty) {
                                  _showErr('Escribe tu email para resetear password.');
                                  return;
                                }
                                ref
                                    .read(authControllerProvider.notifier)
                                    .resetPassword(email);
                              },
                        child: const Text('Olvidé mi contraseña'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
