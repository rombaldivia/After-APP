import 'package:flutter/material.dart';
import '../neon_theme.dart';

class NeonCard extends StatelessWidget {
  final Widget child;
  final Color glowColor;

  const NeonCard({super.key, required this.child, required this.glowColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: NeonTheme.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: glowColor.withValues(alpha: 0.60),
            blurRadius: 25,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: glowColor.withValues(alpha: 0.35),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}
