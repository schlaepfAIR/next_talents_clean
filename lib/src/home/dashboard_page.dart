import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:next_talents_clean/src/shared/header.dart';
import 'package:next_talents_clean/src/shared/footer.dart';
import 'package:next_talents_clean/src/screens/job_detail_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final userId = FirebaseAuth.instance.currentUser!.uid;

  Future<void> addToWishlist(String jobId, String companyId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(jobId)
        .set({'addedAt': Timestamp.now(), 'jobId': jobId});

    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'wishlistedBy': FieldValue.arrayUnion([userId]),
    });
  }

  Future<void> removeFromWishlist(String jobId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .doc(jobId)
        .delete();

    await FirebaseFirestore.instance.collection('jobs').doc(jobId).update({
      'wishlistedBy': FieldValue.arrayRemove([userId]),
    });
  }

  Stream<List<DocumentSnapshot>> getWishlistJobs() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('wishlist')
        .snapshots()
        .asyncMap((snapshot) async {
          final jobIds = snapshot.docs.map((doc) => doc.id).toList();
          if (jobIds.isEmpty) return [];
          final jobsSnap =
              await FirebaseFirestore.instance
                  .collection('jobs')
                  .where(FieldPath.documentId, whereIn: jobIds)
                  .get();
          return jobsSnap.docs;
        });
  }

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
                  // Neue Inserate + Wunschliste
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Neue Inserate',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: StreamBuilder<QuerySnapshot>(
                            stream:
                                FirebaseFirestore.instance
                                    .collection('jobs')
                                    .where('published', isEqualTo: true)
                                    .orderBy('createdAt', descending: true)
                                    .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  'Fehler beim Laden: ${snapshot.error}',
                                );
                              }
                              final jobs = snapshot.data?.docs ?? [];
                              if (jobs.isEmpty) {
                                return const Text(
                                  'Aktuell sind keine Inserate verfügbar.',
                                );
                              }
                              return ListView.builder(
                                itemCount: jobs.length,
                                itemBuilder: (context, index) {
                                  final data =
                                      jobs[index].data()
                                          as Map<String, dynamic>;
                                  final jobId = jobs[index].id;
                                  final title = data['title'] ?? 'Unbenannt';
                                  final description = data['description'] ?? '';
                                  final createdAt =
                                      (data['createdAt'] as Timestamp?)
                                          ?.toDate();
                                  final companyEmail =
                                      data['companyEmail'] ?? 'unbekannt';

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            title,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Firma: $companyEmail',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            description,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (createdAt != null)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4,
                                              ),
                                              child: Text(
                                                'Erstellt am: ${DateFormat('dd.MM.yyyy').format(createdAt)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          const SizedBox(height: 8),
                                          Row(
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (_) => JobDetailPage(
                                                            jobData: data,
                                                          ),
                                                    ),
                                                  );
                                                },
                                                child: const Text('Details'),
                                              ),
                                              const SizedBox(width: 12),
                                              TextButton(
                                                onPressed:
                                                    () => addToWishlist(
                                                      jobId,
                                                      data['companyId'] ?? '',
                                                    ),
                                                child: const Text(
                                                  'Auf Wunschliste',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Meine Wunschliste',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: StreamBuilder<List<DocumentSnapshot>>(
                            stream: getWishlistJobs(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              final wishlistJobs = snapshot.data!;
                              if (wishlistJobs.isEmpty) {
                                return const Text(
                                  'Keine Jobs auf deiner Wunschliste.',
                                );
                              }
                              return ListView.builder(
                                itemCount: wishlistJobs.length,
                                itemBuilder: (context, index) {
                                  final job =
                                      wishlistJobs[index].data()
                                          as Map<String, dynamic>;
                                  final jobId = wishlistJobs[index].id;
                                  final title = job['title'] ?? 'Unbenannt';
                                  final createdAt =
                                      (job['createdAt'] as Timestamp?)
                                          ?.toDate();

                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(title),
                                      subtitle: Text(
                                        createdAt != null
                                            ? 'Erstellt am: ${DateFormat('dd.MM.yyyy').format(createdAt)}'
                                            : '',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed:
                                            () => removeFromWishlist(jobId),
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
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
