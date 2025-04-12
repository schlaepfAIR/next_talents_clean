import 'package:flutter/material.dart';
import 'package:next_talents_clean/src/shared/header.dart';
import 'package:next_talents_clean/src/shared/footer.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Header(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Neue Inserate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Neue Inserate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text('Hier erscheinen die neusten Stellenangebote.'),
                        // TODO: Ersetze dies mit dynamischer Liste
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Aktuelle Matches
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Aktuelle Matches',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 12),
                        Text('Hier siehst du deine aktuellen Matches.'),
                        // TODO: Ersetze dies mit dynamischer Liste
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
