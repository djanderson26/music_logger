#!/usr/bin/env bash
# =============================================================================
# setup_github.sh — Bootstrap GitHub labels, milestones, and issues
#
# REQUIREMENTS:
#   - GitHub CLI (gh): https://cli.github.com/
#   - Authenticated: gh auth login
#
# USAGE:
#   cd .github
#   bash setup_github.sh
#
# This script is idempotent: running it again won't create duplicates.
# =============================================================================

set -euo pipefail

REPO="djanderson26/music_logger"

echo "🏷️  Creating labels..."

create_label() {
  local name="$1" color="$2" description="$3"
  gh label create "$name" --color "$color" --description "$description" \
    --repo "$REPO" --force 2>/dev/null || true
}

# Type labels
create_label "type: feature"   "0075ca" "New functionality"
create_label "type: bug"       "d73a4a" "Something is broken"
create_label "type: chore"     "e4e669" "Maintenance / tooling"
create_label "type: docs"      "0052cc" "Documentation only"

# Priority labels
create_label "priority: high"   "b60205" "Must-have for milestone"
create_label "priority: medium" "fbca04" "Should-have"
create_label "priority: low"    "0e8a16" "Nice-to-have"

# Skill labels
create_label "beginner-friendly" "7057ff" "Good first issue"

# Milestone labels
create_label "milestone: 1-foundation"   "c5def5" "Phase 1 – Milestone 1"
create_label "milestone: 2-api"          "bfd4f2" "Phase 1 – Milestone 2"
create_label "milestone: 3-detail-pages" "d4c5f9" "Phase 1 – Milestone 3"
create_label "milestone: 4-catalog"      "c2e0c6" "Phase 1 – Milestone 4"
create_label "milestone: 5-ratings"      "fef2c0" "Phase 1 – Milestone 5"
create_label "milestone: 6-lists"        "f9d0c4" "Phase 1 – Milestone 6"
create_label "milestone: 7-polish"       "e4c1f9" "Phase 1 – Milestone 7"

echo "✅ Labels created."

# =============================================================================
echo ""
echo "📅 Creating milestones..."

create_milestone() {
  local title="$1" description="$2"
  gh api repos/"$REPO"/milestones \
    --method POST \
    --field title="$title" \
    --field description="$description" \
    --field state="open" 2>/dev/null || true
}

create_milestone "Milestone 1 – Project Foundation"  "Flutter scaffold, Hive setup, navigation, theming"
create_milestone "Milestone 2 – Music Search & APIs" "MusicBrainz, Cover Art Archive, Last.fm, Genius integrations"
create_milestone "Milestone 3 – Detail Pages"        "Album, artist, and song detail screens"
create_milestone "Milestone 4 – Personal Catalog"    "Listening status, catalog browsing, favorites"
create_milestone "Milestone 5 – Ratings & Reviews"   "Star ratings and written reviews with edit history"
create_milestone "Milestone 6 – Lists Feature"       "Static and dynamic lists / groups"
create_milestone "Milestone 7 – Home & Polish"       "Home feed, profile page, empty states, animations"

echo "✅ Milestones created."

# =============================================================================
# Helper: get a milestone number by title
get_milestone_number() {
  local title="$1"
  gh api repos/"$REPO"/milestones --jq ".[] | select(.title == \"$title\") | .number"
}

# =============================================================================
echo ""
echo "🐛 Creating issues..."

create_issue() {
  local title="$1" body="$2" labels="$3" milestone_title="$4"
  local milestone_num
  milestone_num=$(get_milestone_number "$milestone_title")
  gh issue create \
    --repo "$REPO" \
    --title "$title" \
    --body "$body" \
    --label "$labels" \
    --milestone "$milestone_num" 2>/dev/null || echo "  ⚠️  Skipped (may already exist): $title"
}

# ── Milestone 1: Foundation ──────────────────────────────────────────────────
M1="Milestone 1 – Project Foundation"

