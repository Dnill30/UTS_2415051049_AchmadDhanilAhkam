import 'package:flutter/material.dart';
import '../models/movie.dart';
import 'movie_card.dart';

class MovieGrid extends StatelessWidget {
  final List<Movie> movies;
  final void Function(Movie movie)? onMovieTap;

  const MovieGrid({super.key, required this.movies, this.onMovieTap});

  int _columnsFor(double width) {
    if (width < 600) return 2; // compact
    if (width < 900) return 3; // medium
    if (width < 1200) return 4; // expanded
    return 5; // large
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _columnsFor(constraints.maxWidth),
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: movies.length,
          itemBuilder: (context, i) => MovieCard(
            movie: movies[i],
            onTap: onMovieTap == null ? null : () => onMovieTap!(movies[i]),
          ),
        );
      },
    );
  }
}