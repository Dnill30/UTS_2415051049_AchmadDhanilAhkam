import 'package:flutter/foundation.dart';

import '../models/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';
import '../services/watchlist_service.dart';
import 'movie_provider.dart' show LoadStatus;

class WatchlistProvider extends ChangeNotifier {
  final WatchlistRepository _repository;

  WatchlistProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<WatchlistItem> _items = [];
  String? _error;

  LoadStatus get status => _status;
  List<WatchlistItem> get items => _items;
  String? get error => _error;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isEmpty => _status == LoadStatus.success && _items.isEmpty;

  /// True jika film dengan id TMDB tersebut sudah ada di watchlist.
  bool contains(int movieId) => _items.any((e) => e.movieId == movieId);

  Future<void> load() async {
    _status = LoadStatus.loading;
    _error = null;
    notifyListeners();

    try {
      _items = await _repository.getWatchlist();
      _status = LoadStatus.success;
    } on DatabaseException catch (e) {
      _error = e.message;
      _status = LoadStatus.error;
    } catch (e) {
      _error = 'Gagal memuat watchlist. Periksa koneksi internet kamu.';
      _status = LoadStatus.error;
      debugPrint('watchlist load error: $e');
    }
    notifyListeners();
  }
}