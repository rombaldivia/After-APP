import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../neon_theme.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';

import '../../nfc/data/nfc_service.dart';
import '../domain/affiliate.dart';
import '../presentation/affiliates_providers.dart';

class AddAffiliatePage extends ConsumerStatefulWidget {
  const AddAffiliatePage({super.key});

  @override
  ConsumerState<AddAffiliatePage> createState() => _AddAffiliatePageState();
}

class _AddAffiliatePageState extends ConsumerState<AddAffiliatePage> {
  final _nfc       = NfcService();
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();

  bool _busy = false;
  String? _uidHex;
  String? _error;

  Future<void> _scan() async {
    setState(() { _busy = true; _error = null; });
    try {
      final res = await _nfc.scanOnce(timeout: const Duration(seconds: 12));
      if (!mounted) return;
      if (res.uidHex.isEmpty) {
        setState(() { _error = 'Tag leído, pero sin UID.'; });
      } else {
        setState(() { _uidHex = res.uidHex; });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error NFC: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _save() async {
    final uid   = _uidHex;
    final name  = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (uid == null || uid.isEmpty) {
      setState(() => _error = 'Primero escanea la tarjeta.');
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = 'Ingresa el nombre.');
      return;
    }

    setState(() { _busy = true; _error = null; });

    try {
      await ref.read(affiliatesNotifierProvider.notifier).upsert(
        Affiliate(uidHex: uid, name: name, phone: phone.isEmpty ? null : phone),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Afiliado guardado: $name')),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error guardando: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: NeonCard(
              glowColor: NeonTheme.neonBlue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Añadir Afiliado',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 10),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('UID: ', style: TextStyle(color: Colors.white70)),
                      Text(_uidHex ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Nombre', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                        labelText: 'Teléfono (opcional)', prefixIcon: Icon(Icons.phone)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.nfc),
                      label: Text(_busy ? 'Escaneando...' : 'Escanear UID'),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _busy ? null : _save,
                      icon: const Icon(Icons.save),
                      label: const Text('Guardar Afiliado'),
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
