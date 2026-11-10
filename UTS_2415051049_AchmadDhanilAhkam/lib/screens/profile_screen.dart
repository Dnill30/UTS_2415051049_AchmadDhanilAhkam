import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/profile_avatar.dart';
import '../widgets/stat_card.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<ProfileProvider>().profile;
    final items = context.watch<WatchlistProvider>().items;

    final watched = items.where((e) => e.isWatched).length;
    final wantToWatch = items.length - watched;
    final ratings = items.where((e) => e.rating != null).map((e) => e.rating!);
    final average = ratings.isEmpty
        ? '-'
        : (ratings.reduce((a, b) => a + b) / ratings.length)
            .toStringAsFixed(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Edit profile',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ProfileAvatar(
                  name: profile.name,
                  colorIndex: profile.avatarColor,
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(profile.name,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge),
              ),
              if (profile.bio.isNotEmpty) ...[
                const SizedBox(height: 4),
                Center(
                  child: Text(profile.bio,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium),
                ),
              ],
              const SizedBox(height: 24),
              Text('Statistik', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 0.95,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: [
                  StatCard(
                    icon: Icons.check_circle_outline,
                    value: '$watched',
                    label: 'Sudah ditonton',
                  ),
                  StatCard(
                    icon: Icons.schedule,
                    value: '$wantToWatch',
                    label: 'Ingin ditonton',
                  ),
                  StatCard(
                    icon: Icons.star_outline,
                    value: average,
                    label: 'Rata-rata rating',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('NIM'),
                      subtitle: Text(profile.nim),
                    ),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Kelas'),
                      subtitle: Text(profile.kelas),
                    ),
                    const ListTile(
                      leading: Icon(Icons.info_outline),
                      title: Text('Aplikasi'),
                      subtitle: Text('MovieExplorer v1.0.0'),
                    ),
                    const ListTile(
                      leading: Icon(Icons.movie_filter_outlined),
                      title: Text('Sumber data film'),
                      subtitle: Text('TMDB API'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}