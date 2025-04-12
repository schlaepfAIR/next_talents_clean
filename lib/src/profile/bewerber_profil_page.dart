import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class BewerberProfilPage extends StatefulWidget {
  const BewerberProfilPage({super.key});

  @override
  State<BewerberProfilPage> createState() => _BewerberProfilPageState();
}

class _BewerberProfilPageState extends State<BewerberProfilPage> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _wohnortController = TextEditingController();
  final _suchradiusController = TextEditingController();
  final _salaryMinController = TextEditingController();
  final _salaryMaxController = TextEditingController();

  double _pensumMin = 50;
  double _pensumMax = 100;
  bool _jobsharing = false;
  bool _onlyPraktikum = false;
  DateTime? _startDate;
  List<String> _selectedAusbildung = [];
  List<String> _selectedKategorien = [];

  bool _isLoading = false;
  String? _error;

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
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);
    try {
      final snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
      if (snapshot.exists) {
        final data = snapshot.data()!;
        _nameController.text = data['name'] ?? '';
        _descriptionController.text = data['beschreibung'] ?? '';
        _requirementsController.text = data['anforderungen'] ?? '';
        _wohnortController.text = data['wohnort'] ?? '';
        _suchradiusController.text = data['suchradius']?.toString() ?? '';
        _salaryMinController.text = data['salaryMin']?.toString() ?? '';
        _salaryMaxController.text = data['salaryMax']?.toString() ?? '';
        _pensumMin = data['pensumMin']?.toDouble() ?? 50;
        _pensumMax = data['pensumMax']?.toDouble() ?? 100;
        _jobsharing = data['jobsharing'] ?? false;
        _onlyPraktikum = data['onlyPraktikum'] ?? false;
        _selectedAusbildung = List<String>.from(data['ausbildung'] ?? []);
        _selectedKategorien = List<String>.from(data['kategorien'] ?? []);
        if (data['startDate'] != null) {
          _startDate = (data['startDate'] as Timestamp).toDate();
        }
      }
    } catch (e) {
      _error = "Fehler beim Laden: $e";
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid);
      await doc.set({
        'name': _nameController.text.trim(),
        'beschreibung': _descriptionController.text.trim(),
        'anforderungen': _requirementsController.text.trim(),
        'wohnort': _wohnortController.text.trim(),
        'suchradius': int.tryParse(_suchradiusController.text.trim()) ?? 0,
        'salaryMin': int.tryParse(_salaryMinController.text.trim()) ?? 0,
        'salaryMax': int.tryParse(_salaryMaxController.text.trim()) ?? 0,
        'pensumMin': _pensumMin,
        'pensumMax': _pensumMax,
        'jobsharing': _jobsharing,
        'onlyPraktikum': _onlyPraktikum,
        'ausbildung': _selectedAusbildung,
        'kategorien': _selectedKategorien,
        'startDate':
            _startDate != null ? Timestamp.fromDate(_startDate!) : null,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Profil gespeichert')));
      }
    } catch (e) {
      setState(() => _error = "Fehler beim Speichern: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bewerberprofil')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Beschreibung',
                      ),
                      maxLines: 3,
                    ),
                    TextField(
                      controller: _requirementsController,
                      decoration: const InputDecoration(
                        labelText: 'Anforderungen',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    const Text('Arbeitspensum (%)'),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _pensumMin,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            label: 'Min ${_pensumMin.round()}%',
                            onChanged:
                                (value) => setState(() => _pensumMin = value),
                          ),
                        ),
                        Expanded(
                          child: Slider(
                            value: _pensumMax,
                            min: 5,
                            max: 100,
                            divisions: 19,
                            label: 'Max ${_pensumMax.round()}%',
                            onChanged:
                                (value) => setState(() => _pensumMax = value),
                          ),
                        ),
                      ],
                    ),
                    CheckboxListTile(
                      value: _jobsharing,
                      title: const Text('Jobsharing gewünscht'),
                      onChanged:
                          (val) => setState(() => _jobsharing = val ?? false),
                    ),
                    CheckboxListTile(
                      value: _onlyPraktikum,
                      title: const Text('Nur Praktikum'),
                      onChanged:
                          (val) =>
                              setState(() => _onlyPraktikum = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children:
                          _ausbildungsoptionen.map((option) {
                            return FilterChip(
                              label: Text(option),
                              selected: _selectedAusbildung.contains(option),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedAusbildung.add(option);
                                  } else {
                                    _selectedAusbildung.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 12),
                    const Text('Branchen (max. 5 auswählen)'),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children:
                          _branchen.map((option) {
                            return FilterChip(
                              label: Text(option),
                              selected: _selectedKategorien.contains(option),
                              onSelected: (selected) {
                                setState(() {
                                  if (selected &&
                                      _selectedKategorien.length < 5) {
                                    _selectedKategorien.add(option);
                                  } else {
                                    _selectedKategorien.remove(option);
                                  }
                                });
                              },
                            );
                          }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _wohnortController,
                      decoration: const InputDecoration(labelText: 'Wohnort'),
                    ),
                    TextField(
                      controller: _suchradiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Suchradius in km',
                      ),
                    ),
                    TextField(
                      controller: _salaryMinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Mindestlohn (CHF)',
                      ),
                    ),
                    TextField(
                      controller: _salaryMaxController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Maximallohn (CHF)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Frühester Starttermin: '),
                        const SizedBox(width: 8),
                        Text(
                          _startDate != null
                              ? DateFormat('dd.MM.yyyy').format(_startDate!)
                              : 'Nicht gewählt',
                        ),
                        IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _pickDate,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveUserProfile,
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
              ),
    );
  }
}
