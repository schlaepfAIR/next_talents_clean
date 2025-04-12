import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:next_talents_clean/src/auth/auth_service.dart';
import 'package:next_talents_clean/src/profile/profile_model.dart';
import 'package:next_talents_clean/src/shared/layout.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final data = await _authService.getProfileData(user.uid);
    if (data != null) {
      setState(() {
        _profile = UserProfile.fromMap(data);
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppLayout(
      child:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : _profile == null
              ? const Center(child: Text('Profil nicht gefunden'))
              : Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Willkommen, ${_profile!.firstName} ${_profile!.lastName}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    Text('E-Mail: ${_profile!.email}'),
                    Text('Typ: ${_profile!.userType}'),
                  ],
                ),
              ),
    );
  }
}
