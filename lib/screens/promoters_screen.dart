import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/neon_card.dart';

class PromotersScreen extends StatelessWidget {
  const PromotersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Promotores', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                Expanded(
                  child: ListView(
                    children: [
                      _row('Carlos Mendoza', '120 Ventas  •  Bs. 4,800', NeonTheme.neonBlue),
                      const SizedBox(height: 12),
                      _row('Laura Gutiérrez', '95 Ventas  •  Bs. 3,600', NeonTheme.neonPink),
                      const SizedBox(height: 12),
                      _row('Diego Suárez', '80 Ventas  •  Bs. 2,800', NeonTheme.neonPurple),
                      const SizedBox(height: 12),
                      _row('Sofía Lima', '60 Ventas  •  Bs. 2,100', NeonTheme.neonBlue),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(String name, String sub, Color glow) {
    return NeonCard(
      glowColor: glow,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: glow.withAlpha((0.25 * 255).round()),
            child: const Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 2),
                Text(sub, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
