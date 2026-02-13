import 'package:flutter/material.dart';
import 'app_shell.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;

  void go(int i) => setState(() => tab = i);

  @override
  Widget build(BuildContext context) {
    return AppShell(
      onGoClients: () => go(2),
      onGoScan: () => go(1),
      onGoPromoters: () => go(0),
    );
  }
}
