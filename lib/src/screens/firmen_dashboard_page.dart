import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_posting.dart';
import 'job_form_page.dart';
import 'job_detail_page.dart';

class FirmenDashboardPage extends StatelessWidget {
  const FirmenDashboardPage({super.key});

  Stream<List<JobPosting>> _loadCompanyJobs() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final query = FirebaseFirestore.instance
        .collection('jobs')
        .where('companyId', isEqualTo: userId)
        .orderBy('createdAt', descending: true);
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return JobPosting.fromDocument(data, doc.id);
      }).toList();
    });
  }

  Stream<List<QueryDocumentSnapshot>> _loadWunschlisten(String jobId) {
    return FirebaseFirestore.instance
        .collection('wunschlisten')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .map((snap) => snap.docs);
  }

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Firmen-Dashboard')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Eigene Inserate',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<List<JobPosting>>(
              stream: _loadCompanyJobs(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Fehler beim Laden: ${snapshot.error}');
                }
                final jobs = snapshot.data ?? [];
                if (jobs.isEmpty) {
                  return const Text('Keine Inserate vorhanden.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ExpansionTile(
                        title: Text(job.title),
                        subtitle: Text(
                          'Status: ${job.published ? 'Veröffentlicht' : 'Deaktiviert'}\nMatches: ${job.matchesCount}   Bewerbungen: ${job.applicationsCount}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => JobFormPage(job: job),
                                  ),
                                );
                              },
                            ),
                            Switch(
                              value: job.published,
                              onChanged: (val) async {
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('jobs')
                                      .doc(job.id)
                                      .update({'published': val});
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Status konnte nicht geändert werden: $e',
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                        children: [
                          StreamBuilder<List<QueryDocumentSnapshot>>(
                            stream: _loadWunschlisten(job.id),
                            builder: (context, wunschSnapshot) {
                              if (wunschSnapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final wishes = wunschSnapshot.data ?? [];
                              if (wishes.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    'Keine Bewerber auf der Wunschliste.',
                                  ),
                                );
                              }
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:
                                      wishes.map((doc) {
                                        final data =
                                            doc.data() as Map<String, dynamic>;
                                        return Text(
                                          '- ${data['userEmail'] ?? data['userId']}',
                                        );
                                      }).toList(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const Divider(height: 40),
            const Text(
              'Andere veröffentlichte Inserate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('jobs')
                      .where('published', isEqualTo: true)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Text('Fehler beim Laden: ${snapshot.error}');
                }
                final jobs =
                    snapshot.data?.docs
                        .where((doc) => doc['companyId'] != userId)
                        .toList();

                if (jobs == null || jobs.isEmpty) {
                  return const Text('Keine weiteren Inserate gefunden.');
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final data = jobs[index].data() as Map<String, dynamic>;
                    final title = data['title'] ?? '';
                    final description = data['description'] ?? '';
                    final company =
                        data['companyName'] ?? data['companyEmail'] ?? '';
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Erstellt von: $company',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => JobDetailPage(jobData: data),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const JobFormPage()),
          );
        },
        tooltip: 'Neues Inserat erstellen',
        child: const Icon(Icons.add),
      ),
    );
  }
}
