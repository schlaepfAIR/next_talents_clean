import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_posting.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JobFormPage extends StatefulWidget {
  final JobPosting? job;

  const JobFormPage({super.key, this.job});

  @override
  State<JobFormPage> createState() => _JobFormPageState();
}

class _JobFormPageState extends State<JobFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _arbeitsortController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  double _pensumMin = 50;
  double _pensumMax = 100;
  bool _jobsharing = false;
  bool _onlyPraktikum = false;
  DateTime? _startDate;

  List<String> _ausbildung = [];
  List<String> _kategorien = [];

  final List<String> _ausbildungsoptionen = [
    'kein',
    'grundausbildung',
    'quereinsteiger',
    'praktische erfahrung im bereich',
    'bachelor',
    'master',
    'phd',
  ];

  final List<String> _branchen = [
    'Bank',
    'Industrie',
    'Bildung',
    'Gesundheit',
    'IT',
    'Verwaltung',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.job != null) {
      final j = widget.job!;
      _titleController.text = j.title;
      _descriptionController.text = j.description;
      _requirementsController.text = j.requirements;
      _arbeitsortController.text = j.arbeitsort;
      _salaryMinController.text = j.salaryMin.toString();
      _salaryMaxController.text = j.salaryMax.toString();
      _pensumMin = j.pensumMin.toDouble();
      _pensumMax = j.pensumMax.toDouble();
      _jobsharing = j.jobsharing;
      _onlyPraktikum = j.onlyPraktikum;
      _startDate = j.startDate;
      _ausbildung = List<String>.from(j.ausbildung);
      _kategorien = List<String>.from(j.kategorien);
    }
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final jobData = {
      'title': _titleController.text.trim(),
      'description': _descriptionController.text.trim(),
      'requirements': _requirementsController.text.trim(),
      'arbeitsort': _arbeitsortController.text.trim(),
      'salaryMin': int.tryParse(_salaryMinController.text.trim()) ?? 0,
      'salaryMax': int.tryParse(_salaryMaxController.text.trim()) ?? 0,
      'pensumMin': _pensumMin,
      'pensumMax': _pensumMax,
      'jobsharing': _jobsharing,
      'onlyPraktikum': _onlyPraktikum,
      'startDate': _startDate != null ? Timestamp.fromDate(_startDate!) : null,
      'ausbildung': _ausbildung,
      'kategorien': _kategorien,
      'companyId': user.uid,
      'companyEmail': user.email ?? '',
      'published': widget.job?.published ?? false,
      'createdAt': widget.job?.createdAt ?? FieldValue.serverTimestamp(),
    };

    final docRef = FirebaseFirestore.instance.collection('jobs');
    if (widget.job != null) {
      await docRef.doc(widget.job!.id).update(jobData);
    } else {
      await docRef.add(jobData);
    }

    if (mounted) Navigator.pop(context);
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.job == null ? 'Neues Inserat' : 'Inserat bearbeiten',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Job Titel'),
                validator: (v) => v!.isEmpty ? 'Titel erforderlich' : null,
              ),
              const SizedBox(height: 12),
              const Text('Pensum (%)'),
              Row(
                children: [
                  Expanded(
                    child: Slider(
                      value: _pensumMin,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: 'Min ${_pensumMin.round()}%',
                      onChanged: (val) => setState(() => _pensumMin = val),
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _pensumMax,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      label: 'Max ${_pensumMax.round()}%',
                      onChanged: (val) => setState(() => _pensumMax = val),
                    ),
                  ),
                ],
              ),
              CheckboxListTile(
                value: _jobsharing,
                title: const Text('Jobsharing möglich'),
                onChanged: (val) => setState(() => _jobsharing = val ?? false),
              ),
              CheckboxListTile(
                value: _onlyPraktikum,
                title: const Text('Nur Praktikum'),
                onChanged:
                    (val) => setState(() => _onlyPraktikum = val ?? false),
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Jobbeschreibung'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _requirementsController,
                decoration: const InputDecoration(labelText: 'Anforderungen'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              const Text('Ausbildung'),
              Wrap(
                spacing: 8,
                children:
                    _ausbildungsoptionen.map((opt) {
                      return FilterChip(
                        label: Text(opt),
                        selected: _ausbildung.contains(opt),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _ausbildung.add(opt);
                            } else {
                              _ausbildung.remove(opt);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Branchen (1–5 auswählen)'),
              Wrap(
                spacing: 8,
                children:
                    _branchen.map((opt) {
                      return FilterChip(
                        label: Text(opt),
                        selected: _kategorien.contains(opt),
                        onSelected: (selected) {
                          setState(() {
                            if (selected &&
                                !_kategorien.contains(opt) &&
                                _kategorien.length < 5) {
                              _kategorien.add(opt);
                            } else {
                              _kategorien.remove(opt);
                            }
                          });
                        },
                      );
                    }).toList(),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _arbeitsortController,
                decoration: const InputDecoration(
                  labelText: 'Arbeitsort (Adresse)',
                ),
              ),
              TextFormField(
                controller: _salaryMinController,
                decoration: const InputDecoration(labelText: 'Salär von (CHF)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _salaryMaxController,
                decoration: const InputDecoration(labelText: 'Salär bis (CHF)'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Starttermin: '),
                  Text(
                    _startDate != null
                        ? DateFormat('dd.MM.yyyy').format(_startDate!)
                        : 'Nicht gewählt',
                  ),
                  IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _pickStartDate,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveJob,
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
