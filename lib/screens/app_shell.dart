import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/presentation/auth_providers.dart';
import '../features/nfc/ui/nfc_scan_flow_page.dart';
import '../features/promos/ui/promos_admin_page.dart';
import '../neon_theme.dart';
import '../widgets/neon_background.dart';

import 'dashboard_screen.dart';
import 'client_screen.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(onGoClients: () => setState(() => _index = 2),
                      onGoScan:    () => setState(() => _index = 1)),
      const NfcScanFlowPage(),
      const ClientScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('BOLICHE XTREMO',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.5)),
        actions: [
          IconButton(
            tooltip: 'Gestionar promociones',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const PromosAdminPage()),
            ),
            icon: const Icon(Icons.local_offer_outlined),
          ),
          IconButton(
            onPressed: () => ref.read(authServiceProvider).signOut(),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: NeonBackground(child: SafeArea(child: pages[_index])),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: NeonTheme.bg.withValues(alpha: 0.65),
          boxShadow: [
            BoxShadow(blurRadius: 30,
                color: NeonTheme.neonPink.withValues(alpha: 0.20)),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _index,
          onTap: (v) => setState(() => _index = v),
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
