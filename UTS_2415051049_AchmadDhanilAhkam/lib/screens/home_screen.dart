import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/movie.dart';
import '../providers/home_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/hero_banner.dart';
import '../widgets/movie_row.dart';
import '../widgets/state_view.dart';
import 'add_watchlist_screen.dart';
import 'movie_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openDetail(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MovieDetailScreen(movie: movie)),
    );
  }

  void _openAdd(BuildContext context, Movie movie) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddWatchlistScreen(movie: movie)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final home = context.watch<HomeProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final featured = home.featured;

    return Scaffold(
      body: StateView(
        isLoading: home.isLoading && !home.hasData,
        errorMessage: home.hasData ? null : home.error,
        isEmpty: home.isEmpty,
        emptyMessage: 'Belum ada film untuk ditampilkan.',
        onRetry: () => context.read<HomeProvider>().load(),
        child: RefreshIndicator(
          onRefresh: () => context.read<HomeProvider>().load(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 700;

              return CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          height: 32,
                          // ignore: unnecessary_underscores
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.movie_filter),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'NilFlix',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                  if (featured != null)
                    SliverToBoxAdapter(
                      child: HeroBanner(
                        movie: featured,
                        wide: wide,
                        inWatchlist: watchlist.contains(featured.id),
                        onDetail: () => _openDetail(context, featured),
                        onAdd: () => _openAdd(context, featured),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: 'Trending',
                      movies: home.trending,
                      onTap: (m) => _openDetail(context, m),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: 'Populer',
                      movies: home.popular,
                      onTap: (m) => _openDetail(context, m),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: 'Rating Tertinggi',
                      movies: home.topRated,
                      onTap: (m) => _openDetail(context, m),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: MovieRow(
                      title: 'Segera Tayang',
                      movies: home.upcoming,
                      onTap: (m) => _openDetail(context, m),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}