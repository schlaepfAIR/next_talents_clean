import 'package:flutter/material.dart';

class DashboardFirmaPage extends StatelessWidget {
  const DashboardFirmaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firmen-Dashboard')),
      body: const Center(child: Text('Willkommen im Firmen-Dashboard!')),
    );
  }
}
