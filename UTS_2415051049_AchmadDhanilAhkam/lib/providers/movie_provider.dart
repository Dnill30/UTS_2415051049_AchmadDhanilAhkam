import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/genre.dart';
import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/movie_service.dart';

enum LoadStatus { idle, loading, success, error }

enum MovieSort { popular, ratingHigh, newest, titleAsc }

enum MovieWatchFilter { all, notInWatchlist, inWatchlist }

class MovieProvider extends ChangeNotifier {
  final MovieRepository _repository;

  MovieProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<Movie> _movies = [];
  List<Genre> _genres = [];
  String? _error;
  String _query = '';
  int? _selectedGenreId;
  MovieSort _sort = MovieSort.popular;
  MovieWatchFilter _watchFilter = MovieWatchFilter.all;

  Timer? _debounce;
  int _requestId = 0;

  LoadStatus get status => _status;
  List<Movie> get movies => _movies;
  List<Genre> get genres => _genres;
  String? get error => _error;
  String get query => _query;
  int? get selectedGenreId => _selectedGenreId;
  MovieSort get sort => _sort;
  MovieWatchFilter get watchFilter => _watchFilter;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isEmpty => _status == LoadStatus.success && _movies.isEmpty;

  /// Daftar film setelah filter watchlist dan sort diterapkan.
  /// [inWatchlist] dipakai untuk mengecek apakah film ada di watchlist.
  List<Movie> visibleMovies(bool Function(int movieId) inWatchlist) {
    final list = _movies.where((m) {
      switch (_watchFilter) {
        case MovieWatchFilter.all:
          return true;
        case MovieWatchFilter.notInWatchlist:
          return !inWatchlist(m.id);
        case MovieWatchFilter.inWatchlist:
          return inWatchlist(m.id);
      }
    }).toList();

    switch (_sort) {
      case MovieSort.popular:
        // Urutan asli dari TMDB.
        break;
      case MovieSort.ratingHigh:
        list.sort((a, b) => b.voteAverage.compareTo(a.voteAverage));
        break;
      case MovieSort.newest:
        list.sort((a, b) => b.releaseDate.compareTo(a.releaseDate));
        break;
      case MovieSort.titleAsc:
        list.sort(
            (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
        break;
    }
    return list;
  }

  void setSort(MovieSort value) {
    if (value == _sort) return;
    _sort = value;
    notifyListeners();
  }

  void setWatchFilter(MovieWatchFilter value) {
    if (value == _watchFilter) return;
    _watchFilter = value;
    notifyListeners();
  }

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