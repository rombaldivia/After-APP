import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../widgets/neon_card.dart';

class DashboardScreen extends StatelessWidget {
  final VoidCallback? onGoClients;

  const DashboardScreen({super.key, this.onGoClients});

  Widget metric(String title, String value, Color glow) {
    return NeonCard(
      glowColor: glow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        const SizedBox(height: 10),
        metric("Ingresos Estimados", "Bs. 14,500", NeonTheme.neonPurple),
        const SizedBox(height: 14),
        metric("Clientes", "128", NeonTheme.neonCyan),
        const SizedBox(height: 14),
        NeonCard(
          glowColor: NeonTheme.neonPink,
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  "Ir a Clientes para ver descuentos, historial y puntos.",
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: onGoClients,
                style: ElevatedButton.styleFrom(
                  backgroundColor: NeonTheme.neonPink.withValues(alpha: 0.20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: NeonTheme.neonPink.withValues(alpha: 0.8)),
                  ),
                ),
                child: const Text("Clientes"),
              )
            ],
          ),
        ),
      ],
    );
  }
}
