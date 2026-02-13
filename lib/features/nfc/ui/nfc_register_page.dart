import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../../neon_theme.dart';
import '../presentation/nfc_providers.dart';

class NfcRegisterPage extends ConsumerStatefulWidget {
  const NfcRegisterPage({super.key});

  @override
  ConsumerState<NfcRegisterPage> createState() => _NfcRegisterPageState();
}

class _NfcRegisterPageState extends ConsumerState<NfcRegisterPage> {
  String? cardId;
  String? linkedUserId;
  Map<String, dynamic>? userData;

  bool busy = false;
  String? errorMsg;

  final nameCtrl = TextEditingController();

  Future<void> scan() async {
    setState(() {
      busy = true;
      errorMsg = null;
      cardId = null;
      linkedUserId = null;
      userData = null;
    });

    final nfc = ref.read(nfcServiceProvider);
    final available = await nfc.isEnabled();
    if (!available) {
      setState(() {
        busy = false;
        errorMsg = 'NFC no disponible en este dispositivo.';
      });
      return;
    }

    final id = await nfc.scanOnce();
    if (!mounted) return;

    if (id == null || id.trim().isEmpty) {
      setState(() {
        busy = false;
        errorMsg = 'No se detectó tarjeta.';
      });
      return;
    }

    final cards = ref.read(cardRepoProvider);
    final users = ref.read(userRepoProvider);

    final uid = await cards.getUserIdForCard(id);
    Map<String, dynamic>? data;
    if (uid != null) {
      data = await users.getUser(uid);
    }

    setState(() {
      busy = false;
      cardId = id;
      linkedUserId = uid;
      userData = data;
    });
  }

  Future<void> createAndLink() async {
    final id = cardId;
    if (id == null) return;

    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => errorMsg = 'Pon el nombre del cliente.');
      return;
    }

    setState(() {
      busy = true;
      errorMsg = null;
    });

    final users = ref.read(userRepoProvider);
    final cards = ref.read(cardRepoProvider);

    final newUserId = await users.createUser(displayName: name);
    await cards.linkCardToUser(cardId: id, userId: newUserId);

    final data = await users.getUser(newUserId);

    setState(() {
      busy = false;
      linkedUserId = newUserId;
      userData = data;
    });
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    super.dispose();
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
                  const Text('NFC • Registrar Tarjeta',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 14),

                  if (errorMsg != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(errorMsg!, style: const TextStyle(color: Colors.redAccent)),
                    ),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: busy ? null : scan,
                      icon: const Icon(Icons.nfc),
                      label: Text(busy ? 'Escaneando...' : 'Escanear tarjeta'),
                    ),
                  ),

                  const SizedBox(height: 14),

                  if (cardId != null) ...[
                    Text('Card ID: $cardId',
                        style: const TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                    const SizedBox(height: 12),

                    if (linkedUserId != null && userData != null) ...[
                      const Text('Tarjeta ya registrada ✅',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text('${userData!['displayName'] ?? 'Sin nombre'}',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text('Puntos: ${userData!['points'] ?? 0}',
                          style: const TextStyle(color: Colors.white70)),
                      Text('Nivel: ${userData!['tier'] ?? 'GOLD'}',
                          style: const TextStyle(color: Colors.white70)),
                    ] else ...[
                      const Text('Tarjeta NO registrada',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nombre del cliente',
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: busy ? null : createAndLink,
                          icon: const Icon(Icons.person_add),
                          label: Text(busy ? 'Registrando...' : 'Crear usuario y asignar tarjeta'),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
