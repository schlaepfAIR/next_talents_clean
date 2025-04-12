import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirmenProfilPage extends StatefulWidget {
  const FirmenProfilPage({super.key});

  @override
  State<FirmenProfilPage> createState() => _FirmenProfilPageState();
}

class _FirmenProfilPageState extends State<FirmenProfilPage> {
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Kein Benutzer angemeldet");

      final doc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      if (data != null) {
        _companyNameController.text = data['companyName'] ?? '';
        _emailController.text = data['email'] ?? '';
      }
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Laden der Firmendaten: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCompanyData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("Kein Benutzer angemeldet");

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'companyName': _companyNameController.text.trim(),
        'email': _emailController.text.trim(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Firmendaten erfolgreich aktualisiert')),
      );
    } catch (e) {
      setState(() {
        _error = 'Fehler beim Speichern der Firmendaten: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Firmenprofil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextField(
                      controller: _companyNameController,
                      decoration: const InputDecoration(
                        labelText: 'Firmenname',
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'E-Mail'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveCompanyData,
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
      ),
    );
  }
}
