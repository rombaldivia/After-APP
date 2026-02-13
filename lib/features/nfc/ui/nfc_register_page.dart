import 'package:flutter/material.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../../neon_theme.dart';
import '../data/nfc_service.dart';

class NfcRegisterPage extends StatefulWidget {
  const NfcRegisterPage({super.key});

  @override
  State<NfcRegisterPage> createState() => _NfcRegisterPageState();
}

class _NfcRegisterPageState extends State<NfcRegisterPage> {
  final _nfc = NfcService();
  final _nameCtrl = TextEditingController();

  bool _busy = false;
  String? _cardId;
  String? _error;

  Future<void> _scan() async {
    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final result = await _nfc.scanOnce();

      if (!mounted) return;

      if (result == null || result.uidHex == null) {
        setState(() {
          _error = "No se pudo leer la tarjeta.";
        });
      } else {
        setState(() {
          _cardId = result.uidHex;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Tarjeta leída: ${result.uidHex}")),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = "Error NFC: $e");
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _register() async {
    final id = _cardId;
    final name = _nameCtrl.text.trim();

    if (id == null || id.isEmpty) {
      setState(() => _error = "Primero escanea una tarjeta.");
      return;
    }

    if (name.isEmpty) {
      setState(() => _error = "Ingresa el nombre del usuario.");
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Usuario $name registrado con tarjeta $id")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayId = (_cardId == null || _cardId!.isEmpty)
        ? "—"
        : _cardId!;

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
                    "Registrar Usuario NFC",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),

                  if (_error != null) ...[
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Card ID: ",
                          style: TextStyle(color: Colors.white70)),
                      Text(displayId,
                          style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),

                  const SizedBox(height: 14),

                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(
                      labelText: "Nombre del usuario",
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _scan,
                      icon: const Icon(Icons.nfc),
                      label: Text(_busy ? "Escaneando..." : "Escanear Tarjeta"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _register,
                      icon: const Icon(Icons.save),
                      label: const Text("Registrar Usuario"),
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