create_issue \
  "[M1] Scaffold Flutter project with flutter create" \
  "Run \`flutter create music_logger_app\` inside the repo. Verify the default counter app runs on simulator. Commit the scaffolded project.\n\n**Acceptance Criteria**\n- [ ] \`flutter run\` launches the app without errors\n- [ ] \`flutter test\` passes\n- [ ] Scaffolded files committed to \`develop\`" \
  "type: feature,priority: high,beginner-friendly,milestone: 1-foundation" \
  "$M1"

create_issue \
  "[M1] Add all Phase 1 dependencies to pubspec.yaml" \
  "Add the following packages and run \`flutter pub get\`:\n- \`flutter_riverpod\`, \`hive_flutter\`, \`http\`, \`cached_network_image\`\n- \`go_router\`, \`youtube_player_flutter\`, \`url_launcher\`\n- \`flutter_dotenv\`, \`intl\`\n- dev: \`hive_generator\`, \`build_runner\`, \`flutter_lints\`\n\n**Acceptance Criteria**\n- [ ] \`flutter pub get\` succeeds\n- [ ] No version conflicts" \
  "type: chore,priority: high,beginner-friendly,milestone: 1-foundation" \
  "$M1"

create_issue \
  "[M1] Set up Hive local storage and open all boxes" \
  "Initialize Hive in \`main.dart\`. Open boxes: \`catalog\`, \`reviews\`, \`lists\`, \`favorites\`, \`settings\`.\n\n**Acceptance Criteria**\n- [ ] App starts without Hive errors\n- [ ] \`HiveBoxes\` constants class created in \`core/constants/\`" \
  "type: feature,priority: high,milestone: 1-foundation" \
  "$M1"

create_issue \
  "[M1] Set up go_router with bottom navigation bar" \
  "Create \`presentation/router.dart\` with routes for: Home, Search, Catalog, Lists, Profile.\nAdd a \`ScaffoldWithNavBar\` widget that wraps pages with a \`BottomNavigationBar\`.\n\n**Acceptance Criteria**\n- [ ] Tapping each nav item navigates to the correct screen\n- [ ] Back button behavior works correctly on Android" \
  "type: feature,priority: high,milestone: 1-foundation" \
  "$M1"

create_issue \
  "[M1] Create dark and light ThemeData" \
  "Create \`core/theme/app_theme.dart\` with \`AppTheme.light\` and \`AppTheme.dark\`.\nUse Material 3, a brand color seed, and a readable font.\nWire up \`themeMode: ThemeMode.system\` in \`MaterialApp.router\`.\n\n**Acceptance Criteria**\n- [ ] App switches theme when device theme changes\n- [ ] Both themes look intentional, not default grey" \
  "type: feature,priority: medium,beginner-friendly,milestone: 1-foundation" \
  "$M1"

create_issue \
  "[M1] Create .env config and gitignore sensitive files" \
  "Add \`.env\` to \`.gitignore\`. Create a \`.env.example\` with placeholder keys.\nLoad the env file with \`flutter_dotenv\` in \`main()\`.\n\n**Acceptance Criteria**\n- [ ] \`.env\` is not tracked by git\n- [ ] \`.env.example\` is committed as a template\n- [ ] App does not crash when \`.env\` is missing a key (graceful fallback)" \
  "type: chore,priority: high,beginner-friendly,milestone: 1-foundation" \
  "$M1"

# ── Milestone 2: Music Search & APIs ────────────────────────────────────────
M2="Milestone 2 – Music Search & APIs"

create_issue \
  "[M2] Create MusicBrainz search service" \
  "Create \`data/datasources/remote/musicbrainz_service.dart\`.\nImplement:\n- \`searchAlbums(query)\`\n- \`searchArtists(query)\`\n- \`searchRecordings(query)\`\n\nUse the \`http\` package. Include the required \`User-Agent\` header.\nReturn typed result objects.\n\n**Acceptance Criteria**\n- [ ] Search returns non-empty results for a known album (e.g. \"Abbey Road\")\n- [ ] Handles network errors gracefully (try/catch)" \
  "type: feature,priority: high,milestone: 2-api" \
  "$M2"

