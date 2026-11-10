import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.person,
                  size: 48, color: theme.colorScheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Achmad Dhanil Ahkam',
                style: theme.textTheme.titleLarge),
          ),
          const SizedBox(height: 24),
          const Card(
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.badge_outlined),
                  title: Text('NIM'),
                  subtitle: Text('2415051049'),
                ),
                ListTile(
                  leading: Icon(Icons.school_outlined),
                  title: Text('Kelas'),
                  subtitle: Text('PTI 5C'),
                ),
                ListTile(
                  leading: Icon(Icons.info_outline),
                  title: Text('Aplikasi'),
                  subtitle: Text('MovieExplorer v1.0.0'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}