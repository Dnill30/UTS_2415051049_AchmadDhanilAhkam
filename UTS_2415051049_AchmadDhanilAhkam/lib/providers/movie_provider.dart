import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/movie_service.dart';

enum LoadStatus { idle, loading, success, error }

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<Movie> _movies = [];
  List<Genre> _genres = [];
  String? _error;
  String _query = '';
  int? _selectedGenreId;

  Timer? _debounce;
  int _requestId = 0;

  LoadStatus get status => _status;
  List<Movie> get movies => _movies;
  List<Genre> get genres => _genres;
  String? get error => _error;
  String get query => _query;
  int? get selectedGenreId => _selectedGenreId;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isEmpty => _status == LoadStatus.success && _movies.isEmpty;

  /// Dipanggil sekali saat aplikasi dibuka.
  Future<void> init() async {
    await Future.wait([_loadGenres(), _fetch()]);
  }

  Future<void> retry() => _fetch();

  void setQuery(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final trimmed = value.trim();
      if (trimmed == _query) return;
      _query = trimmed;
      _fetch();
    });
  }

  void selectGenre(int? genreId) {
    if (genreId == _selectedGenreId) return;
    _selectedGenreId = genreId;
    _fetch();
  }

  Future<void> _loadGenres() async {
    try {
      _genres = await _repository.getGenres();
      notifyListeners();
    } catch (e) {
      // Genre bersifat tambahan, jadi kegagalan tidak menampilkan error layar.
      debugPrint('loadGenres error: $e');
    }
  }

  Future<void> _fetch() async {
    final id = ++_requestId;
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      List<Movie> result;
      if (_query.isNotEmpty) {
        result = await _repository.searchMovies(_query);
        final genreId = _selectedGenreId;
        if (genreId != null) {
          result = result.where((m) => m.genreIds.contains(genreId)).toList();
        }
      } else if (_selectedGenreId != null) {
        result = await _repository.getMoviesByGenre(_selectedGenreId!);
      } else {
        result = await _repository.getPopularMovies();
      }

      if (id != _requestId) return;
      _movies = result;
      _status = LoadStatus.success;
    } on TmdbException catch (e) {
      if (id != _requestId) return;
      _error = e.message;
      _status = LoadStatus.error;
    } catch (e) {
      if (id != _requestId) return;
      _error = 'Gagal memuat film. Periksa koneksi internet kamu.';
      _status = LoadStatus.error;
      debugPrint('fetch error: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}