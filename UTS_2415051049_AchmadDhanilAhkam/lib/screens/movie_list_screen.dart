import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/genre_filter_bar.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_view.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static String _sortLabel(MovieSort s) {
    switch (s) {
      case MovieSort.popular:
        return 'Populer';
      case MovieSort.ratingHigh:
        return 'Rating tertinggi';
      case MovieSort.newest:
        return 'Terbaru';
      case MovieSort.titleAsc:
        return 'Judul A-Z';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();
    final watchlist = context.watch<WatchlistProvider>();

    final visible = provider.visibleMovies(watchlist.contains);

    final filteredEmpty = !provider.isLoading &&
        provider.error == null &&
        provider.movies.isNotEmpty &&
        visible.isEmpty;

    final emptyMessage = filteredEmpty
        ? 'Tidak ada film dengan filter ini.'
        : provider.query.isNotEmpty
            ? 'Tidak ada film untuk "${provider.query}".'
            : 'Tidak ada film ditemukan.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
        actions: [
          PopupMenuButton<MovieSort>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: provider.sort,
            onSelected: (v) => context.read<MovieProvider>().setSort(v),
            itemBuilder: (_) => [
              for (final s in MovieSort.values)
                PopupMenuItem(value: s, child: Text(_sortLabel(s))),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: _searchController,
              builder: (context, value, _) {
                return TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) =>
                      context.read<MovieProvider>().setQuery(text),
                  decoration: InputDecoration(
                    hintText: 'Cari film...',
                    isDense: true,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              _searchController.clear();
                              context.read<MovieProvider>().setQuery('');
                            },
                          ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                );
              },
            ),
          ),
          GenreFilterBar(
            genres: provider.genres,
            selectedId: provider.selectedGenreId,
            onSelected: (id) => context.read<MovieProvider>().selectGenre(id),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Center(
                  child: ChoiceChip(
                    label: const Text('Semua'),
                    selected: provider.watchFilter == MovieWatchFilter.all,
                    onSelected: (_) => context
                        .read<MovieProvider>()
                        .setWatchFilter(MovieWatchFilter.all),
                  ),
                ),
                const SizedBox(width: 8),
                Center(
                  child: ChoiceChip(
                    label: const Text('Belum di watchlist'),
                    selected:
                        provider.watchFilter == MovieWatchFilter.notInWatchlist,
                    onSelected: (_) => context
                        .read<MovieProvider>()
                        .setWatchFilter(MovieWatchFilter.notInWatchlist),
                  ),
                ),
                const SizedBox(width: 8),
                Center(
                  child: ChoiceChip(
                    label: const Text('Sudah di watchlist'),
                    selected:
                        provider.watchFilter == MovieWatchFilter.inWatchlist,
                    onSelected: (_) => context
                        .read<MovieProvider>()
                        .setWatchFilter(MovieWatchFilter.inWatchlist),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Urutan: ${_sortLabel(provider.sort)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: StateView(
              isLoading: provider.isLoading,
              errorMessage: provider.error,
              isEmpty: provider.isEmpty || filteredEmpty,
              emptyMessage: emptyMessage,
              onRetry: () => context.read<MovieProvider>().retry(),
              child: MovieGrid(
                movies: visible,
                onMovieTap: (movie) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MovieDetailScreen(movie: movie),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}