create_issue \
  "[M2] Fetch album art from Cover Art Archive" \
  "Create \`data/datasources/remote/cover_art_service.dart\`.\nGiven a MusicBrainz release MBID, fetch the front cover art URL.\nFall back to a placeholder asset if no art is available.\n\n**Acceptance Criteria**\n- [ ] \`getCoverArtUrl(mbid)\` returns a valid image URL\n- [ ] Placeholder shown when art unavailable" \
  "type: feature,priority: high,milestone: 2-api" \
  "$M2"

create_issue \
  "[M2] Fetch artist info from Last.fm API" \
  "Create \`data/datasources/remote/lastfm_service.dart\`.\nImplement \`getArtistInfo(artistName)\` using the Last.fm \`artist.getInfo\` endpoint.\nParse: bio summary, image URL, top tags, listener count.\n\n**Acceptance Criteria**\n- [ ] Returns bio for a known artist\n- [ ] API key loaded from \`.env\`, never hardcoded" \
  "type: feature,priority: medium,milestone: 2-api" \
  "$M2"

create_issue \
  "[M2] Fetch song credits and annotations from Genius API" \
  "Create \`data/datasources/remote/genius_service.dart\`.\nImplement \`searchSong(title, artist)\` to find a song and return its Genius URL and metadata.\n\n**Acceptance Criteria**\n- [ ] Returns a valid Genius URL for a known song\n- [ ] API token loaded from \`.env\`" \
  "type: feature,priority: low,milestone: 2-api" \
  "$M2"

create_issue \
  "[M2] Create domain entities for Album, Artist, Song" \
  "Create pure Dart entity classes in \`domain/entities/\`:\n- \`Album\` (id, title, artistName, releaseDate, genres, trackCount, coverArtUrl, mbid)\n- \`Artist\` (id, name, bio, imageUrl, mbid)\n- \`Song\` (id, title, artistName, albumTitle, duration, trackNumber, mbid)\n\nNo Flutter imports. No Hive annotations (those go in models).\n\n**Acceptance Criteria**\n- [ ] Entities are plain Dart classes with named constructors and \`copyWith\`\n- [ ] Unit tests pass for each entity" \
  "type: feature,priority: high,milestone: 2-api" \
  "$M2"

create_issue \
  "[M2] Build Search screen UI with live results" \
  "Implement \`presentation/screens/search/search_screen.dart\`.\n- TextField input with debounce (300ms)\n- Tabs for Albums / Artists / Songs\n- Results list with cover art thumbnail, title, artist\n- Loading and error states\n\n**Acceptance Criteria**\n- [ ] Typing in the search bar shows results after a short delay\n- [ ] Tapping a result navigates to the detail screen (stub OK for now)\n- [ ] Empty state shown when no results found" \
  "type: feature,priority: high,milestone: 2-api" \
  "$M2"

# ── Milestone 3: Detail Pages ────────────────────────────────────────────────
M3="Milestone 3 – Detail Pages"

create_issue \
  "[M3] Build Album Detail screen" \
  "Implement \`presentation/screens/album_detail/album_detail_screen.dart\`.\nSections:\n- Hero cover art with album title, artist, year, genres\n- Tracklist (song title + duration)\n- \"Add to Catalog\" button (triggers status picker)\n- Spotify / Apple Music redirect buttons\n\n**Acceptance Criteria**\n- [ ] All metadata displayed correctly\n- [ ] Tracklist scrollable\n- [ ] External links open in browser" \
  "type: feature,priority: high,milestone: 3-detail-pages" \
  "$M3"

