import 'package:flutter/material.dart';
import 'package:next_talents_clean/src/theme/theme.dart';
import 'package:next_talents_clean/src/shared/header.dart';
import 'package:next_talents_clean/src/shared/footer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          Header(),
          Expanded(
            child: Center(
              child: Text(
                'Willkommen bei Next Talents!',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Footer(),
        ],
      ),
    );
  }
}
