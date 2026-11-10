import '../models/genre.dart';
import '../models/movie.dart';
import '../services/movie_service.dart';

class MovieRepository {
  final MovieService _service;

  MovieRepository(this._service);

  Future<List<Movie>> getPopularMovies() => _service.fetchPopular();

  Future<List<Movie>> searchMovies(String query) =>
      _service.searchMovies(query);

  Future<List<Movie>> getMoviesByGenre(int genreId) =>
      _service.fetchByGenre(genreId);

  Future<List<Genre>> getGenres() => _service.fetchGenres();
}