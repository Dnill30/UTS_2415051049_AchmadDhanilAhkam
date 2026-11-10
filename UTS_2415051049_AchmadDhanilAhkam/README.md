# MovieExplorer

Aplikasi mobile Flutter untuk menjelajahi film dan mengelola watchlist pribadi.
Katalog film diambil dari TMDB API, sedangkan watchlist (status, rating, catatan)
disimpan di database Supabase. Tampilan terinspirasi gaya aplikasi streaming
dengan tema gelap dan baris poster horizontal.

## Identitas
- Nama: Achmad Dhanil Ahkam
- NIM: 2415051049
- Kelas: PTI 5C
- Mata kuliah: Pemrograman Mobile (Project UTS)

## Fitur
- Home dengan banner film unggulan dan baris Trending, Populer, Rating Tertinggi, Segera Tayang
- Pencarian film, filter genre, filter status watchlist, dan sort (Populer, Rating, Terbaru, Judul)
- Detail film dengan passing data antar-screen
- Watchlist (CRUD): tambah, lihat, edit status/rating/catatan, hapus dengan dialog konfirmasi
- Filter dan sort watchlist
- Profile yang dapat diedit (disimpan lokal) dengan statistik: jumlah ditonton dan rata-rata rating
- Loading, error, dan empty state di semua daftar
- Layout responsif: NavigationBar (compact) dan NavigationRail (wide), grid yang berubah kolom
- Validasi form dan feedback melalui SnackBar dan AlertDialog

## Tech Stack
- Flutter dan Dart (Material 3)
- Provider (ChangeNotifier) untuk state management
- http untuk REST API
- supabase_flutter untuk database
- flutter_dotenv untuk konfigurasi key
- shared_preferences untuk data profile lokal

## REST API
TMDB API (https://www.themoviedb.org), endpoint yang dipakai:
`/movie/popular`, `/trending/movie/week`, `/movie/top_rated`, `/movie/upcoming`,
`/search/movie`, `/discover/movie`, `/genre/movie/list`.

## Backend / Database
Supabase (PostgreSQL), tabel `watchlist`:

| Kolom | Tipe |
|---|---|
| id | bigint (primary key, identity) |
| student_id | text |
| movie_id | int |
| title | text |
| poster_path | text |
| status | text (`want_to_watch` / `watched`) |
| rating | int (1-10) |
| note | text |
| created_at | timestamptz |

Hanya publishable (anon) key yang dipakai di aplikasi. Tidak ada service_role key.

## Arsitektur
UI (screens/widgets) -> Provider -> Repository -> Service -> TMDB API / Supabase

```
lib/
├── models/         movie, genre, watchlist_item, profile
├── services/       movie_service, watchlist_service, profile_service
├── repositories/   movie_repository, watchlist_repository, profile_repository
├── providers/      home_provider, movie_provider, watchlist_provider, profile_provider
├── screens/        main_shell, home, movie_list, movie_detail, add_watchlist,
│                   edit_watchlist, watchlist, profile, edit_profile
├── widgets/        movie_card, movie_grid, movie_row, hero_banner, state_view, ...
├── theme/          app_theme
└── main.dart
```
Screen tidak memanggil HTTP atau database secara langsung.

## Screenshot
| Home | Movies | Detail |
|---|---|---|
| ![](screenshots/home.png) | ![](screenshots/list.png) | ![](screenshots/detail.png) |

| Tambah | Edit | Watchlist |
|---|---|---|
| ![](screenshots/create.png) | ![](screenshots/edit.png) | ![](screenshots/watchlist.png) |

| Responsive | Data API | Data Database |
|---|---|---|
| ![](screenshots/responsive.png) | ![](screenshots/api.png) | ![](screenshots/database.png) |

## Cara Menjalankan
1. Pastikan Flutter SDK terpasang (`flutter doctor`).
2. Clone repository:
   ```
   git clone https://github.com/USERNAME_KAMU/UTS_2415051049_AchmadDhanilAhkam.git
   cd UTS_2415051049_AchmadDhanilAhkam
   ```
3. Salin `.env.example` menjadi `.env`, lalu isi:
   ```
   TMDB_API_KEY=api_key_v3_tmdb
   SUPABASE_URL=url_project_supabase
   SUPABASE_ANON_KEY=publishable_key_supabase
   ```
4. Buat tabel di Supabase (SQL Editor):
   ```sql
   create table watchlist (
     id bigint generated always as identity primary key,
     student_id text not null,
     movie_id int not null,
     title text not null,
     poster_path text,
     status text not null default 'want_to_watch',
     rating int check (rating between 1 and 10),
     note text,
     created_at timestamptz default now()
   );
   alter table watchlist enable row level security;
   create policy "anon full access" on watchlist
     for all to anon using (true) with check (true);
   ```
5. Jalankan:
   ```
   flutter pub get
   flutter run
   ```
6. Build APK: `flutter build apk --release`