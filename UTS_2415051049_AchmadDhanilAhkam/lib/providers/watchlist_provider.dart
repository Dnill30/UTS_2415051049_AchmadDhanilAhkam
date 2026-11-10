import 'package:flutter/foundation.dart';

import '../models/watchlist_item.dart';
import '../repositories/watchlist_repository.dart';
import '../services/watchlist_service.dart';
import 'movie_provider.dart' show LoadStatus;

enum WatchlistSort { newest, ratingHigh, titleAsc }

enum WatchlistFilter { all, wantToWatch, watched }

class WatchlistProvider extends ChangeNotifier {
  final WatchlistRepository _repository;

  WatchlistProvider(this._repository);

  LoadStatus _status = LoadStatus.idle;
  List<WatchlistItem> _items = [];
  String? _error;
  WatchlistSort _sort = WatchlistSort.newest;
  WatchlistFilter _filter = WatchlistFilter.all;

  LoadStatus get status => _status;
  List<WatchlistItem> get items => _items;
  String? get error => _error;
  WatchlistSort get sort => _sort;
  WatchlistFilter get filter => _filter;
  bool get isLoading => _status == LoadStatus.loading;
  bool get isEmpty => _status == LoadStatus.success && _items.isEmpty;

  /// True jika ada data, tapi filter aktif tidak menemukan satu pun.
  bool get isFilteredEmpty =>
      _status == LoadStatus.success &&
      _items.isNotEmpty &&
      visibleItems.isEmpty;

  int get watchedCount => _items.where((e) => e.isWatched).length;
  int get wantToWatchCount => _items.length - watchedCount;

  /// Daftar yang sudah difilter dan diurutkan, untuk ditampilkan di UI.
  List<WatchlistItem> get visibleItems {
    final list = _items.where((e) {
      switch (_filter) {
        case WatchlistFilter.all:
          return true;
        case WatchlistFilter.wantToWatch:
          return !e.isWatched;
        case WatchlistFilter.watched:
          return e.isWatched;
      }
    }).toList();

    switch (_sort) {
      case WatchlistSort.newest:
        // Urutan dari database sudah terbaru dulu.
        break;
      case WatchlistSort.ratingHigh:
        list.sort((a, b) {
          final ra = a.rating ?? -1;
          final rb = b.rating ?? -1;
          return rb.compareTo(ra);
        });
        break;
      case WatchlistSort.titleAsc:
        list.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
    }
    return list;
  }

  void setSort(WatchlistSort value) {
    if (value == _sort) return;
    _sort = value;
    notifyListeners();
  }

  void setFilter(WatchlistFilter value) {
    if (value == _filter) return;
    _filter = value;
    notifyListeners();
  }

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
      _items = [for (final e in _items) e.id == saved.id ? saved : e];
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
    try {
      final id = item.id;
      if (id == null) {
        return 'Film tidak memiliki ID watchlist yang valid.';
      }
      await _repository.remove(id);
      _items = _items.where((e) => e.id != item.id).toList();
      _status = LoadStatus.success;
      _error = null;
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
