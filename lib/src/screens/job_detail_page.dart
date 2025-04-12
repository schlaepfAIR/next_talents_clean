import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class JobDetailPage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const JobDetailPage({super.key, required this.jobData});

  @override
  Widget build(BuildContext context) {
    final title = jobData['title'] ?? 'Kein Titel';
    final description = jobData['description'] ?? '-';
    final requirements = jobData['requirements'] ?? '-';
    final pensumMin = jobData['pensumMin']?.toString() ?? '-';
    final pensumMax = jobData['pensumMax']?.toString() ?? '-';
    final jobsharing = jobData['jobsharing'] == true ? 'Ja' : 'Nein';
    final ausbildung = (jobData['ausbildung'] as List<dynamic>? ?? []).join(
      ', ',
    );
    final arbeitsort = jobData['arbeitsort'] ?? '-';
    final startDate =
        jobData['startDate'] != null
            ? DateFormat(
              'dd.MM.yyyy',
            ).format((jobData['startDate'] as Timestamp).toDate())
            : '-';
    final salaryMin = jobData['salaryMin']?.toString() ?? '-';
    final salaryMax = jobData['salaryMax']?.toString() ?? '-';
    final onlyPraktikum = jobData['onlyPraktikum'] == true ? 'Ja' : 'Nein';
    final kategorien = (jobData['kategorien'] as List<dynamic>? ?? []).join(
      ', ',
    );
    final createdAt =
        jobData['createdAt'] != null
            ? DateFormat(
              'dd.MM.yyyy',
            ).format((jobData['createdAt'] as Timestamp).toDate())
            : '-';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Erstellt am: $createdAt',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Text('Jobbeschreibung:', style: _sectionTitle),
            Text(description),
            const SizedBox(height: 16),
            Text('Anforderungen:', style: _sectionTitle),
            Text(requirements),
            const SizedBox(height: 16),
            Text('Pensum: $pensumMin% – $pensumMax%', style: _sectionTitle),
            const SizedBox(height: 8),
            Text('Jobsharing: $jobsharing'),
            const SizedBox(height: 16),
            Text('Ausbildung:', style: _sectionTitle),
            Text(ausbildung),
            const SizedBox(height: 16),
            Text('Arbeitsort:', style: _sectionTitle),
            Text(arbeitsort),
            const SizedBox(height: 16),
            Text('Starttermin:', style: _sectionTitle),
            Text(startDate),
            const SizedBox(height: 16),
            Text('Salärband:', style: _sectionTitle),
            Text('CHF $salaryMin – CHF $salaryMax'),
            const SizedBox(height: 16),
            Text('Nur Praktikum:', style: _sectionTitle),
            Text(onlyPraktikum),
            const SizedBox(height: 16),
            Text('Kategorien:', style: _sectionTitle),
            Text(kategorien),
          ],
        ),
      ),
    );
  }

  TextStyle get _sectionTitle =>
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 16);
}
