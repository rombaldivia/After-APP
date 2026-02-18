import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../../../neon_theme.dart';

import '../presentation/affiliates_providers.dart';
import 'add_affiliate_page.dart';

class AffiliatesListPage extends ConsumerWidget {
  const AffiliatesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncList = ref.watch(affiliatesListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddAffiliatePage()),
        ),
        child: const Icon(Icons.add),
      ),
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: NeonCard(
              glowColor: NeonTheme.neonBlue,
              child: asyncList.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(child: Text('No hay afiliados todavía.'));
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final a = list[i];
                      return ListTile(
                        title: Text(a.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                        subtitle: Text('UID: ${a.uidHex}${a.phone == null ? "" : "  •  Tel: ${a.phone}"}'),
                        leading: const Icon(Icons.person),
                      );
                    },
                  );
                },
                error: (e, _) => Center(child: Text('Error: $e')),
                loading: () => const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
