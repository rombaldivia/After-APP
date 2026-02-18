import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../neon_theme.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../promos/domain/promo.dart';
import '../presentation/nfc_scan_controller.dart';

class NfcScanFlowPage extends ConsumerWidget {
  const NfcScanFlowPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(nfcScanControllerProvider);
    final ctrl  = ref.read(nfcScanControllerProvider.notifier);

    ref.listen<ScanFlowState>(nfcScanControllerProvider, (prev, next) {
      if (next.successMsg != null && next.successMsg != prev?.successMsg) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.successMsg!),
          backgroundColor: NeonTheme.neonCyan.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ));
      }
      if (next.error != null && next.error != prev?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.error!),
          backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    return NeonBackground(
      child: SafeArea(
        child: switch (state.step) {
          ScanStep.idle       => _IdleView(onScan: ctrl.scanAndLookup),
          ScanStep.scanning   => const _ScanningView(),
          ScanStep.notFound   => _NotFoundView(
              uidHex: state.uidHex ?? '',
              onCreateUser: (name, phone) =>
                  ctrl.createAffiliate(name: name, phone: phone),
              onCancel: ctrl.reset,
            ),
          ScanStep.showingUser => _UserView(
              state: state,
              onRedeem: ctrl.redeem,
              onReset: ctrl.reset,
            ),
        },
      ),
    );
  }
}

// ── Idle ──────────────────────────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final VoidCallback onScan;
  const _IdleView({required this.onScan});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: NeonCard(
          glowColor: NeonTheme.neonPurple,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.nfc, size: 72,
                  color: NeonTheme.neonPurple.withValues(alpha: 0.9)),
              const SizedBox(height: 16),
              const Text('Escanear Tarjeta',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              const SizedBox(height: 8),
              const Text(
                'Acerca la tarjeta NFC del cliente para ver sus promociones.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onScan,
                  icon: const Icon(Icons.nfc),
                  label: const Text('Escanear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: NeonTheme.neonPurple.withValues(alpha: 0.3),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: NeonTheme.neonPurple.withValues(alpha: 0.8)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Scanning ──────────────────────────────────────────────────────────────────

class _ScanningView extends StatelessWidget {
  const _ScanningView();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: NeonCard(
        glowColor: NeonTheme.neonPurple,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 60, height: 60,
              child: CircularProgressIndicator(
                  color: NeonTheme.neonPurple, strokeWidth: 3),
            ),
            const SizedBox(height: 20),
            const Text('Acerca la tarjeta…',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('Esperando NFC (15 seg)',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
      ),
    ),
  );
}

// ── Not Found ─────────────────────────────────────────────────────────────────

class _NotFoundView extends StatefulWidget {
  final String uidHex;
  final void Function(String name, String phone) onCreateUser;
  final VoidCallback onCancel;
  const _NotFoundView({required this.uidHex, required this.onCreateUser, required this.onCancel});

  @override
  State<_NotFoundView> createState() => _NotFoundViewState();
}

class _NotFoundViewState extends State<_NotFoundView> {
  final _nameCtrl  = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _creating = false;

  @override
  void dispose() { _nameCtrl.dispose(); _phoneCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: NeonCard(
        glowColor: NeonTheme.neonPink,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.person_add, size: 48, color: NeonTheme.neonPink),
            const SizedBox(height: 12),
            const Text('Tarjeta no registrada',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('UID: ${widget.uidHex}',
                style: const TextStyle(color: Colors.white54, fontSize: 12, fontFamily: 'monospace')),
            const SizedBox(height: 16),
            const Text('¿Registrar como nuevo cliente?',
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            TextField(
              controller: _nameCtrl,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                  labelText: 'Nombre *', prefixIcon: Icon(Icons.person)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                  labelText: 'Teléfono (opcional)', prefixIcon: Icon(Icons.phone)),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _creating ? null : () {
                  final name = _nameCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('El nombre es obligatorio.')));
                    return;
                  }
                  setState(() => _creating = true);
                  widget.onCreateUser(name, _phoneCtrl.text.trim());
                },
                icon: _creating
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.save),
                label: Text(_creating ? 'Guardando...' : 'Registrar Cliente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.25),
                  foregroundColor: Colors.white,
                  side: BorderSide(color: NeonTheme.neonPink.withValues(alpha: 0.8)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: widget.onCancel,
              child: const Text('Cancelar', style: TextStyle(color: Colors.white54)),
            ),
          ],
        ),
      ),
    );
  }
}

