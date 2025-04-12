import 'package:cloud_firestore/cloud_firestore.dart';

class JobPosting {
  final String id;
  final String title;
  final String description;
  final String requirements;
  final String arbeitsort;
  final int salaryMin;
  final int salaryMax;
  final int pensumMin;
  final int pensumMax;
  final bool jobsharing;
  final bool onlyPraktikum;
  final DateTime? startDate;
  final List<String> ausbildung;
  final List<String> kategorien;
  final String companyId;
  final bool published;
  final DateTime? createdAt;
  final int matchesCount;
  final int applicationsCount;

  JobPosting({
    required this.id,
    required this.title,
    required this.description,
    required this.requirements,
    required this.arbeitsort,
    required this.salaryMin,
    required this.salaryMax,
    required this.pensumMin,
    required this.pensumMax,
    required this.jobsharing,
    required this.onlyPraktikum,
    required this.startDate,
    required this.ausbildung,
    required this.kategorien,
    required this.companyId,
    required this.published,
    required this.createdAt,
    this.matchesCount = 0,
    this.applicationsCount = 0,
  });

  factory JobPosting.fromDocument(Map<String, dynamic> data, String id) {
    return JobPosting(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      requirements: data['requirements'] ?? '',
      arbeitsort: data['arbeitsort'] ?? '',
      salaryMin: data['salaryMin'] ?? 0,
      salaryMax: data['salaryMax'] ?? 0,
      pensumMin: data['pensumMin'] ?? 0,
      pensumMax: data['pensumMax'] ?? 0,
      jobsharing: data['jobsharing'] ?? false,
      onlyPraktikum: data['onlyPraktikum'] ?? false,
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      ausbildung: List<String>.from(data['ausbildung'] ?? []),
      kategorien: List<String>.from(data['kategorien'] ?? []),
      companyId: data['companyId'] ?? '',
      published: data['published'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      matchesCount: data['matchesCount'] ?? 0,
      applicationsCount: data['applicationsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'requirements': requirements,
      'arbeitsort': arbeitsort,
      'salaryMin': salaryMin,
      'salaryMax': salaryMax,
      'pensumMin': pensumMin,
      'pensumMax': pensumMax,
      'jobsharing': jobsharing,
      'onlyPraktikum': onlyPraktikum,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'ausbildung': ausbildung,
      'kategorien': kategorien,
      'companyId': companyId,
      'published': published,
      'createdAt':
          createdAt != null
              ? Timestamp.fromDate(createdAt!)
              : FieldValue.serverTimestamp(),
      'matchesCount': matchesCount,
      'applicationsCount': applicationsCount,
    };
  }
}
