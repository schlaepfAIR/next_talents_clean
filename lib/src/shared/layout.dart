import 'package:flutter/material.dart';
import 'package:next_talents_clean/src/shared/footer.dart';
import 'package:next_talents_clean/src/shared/header.dart';

class AppLayout extends StatelessWidget {
  final Widget child;

  const AppLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [const Header(), Expanded(child: child), const Footer()],
      ),
    );
  }
}
