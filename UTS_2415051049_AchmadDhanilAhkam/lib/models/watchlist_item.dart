class WatchlistItem {
  final int? id;
  final String studentId;
  final int movieId;
  final String title;
  final String? posterPath;
  final String status; // 'want_to_watch' atau 'watched'
  final int? rating;
  final String? note;
  final DateTime? createdAt;

  const WatchlistItem({
    this.id,
    required this.studentId,
    required this.movieId,
    required this.title,
    this.posterPath,
    this.status = 'want_to_watch',
    this.rating,
    this.note,
    this.createdAt,
  });

  factory WatchlistItem.fromJson(Map<String, dynamic> json) {
    return WatchlistItem(
      id: json['id'] as int?,
      studentId: json['student_id'] as String,
      movieId: json['movie_id'] as int,
      title: json['title'] as String,
      posterPath: json['poster_path'] as String?,
      status: (json['status'] ?? 'want_to_watch') as String,
      rating: json['rating'] as int?,
      note: json['note'] as String?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  /// Untuk insert/update. id dan created_at diisi otomatis oleh database.
  Map<String, dynamic> toJson() => {
        'student_id': studentId,
        'movie_id': movieId,
        'title': title,
        'poster_path': posterPath,
        'status': status,
        'rating': rating,
        'note': note,
      };

  WatchlistItem copyWith({String? status, int? rating, String? note}) {
    return WatchlistItem(
      id: id,
      studentId: studentId,
      movieId: movieId,
      title: title,
      posterPath: posterPath,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}