create_issue \
  "[M3] Build Artist Detail screen" \
  "Implement \`presentation/screens/artist_detail/artist_detail_screen.dart\`.\nSections:\n- Artist header image, name, listener count\n- Bio (collapsible with \"Read more\")\n- Discography list (album cards)\n\n**Acceptance Criteria**\n- [ ] Bio truncates to 3 lines and expands on tap\n- [ ] Discography list scrollable" \
  "type: feature,priority: high,milestone: 3-detail-pages" \
  "$M3"

create_issue \
  "[M3] Build Song Detail screen with YouTube embed" \
  "Implement \`presentation/screens/album_detail/song_detail_screen.dart\` (or similar path).\nSections:\n- Song title, artist, album, duration\n- YouTube video embed (use \`youtube_player_flutter\`)\n- Genius credits link (open in browser)\n\n**Acceptance Criteria**\n- [ ] YouTube player loads and plays\n- [ ] Graceful fallback if no YouTube video found\n- [ ] Genius link opens the Genius page" \
  "type: feature,priority: medium,milestone: 3-detail-pages" \
  "$M3"

create_issue \
  "[M3] Create reusable AlbumCard and ArtistCard widgets" \
  "Create:\n- \`presentation/widgets/album/album_card.dart\` — shows cover art, title, artist, year\n- \`presentation/widgets/artist/artist_card.dart\` — shows image, name\n\nBoth should accept a tap callback.\n\n**Acceptance Criteria**\n- [ ] Cards display correctly in both dark and light mode\n- [ ] Cover art uses \`CachedNetworkImage\` with placeholder" \
  "type: feature,priority: high,beginner-friendly,milestone: 3-detail-pages" \
  "$M3"

# ── Milestone 4: Personal Catalog ────────────────────────────────────────────
M4="Milestone 4 – Personal Catalog"

create_issue \
  "[M4] Create CatalogEntry Hive model" \
  "Create \`data/models/catalog_entry.dart\` with \`@HiveType\` annotations.\nFields: albumMbid, status (WantToListen / Listening / Listened), dateAdded, dateUpdated.\nRun \`build_runner\` to generate the adapter.\n\n**Acceptance Criteria**\n- [ ] Model saves and loads from Hive without errors\n- [ ] Unit test: save an entry, reload it, values match" \
  "type: feature,priority: high,milestone: 4-catalog" \
  "$M4"

create_issue \
  "[M5] Create listening status picker bottom sheet" \
  "Create \`presentation/widgets/common/status_picker.dart\`.\nShows a modal bottom sheet with three options:\n- 🎵 Want to Listen\n- 🎧 Listening\n- ✅ Listened\n\nUpdates the catalog entry in Hive on selection.\n\n**Acceptance Criteria**\n- [ ] Status picker opens from Album Detail screen\n- [ ] Selected status persists after app restart" \
  "type: feature,priority: high,milestone: 4-catalog" \
  "$M4"

create_issue \
  "[M4] Build Catalog screen with filter tabs" \
  "Implement \`presentation/screens/catalog/catalog_screen.dart\`.\n- Tabs: All / Want to Listen / Listening / Listened\n- Album grid or list view\n- Sort by: Date Added, Title, Artist\n\n**Acceptance Criteria**\n- [ ] Each tab shows only the correct entries\n- [ ] Sort controls work\n- [ ] Empty state shown per tab" \
  "type: feature,priority: high,milestone: 4-catalog" \
  "$M4"

create_issue \
  "[M4] Implement favorites system for albums, artists, and songs" \
  "Add a \`favorites\` Hive box storing IDs by type.\nAdd a heart/favorite toggle button to Album Detail, Artist Detail, and Song Detail screens.\n\n**Acceptance Criteria**\n- [ ] Tapping the heart toggles the favorite state\n- [ ] Favorites persist after app restart\n- [ ] Profile screen can show a count of favorites" \
  "type: feature,priority: medium,milestone: 4-catalog" \
  "$M4"

# ── Milestone 5: Ratings & Reviews ──────────────────────────────────────────
M5="Milestone 5 – Ratings & Reviews"

