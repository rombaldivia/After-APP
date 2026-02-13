import 'package:flutter/material.dart';
import '../neon_theme.dart';

class NeonBackground extends StatelessWidget {
  final Widget child;
  const NeonBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topCenter,
          radius: 1.5,
          colors: [
            NeonTheme.neonPurple,
            NeonTheme.bg,
          ],
        ),
      ),
      child: child,
    );
  }
}
