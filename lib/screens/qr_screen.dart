import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../widgets/neon_background.dart';
import '../widgets/neon_card.dart';

class QrScreen extends StatelessWidget {
  const QrScreen({super.key});

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
                  const Text("BOLICHE XTREMO", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 10),
                  const Text("Ana Pérez", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Nivel: ", style: TextStyle(color: Colors.white70)),
                      Text("GOLD", style: TextStyle(fontWeight: FontWeight.w800, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text("1,250", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  const Text("Puntos", style: TextStyle(color: Colors.white70)),
                  const SizedBox(height: 18),
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Center(
                      child: Icon(Icons.qr_code_2, size: 160, color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Vence: 15/03/2023", style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