create_issue \
  "[M5] Create star rating widget (1–5 stars)" \
  "Create \`presentation/widgets/common/star_rating.dart\`.\n- Supports half-star or whole-star increments (your choice)\n- Read-only and interactive modes\n- Shows average rating as text below stars\n\n**Acceptance Criteria**\n- [ ] Tapping a star updates the rating\n- [ ] Read-only mode does not allow changes\n- [ ] Accessible (screen reader labels)" \
  "type: feature,priority: high,beginner-friendly,milestone: 5-ratings" \
  "$M5"

create_issue \
  "[M5] Create Review Hive model" \
  "Create \`data/models/review.dart\` with \`@HiveType\`.\nFields: id, subjectMbid, subjectType (album/song), body, rating, createdAt, editHistory (list of previous bodies).\n\n**Acceptance Criteria**\n- [ ] Model saves and loads from Hive\n- [ ] Edit history list appends on each edit\n- [ ] Unit tests cover create and edit scenarios" \
  "type: feature,priority: high,milestone: 5-ratings" \
  "$M5"

create_issue \
  "[M5] Build Review composer screen" \
  "Implement \`presentation/screens/review/review_screen.dart\`.\n- Large text input for the review body\n- Star rating widget at top\n- Save / Update button\n- View edit history (list of timestamps + old text)\n\n**Acceptance Criteria**\n- [ ] New review saves to Hive\n- [ ] Editing an existing review appends old body to edit history\n- [ ] Review appears on the Album / Song detail screen after saving" \
  "type: feature,priority: high,milestone: 5-ratings" \
  "$M5"

create_issue \
  "[M5] Display ratings and reviews on Album Detail" \
  "On the Album Detail screen add:\n- Current user rating (stars) with tap-to-rate\n- Review snippet (first 100 chars) with \"Read full review\" link\n- Song-level ratings inline in the tracklist\n\n**Acceptance Criteria**\n- [ ] Rating shows correct persisted value\n- [ ] Tapping review snippet navigates to review screen\n- [ ] Song ratings editable from tracklist" \
  "type: feature,priority: high,milestone: 5-ratings" \
  "$M5"

# ── Milestone 6: Lists ───────────────────────────────────────────────────────
M6="Milestone 6 – Lists Feature"

create_issue \
  "[M6] Create MusicList Hive model" \
  "Create \`data/models/music_list.dart\` with \`@HiveType\`.\nFields: id, name, description, createdAt, itemMbids (List<String>), isDynamic, filterRules (Map).\n\n**Acceptance Criteria**\n- [ ] Saves and loads from Hive\n- [ ] Unit tests for create, add item, remove item" \
  "type: feature,priority: high,milestone: 6-lists" \
  "$M6"

create_issue \
  "[M6] Build Lists screen" \
  "Implement \`presentation/screens/lists/lists_screen.dart\`.\n- Shows all user lists with name, item count, last updated\n- FAB to create a new list (shows a name/description dialog)\n- Tap list → opens list detail\n\n**Acceptance Criteria**\n- [ ] New list appears immediately after creation\n- [ ] Empty state shown when no lists exist" \
  "type: feature,priority: high,milestone: 6-lists" \
  "$M6"

create_issue \
  "[M6] Build List Detail screen with add/remove items" \
  "Create a List Detail screen showing all albums in the list.\n- Reorderable list items\n- Swipe-to-remove\n- \"Add item\" button opens search to add an album\n\n**Acceptance Criteria**\n- [ ] Reorder persists after app restart\n- [ ] Item removal updates Hive immediately\n- [ ] Adding via search finds and adds the album" \
  "type: feature,priority: high,milestone: 6-lists" \
  "$M6"

