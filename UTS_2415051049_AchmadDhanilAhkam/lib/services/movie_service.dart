import '../data/dummy_movies.dart';
import '../models/movie.dart';

/// Sementara memakai data dummy. Diganti TMDB di commit berikutnya.
class MovieService {
  Future<List<Movie>> fetchPopular() async {
    await Future.delayed(const Duration(seconds: 1));
    return dummyMovies;
  }
}