import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/watchlist_item.dart';
import '../providers/watchlist_provider.dart';

class EditWatchlistScreen extends StatefulWidget {
  final WatchlistItem item;

  const EditWatchlistScreen({super.key, required this.item});

  @override
  State<EditWatchlistScreen> createState() => _EditWatchlistScreenState();
}

class _EditWatchlistScreenState extends State<EditWatchlistScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteController;

  late String _status;
  int? _rating;
  bool _saving = false;
  bool _deleting = false;

  bool get _busy => _saving || _deleting;

  @override
  void initState() {
    super.initState();
    _status = widget.item.status;
    _rating = widget.item.rating;
    _noteController = TextEditingController(text: widget.item.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final note = _noteController.text.trim();
    final updated = WatchlistItem(
      id: widget.item.id,
      studentId: widget.item.studentId,
      movieId: widget.item.movieId,
      title: widget.item.title,
      posterPath: widget.item.posterPath,
      status: _status,
      rating: _status == 'watched' ? _rating : null,
      note: note.isEmpty ? null : note,
      createdAt: widget.item.createdAt,
    );

    final error = await context.read<WatchlistProvider>().update(updated);

    if (!mounted) return;
    setState(() => _saving = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context);
    messenger.showSnackBar(
      const SnackBar(content: Text('Perubahan disimpan')),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: const Text('Hapus dari watchlist?'),
        content: Text(
          '"${widget.item.title}" akan dihapus dari watchlist kamu. '
          'Tindakan ini tidak bisa dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _deleting = true);

    final error =
        await context.read<WatchlistProvider>().remove(widget.item);

    if (!mounted) return;
    setState(() => _deleting = false);

    final messenger = ScaffoldMessenger.of(context);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }

    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text('"${widget.item.title}" dihapus dari watchlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Watchlist'),
        actions: [
          IconButton(
            tooltip: 'Hapus',
            icon: const Icon(Icons.delete_outline),
            onPressed: _busy ? null : _confirmDelete,
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(widget.item.title, style: theme.textTheme.titleLarge),
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
                  onPressed: _busy ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_saving ? 'Menyimpan...' : 'Simpan perubahan'),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                  ),
                  onPressed: _busy ? null : _confirmDelete,
                  icon: _deleting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.delete_outline),
                  label: Text(
                      _deleting ? 'Menghapus...' : 'Hapus dari Watchlist'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}