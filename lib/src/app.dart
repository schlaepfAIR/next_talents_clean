import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:next_talents_clean/src/auth/login_page.dart';
import 'package:next_talents_clean/src/home/home_page.dart';
import 'package:next_talents_clean/src/profile/profile_page.dart';
import 'package:next_talents_clean/src/auth/register_page.dart';
import 'package:next_talents_clean/src/theme/theme.dart';
import 'package:next_talents_clean/src/home/dashboard_page.dart';
import 'package:next_talents_clean/src/profile/bewerber_profil_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Next Talents',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      initialRoute: '/',
      routes: {
        '/': (_) => const HomePage(),
        '/login': (_) => const LoginPage(),
        '/register': (_) => const RegisterPage(),
        '/profile': (_) => const ProfilePage(),
        '/dashboard': (_) => const DashboardPage(),
        '/bewerberProfil': (_) => const BewerberProfilPage(), // Füge dies hinzu
      },
    );
  }
}
