import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'providers/home_provider.dart';
import 'providers/movie_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/watchlist_provider.dart';
import 'repositories/movie_repository.dart';
import 'repositories/profile_repository.dart';
import 'repositories/watchlist_repository.dart';
import 'screens/main_shell.dart';
import 'services/movie_service.dart';
import 'services/profile_service.dart';
import 'services/watchlist_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const MovieExplorerApp());
}

class MovieExplorerApp extends StatelessWidget {
  const MovieExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => HomeProvider(MovieRepository(MovieService()))..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => MovieProvider(MovieRepository(MovieService()))..init(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              WatchlistProvider(WatchlistRepository(WatchlistService()))
                ..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileProvider(ProfileRepository(ProfileService()))..load(),
        ),
      ],
      child: MaterialApp(
        title: 'MovieExplorer',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        themeMode: ThemeMode.dark,
        home: const MainShell(),
      ),
    );
  }
}