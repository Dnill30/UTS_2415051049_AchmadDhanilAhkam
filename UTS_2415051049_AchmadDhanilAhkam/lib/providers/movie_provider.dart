import 'package:flutter/foundation.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';

enum LoadStatus { idle, loading, success, error }

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<Movie> _movies = [];
  String? _error;

  LoadStatus get status => _status;
  List<Movie> get movies => _movies;
  String? get error => _error;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isEmpty => _status == LoadStatus.success && _movies.isEmpty;

  Future<void> loadPopular() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _movies = await _repository.getPopularMovies();
      _status = LoadStatus.success;
    } catch (e) {
      _error = 'Gagal memuat film. Periksa koneksi internet kamu.';
      _status = LoadStatus.error;
      debugPrint('loadPopular error: $e');
    }
    notifyListeners();
  }
}