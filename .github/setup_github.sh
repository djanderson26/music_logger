#!/usr/bin/env bash
# =============================================================================
# setup_github.sh — Bootstrap GitHub labels, milestones, and issues for
#                   Music Logger (Phase 1 MVP)
#
# REQUIREMENTS:
#   - GitHub CLI (gh): https://cli.github.com/
#   - Authenticated:   gh auth login
#
# USAGE:
#   cd .github
#   bash setup_github.sh
#
# IDEMPOTENT: Safe to re-run — won't create duplicates.
# =============================================================================

set -euo pipefail

REPO="djanderson26/music_logger"

echo ""
echo "🎵  Music Logger — GitHub setup"
echo "======================================================"

# ── Helpers ───────────────────────────────────────────────────────────────────

info()  { echo ""; echo "▸ $*"; }
ok()    { echo "  ✔  $*"; }
skip()  { echo "  ~  (exists) $*"; }

create_label() {
  local name="$1" color="$2" desc="$3"
  # --force updates the label if it already exists; safe to re-run
  gh label create "$name" --color "$color" --description "$desc" \
    --repo "$REPO" --force > /dev/null
  ok "label: $name"
}

create_milestone() {
  local title="$1" desc="$2"
  # Only create if not already present
  local existing
  existing=$(gh api "repos/$REPO/milestones" \
    --jq ".[] | select(.title == \"$title\") | .number" 2>/dev/null || true)
  if [[ -n "$existing" ]]; then
    skip "milestone: $title"
  else
    gh api "repos/$REPO/milestones" \
      -f title="$title" -f description="$desc" -f state="open" > /dev/null
    ok "milestone: $title"
  fi
}

get_milestone_number() {
  gh api "repos/$REPO/milestones" \
    --jq ".[] | select(.title == \"$1\") | .number" 2>/dev/null
}

create_issue() {
  local title="$1" body="$2" labels="$3" milestone_title="$4"

  # Skip if any issue (open or closed) with this exact title already exists
  local existing
  existing=$(gh issue list --repo "$REPO" --state all --limit 300 \
    --json title --jq ".[] | select(.title == \"$title\") | .title" 2>/dev/null || true)
  if [[ -n "$existing" ]]; then
    skip "issue: $title"
    return
  fi

  local ms_num
  ms_num=$(get_milestone_number "$milestone_title")

  gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "$labels" \
    --milestone "$ms_num" \
    > /dev/null
  ok "issue: $title"
}

# =============================================================================
# 1. LABELS
# =============================================================================
info "Creating labels…"

# Type
create_label "type: feature"  "0075ca" "New functionality"
create_label "type: bug"      "d73a4a" "Something is broken"
create_label "type: chore"    "e4e669" "Maintenance / tooling"
create_label "type: docs"     "0052cc" "Documentation only"

# Priority
create_label "priority: high"   "b60205" "Must-have for the milestone"
create_label "priority: medium" "fbca04" "Should-have"
create_label "priority: low"    "0e8a16" "Nice-to-have"

# Audience
create_label "beginner-friendly" "7057ff" "Good first issue — limited context needed"

# Milestone tags
create_label "milestone: 1-foundation"   "c5def5" "Phase 1 – M1: Project Foundation"
create_label "milestone: 2-api"          "bfd4f2" "Phase 1 – M2: API Integration"
create_label "milestone: 3-detail-pages" "d4c5f9" "Phase 1 – M3: Detail Pages"
create_label "milestone: 4-catalog"      "c2e0c6" "Phase 1 – M4: Personal Catalog"
create_label "milestone: 5-ratings"      "fef2c0" "Phase 1 – M5: Ratings & Reviews"
create_label "milestone: 6-lists"        "f9d0c4" "Phase 1 – M6: Lists"
create_label "milestone: 7-polish"       "e4c1f9" "Phase 1 – M7: Home, Profile & Polish"
create_label "phase-2"                   "ededed" "Future – Phase 2 (Firebase + Social)"

echo ""
echo "✅  Labels done."

# =============================================================================
# 2. MILESTONES
# =============================================================================
info "Creating milestones…"

create_milestone "M1 – Project Foundation"  "Flutter scaffold, Hive setup, navigation, and theming"
create_milestone "M2 – API Integration"     "MusicBrainz, Cover Art Archive, Last.fm, Genius API services"
create_milestone "M3 – Detail Pages"        "Album, Artist, and Song detail screens"
create_milestone "M4 – Personal Catalog"    "Listening status, catalog browsing, and favorites"
create_milestone "M5 – Ratings & Reviews"   "Star ratings and written reviews with edit history"
create_milestone "M6 – Lists"               "Custom static and dynamic lists"
create_milestone "M7 – Home & Polish"       "Home feed, profile page, empty/error states, and final polish"

echo ""
echo "✅  Milestones done."

# =============================================================================
# 3. ISSUES
# =============================================================================
info "Creating issues…"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 1 – Project Foundation
# ──────────────────────────────────────────────────────────────────────────────
M1="M1 – Project Foundation"

create_issue \
"[M1] Scaffold Flutter project with flutter create" \
'## What to do
Run `flutter create music_logger_app` inside the repo root to generate the base Flutter project.

## Steps
1. Open a terminal in the repo root (`music_logger/`).
2. Run: `flutter create music_logger_app`
3. `cd music_logger_app` and run `flutter run`.
4. Confirm the default counter app launches without errors.
5. Commit: `git commit -m "chore: flutter create initial scaffold"`

## Acceptance Criteria
- [ ] `flutter run` shows the default counter app with no errors
- [ ] `flutter test` passes
- [ ] The `music_logger_app/` folder is committed to the `develop` branch

