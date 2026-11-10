import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/genre.dart';
import '../models/movie.dart';

class TmdbException implements Exception {
  final String message;

  const TmdbException(this.message);

  @override
  String toString() => message;
}

class MovieService {
  static const _host = 'api.themoviedb.org';
  static const _language = 'en-US';

  final http.Client _client;

  MovieService({http.Client? client}) : _client = client ?? http.Client();

  String get _apiKey => dotenv.env['TMDB_API_KEY'] ?? '';

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String> query = const {},
  ]) async {
    if (_apiKey.isEmpty) {
      throw const TmdbException('API key TMDB belum diisi di file .env');
    }

    final uri = Uri.https(_host, '/3$path', {
      'api_key': _apiKey,
      'language': _language,
      ...query,
    });

    final response =
        await _client.get(uri).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    if (response.statusCode == 401) {
      throw const TmdbException('API key TMDB tidak valid.');
    }
    throw TmdbException('Server TMDB bermasalah (${response.statusCode}).');
  }

  List<Movie> _parseMovies(Map<String, dynamic> json) {
    final results = (json['results'] as List?) ?? const [];
    return results
        .map((e) => Movie.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Movie>> fetchPopular() async {
    final json = await _get('/movie/popular');
    return _parseMovies(json);
  }

  Future<List<Movie>> searchMovies(String query) async {
    final json = await _get('/search/movie', {
      'query': query,
      'include_adult': 'false',
    });
    return _parseMovies(json);
  }

  Future<List<Movie>> fetchByGenre(int genreId) async {
    final json = await _get('/discover/movie', {
      'with_genres': '$genreId',
      'sort_by': 'popularity.desc',
    });
    return _parseMovies(json);
  }

  Future<List<Genre>> fetchGenres() async {
    final json = await _get('/genre/movie/list');
    final list = (json['genres'] as List?) ?? const [];
    return list.map((e) => Genre.fromJson(e as Map<String, dynamic>)).toList();
  }
}