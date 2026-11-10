import 'package:flutter/material.dart';

import '../models/genre.dart';

class GenreFilterBar extends StatelessWidget {
  final List<Genre> genres;
  final int? selectedId;
  final ValueChanged<int?> onSelected;

  const GenreFilterBar({
    super.key,
    required this.genres,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (genres.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: genres.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final genre = genres[i];
          final selected = genre.id == selectedId;
          return Center(
            child: FilterChip(
              label: Text(genre.name),
              selected: selected,
              onSelected: (_) => onSelected(selected ? null : genre.id),
            ),
          );
        },
      ),
    );
  }
}