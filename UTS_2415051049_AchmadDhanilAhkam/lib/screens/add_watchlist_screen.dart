import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/movie.dart';
import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';

class AddWatchlistScreen extends StatefulWidget {
  final Movie movie;

  const AddWatchlistScreen({super.key, required this.movie});

  @override
  State<AddWatchlistScreen> createState() => _AddWatchlistScreenState();
}

class _AddWatchlistScreenState extends State<AddWatchlistScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();

  String _status = 'want_to_watch';
  int? _rating;
  bool _saving = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final item = WatchlistItem(
      studentId: kStudentId,
      movieId: widget.movie.id,
      title: widget.movie.title,
      posterPath: widget.movie.posterPath,
      status: _status,
      rating: _status == 'watched' ? _rating : null,
      note: note.isEmpty ? null : note,
    );

    final error = await context.read<WatchlistProvider>().add(item);

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('"${widget.movie.title}" ditambahkan ke watchlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Tambah ke Watchlist')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.movie.title, style: theme.textTheme.titleLarge),
                const SizedBox(height: 20),
                Text('Status', style: theme.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'want_to_watch',
                      label: Text('Ingin ditonton'),
                      icon: Icon(Icons.schedule),
                    ),
                    ButtonSegment(
                      value: 'watched',
                      label: Text('Sudah ditonton'),
                      icon: Icon(Icons.check_circle_outline),
                    ),
                  ],
                  selected: {_status},
                  onSelectionChanged: (s) => setState(() {
                    _status = s.first;
                    if (_status != 'watched') _rating = null;
                  }),
                ),
                if (_status == 'watched') ...[
                  const SizedBox(height: 20),
                  DropdownButtonFormField<int>(
                    value: _rating,
                    decoration: const InputDecoration(
                      labelText: 'Rating kamu (1-10)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.star_outline),
                    ),
                    items: [
                      for (var i = 10; i >= 1; i--)
                        DropdownMenuItem(value: i, child: Text('$i')),
                    ],
                    onChanged: (v) => setState(() => _rating = v),
                    validator: (v) => v == null
                        ? 'Beri rating untuk film yang sudah ditonton'
                        : null,
                  ),
                ],
                const SizedBox(height: 20),
                TextFormField(
                  controller: _noteController,
                  maxLines: 4,
                  maxLength: 200,
                  decoration: const InputDecoration(
                    labelText: 'Catatan (opsional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => (v ?? '').trim().length > 200
                      ? 'Catatan maksimal 200 karakter'
                      : null,
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.bookmark_add_outlined),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}