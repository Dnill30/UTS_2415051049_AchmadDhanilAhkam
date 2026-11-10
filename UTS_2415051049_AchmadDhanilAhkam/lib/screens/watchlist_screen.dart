import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../widgets/state_view.dart';
import '../widgets/watchlist_card.dart';
import 'edit_watchlist_screen.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  static String _sortLabel(WatchlistSort s) {
    switch (s) {
      case WatchlistSort.newest:
        return 'Terbaru';
      case WatchlistSort.ratingHigh:
        return 'Rating tertinggi';
      case WatchlistSort.titleAsc:
        return 'Judul A-Z';
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();
    final visible = provider.visibleItems;

    final filteredEmpty =
        !provider.isLoading &&
        provider.error == null &&
        !provider.isEmpty &&
        visible.isEmpty;

    final emptyMessage = provider.isEmpty
        ? 'Watchlist masih kosong.\nTambahkan film dari halaman detail.'
        : 'Tidak ada film dengan filter ini.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          PopupMenuButton<WatchlistSort>(
            tooltip: 'Urutkan',
            icon: const Icon(Icons.sort),
            initialValue: provider.sort,
            onSelected: (v) => context.read<WatchlistProvider>().setSort(v),
            itemBuilder: (_) => [
              for (final s in WatchlistSort.values)
                PopupMenuItem(value: s, child: Text(_sortLabel(s))),
            ],
          ),
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading
                ? null
                : () => context.read<WatchlistProvider>().load(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  ChoiceChip(
                    label: Text('Semua (${provider.items.length})'),
                    selected: provider.filter == WatchlistFilter.all,
                    onSelected: (_) => context
                        .read<WatchlistProvider>()
                        .setFilter(WatchlistFilter.all),
                  ),
                  ChoiceChip(
                    label: Text(
                      'Ingin ditonton (${provider.wantToWatchCount})',
                    ),
                    selected: provider.filter == WatchlistFilter.wantToWatch,
                    onSelected: (_) => context
                        .read<WatchlistProvider>()
                        .setFilter(WatchlistFilter.wantToWatch),
                  ),
                  ChoiceChip(
                    label: Text('Sudah ditonton (${provider.watchedCount})'),
                    selected: provider.filter == WatchlistFilter.watched,
                    onSelected: (_) => context
                        .read<WatchlistProvider>()
                        .setFilter(WatchlistFilter.watched),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Urutan: ${_sortLabel(provider.sort)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
          Expanded(
            child: StateView(
              isLoading: provider.isLoading,
              errorMessage: provider.error,
              isEmpty: provider.isEmpty || filteredEmpty,
              emptyMessage: emptyMessage,
              onRetry: () => context.read<WatchlistProvider>().load(),
              child: GridView.builder(
                padding: const EdgeInsets.all(12),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 520,
                  mainAxisExtent: 132,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: visible.length,
                itemBuilder: (context, i) {
                  final item = visible[i];
                  return WatchlistCard(
                    item: item,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditWatchlistScreen(item: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