create_issue \
  "[M6] Implement dynamic list rules (filter-based auto-populate)" \
  "For dynamic lists, add a rule builder:\n- Filter by genre, minimum rating, listening status\n- List auto-populates from catalog on open\n\n**Acceptance Criteria**\n- [ ] Dynamic list shows correct albums matching rules\n- [ ] Adding a new catalog item that matches rules makes it appear\n- [ ] Clearly labelled as \"Dynamic\" in the UI" \
  "type: feature,priority: low,milestone: 6-lists" \
  "$M6"

# ── Milestone 7: Home & Polish ───────────────────────────────────────────────
M7="Milestone 7 – Home & Polish"

create_issue \
  "[M7] Build Home screen with recent activity feed" \
  "Implement \`presentation/screens/home/home_screen.dart\`.\nShow the last 10 catalog updates:\n- Album art thumbnail, title, action (\"added to Listened\", \"rated 4★\", etc.)\n- Sorted by most recent\n\n**Acceptance Criteria**\n- [ ] Activity reflects real catalog changes\n- [ ] Empty state shown on first launch\n- [ ] Tapping an activity item navigates to that album" \
  "type: feature,priority: high,milestone: 7-polish" \
  "$M7"

create_issue \
  "[M7] Build Profile screen" \
  "Implement \`presentation/screens/profile/profile_screen.dart\`.\nStats to display:\n- Total albums in catalog (by status)\n- Total reviews written\n- Favorite count\n- Average album rating\n- Top genre (based on catalog)\n\n**Acceptance Criteria**\n- [ ] All stats computed live from Hive\n- [ ] Stats update immediately after changes elsewhere" \
  "type: feature,priority: medium,beginner-friendly,milestone: 7-polish" \
  "$M7"

create_issue \
  "[M7] Add empty state illustrations and messages" \
  "Create \`presentation/widgets/common/empty_state.dart\`.\nAdd meaningful empty states to: Search, Catalog, Lists, Home, Profile.\nUse a simple icon + headline + subtext layout.\n\n**Acceptance Criteria**\n- [ ] Each major screen has a distinct empty state\n- [ ] Empty states look polished in both dark and light mode" \
  "type: feature,priority: medium,beginner-friendly,milestone: 7-polish" \
  "$M7"

create_issue \
  "[M7] Add loading and error state handling app-wide" \
  "Create \`presentation/widgets/common/loading_indicator.dart\` and \`error_message.dart\`.\nWrap all async Riverpod providers with proper \`when(\`loading\`, \`error\`, \`data\`)\` handling.\n\n**Acceptance Criteria**\n- [ ] Loading spinner shown during API calls\n- [ ] User-friendly error message shown on network failure\n- [ ] Retry button on error states where appropriate" \
  "type: feature,priority: high,milestone: 7-polish" \
  "$M7"

create_issue \
  "[M7] Implement theme toggle in Settings" \
  "Add a Settings option (in Profile screen) to toggle between System / Light / Dark mode.\nPersist preference in the \`settings\` Hive box.\n\n**Acceptance Criteria**\n- [ ] Theme changes immediately on toggle\n- [ ] Preference persists across app restarts" \
  "type: feature,priority: low,beginner-friendly,milestone: 7-polish" \
  "$M7"

create_issue \
  "[M7] Phase 1 QA pass and bug fixes" \
  "Walk through the entire app manually on both light and dark mode.\nFile individual bug issues for anything broken.\nFix any blockers before merging \`develop\` → \`main\`.\n\n**Acceptance Criteria**\n- [ ] No crash-level bugs remain\n- [ ] All milestone issues are closed\n- [ ] \`develop\` merged to \`main\` as Phase 1 release" \
  "type: chore,priority: high,milestone: 7-polish" \
  "$M7"

echo ""
echo "🎉 Done! All labels, milestones, and issues have been created."
echo "   Visit: https://github.com/$REPO/issues"
echo "   Create a Project board at: https://github.com/$REPO/projects"
echo ""
echo "📋 Recommended Kanban columns:"
echo "   📋 Backlog | 🔜 Up Next | 🚧 In Progress | 👀 In Review | ✅ Done | 🧊 Icebox"
