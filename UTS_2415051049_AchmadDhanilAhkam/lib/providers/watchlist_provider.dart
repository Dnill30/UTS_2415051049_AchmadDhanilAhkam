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

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  Future<String?> add(WatchlistItem item) async {
    if (contains(item.movieId)) {
      return 'Film ini sudah ada di watchlist.';
    }

    try {
      final saved = await _repository.add(item);
      _items = [saved, ..._items];
      _status = LoadStatus.success;
      _error = null;
      notifyListeners();
      return null;
    } on DatabaseException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('watchlist add error: $e');
      return 'Gagal menyimpan. Periksa koneksi internet kamu.';
    }
  }

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  Future<String?> update(WatchlistItem item) async {
    try {
      final saved = await _repository.update(item);
      _items = [
        for (final e in _items) e.id == saved.id ? saved : e,
      ];
      notifyListeners();
      return null;
    } on DatabaseException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('watchlist update error: $e');
      return 'Gagal memperbarui. Periksa koneksi internet kamu.';
    }
  }

  /// Mengembalikan null jika berhasil, atau pesan error jika gagal.
  Future<String?> remove(WatchlistItem item) async {
    final id = item.id;
    if (id == null) return 'Data tidak punya id.';

    try {
      await _repository.remove(id);
      _items = _items.where((e) => e.id != id).toList();
      notifyListeners();
      return null;
    } on DatabaseException catch (e) {
      return e.message;
    } catch (e) {
      debugPrint('watchlist remove error: $e');
      return 'Gagal menghapus. Periksa koneksi internet kamu.';
    }
  }
}