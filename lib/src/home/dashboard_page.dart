import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Neue Inserate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _InserateList(),

            const SizedBox(height: 30),
            const Text(
              'Aktuelle Matches',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _MatchesList(),
          ],
        ),
      ),
    );
  }
}

class _InserateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final inserate = List<String>.generate(5, (i) => 'Inserat #${i + 1}');
    return Column(
      children:
          inserate.map((e) => Card(child: ListTile(title: Text(e)))).toList(),
    );
  }
}

class _MatchesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final matches = List<String>.generate(3, (i) => 'Match Kandidat ${i + 1}');
    return Column(
      children:
          matches
              .map(
                (e) => Card(
                  color: Colors.green.shade50,
                  child: ListTile(title: Text(e)),
                ),
              )
              .toList(),
    );
  }
}
