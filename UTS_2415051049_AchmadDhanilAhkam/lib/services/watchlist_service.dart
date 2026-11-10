import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/watchlist_item.dart';

class DatabaseException implements Exception {
  final String message;

  const DatabaseException(this.message);

  @override
  String toString() => message;
}

class WatchlistService {
  static const _table = 'watchlist';

  final SupabaseClient _client;

  WatchlistService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  Future<List<WatchlistItem>> fetchAll(String studentId) async {
    try {
      final data = await _client
          .from(_table)
          .select()
          .eq('student_id', studentId)
          .order('created_at', ascending: false);

      return data
          .map((row) => WatchlistItem.fromJson(row))
          .toList();
    } on PostgrestException catch (e) {
      throw DatabaseException('Database bermasalah: ${e.message}');
    }
  }
}