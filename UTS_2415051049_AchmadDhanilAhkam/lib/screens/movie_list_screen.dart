import 'package:flutter/material.dart';
import '../data/dummy_movies.dart';
import '../widgets/movie_grid.dart';

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Movies')),
      body: MovieGrid(movies: dummyMovies),
    );
  }
}