## Resources
- [Flutter install guide](https://docs.flutter.dev/get-started/install)' \
"type: chore,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

create_issue \
"[M1] Add all Phase 1 dependencies to pubspec.yaml" \
'## What to do
Replace the default `pubspec.yaml` dependencies with the full Phase 1 package set.

## Packages to add

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # state management
  hive_flutter: ^1.1.0        # local storage
  http: ^1.2.1                # API calls
  cached_network_image: ^3.3.1 # image caching
  go_router: ^13.2.0          # navigation / routing
  youtube_player_flutter: ^9.0.3
  url_launcher: ^6.2.6        # open external links
  flutter_dotenv: ^5.1.0      # API key management
  intl: ^0.19.0               # date / number formatting

dev_dependencies:
  hive_generator: ^2.0.1
  build_runner: ^2.4.9
  flutter_lints: ^4.0.0
```

## Steps
1. Open `pubspec.yaml`.
2. Paste the packages above into the correct sections.
3. Run `flutter pub get`.

## Acceptance Criteria
- [ ] `flutter pub get` exits with no errors
- [ ] All packages resolve in `pubspec.lock`' \
"type: chore,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

create_issue \
"[M1] Set up environment variables with flutter_dotenv" \
'## What to do
Configure API key management so secrets are never committed to git.

## Steps
1. Create `music_logger_app/.env` with placeholder values:
   ```
   LASTFM_API_KEY=your_key_here
   GENIUS_ACCESS_TOKEN=your_token_here
   ```
2. Add `.env` to `.gitignore` **immediately**.
3. Commit a `.env.example` file with the same keys but blank values.
4. Register `.env` as a Flutter asset in `pubspec.yaml`.
5. Call `await dotenv.load()` in `main()` before `runApp()`.
6. Create `lib/core/constants/api_constants.dart` with static getters that read from `dotenv`.

## Acceptance Criteria
- [ ] `.env` is in `.gitignore` and NOT committed
- [ ] `.env.example` is committed with placeholder values
- [ ] `ApiConstants.lastFmKey` returns the correct value at runtime

## Resources
- [flutter_dotenv docs](https://pub.dev/packages/flutter_dotenv)' \
"type: chore,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

create_issue \
"[M1] Initialize Hive and define named storage boxes" \
'## What to do
Set up Hive as the local database and open all boxes the app will use.

## Boxes to open
Create `lib/core/constants/hive_boxes.dart` with string constants:
```dart
class HiveBoxes {
  static const catalog  = "catalog";
  static const reviews  = "reviews";
  static const ratings  = "ratings";
  static const lists    = "lists";
  static const favorites = "favorites";
  static const settings = "settings";
}
```

## Steps
1. Create the constants file above.
2. In `main()`, call:
   ```dart
   WidgetsFlutterBinding.ensureInitialized();
   await Hive.initFlutter();
   await Future.wait([
     Hive.openBox(HiveBoxes.catalog),
     Hive.openBox(HiveBoxes.reviews),
     // ... etc
   ]);
   ```
3. Run the app and confirm no Hive errors.

## Acceptance Criteria
- [ ] App starts without any Hive exceptions
- [ ] All box constants are in a single file

## Resources
- [Hive getting started](https://docs.hivedb.dev/#/)' \
"type: feature,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

create_issue \
"[M1] Set up go_router with bottom navigation bar (5 tabs)" \
'## What to do
Create the main navigation shell of the app: a 5-tab bottom nav bar with named routes.

## Tabs
1. 🏠 Home — `/home`
2. 🔍 Search — `/search`
3. 📚 Catalog — `/catalog`
4. 📋 Lists — `/lists`
5. 👤 Profile — `/profile`

## Additional routes (child/detail screens)
- `/album/:id`
- `/artist/:id`
- `/song/:id`
- `/review`
- `/list/:id`

## Steps
1. Create `lib/core/router/app_router.dart` using `go_router`.
2. Use a `ShellRoute` for the bottom nav shell.
3. Create `lib/presentation/widgets/common/scaffold_with_nav_bar.dart`.
4. Replace `MaterialApp` with `MaterialApp.router`.
5. Test that tapping each tab navigates correctly.

## Acceptance Criteria
- [ ] 5-tab bottom nav visible in the app
- [ ] Each tab navigates to the correct screen
- [ ] Hardware back button works correctly (does not exit app on first press)

## Resources
- [go_router ShellRoute](https://pub.dev/documentation/go_router/latest/topics/Shell%20routes-topic.html)' \
"type: feature,priority: high,milestone: 1-foundation" \
"$M1"

create_issue \
"[M1] Create placeholder screens for all routes" \
'## What to do
Create a minimal placeholder Scaffold for every screen so navigation works end-to-end before building real UI.

## Screens to create
Each is just: `Scaffold(appBar: AppBar(title: Text("...")), body: Center(child: Text("Screen name")))`

- `HomeScreen`
- `SearchScreen`
- `CatalogScreen`
- `ListsScreen`
- `ProfileScreen`
- `AlbumDetailScreen` (takes `albumId` param)
- `ArtistDetailScreen` (takes `artistId` param)
- `SongDetailScreen` (takes `songId` param)
- `ReviewScreen`
- `ListDetailScreen` (takes `listId` param)

## Acceptance Criteria
- [ ] All routes navigate without a 404/error
- [ ] Each screen shows its own name, confirming the right screen loaded
- [ ] Deep linking (e.g. `/album/123`) works' \
"type: feature,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

create_issue \
"[M1] Create app theme — dark mode and light mode" \
'## What to do
Define ThemeData for dark mode and light mode using Material 3.

## Steps
1. Create `lib/core/theme/app_theme.dart` with:
   ```dart
   class AppTheme {
     static ThemeData get dark => ThemeData(
       useMaterial3: true,
       brightness: Brightness.dark,
       colorSchemeSeed: Colors.deepPurple,
     );
     static ThemeData get light => ThemeData(
       useMaterial3: true,
       brightness: Brightness.light,
       colorSchemeSeed: Colors.deepPurple,
     );
   }
   ```
2. Wire into `MaterialApp.router`:
   ```dart
   theme: AppTheme.light,
   darkTheme: AppTheme.dark,
   themeMode: ThemeMode.system,
   ```
3. Create a `themeProvider` (Riverpod `StateProvider<ThemeMode>`) for manual override.

## Acceptance Criteria
- [ ] Dark mode is the default when system is dark
- [ ] Light mode activates when system is light
- [ ] Both themes look clean (not default grey)' \
"type: feature,priority: high,milestone: 1-foundation,beginner-friendly" \
"$M1"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 2 – API Integration
# ──────────────────────────────────────────────────────────────────────────────
M2="M2 – API Integration"

create_issue \
"[M2] Create domain entities: Album, Artist, Track" \
'## What to do
Define pure Dart entity classes. These live in `domain/` and have NO Flutter imports and NO Hive annotations.

## Entities to create

**`lib/domain/entities/album.dart`**
```dart
class Album {
  final String id;          // MusicBrainz release-group ID
  final String title;
  final String artistName;
  final String artistId;
  final int? year;
  final String? coverArtUrl;
  final List<Track> tracks;
}
```

**`lib/domain/entities/artist.dart`**
```dart
class Artist {
  final String id;
  final String name;
  final String? bioSummary;
  final List<String> tags;
  final String? imageUrl;
}
```

**`lib/domain/entities/track.dart`**
```dart
class Track {
  final String id;
  final String title;
  final int position;
  final int? durationMs; // milliseconds
}
```

## Acceptance Criteria
- [ ] All three classes are pure Dart (no Flutter/Hive imports)
- [ ] Each has a `copyWith` method
- [ ] Each has a factory constructor `fromMap(Map<String, dynamic> map)` for API parsing' \
"type: feature,priority: high,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Create MusicBrainz service — search albums and artists" \
'## What to do
Build an HTTP service that searches MusicBrainz for albums and artists.

## File: `lib/data/datasources/remote/musicbrainz_service.dart`

## Required header (MusicBrainz policy — must be included on every request)
```dart
"User-Agent": "MusicLogger/1.0 (github.com/djanderson26/music_logger)"
```

## Methods to implement
```dart
Future<List<Album>> searchAlbums(String query)
// GET https://musicbrainz.org/ws/2/release-group?query=<term>&type=album&fmt=json

Future<List<Artist>> searchArtists(String query)
// GET https://musicbrainz.org/ws/2/artist?query=<term>&fmt=json
```

## Error handling
- Throw a custom `ApiException` on non-200 responses.
- Return an empty list (not an error) when the query has no results.

## Acceptance Criteria
- [ ] `searchAlbums("Blonde")` returns Frank Ocean'\''s Blonde
- [ ] `searchArtists("Frank Ocean")` returns the correct artist
- [ ] A bad network throws `ApiException`, not an unhandled exception

## Resources
- [MusicBrainz API docs](https://musicbrainz.org/doc/MusicBrainz_API)' \
"type: feature,priority: high,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Create MusicBrainz service — fetch album detail (tracklist + metadata)" \
'## What to do
Fetch full album details including the track listing.

## API endpoint
```
GET https://musicbrainz.org/ws/2/release?release-group=<id>&inc=recordings+artists&fmt=json
```

## Method to implement
```dart
Future<Album> getAlbumDetail(String releaseGroupId)
```

## Steps
1. Add the method to `musicbrainz_service.dart`.
2. Parse the response into the `Album` entity with a full `tracks` list.
3. Format track duration from milliseconds to `mm:ss`.
4. If multiple releases exist for the release-group, use the first one.

## Acceptance Criteria
- [ ] Returns correct tracklist for a known release-group ID
- [ ] Track durations are formatted as `mm:ss`
- [ ] Respects the 1 request/second rate limit' \
"type: feature,priority: high,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Integrate Cover Art Archive for album artwork" \
'## What to do
Fetch album cover art from the Cover Art Archive, which is tied to MusicBrainz.

## File: `lib/data/datasources/remote/cover_art_service.dart`

## API endpoint
```
GET https://coverartarchive.org/release-group/<release-group-id>
```
Use the `front` image'\''s `thumbnails.large` URL.

## Method to implement
```dart
Future<String?> getCoverArtUrl(String releaseGroupId)
// Returns null if no art is available
```

## Steps
1. Create the service.
2. Return `null` (not an error) if the API returns 404.
3. Use `CachedNetworkImage` when displaying the image.
4. Create a grey placeholder widget to show when `url == null`.

## Acceptance Criteria
- [ ] Returns a valid image URL for a known album
- [ ] Returns `null` (no crash) for albums without art
- [ ] Placeholder is shown in the UI when art is unavailable' \
"type: feature,priority: high,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Create Last.fm service — artist bio and tags" \
'## What to do
Fetch an artist'\''s biography, genre tags, and image from Last.fm.

## File: `lib/data/datasources/remote/lastfm_service.dart`

## API endpoint
```
GET https://ws.audioscrobbler.com/2.0/
    ?method=artist.getinfo
    &artist=<name>
    &api_key=<key>
    &format=json
```

## Method to implement
```dart
Future<Artist> getArtistInfo(String artistName)
```

## Steps
1. Read the API key from `ApiConstants.lastFmKey` (dotenv).
2. Strip HTML tags from the bio text before storing.
3. Return the `Artist` entity populated with bio, tags, and image URL.

## Acceptance Criteria
- [ ] `getArtistInfo("Frank Ocean")` returns a non-empty bio
- [ ] HTML is stripped from the bio text
- [ ] API key is NEVER hardcoded

## Resources
- [Last.fm API docs](https://www.last.fm/api/show/artist.getInfo)' \
"type: feature,priority: medium,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Create Genius service — song credits" \
'## What to do
Search Genius for a song and return the Genius page URL and thumbnail.

## File: `lib/data/datasources/remote/genius_service.dart`

## API endpoint
```
GET https://api.genius.com/search?q=<artist+title>
Authorization: Bearer <token>
```

## Method to implement
```dart
Future<GeniusSongResult?> searchSong(String artist, String title)
// Returns null if no result found

class GeniusSongResult {
  final String url;
  final String title;
  final String? thumbnailUrl;
}
```

## Acceptance Criteria
- [ ] Searching for "Frank Ocean Nights" returns the Genius URL
- [ ] Token loaded from dotenv, never hardcoded
- [ ] Returns `null` gracefully when no result is found

## Resources
- [Genius API docs](https://docs.genius.com/)' \
"type: feature,priority: medium,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Build Search screen UI — search bar and tabbed results" \
'## What to do
Build the full search screen with a live text field and tabbed results (Albums / Artists / Songs).

## Layout
```
[ 🔍 Search text field ]
[ Albums | Artists | Songs ]  ← Tab bar
[ Result cards list ]
```

## Steps
1. Add a Riverpod `searchQueryProvider` (`StateProvider<String>`).
2. Add a `searchResultsProvider` (`FutureProvider.family`) debounced to 300ms.
3. Each result card: cover art, title, subtitle (artist / release year).
4. Tapping a result navigates to `/album/:id`, `/artist/:id`, or `/song/:id`.
5. Empty state: "Search for albums, artists, or songs" before any query.
6. No results state: "No results for '\''<query>'\''".

## Acceptance Criteria
- [ ] Typing "Blonde" shows album results within ~2 seconds
- [ ] Switching tabs shows artist/song results
- [ ] Tapping a result navigates to the correct detail screen
- [ ] Loading and error states are handled' \
"type: feature,priority: high,milestone: 2-api" \
"$M2"

create_issue \
"[M2] Create reusable AlbumCard and ArtistCard widgets" \
'## What to do
Create reusable card widgets used throughout the app to display albums and artists.

## AlbumCard — `lib/presentation/widgets/album/album_card.dart`
- Cover art (CachedNetworkImage with grey placeholder)
- Album title
- Artist name
- Year
- Tap callback

## ArtistCard — `lib/presentation/widgets/artist/artist_card.dart`
- Artist image
- Artist name
- Tap callback

## Acceptance Criteria
- [ ] Cards render correctly in both dark and light mode
- [ ] No overflow errors on long titles (use `TextOverflow.ellipsis`)
- [ ] Cover art loads with a shimmer/grey placeholder while fetching' \
"type: feature,priority: high,milestone: 2-api,beginner-friendly" \
"$M2"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 3 – Detail Pages
# ──────────────────────────────────────────────────────────────────────────────
M3="M3 – Detail Pages"

create_issue \
"[M3] Build Album Detail screen — header (cover art + metadata)" \
'## What to do
Build the hero section of the album detail page.

## Layout
```
[ Full-width cover art ]
[ Album Title  (large, bold) ]
[ Artist Name  (tappable → /artist/:id) ]
[ Year · Genre tags ]
[ ⭐ Rate | + Catalog | ♥ Favorite | + List ]  ← action row (stubs ok)
```

## Steps
1. Create `lib/presentation/screens/album_detail/album_detail_screen.dart`.
2. Accept `albumId` as a route parameter from go_router.
3. Use a `FutureProvider.family` to load album + cover art concurrently.
4. Use `CachedNetworkImage` with a shimmer placeholder for the art.
5. Tapping the artist name navigates to `/artist/:id`.
6. Action buttons are stubs — implement their logic in later milestones.

## Acceptance Criteria
- [ ] Cover art, title, artist, and year display correctly
- [ ] Tapping the artist name navigates to the artist detail screen
- [ ] Shimmer shown while data is loading' \
"type: feature,priority: high,milestone: 3-detail-pages" \
"$M3"

create_issue \
"[M3] Build Album Detail screen — scrollable tracklist" \
'## What to do
Add the tracklist below the album header so users can see and interact with every track.

## Layout per row
```
[ # ]  Track Title                 3:45  [ ⭐ ]
```

## Steps
1. Add a `TrackListWidget` below the album header inside a `CustomScrollView` (`SliverList`).
2. Each row shows: position, title, formatted duration, and a stub star icon.
3. Tapping a track navigates to `/song/:id`.
4. The header scrolls away as the user scrolls down.

## Acceptance Criteria
- [ ] Tracks are listed in correct order
- [ ] Tapping a track navigates to the song detail screen
- [ ] Header scrolls off-screen naturally (not sticky)' \
"type: feature,priority: high,milestone: 3-detail-pages" \
"$M3"

create_issue \
"[M3] Build Artist Detail screen" \
'## What to do
Create the artist page showing bio, genre tags, and discography.

## Layout
```
[ Artist image (header) ]
[ Artist name ]
[ Tags: soul · r&b · neo-soul ]
[ Bio — 3 lines with "Read more" expand ]
[ Discography grid ]
  [ AlbumCard ] [ AlbumCard ] ...
```

## Steps
1. Create `lib/presentation/screens/artist_detail/artist_detail_screen.dart`.
2. Load artist info (Last.fm) and discography (MusicBrainz) using two `FutureProvider.family`.
3. Bio is truncated to 3 lines; tapping "Read more" expands it.
4. Tapping a discography album navigates to `/album/:id`.

## Acceptance Criteria
- [ ] Bio and discography load correctly
- [ ] "Read more" expands the bio
- [ ] Tapping a discography album opens it' \
"type: feature,priority: high,milestone: 3-detail-pages" \
"$M3"

create_issue \
"[M3] Build Song Detail screen" \
'## What to do
Create the song/track detail page.

## Layout
```
[ Small album art thumbnail ]
[ Song Title ]
[ Artist · Album ]
[ Duration ]
[ ▶ YouTube  |  🎧 Spotify  |  🍎 Apple Music ]
[ View on Genius → ]
```

## Steps
1. Create `lib/presentation/screens/song_detail/song_detail_screen.dart`.
2. Accept `songId` (MusicBrainz recording ID) as a route param.
3. Add the YouTube embed widget (see related issue).
4. Spotify and Apple Music buttons use fallback search URLs via `url_launcher`.
5. Genius button opens the URL returned by `GeniusService.searchSong()`.

## Acceptance Criteria
- [ ] Song title, artist, and album display correctly
- [ ] "View on Genius" opens the correct URL
- [ ] External link buttons open in browser / app without crashing' \
"type: feature,priority: medium,milestone: 3-detail-pages" \
"$M3"

create_issue \
"[M3] Add YouTube embed widget to Song Detail screen" \
'## What to do
Embed a YouTube player in the song detail screen.

## File: `lib/presentation/widgets/song/youtube_player_widget.dart`

## Steps
1. Create `YoutubePlayerWidget` accepting a nullable `videoId` string.
2. If `videoId == null`, hide the widget entirely (no error shown).
3. Use `YoutubePlayerController` with autoPlay disabled.
4. Handle web vs. mobile: consider `youtube_player_iframe` for web.

## Notes
For MVP, the `videoId` can be searched manually for a few test tracks. Full YouTube search API integration is a Phase 2 enhancement.

## Acceptance Criteria
- [ ] Passing a known video ID renders a working inline player
- [ ] `videoId == null` hides the widget silently
- [ ] Player does not auto-play on screen open' \
"type: feature,priority: medium,milestone: 3-detail-pages" \
"$M3"

create_issue \
"[M3] Add Spotify and Apple Music redirect buttons" \
'## What to do
Add two external-link buttons to the album and song detail screens.

## File: `lib/presentation/widgets/common/streaming_link_buttons.dart`

## Behavior
For MVP, construct search URLs:
- Spotify: `https://open.spotify.com/search/<artist+title>`
- Apple Music: `https://music.apple.com/search?term=<artist+title>`

## Steps
1. Create the widget accepting `artistName` and `albumOrSongTitle`.
2. Use `url_launcher` to open the URL.
3. Grey out / hide buttons that cannot be constructed.

## Acceptance Criteria
- [ ] Tapping Spotify opens the Spotify app (or browser fallback)
- [ ] Tapping Apple Music opens Apple Music (or browser fallback)
- [ ] No crash when url_launcher cannot open the URL' \
"type: feature,priority: low,milestone: 3-detail-pages" \
"$M3"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 4 – Personal Catalog
# ──────────────────────────────────────────────────────────────────────────────
M4="M4 – Personal Catalog"

create_issue \
"[M4] Create CatalogEntry model and Hive adapter" \
'## What to do
Define the model that stores a user'\''s listening relationship with an album.

## Entity: `lib/domain/entities/catalog_entry.dart`
```dart
enum ListeningStatus { wantToListen, listening, listened }

class CatalogEntry {
  final String albumId;
  ListeningStatus status;
  DateTime addedAt;
  DateTime? listenedAt;
}
```

## Steps
1. Create the entity above.
2. Create the Hive model in `lib/data/models/catalog_entry_model.dart` with `@HiveType` annotations.
3. Create a `ListeningStatusAdapter` (Hive needs a custom adapter for enums).
4. Run `flutter pub run build_runner build --delete-conflicting-outputs`.
5. Register the adapter in `main.dart`.

## Acceptance Criteria
- [ ] A `CatalogEntry` can be stored and retrieved from Hive
- [ ] `ListeningStatus` enum persists correctly across restarts' \
"type: feature,priority: high,milestone: 4-catalog" \
"$M4"

create_issue \
"[M4] Build catalog repository — CRUD with Hive" \
'## What to do
Create a repository that wraps the Hive catalog box with clean methods for the UI.

## Interface: `lib/domain/repositories/catalog_repository.dart`
```dart
abstract class CatalogRepository {
  Future<void> addEntry(CatalogEntry entry);
  Future<void> updateStatus(String albumId, ListeningStatus status);
  Future<void> removeEntry(String albumId);
  Future<CatalogEntry?> getEntry(String albumId);
  Future<List<CatalogEntry>> getAllEntries();
  Future<List<CatalogEntry>> getByStatus(ListeningStatus status);
}
```

## Steps
1. Create the abstract interface above.
2. Create the Hive implementation in `lib/data/repositories/hive_catalog_repository.dart`.
3. Register with a Riverpod provider: `catalogRepositoryProvider`.

## Acceptance Criteria
- [ ] `getAllEntries()` returns entries in reverse-chronological order
- [ ] Unit tests cover add, update, remove, and filter by status' \
"type: feature,priority: high,milestone: 4-catalog" \
"$M4"

create_issue \
"[M4] Add listening status selector to Album Detail screen" \
'## What to do
Allow users to set their listening status for an album directly from the album detail page.

## UI
A segmented button or modal bottom sheet with three options:
- 🎵 Want to Listen
- 🎧 Listening
- ✅ Listened

## Steps
1. Add a `catalogStatusProvider` (`StateNotifier`) that reads/writes from `CatalogRepository`.
2. Wire the status widget into the album detail action row.
3. If the album is not in the catalog, the button shows "Add to Catalog" and opens the picker on tap.
4. Show a `SnackBar` confirmation when the status is set or changed.

## Acceptance Criteria
- [ ] Setting a status persists after app restart
- [ ] The correct option is highlighted when revisiting the album
- [ ] Confirmation snackbar appears on status change' \
"type: feature,priority: high,milestone: 4-catalog" \
"$M4"

create_issue \
"[M4] Build Catalog screen with filter tabs and sort" \
'## What to do
Build the main catalog screen showing all albums the user has added.

## Layout
```
[ All | Want to Listen | Listening | Listened ]  ← filter chips
[ Sort ▾ ]                                       ← sort dropdown
[ Album rows / grid ]
```

## Each row: cover art thumbnail, album title, artist, status badge, star rating (if rated)

## Steps
1. Create `lib/presentation/screens/catalog/catalog_screen.dart`.
2. Drive it with a `catalogProvider` that loads from `CatalogRepository`.
3. Filter chips call `getByStatus()` to filter the list.
4. Sort options: Recently Added (default), A–Z, Highest Rated.
5. Tapping an album navigates to `/album/:id`.
6. Empty state per tab: "No albums with status '\''Listening'\'' yet."

## Acceptance Criteria
- [ ] All catalog entries are shown
- [ ] Filter chips work correctly
- [ ] Sort reorders list immediately
- [ ] Empty state shown when a tab has no entries' \
"type: feature,priority: high,milestone: 4-catalog" \
"$M4"

create_issue \
"[M4] Build favorites system — toggle and favorites list" \
'## What to do
Allow users to favorite albums, artists, and songs.

## Steps
1. Create a `Favorite` Hive model: `{ id, type ("album"|"artist"|"song"), addedAt }`.
2. Create `FavoritesRepository` with:
   - `toggle(String id, String type)`
   - `isFavorite(String id)`
   - `getAll()`
3. Add a heart icon button to album detail, artist detail, and song detail screens.
4. Heart fills/unfills on tap immediately (optimistic update).
5. Show a Favorites section in the Profile screen.

## Acceptance Criteria
- [ ] Tapping the heart icon toggles state visually
- [ ] Favorites persist after restart
- [ ] Profile screen shows the correct favorite count' \
"type: feature,priority: medium,milestone: 4-catalog" \
"$M4"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 5 – Ratings & Reviews
# ──────────────────────────────────────────────────────────────────────────────
M5="M5 – Ratings & Reviews"

create_issue \
"[M5] Build star rating widget (1–5, interactive + read-only)" \
'## What to do
Create a reusable star rating widget with two modes: interactive and read-only.

## File: `lib/presentation/widgets/common/star_rating_widget.dart`

## Props
```dart
StarRatingWidget({
  required double? rating,      // null = unrated
  void Function(double)? onChanged, // null = read-only mode
  double size = 24.0,
})
```

## Steps
1. Use filled/unfilled star icons from Material Icons.
2. Interactive: tap a star to set rating 1–5.
3. Read-only: same widget but no tap handling (`onChanged == null`).
4. `rating == null` shows 5 empty stars.

## Acceptance Criteria
- [ ] Tapping stars changes the displayed rating
- [ ] Read-only mode ignores taps
- [ ] `rating: null` shows all empty stars
- [ ] Works in both dark and light mode' \
"type: feature,priority: high,milestone: 5-ratings,beginner-friendly" \
"$M5"

create_issue \
"[M5] Create Rating model and Hive adapter" \
'## What to do
Define the data model for storing album and song ratings.

## Entity
```dart
class Rating {
  final String targetId;    // albumId or trackId
  final String targetType;  // "album" or "song"
  double stars;             // 1.0 – 5.0
  DateTime ratedAt;
}
```

## Steps
1. Create entity and Hive model.
2. Create `RatingsRepository`:
   - `setRating(String id, String type, double stars)`
   - `getRating(String id, String type) → Rating?`
   - `removeRating(String id, String type)`
3. Register with a Riverpod provider.

## Acceptance Criteria
- [ ] A rating survives app restart
- [ ] `getRating(albumId, "album")` returns the correct stars value' \
"type: feature,priority: high,milestone: 5-ratings" \
"$M5"

create_issue \
"[M5] Wire album rating into Album Detail screen" \
'## What to do
Connect the star rating widget to the album detail screen so users can rate an album.

## Steps
1. Add `StarRatingWidget` to the album detail action row.
2. Pre-fill with the existing rating from `RatingsRepository`.
3. On change, call `ratingsRepository.setRating(albumId, "album", stars)`.
4. Show the rating in the catalog list row next to the album.

## Acceptance Criteria
- [ ] Rating an album updates immediately and persists after restart
- [ ] Catalog list shows the correct star value next to each entry' \
"type: feature,priority: high,milestone: 5-ratings" \
"$M5"

create_issue \
"[M5] Add per-song ratings to the tracklist" \
'## What to do
Let users rate individual tracks from the tracklist on the album detail screen.

## Steps
1. Add a small `StarRatingWidget` to each track row.
2. To avoid accidental taps, tapping the stars opens a small bottom sheet to confirm the rating.
3. Save via `ratingsRepository.setRating(trackId, "song", stars)`.
4. Show the set rating inline in the track row.

## Acceptance Criteria
- [ ] Each track has its own independent star rating
- [ ] Track ratings persist after restart
- [ ] Confirming a rating via the bottom sheet saves it' \
"type: feature,priority: medium,milestone: 5-ratings" \
"$M5"

create_issue \
"[M5] Create Review model with edit history" \
'## What to do
Define the data model for written reviews that tracks every revision.

## Entities
```dart
class Review {
  final String id;
  final String targetId;
  final String targetType;  // "album" or "song"
  String body;
  final DateTime createdAt;
  List<ReviewEdit> editHistory;
}

class ReviewEdit {
  final String previousBody;
  final DateTime editedAt;
}
```

## Steps
1. Create entities and Hive models for both `Review` and `ReviewEdit`.
2. Create `ReviewRepository`:
   - `saveReview(Review review)`
   - `editReview(String id, String newBody)` — appends old body to `editHistory`
   - `getReview(String targetId, String type) → Review?`
3. Register provider.

## Acceptance Criteria
- [ ] A review can be saved and retrieved
- [ ] Editing appends the old body to `editHistory`
- [ ] Unit tests cover create, edit (×2), and history length' \
"type: feature,priority: high,milestone: 5-ratings" \
"$M5"

create_issue \
"[M5] Build Review composer screen" \
'## What to do
Create the screen where users write and edit reviews.

## Layout
```
[ Album/Song thumbnail + title ]
[ Large multi-line text input ]
[ Character count ]
[ Save / Update button ]
```

## Steps
1. Create `lib/presentation/screens/review/review_screen.dart`.
2. Accept `targetId` and `targetType` params.
3. Pre-fill the text field if a review already exists.
4. On save, call `saveReview` or `editReview`.
5. Navigate back to the detail screen after saving.

## Acceptance Criteria
- [ ] Typing a review and tapping Save persists the text
- [ ] Re-opening the screen shows the saved text
- [ ] Editing and saving a second time appends to edit history' \
"type: feature,priority: high,milestone: 5-ratings" \
"$M5"

create_issue \
"[M5] Show review and edit history on Album/Song Detail screens" \
'## What to do
Display the user'\''s review on album and song detail pages.

## Layout addition (bottom of detail screen)
```
── Your Review ─────────────────────────────────
  "This album changed my life..."               (truncated to 3 lines)
  [ Edit Review ]     [ History (2 edits) ]
```

## Steps
1. Add a review section widget to `AlbumDetailScreen` and `SongDetailScreen`.
2. If no review exists: show a "Write a Review" button → `/review?targetId=&type=album`.
3. If a review exists: show truncated text + Edit and History buttons.
4. History opens a bottom sheet listing each revision with its timestamp.

## Acceptance Criteria
- [ ] Written review appears on the detail screen after composing
- [ ] "Edit Review" pre-fills the composer with the current text
- [ ] History modal shows all past versions with timestamps' \
"type: feature,priority: medium,milestone: 5-ratings" \
"$M5"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 6 – Lists
# ──────────────────────────────────────────────────────────────────────────────
M6="M6 – Lists"

create_issue \
"[M6] Create MusicList model and Hive adapter" \
'## What to do
Define the data model for user-created lists (static and dynamic).

## Entity
```dart
class MusicList {
  final String id;
  String name;
  String? description;
  bool isDynamic;
  List<String> itemIds;           // album IDs for static lists
  Map<String, dynamic>? filter;   // filter rules for dynamic lists
  DateTime createdAt;
  DateTime updatedAt;
}
```

## Steps
1. Create entity and Hive model.
2. Create `ListRepository`:
   - `createList(MusicList list)`
   - `updateList(MusicList list)`
   - `deleteList(String id)`
   - `addItem(String listId, String albumId)`
   - `removeItem(String listId, String albumId)`
   - `getAllLists() → List<MusicList>`
3. Register provider.

## Acceptance Criteria
- [ ] A list can be created, items added, and retrieved after restart
- [ ] `deleteList` removes the entry from Hive completely' \
"type: feature,priority: high,milestone: 6-lists" \
"$M6"

create_issue \
"[M6] Build Lists overview screen" \
'## What to do
Create the screen that shows all user-created lists.

## Layout
```
[ ＋ New List ]   ← FAB or app bar button
[ List Card ]  name · X albums · last updated
[ List Card ]
...
[ Empty state ]
```

## Steps
1. Create `lib/presentation/screens/lists/lists_screen.dart`.
2. Drive with a `listsProvider` reading from `ListRepository.getAllLists()`.
3. Tapping a list navigates to `/list/:id`.
4. Long-press shows a delete confirmation dialog.
5. FAB opens a `showDialog` with a name and optional description field.

## Acceptance Criteria
- [ ] All lists displayed correctly
- [ ] Creating a new list appears immediately
- [ ] Deleting a list removes it from the screen
- [ ] Empty state shown when no lists exist' \
"type: feature,priority: high,milestone: 6-lists" \
"$M6"

create_issue \
"[M6] Build List Detail screen — view and manage items" \
'## What to do
Build the detail screen for a single list.

## Layout
- List name and description as a header
- Grid or list of album cards
- "Edit list name" option in app bar overflow menu
- Swipe-to-delete or long-press to remove items
- Drag handle to reorder items

## Steps
1. Create `lib/presentation/screens/lists/list_detail_screen.dart`.
2. For each `albumId` in `itemIds`, load the cached album from Hive.
3. Use `ReorderableListView` to support drag-and-drop reordering.
4. Persist reordering back to Hive via `updateList`.

## Acceptance Criteria
- [ ] All items display with cover art
- [ ] Reordering items persists after restart
- [ ] Removing an item updates Hive immediately' \
"type: feature,priority: high,milestone: 6-lists" \
"$M6"

create_issue \
"[M6] Add 'Add to List' action from Album Detail screen" \
'## What to do
Let users add an album to a list from within the album detail page.

## Steps
1. Add a "+ List" button to the album detail action row.
2. Tapping opens a bottom sheet listing all the user'\''s lists.
3. Lists already containing this album show a checkmark.
4. Tapping a list toggles the album in/out of it.
5. A "Create New List" option at the bottom of the sheet creates a list and adds the album.

## Acceptance Criteria
- [ ] Album is added/removed from the selected list immediately
- [ ] Re-opening the sheet shows correct checkmark state
- [ ] Creating a new list from this flow creates it and adds the album' \
"type: feature,priority: high,milestone: 6-lists" \
"$M6"

create_issue \
"[M6] Implement dynamic list rules (filter-based auto-population)" \
'## What to do
Allow a list to auto-populate based on filter rules applied to the user'\''s catalog.

## Example rules
- All albums rated ≥ 4 stars
- All albums with status "Listened"
- All favorited albums
- All albums tagged with a specific genre

## Steps
1. Define a `ListFilter` class with composable criteria.
2. Add a "Dynamic List" toggle in the new list creation dialog.
3. When opening a dynamic list, compute results from catalog + ratings repos on the fly.
4. Dynamic lists do NOT store `itemIds` — they are always recomputed.
5. Label dynamic lists clearly in the UI (e.g. a ⚡ icon).

## Acceptance Criteria
- [ ] A "Top Rated" dynamic list shows all albums rated 4+ stars
- [ ] Adding a new 4-star rating causes the album to appear in the list
- [ ] Dynamic list is clearly distinguished from static lists in the UI' \
"type: feature,priority: low,milestone: 6-lists" \
"$M6"

# ──────────────────────────────────────────────────────────────────────────────
# MILESTONE 7 – Home & Polish
# ──────────────────────────────────────────────────────────────────────────────
M7="M7 – Home & Polish"

create_issue \
"[M7] Build Home screen — recent activity feed" \
'## What to do
Build the home screen showing a reverse-chronological feed of user activity.

## Activity types
- "Added [Album] to Listened" 
- "Rated [Album] ⭐⭐⭐⭐"
- "Wrote a review for [Album]"
- "Created list [List Name]"

## Steps
1. Create a `RecentActivity` sealed class / union covering all activity types.
2. Build `activityFeedProvider` that merges sorted events from catalog, ratings, reviews, and lists repos.
3. Build `HomeScreen` with a `ListView` of activity cards.
4. Each card shows album art thumbnail, description text, and timestamp.
5. Tapping an activity card navigates to the related album/list.

## Acceptance Criteria
- [ ] Adding an album to the catalog shows a card on the home screen
- [ ] Rating an album shows a card with the star count
- [ ] Feed is in reverse-chronological order
- [ ] Empty state on first launch: "Start by searching for an album!"' \
"type: feature,priority: high,milestone: 7-polish" \
"$M7"

create_issue \
"[M7] Build Profile screen — listening stats" \
'## What to do
Build the profile screen showing an at-a-glance view of the user'\''s music stats.

## Stats to show
- Total albums in catalog
- Albums per status (Want to Listen / Listening / Listened)
- Total reviews written
- Favorites count
- Average album rating (across all rated albums)
- Top-rated album
- Most common genre in catalog

## Steps
1. Create a `statsProvider` that aggregates data from all repositories.
2. Build `ProfileScreen` with a scrollable card layout.
3. Add the theme toggle switch (dark / light / system) here.

## Acceptance Criteria
- [ ] All stats reflect actual data from Hive
- [ ] Stats update immediately after changes elsewhere in the app
- [ ] Theme toggle works and preference persists' \
"type: feature,priority: medium,milestone: 7-polish" \
"$M7"

create_issue \
"[M7] Add empty state widgets for all main screens" \
'## What to do
Replace blank screens with helpful empty states when there is no data.

## File: `lib/presentation/widgets/common/empty_state_widget.dart`
```dart
EmptyStateWidget({
  required IconData icon,
  required String title,
  required String subtitle,
  Widget? action, // optional CTA button
})
```

## Screens that need empty states
| Screen | Message |
|---|---|
| Search (before query) | "Search for albums, artists, or songs" |
| Catalog (no entries) | "Your catalog is empty — search for an album to get started" |
| Lists (no lists) | "No lists yet — tap + to create your first list" |
| Home (no activity) | "No activity yet — start by adding an album to your catalog" |
| Favorites | "No favorites yet — tap ♥ on any album, artist, or song" |

## Acceptance Criteria
- [ ] All listed screens have a distinct empty state
- [ ] Empty states look polished in both dark and light mode
- [ ] Optional CTA button navigates to the correct action' \
"type: feature,priority: medium,milestone: 7-polish,beginner-friendly" \
"$M7"

create_issue \
"[M7] Add loading skeleton / shimmer effect to data-fetching screens" \
'## What to do
Replace spinner loading indicators with shimmer skeleton placeholders.

## File: `lib/presentation/widgets/common/shimmer_widgets.dart`

## Shimmer widgets to create
- `ShimmerAlbumCard` — matches the AlbumCard layout
- `ShimmerTrackRow` — matches the tracklist row layout
- `ShimmerArtistHeader` — matches the artist detail header

## Steps
1. Add `shimmer: ^3.0.0` to `pubspec.yaml`.
2. Create shimmer widgets that match the real layout dimensions.
3. Show shimmers while a `FutureProvider` is in the loading state.
4. Replace with real content when data arrives.

## Acceptance Criteria
- [ ] Album detail shows a shimmer layout (not a spinner) while loading
- [ ] No layout shift / jump when real content replaces the shimmer' \
"type: feature,priority: low,milestone: 7-polish" \
"$M7"

create_issue \
"[M7] Add error state widgets and retry logic" \
'## What to do
Handle API and storage errors gracefully with user-friendly error screens.

## File: `lib/presentation/widgets/common/error_state_widget.dart`
```dart
ErrorStateWidget({
  required String message,
  VoidCallback? onRetry,
})
```

## Steps
1. Create the widget with an error icon, message, and "Try Again" button.
2. Add to all `FutureProvider` consumers via the `.when(error: ...)` handler.
3. Retry button calls `ref.refresh(provider)`.
4. Show specific messages: "No internet connection" vs "Something went wrong".

## Acceptance Criteria
- [ ] Turning off Wi-Fi and searching shows an error state — no crash
- [ ] Tapping "Try Again" re-fetches when connectivity is restored' \
"type: feature,priority: medium,milestone: 7-polish" \
"$M7"

create_issue \
"[M7] Add dark/light mode toggle to Profile screen" \
'## What to do
Let users manually override the system theme preference from within the app.

## Steps
1. Add a `themeProvider` (`StateProvider<ThemeMode>`) if not already done.
2. Persist preference in the Hive `settings` box: `{"themeMode": "dark"}`.
3. Add a segmented button (Dark / Light / System) to the Profile screen.
4. Toggling updates the app theme immediately via `themeProvider`.
5. The preference is read from Hive on app start so it persists.

## Acceptance Criteria
- [ ] Toggling theme updates the entire app immediately
- [ ] Preference survives app restart' \
"type: feature,priority: medium,milestone: 7-polish,beginner-friendly" \
"$M7"

create_issue \
"[M7] Configure app icon and splash screen" \
'## What to do
Set the app icon and native splash screen so the app looks polished on device.

## Steps
1. Add `flutter_launcher_icons` and `flutter_native_splash` to `dev_dependencies`.
2. Design or download a simple 1024×1024 PNG app icon (music note or your own design).
3. Configure `flutter_launcher_icons` in `pubspec.yaml` and run:
   `dart run flutter_launcher_icons`
4. Configure `flutter_native_splash` and run:
   `dart run flutter_native_splash:create`
5. Set the app name:
   - Android: `android/app/src/main/AndroidManifest.xml` → `android:label`
   - iOS: `ios/Runner/Info.plist` → `CFBundleName`

## Acceptance Criteria
- [ ] App icon appears correctly on home screen (Android + iOS)
- [ ] Splash screen shows on launch (no white flash)
- [ ] App name shows as "Music Logger"

## Resources
- [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)
- [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)' \
"type: chore,priority: low,milestone: 7-polish,beginner-friendly" \
"$M7"

create_issue \
"[M7] Phase 1 QA pass — full end-to-end walkthrough" \
'## What to do
Manually test every Phase 1 user flow before merging `develop` → `main` as the v1.0 release.

## Test checklist
- [ ] Search album → open detail → view tracklist → add to catalog (Listened) → rate → write review
- [ ] Search artist → open artist detail → tap album in discography → confirm album detail loads
- [ ] Open song detail → play YouTube embed → tap "View on Genius" → confirm correct page opens
- [ ] Open catalog → filter by each status tab → sort by rating
- [ ] Create a static list → add 3 albums → reorder → remove one
- [ ] Create a dynamic list (all 5-star albums) → rate an album 5 stars → confirm it appears
- [ ] Toggle favorites on an album, artist, and song → verify they appear in Profile favorites
- [ ] Home feed shows activity cards for all of the above
- [ ] Profile stats are accurate (album count, avg rating, etc.)
- [ ] Toggle dark ↔ light mode → all screens look correct in both
- [ ] Force-quit and reopen → all data persists

## Done when
- [ ] All checklist items pass on both a real device and a simulator
- [ ] No crash-level bugs remain
- [ ] `develop` is merged to `main` and tagged `v1.0.0-local`' \
"type: chore,priority: high,milestone: 7-polish" \
"$M7"

echo ""
echo "======================================================"
echo "🎉  All done!"
echo ""
echo "   Issues:      https://github.com/$REPO/issues"
echo "   Milestones:  https://github.com/$REPO/milestones"
echo "   Labels:      https://github.com/$REPO/labels"
echo ""
echo "📋  Next: create a GitHub Project board"
echo "   https://github.com/$REPO/projects/new"
echo ""
echo "   Recommended columns:"
echo "   📋 Backlog | 🔜 Up Next | 🚧 In Progress | 👀 In Review | ✅ Done | 🧊 Icebox"
echo ""
echo "   Start by dragging the first 2 M1 issues into 'Up Next'."
