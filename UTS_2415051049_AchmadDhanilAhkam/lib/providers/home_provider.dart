import 'package:flutter/foundation.dart';

import '../models/movie.dart';
import '../repositories/movie_repository.dart';
import '../services/movie_service.dart';
import 'movie_provider.dart' show LoadStatus;

class HomeProvider extends ChangeNotifier {
  final MovieRepository _repository;

  HomeProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<Movie> _trending = [];
  List<Movie> _popular = [];
  List<Movie> _topRated = [];
  List<Movie> _upcoming = [];
  String? _error;

  LoadStatus get status => _status;
  List<Movie> get trending => _trending;
  List<Movie> get popular => _popular;
  List<Movie> get topRated => _topRated;
  List<Movie> get upcoming => _upcoming;
  String? get error => _error;

  bool get isLoading => _status == LoadStatus.loading;
  bool get hasData =>
      _trending.isNotEmpty ||
      _popular.isNotEmpty ||
      _topRated.isNotEmpty ||
      _upcoming.isNotEmpty;
  bool get isEmpty => _status == LoadStatus.success && !hasData;

  /// Film untuk banner: trending pertama yang punya gambar.
  Movie? get featured {
    for (final m in _trending) {
      if (m.backdropPath != null || m.posterPath != null) return m;
    }
    return null;
  }

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getTrendingMovies(),
        _repository.getPopularMovies(),
        _repository.getTopRatedMovies(),
        _repository.getUpcomingMovies(),
      ]);
      _trending = results[0];
      _popular = results[1];
      _topRated = results[2];
      _upcoming = results[3];
      _status = LoadStatus.success;
    } on TmdbException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
    } catch (e) {
      _error = 'Gagal memuat beranda. Periksa koneksi internet kamu.';
      _status = LoadStatus.error;
      debugPrint('home load error: $e');
    }
    notifyListeners();
  }
}