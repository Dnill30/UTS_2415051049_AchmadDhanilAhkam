class Movie {
  final int id;
  final String title;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String releaseDate;
  final double voteAverage;
  final List<int> genreIds;

  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    this.posterPath,
    this.backdropPath,
    this.releaseDate = '',
    this.voteAverage = 0,
    this.genreIds = const [],
  });

  static const _imageBase = 'https://image.tmdb.org/t/p';

  String? get posterUrl =>
      posterPath == null ? null : '$_imageBase/w500$posterPath';

  String? get largePosterUrl =>
      posterPath == null ? null : '$_imageBase/w780$posterPath';

  String? get backdropUrl =>
      backdropPath == null ? null : '$_imageBase/w780$backdropPath';

  String get year =>
      releaseDate.length >= 4 ? releaseDate.substring(0, 4) : '-';

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      overview: (json['overview'] ?? '') as String,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      releaseDate: (json['release_date'] ?? '') as String,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
      genreIds:
          (json['genre_ids'] as List?)?.map((e) => e as int).toList() ??
              const [],
    );
  }
}