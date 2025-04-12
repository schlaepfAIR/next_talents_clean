import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BewerberProfilPage extends StatefulWidget {
  const BewerberProfilPage({super.key});

  @override
  State<BewerberProfilPage> createState() => _BewerberProfilPageState();
}

class _BewerberProfilPageState extends State<BewerberProfilPage> {
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();

  bool _isLoading = false;
  String? _error;

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
        _cityController.text = data['city'] ?? '';
        _countryController.text = data['country'] ?? '';
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
        'city': _cityController.text.trim(),
        'country': _countryController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bewerberprofil')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
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
                      controller: _cityController,
                      decoration: const InputDecoration(
                        labelText: 'Wohnort / PLZ',
                      ),
                    ),
                    TextField(
                      controller: _countryController,
                      decoration: const InputDecoration(labelText: 'Land'),
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
