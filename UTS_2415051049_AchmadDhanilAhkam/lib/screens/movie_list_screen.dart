import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/movie_provider.dart';
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    final emptyMessage = provider.query.isNotEmpty
        ? 'Tidak ada film untuk "${provider.query}".'
        : 'Tidak ada film ditemukan.';

    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
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
          Expanded(
            child: StateView(
              isLoading: provider.isLoading,
              errorMessage: provider.error,
              isEmpty: provider.isEmpty,
              emptyMessage: emptyMessage,
              onRetry: () => context.read<MovieProvider>().retry(),
              child: MovieGrid(
                movies: provider.movies,
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