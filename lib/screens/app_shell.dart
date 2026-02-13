import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../widgets/neon_background.dart';
import '../neon_theme.dart';

import 'dashboard_screen.dart';
import 'scan_screen.dart';
import 'client_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  final VoidCallback? onGoClients;
  final VoidCallback? onGoPromoters;
  final VoidCallback? onGoScan;

  const AppShell({
    super.key,
    this.onGoClients,
    this.onGoPromoters,
    this.onGoScan,
  });

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onGoClients: widget.onGoClients),
      const ScanScreen(),
      const ClientScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('BOLICHE XTREMO'),
        actions: [
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: NeonBackground(
        child: SafeArea(child: pages[index]),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: NeonTheme.bg.withValues(alpha: 0.65),
          boxShadow: [
            BoxShadow(
              blurRadius: 30,
              color: NeonTheme.neonPink.withValues(alpha: 0.20),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: index,
          onTap: (v) {
            setState(() => index = v);

            if (v == 0) widget.onGoPromoters?.call();
            if (v == 1) widget.onGoScan?.call();
            if (v == 2) widget.onGoClients?.call();
          },
          selectedItemColor: NeonTheme.neonPink,
          unselectedItemColor: Colors.white60,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.nfc), label: 'Escanear'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Cliente'),
          ],
        ),
      ),
    );
  }
}
