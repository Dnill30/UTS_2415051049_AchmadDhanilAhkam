import 'package:flutter/material.dart';
import '../widgets/screen_placeholder.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const ScreenPlaceholder(title: 'Watchlist', icon: Icons.bookmark_border);
}