import 'package:flutter/material.dart';

import '../models/movie.dart';

class HeroBanner extends StatelessWidget {
  final Movie movie;
  final bool wide;
  final bool inWatchlist;
  final VoidCallback onDetail;
  final VoidCallback onAdd;

  const HeroBanner({
    super.key,
    required this.movie,
    required this.wide,
    required this.inWatchlist,
    required this.onDetail,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = theme.scaffoldBackgroundColor;
    final fallback = Container(color: theme.colorScheme.surfaceContainerHighest);

    final imageUrl = wide
        ? (movie.backdropUrl ?? movie.largePosterUrl)
        : (movie.largePosterUrl ?? movie.backdropUrl);

    return SizedBox(
      height: wide ? 440 : 480,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl == null)
            fallback
          else
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              errorBuilder: (_, __, ___) => fallback,
            ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.45, 1.0],
                colors: [
                  Colors.transparent,
                  bg.withValues(alpha: 0.4),
                  bg,
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Align(
              alignment: Alignment.bottomLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TRENDING MINGGU INI',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      movie.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(movie.voteAverage.toStringAsFixed(1),
                            style: theme.textTheme.bodyMedium),
                        const SizedBox(width: 12),
                        Text(movie.year, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      movie.overview,
                      maxLines: wide ? 3 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: onDetail,
                          icon: const Icon(Icons.info_outline),
                          label: const Text('Detail'),
                        ),
                        OutlinedButton.icon(
                          onPressed: inWatchlist ? null : onAdd,
                          icon: Icon(inWatchlist
                              ? Icons.bookmark_added
                              : Icons.bookmark_add_outlined),
                          label: Text(
                              inWatchlist ? 'Di Watchlist' : 'Watchlist'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}