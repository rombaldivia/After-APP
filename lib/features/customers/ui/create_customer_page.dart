import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../neon_theme.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../affiliates/domain/affiliate.dart';
import '../../affiliates/presentation/affiliates_providers.dart';

class CreateCustomerPage extends ConsumerStatefulWidget {
  const CreateCustomerPage({super.key, required this.cardUidHex});
  final String cardUidHex;

  @override
  ConsumerState<CreateCustomerPage> createState() => _CreateCustomerPageState();
}

class _CreateCustomerPageState extends ConsumerState<CreateCustomerPage> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Escribe el nombre del cliente.');
      return;
    }

    setState(() { _busy = true; _error = null; });

    try {
      final affiliate = Affiliate(
        uidHex: widget.cardUidHex,
        name: name,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
      );
      await ref.read(affiliatesNotifierProvider.notifier).upsert(affiliate);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: NeonCard(
              glowColor: NeonTheme.accentPink,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Registrar cliente',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: NeonTheme.textPrimary)),
                  const SizedBox(height: 8),
                  Text('Tarjeta: ${widget.cardUidHex}',
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: NeonTheme.textSecondary)),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre completo'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono (opcional)'),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  if (_error != null)
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _busy ? null : _save,
                      child: Text(_busy ? 'Guardando...' : 'Guardar'),
                    ),
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
