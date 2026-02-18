import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../neon_theme.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../domain/promo.dart';
import '../presentation/promos_providers.dart';
import 'create_promo_page.dart';

class PromosAdminPage extends ConsumerWidget {
  const PromosAdminPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncPromos = ref.watch(allPromosProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreatePromoPage()),
          );
          ref.read(promosNotifierProvider.notifier).load();
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Promo'),
        backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.85),
        foregroundColor: Colors.white,
      ),
      body: NeonBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    ),
                    const Text('Mis Promociones',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: asyncPromos.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (promos) {
                    if (promos.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.local_offer_outlined,
                                size: 60,
                                color: NeonTheme.neonPink.withValues(alpha: 0.5)),
                            const SizedBox(height: 12),
                            const Text('No hay promociones todavía.',
                                style: TextStyle(color: Colors.white60)),
                            const SizedBox(height: 6),
                            const Text('Toca + para crear la primera.',
                                style: TextStyle(color: Colors.white38)),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                      itemCount: promos.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PromoCard(promo: promos[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PromoCard extends ConsumerWidget {
  final Promo promo;
  const _PromoCard({required this.promo});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(promosNotifierProvider.notifier);

    return NeonCard(
      glowColor: promo.active ? NeonTheme.neonPink : Colors.white24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(promo.title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(promo.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (promo.pointsReward > 0) ...[
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('+${promo.pointsReward} pts',
                          style: const TextStyle(
                              color: Colors.amber,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(width: 12),
                    ],
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: promo.active
                            ? NeonTheme.neonCyan.withValues(alpha: 0.15)
                            : Colors.white12,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: promo.active
                              ? NeonTheme.neonCyan.withValues(alpha: 0.5)
                              : Colors.white24,
                        ),
                      ),
                      child: Text(
                        promo.active ? 'Activa' : 'Inactiva',
                        style: TextStyle(
                          fontSize: 11,
                          color: promo.active ? NeonTheme.neonCyan : Colors.white38,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              Switch(
                value: promo.active,
                onChanged: (v) => notifier.toggleActive(promo.id, v),
                activeThumbColor: NeonTheme.neonPink,
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Colors.redAccent, size: 20),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: NeonTheme.card,
                      title: const Text('Eliminar promoción'),
                      content: Text('¿Eliminar "${promo.title}"?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancelar')),
                        TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Eliminar',
                                style: TextStyle(color: Colors.redAccent))),
                      ],
                    ),
                  );
                  if (ok == true) await notifier.delete(promo.id);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
