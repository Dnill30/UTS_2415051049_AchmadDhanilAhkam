import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'movie_list_screen.dart';
import 'profile_screen.dart';
import 'watchlist_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _screens = <Widget>[
    HomeScreen(),
    MovieListScreen(),
    WatchlistScreen(),
    ProfileScreen(),
  ];

  static const _destinations = <({IconData icon, IconData selected, String label})>[
    (icon: Icons.home_outlined, selected: Icons.home, label: 'Home'),
    (icon: Icons.movie_outlined, selected: Icons.movie, label: 'Movies'),
    (icon: Icons.bookmark_border, selected: Icons.bookmark, label: 'Watchlist'),
    (icon: Icons.person_outline, selected: Icons.person, label: 'Profile'),
  ];

  void _onSelect(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        final body = IndexedStack(index: _index, children: _screens);

        if (isWide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _index,
                  onDestinationSelected: _onSelect,
                  labelType: NavigationRailLabelType.all,
                  destinations: [
                    for (final d in _destinations)
                      NavigationRailDestination(
                        icon: Icon(d.icon),
                        selectedIcon: Icon(d.selected),
                        label: Text(d.label),
                      ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: body),
              ],
            ),
          );
        }

        return Scaffold(
          body: body,
          bottomNavigationBar: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _onSelect,
            destinations: [
              for (final d in _destinations)
                NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selected),
                  label: d.label,
                ),
            ],
          ),
        );
      },
    );
  }
}