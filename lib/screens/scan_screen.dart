import 'package:flutter/material.dart';
import '../neon_theme.dart';
import '../widgets/neon_background.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 3))
          ..repeat();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NeonBackground(
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) {
            final t = controller.value;
            final a = (0.25 + 0.55 * (1 - (t - 0.5).abs() * 2))
                .clamp(0.0, 1.0);
            return Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 40,
                    spreadRadius: 2,
                    color: NeonTheme.neonCyan.withValues(alpha: a),
                  ),
                ],
                border: Border.all(
                  color: NeonTheme.neonCyan.withValues(alpha: 0.75),
                  width: 2,
                ),
              ),
              child: const Center(
                child: Icon(Icons.nfc, size: 90, color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }
}
