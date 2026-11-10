import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieRepository {
  final MovieService _service;

  MovieRepository(this._service);

  Future<List<Movie>> getPopularMovies() => _service.fetchPopular();
}