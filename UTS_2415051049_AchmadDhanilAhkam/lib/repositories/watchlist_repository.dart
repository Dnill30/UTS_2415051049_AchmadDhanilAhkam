import '../constants.dart';
import '../models/watchlist_item.dart';
import '../services/watchlist_service.dart';

class WatchlistRepository {
  final WatchlistService _service;

  WatchlistRepository(this._service);

  Future<List<WatchlistItem>> getWatchlist() => _service.fetchAll(kStudentId);
}