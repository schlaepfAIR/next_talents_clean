import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:next_talents_clean/src/theme/theme.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return _buildHeader(context, isMobile, null);
        }

        return FutureBuilder<DocumentSnapshot>(
          future:
              FirebaseFirestore.instance
                  .collection('users')
                  .doc(user.uid)
                  .get(),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const SizedBox();
            }
            final userType = userSnapshot.data?.get('type') ?? 'bewerber';
            return _buildHeader(context, isMobile, userType);
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isMobile, String? userType) {
    final user = FirebaseAuth.instance.currentUser;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(70)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: AppColors.electricBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.play_arrow, color: AppColors.accent),
          ),
          const SizedBox(width: 16),
          const Text(
            'Next Talents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGrey,
            ),
          ),
          const Spacer(),
          if (!isMobile)
            Row(
              children: [
                _NavItem(
                  title: 'Home',
                  onTap: () => Navigator.pushNamed(context, '/'),
                ),
                const SizedBox(width: 20),
                _NavItem(
                  title: 'Wie es funktioniert',
                  onTap: () => Navigator.pushNamed(context, '/how-it-works'),
                ),
                const SizedBox(width: 20),
                _NavItem(
                  title: 'Kontakt',
                  onTap: () => Navigator.pushNamed(context, '/contact'),
                ),
                if (user != null && userType != null) ...[
                  const SizedBox(width: 20),
                  if (userType == 'firma')
                    _NavItem(
                      title: 'Firmen-Dashboard',
                      onTap:
                          () =>
                              Navigator.pushNamed(context, '/firmenDashboard'),
                    )
                  else
                    _NavItem(
                      title: 'Dashboard',
                      onTap: () => Navigator.pushNamed(context, '/dashboard'),
                    ),
                  const SizedBox(width: 20),
                  _NavItem(
                    title: 'Profil',
                    onTap:
                        () => Navigator.pushNamed(
                          context,
                          userType == 'firma'
                              ? '/firmenProfil'
                              : '/bewerberProfil',
                        ),
                  ),
                ],
                const SizedBox(width: 32),
                if (user == null)
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.electricBlue,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Login'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed:
                            () => Navigator.pushNamed(context, '/register'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.electricBlue,
                        ),
                        child: const Text('Registrieren'),
                      ),
                    ],
                  )
                else
                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'profil') {
                        Navigator.pushNamed(
                          context,
                          userType == 'firma'
                              ? '/firmenProfil'
                              : '/bewerberProfil',
                        );
                      } else if (value == 'logout') {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (_) => false,
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                          const PopupMenuItem(
                            value: 'profil',
                            child: Text('Profil'),
                          ),
                          const PopupMenuItem(
                            value: 'logout',
                            child: Text('Logout'),
                          ),
                        ],
                    child: CircleAvatar(
                      backgroundColor: AppColors.electricBlue,
                      child: Text(
                        user?.displayName?.substring(0, 1).toUpperCase() ?? 'U',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
              ],
            ),
          if (isMobile) ...[
            IconButton(
              icon: const Icon(Icons.menu),
              onPressed:
                  () => showModalBottomSheet(
                    context: context,
                    builder: (context) => _MobileDrawer(userType: userType),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _NavItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(title, style: const TextStyle(fontSize: 18)),
    );
  }
}

class _MobileDrawer extends StatelessWidget {
  final String? userType;
  const _MobileDrawer({this.userType});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DrawerItem(
              title: 'Home',
              onTap: () => Navigator.pushNamed(context, '/'),
            ),
            _DrawerItem(
              title: 'Wie es funktioniert',
              onTap: () => Navigator.pushNamed(context, '/how-it-works'),
            ),
            _DrawerItem(
              title: 'Kontakt',
              onTap: () => Navigator.pushNamed(context, '/contact'),
            ),
            if (user != null && userType != null) ...[
              _DrawerItem(
                title: userType == 'firma' ? 'Firmen-Dashboard' : 'Dashboard',
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      userType == 'firma' ? '/firmenDashboard' : '/dashboard',
                    ),
              ),
              _DrawerItem(
                title: 'Profil',
                onTap:
                    () => Navigator.pushNamed(
                      context,
                      userType == 'firma' ? '/firmenProfil' : '/bewerberProfil',
                    ),
              ),
            ],
            const SizedBox(height: 20),
            if (user == null) ...[
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: const Text('Login'),
              ),
              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text('Registrieren'),
              ),
            ] else
              OutlinedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
                },
                child: const Text('Logout'),
              ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
