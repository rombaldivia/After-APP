import 'package:flutter/material.dart';

import '../features/nfc/data/nfc_service.dart';
import '../widgets/neon_background.dart';
import '../widgets/neon_card.dart';
import '../neon_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final _nfc = NfcService();

  bool _busy = false;
  String? _error;
  NfcScanResult? _last;

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final r = await _nfc.scanOnce(timeout: const Duration(seconds: 12));
      if (!mounted) return;
      setState(() => _last = r);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = '$e');
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
              glowColor: NeonTheme.neonPurple,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Escáner NFC',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),

                  if (_error != null) ...[
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.redAccent.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('UID: ', style: TextStyle(color: Colors.white70)),
                      Text(_last?.uidHex ?? '—', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Techs: ${_last?.techList.join(', ') ?? '—'}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.nfc),
                      label: Text(_busy ? 'Escaneando...' : 'Escanear'),
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
