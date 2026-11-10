import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/watchlist_provider.dart';
import '../widgets/state_view.dart';
import '../widgets/watchlist_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WatchlistProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Watchlist'),
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            icon: const Icon(Icons.refresh),
            onPressed: provider.isLoading
                ? null
                : () => context.read<WatchlistProvider>().load(),
          ),
        ],
      ),
      body: StateView(
        isLoading: provider.isLoading,
        errorMessage: provider.error,
        isEmpty: provider.isEmpty,
        emptyMessage:
            'Watchlist masih kosong.\nTambahkan film dari halaman detail.',
        onRetry: () => context.read<WatchlistProvider>().load(),
        child: GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 520,
            mainAxisExtent: 132,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: provider.items.length,
          itemBuilder: (context, i) => WatchlistCard(item: provider.items[i]),
        ),
      ),
    );
  }
}