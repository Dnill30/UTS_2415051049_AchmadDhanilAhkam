import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/movie_provider.dart';
import '../widgets/movie_grid.dart';
import '../widgets/state_view.dart';
import 'movie_detail_screen.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MovieProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: StateView(
        isLoading: provider.isLoading,
        errorMessage: provider.error,
        isEmpty: provider.isEmpty,
        emptyMessage: 'Tidak ada film ditemukan.',
        onRetry: () => context.read<MovieProvider>().loadPopular(),
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
    );
  }
}