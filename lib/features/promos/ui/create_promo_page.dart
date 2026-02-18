import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../neon_theme.dart';
import '../../../widgets/neon_background.dart';
import '../../../widgets/neon_card.dart';
import '../domain/promo.dart';
import '../presentation/promos_providers.dart';

class CreatePromoPage extends ConsumerStatefulWidget {
  const CreatePromoPage({super.key});

  @override
  ConsumerState<CreatePromoPage> createState() => _CreatePromoPageState();
}

class _CreatePromoPageState extends ConsumerState<CreatePromoPage> {
  final _titleCtrl  = TextEditingController();
  final _descCtrl   = TextEditingController();
  final _pointsCtrl = TextEditingController(text: '0');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _pointsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title  = _titleCtrl.text.trim();
    final desc   = _descCtrl.text.trim();
    final points = int.tryParse(_pointsCtrl.text.trim()) ?? 0;

    if (title.isEmpty) { setState(() => _error = 'El título es obligatorio.'); return; }
    if (desc.isEmpty)  { setState(() => _error = 'La descripción es obligatoria.'); return; }

    setState(() { _busy = true; _error = null; });

    try {
      await ref.read(promosNotifierProvider.notifier).create(
        Promo(id: '', title: title, description: desc, pointsReward: points),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Error: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: NeonCard(
              glowColor: NeonTheme.neonPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                      ),
                      const Text('Nueva Promoción',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_error != null) ...[
                    Text(_error!,
                        style: const TextStyle(
                            color: Colors.redAccent, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                  ],
                  TextField(
                    controller: _titleCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Título *', prefixIcon: Icon(Icons.local_offer)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                        labelText: 'Descripción *',
                        prefixIcon: Icon(Icons.description),
                        alignLabelWithHint: true),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _pointsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: 'Puntos de recompensa',
                        prefixIcon: Icon(Icons.star),
                        helperText: 'Se suman al canjear (0 = sin puntos)'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _busy ? null : _save,
                      icon: _busy
                          ? const SizedBox(
                              height: 18, width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.check),
                      label: Text(_busy ? 'Guardando...' : 'Crear Promoción'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.25),
                        foregroundColor: Colors.white,
                        side: BorderSide(color: NeonTheme.neonPink.withValues(alpha: 0.8)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
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
