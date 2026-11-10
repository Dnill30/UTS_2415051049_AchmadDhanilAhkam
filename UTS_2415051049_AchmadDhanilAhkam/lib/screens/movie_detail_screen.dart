import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/watchlist_provider.dart';
import 'add_watchlist_screen.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 700;
          final poster = _Poster(url: movie.posterUrl);
          final info = _Info(movie: movie);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: isWide
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 280, child: poster),
                      const SizedBox(width: 24),
                      Expanded(child: info),
                    ],
                  )
                : Column(
                    children: [
                      Center(child: SizedBox(width: 220, child: poster)),
                      const SizedBox(height: 16),
                      info,
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _Poster extends StatelessWidget {
  final String? url;

  const _Poster({this.url});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final placeholder = Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Icon(Icons.movie_outlined,
          size: 56, color: theme.colorScheme.outline),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 2 / 3,
        child: url == null
            ? placeholder
            : Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => placeholder,
              ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Movie movie;

  const _Info({required this.movie});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inWatchlist =
        context.watch<WatchlistProvider>().contains(movie.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(movie.title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.star, size: 20, color: Colors.amber),
            const SizedBox(width: 4),
            Text(movie.voteAverage.toStringAsFixed(1),
                style: theme.textTheme.titleMedium),
            const SizedBox(width: 16),
            const Icon(Icons.calendar_today_outlined, size: 18),
            const SizedBox(width: 4),
            Text(movie.year, style: theme.textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 16),
        Text('Sinopsis', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          movie.overview.isEmpty
              ? 'Sinopsis belum tersedia.'
              : movie.overview,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: inWatchlist
                ? null
                : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddWatchlistScreen(movie: movie),
                      ),
                    );
                  },
            icon: Icon(inWatchlist
                ? Icons.bookmark_added
                : Icons.bookmark_add_outlined),
            label: Text(
                inWatchlist ? 'Sudah di Watchlist' : 'Tambah ke Watchlist'),
          ),
        ),
      ],
    );
  }
}