// ── User + Promos ─────────────────────────────────────────────────────────────

class _UserView extends StatelessWidget {
  final ScanFlowState state;
  final void Function(String promoId, int points) onRedeem;
  final VoidCallback onReset;
  const _UserView({required this.state, required this.onRedeem, required this.onReset});

  @override
  Widget build(BuildContext context) {
    final affiliate = state.affiliate!;
    final promos    = state.promos;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        // Card del cliente
        NeonCard(
          glowColor: NeonTheme.neonCyan,
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: NeonTheme.neonCyan.withValues(alpha: 0.2),
                child: const Icon(Icons.person, size: 30, color: NeonTheme.neonCyan),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(affiliate.name,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                    if (affiliate.phone != null)
                      Text(affiliate.phone!,
                          style: const TextStyle(color: Colors.white54, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${affiliate.points} puntos',
                            style: const TextStyle(color: Colors.amber, fontSize: 13,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onReset,
                icon: const Icon(Icons.close, color: Colors.white38),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text('Promociones Disponibles',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text(
          '${promos.where((p) => !p.redeemed).length} sin canjear  •  ${promos.length} total',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 12),
        if (promos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              children: [
                Icon(Icons.sentiment_dissatisfied, size: 40, color: Colors.white24),
                SizedBox(height: 8),
                Text('No hay promociones activas.',
                    style: TextStyle(color: Colors.white38)),
              ],
            ),
          ),
        ...promos.map((ps) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _PromoTile(ps: ps, onRedeem: onRedeem),
            )),
      ],
    );
  }
}

class _PromoTile extends StatelessWidget {
  final PromoWithStatus ps;
  final void Function(String promoId, int points) onRedeem;
  const _PromoTile({required this.ps, required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final redeemed = ps.redeemed;

    return NeonCard(
      glowColor: redeemed ? Colors.white24 : NeonTheme.neonPink,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 14, top: 2),
            child: Icon(
              redeemed ? Icons.check_circle : Icons.local_offer,
              color: redeemed ? Colors.white30 : NeonTheme.neonPink,
              size: 28,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ps.promo.title,
                    style: TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800,
                        color: redeemed ? Colors.white38 : Colors.white)),
                const SizedBox(height: 3),
                Text(ps.promo.description,
                    style: TextStyle(
                        color: redeemed ? Colors.white24 : Colors.white60,
                        fontSize: 13)),
                if (ps.promo.pointsReward > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.star, size: 13,
                          color: redeemed ? Colors.white24 : Colors.amber),
                      const SizedBox(width: 3),
                      Text('+${ps.promo.pointsReward} puntos',
                          style: TextStyle(
                              color: redeemed ? Colors.white24 : Colors.amber,
                              fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
                if (redeemed) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Text('✓ Ya canjeado',
                        style: TextStyle(color: Colors.white38, fontSize: 11,
                            fontWeight: FontWeight.w700)),
                  ),
                ],
              ],
            ),
          ),
          if (!redeemed) ...[
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _confirm(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.25),
                foregroundColor: Colors.white,
                side: BorderSide(color: NeonTheme.neonPink.withValues(alpha: 0.8)),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Canjear',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }

  void _confirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: NeonTheme.card,
        title: Text('Canjear: ${ps.promo.title}'),
        content: Text(ps.promo.pointsReward > 0
            ? '${ps.promo.description}\n\n+${ps.promo.pointsReward} puntos al cliente.'
            : ps.promo.description),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onRedeem(ps.promo.id, ps.promo.pointsReward);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.3),
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }
}
