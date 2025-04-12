import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_posting.dart';
import 'job_form_page.dart';
import 'job_detail_page.dart';

class FirmenDashboardPage extends StatelessWidget {
  const FirmenDashboardPage({Key? key}) : super(key: key);

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
                    return ListTile(
                      title: Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        'Status: ${job.published ? 'Veröffentlicht' : 'Deaktiviert'}\n'
                        'Matches: ${job.matchesCount}   Bewerbungen: ${job.applicationsCount}',
                      ),
                      isThreeLine: true,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobFormPage(job: job),
                          ),
                        );
                      },
                      leading: const Icon(Icons.work),
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
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(title),
                        subtitle: Text(
                          description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
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
        child: const Icon(Icons.add),
        tooltip: 'Neues Inserat erstellen',
      ),
    );
  }
}
