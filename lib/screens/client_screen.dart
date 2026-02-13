import 'package:flutter/material.dart';
import '../widgets/neon_background.dart';
import '../widgets/neon_card.dart';
import '../neon_theme.dart';

class ClientScreen extends StatelessWidget {
  const ClientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NeonBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: NeonCard(
              glowColor: NeonTheme.neonPink,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Cliente", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 10),
                  const Text("Ana Pérez", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Nivel: ", style: TextStyle(color: Colors.white70)),
                      Text("GOLD", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text("1,250", style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold)),
                  const Text("Puntos", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text("Agregar Puntos"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.local_offer),
                      label: const Text("Aplicar Descuento"),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.refresh),
                      label: const Text("Renovar Membresía"),
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
