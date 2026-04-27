# 🎵 Music Logger

> A personal music journaling and discovery app — like Letterboxd, but for music.

Track albums, rate songs, write reviews, and manage your listening catalog. Built with Flutter for iOS, Android, and Web, powered by MusicBrainz, Cover Art Archive, Last.fm, and Genius APIs.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Development Phases](#development-phases)
- [Branching Strategy](#branching-strategy)
- [Getting Started (Flutter)](#getting-started-flutter)
- [API Keys & Configuration](#api-keys--configuration)
- [GitHub Workflow](#github-workflow)
- [Terminal Prototype](#terminal-prototype)

---

## Overview

Music Logger lets you:

- 🔍 **Search** albums, artists, and songs via MusicBrainz
- 🎨 **Browse** full metadata with album art (Cover Art Archive) and artist bios (Last.fm)
- 📚 **Catalog** your listening with statuses: *Want to Listen*, *Listening*, *Listened*
- ⭐ **Rate** albums and individual songs (1–5 stars)
- ✍️ **Review** albums and songs with full edit history
- 📋 **Organize** music into custom Lists (static and dynamic)
- ❤️ **Favorite** albums, artists, and songs
- 🎬 **Watch** YouTube embeds for songs; open Spotify / Apple Music directly
- 🌙 **Dark / Light mode** support

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile + Web | Flutter / Dart |
| Local Storage | Hive (offline-first MVP) |
| Cloud Backend *(Phase 2)* | Firebase (Firestore, Auth, Storage) |
| Music Data | MusicBrainz API |
| Album Art | Cover Art Archive |
| Artist Bios | Last.fm API |
| Song Credits | Genius API |
| State Management | Riverpod |

---

## Project Structure

```
music_logger/
├── README.md                        # This file
├── music_logger.py                  # Legacy terminal prototype
│
├── .github/
│   ├── ISSUE_TEMPLATE/              # GitHub issue templates
│   │   ├── feature_request.md
│   │   ├── bug_report.md
│   │   └── task.md
│   └── workflows/                   # CI/CD (future)
│
└── music_logger_app/                # Flutter application root
    ├── pubspec.yaml
    ├── lib/
    │   ├── main.dart                # App entry point
    │   │
    │   ├── core/                    # App-wide shared code
    │   │   ├── constants/           # API URLs, Hive box names, etc.
    │   │   ├── theme/               # Dark/light ThemeData
    │   │   ├── utils/               # Date formatters, helpers
    │   │   └── errors/              # Custom exceptions
    │   │
    │   ├── data/                    # Data layer
    │   │   ├── models/              # JSON-serializable data models
    │   │   ├── repositories/        # Concrete repository implementations
    │   │   └── datasources/
    │   │       ├── local/           # Hive adapters & DAOs
    │   │       └── remote/          # HTTP clients for APIs
    │   │
    │   ├── domain/                  # Business logic layer (pure Dart)
    │   │   ├── entities/            # Core business objects
    │   │   ├── repositories/        # Abstract repository interfaces
    │   │   └── usecases/            # Single-purpose use-case classes
    │   │
    │   └── presentation/            # UI layer
    │       ├── screens/
    │       │   ├── home/            # Home feed / recent activity
    │       │   ├── search/          # Search + results
    │       │   ├── album_detail/    # Album page
    │       │   ├── artist_detail/   # Artist page
    │       │   ├── catalog/         # Personal listening catalog
    │       │   ├── profile/         # User profile
    │       │   ├── review/          # Write / edit review
    │       │   └── lists/           # Groups & lists
    │       ├── widgets/
    │       │   ├── common/          # Reusable UI components
    │       │   ├── album/           # Album-specific widgets
    │       │   ├── artist/          # Artist-specific widgets
    │       │   └── song/            # Song-specific widgets
    │       ├── blocs/               # BLoC classes (alternative to Riverpod)
    │       └── providers/           # Riverpod providers
    │
    ├── assets/
    │   ├── fonts/                   # Custom fonts
    │   ├── images/                  # Static images / placeholders
    │   └── icons/                   # Custom icons
    │
    └── test/
        ├── unit/                    # Unit tests (use-cases, models)
        ├── widget/                  # Widget tests
        └── integration/             # End-to-end tests
```

---

## Development Phases

### ✅ Phase 0 — Terminal Prototype (Done)
- Python CLI app with local JSON storage
- Album logging, star ratings, notes, search, and stats dashboard

### 🚧 Phase 1 — Flutter MVP (Local Only)

> All data stored on-device with Hive. No account or sync required.

**Milestone 1 — Project Foundation**
- Flutter project scaffold with `flutter create`
- Hive local storage setup and configuration
- App navigation (bottom nav bar + named routing)
- Dark / light theme with ThemeData

**Milestone 2 — Music Search & API Integration**
- MusicBrainz search service (albums, artists, songs)
- Cover Art Archive integration for album artwork
- Artist bios and metadata via Last.fm
- Song credits and annotations via Genius

**Milestone 3 — Album & Artist Detail Pages**
- Album detail screen (cover art, tracklist, metadata)
- Artist detail screen (bio, discography)
- Song detail screen (credits, YouTube embed)
- External links to Spotify / Apple Music

**Milestone 4 — Personal Catalog**
- Listening status management (Want to Listen / Listening / Listened)
- Catalog browsing with filter and sort
- Favorites system for albums, artists, and songs

**Milestone 5 — Ratings & Reviews**
- 1–5 star rating widget for albums and songs
- Written review composer with markdown support
- Review edit history (stored locally)

**Milestone 6 — Lists Feature**
- Create and manage named lists
- Static lists (manual curation)
- Dynamic lists (auto-populate from filter rules)
- Add / remove albums or songs from any list

**Milestone 7 — Home & Profile Pages**
- Recent activity home feed
- Basic profile page with stats snapshot
- App polish: animations, empty states, error handling screens

### 🔮 Phase 2 — Firebase + Social (Future)
- User accounts and Firebase Authentication
- Firestore data sync across devices
- Follow users, shared reviews, social activity feed
- Billboard chart integration

---

## Branching Strategy

This project uses a simplified **GitHub Flow** adapted for solo development with occasional collaborators.

```
main                    ← Always stable; only merge via PR
  └── develop           ← Integration branch for in-progress Phase 1
        ├── feature/    ← One branch per issue or feature
        ├── fix/        ← Bug fixes
        └── chore/      ← Tooling, deps, non-user-facing work
```

### Branch Naming

| Prefix | Example | When to use |
|---|---|---|
| `feature/` | `feature/album-detail-screen` | New feature work |
| `fix/` | `fix/search-empty-state-crash` | Bug fixes |
| `chore/` | `chore/update-dependencies` | Maintenance tasks |
| `docs/` | `docs/update-api-setup` | Documentation only |

### Rules

1. **Never push directly to `main`.** Always open a Pull Request.
2. Merge `feature/*` → `develop`, then `develop` → `main` when a milestone is complete.
3. Keep branches short-lived (1–3 days ideally). Break large features into smaller issues.
4. Use **squash merges** when merging feature branches to keep history clean.
5. Collaborators fork the repo or request branch access, then open PRs against `develop`.

### Typical Workflow

```bash
# Start a new task
git checkout develop
git pull origin develop
git checkout -b feature/album-detail-screen

# Work, commit often with meaningful messages
git add .
git commit -m "feat: add album header with cover art and metadata"

# Push and open a PR into develop
git push origin feature/album-detail-screen
# On GitHub: open PR → develop, review, squash & merge
```

---

## Getting Started (Flutter)

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.19
- Dart SDK (included with Flutter)
- Android Studio **or** VS Code with Flutter & Dart extensions
- Android/iOS simulator or physical device

### Setup

```bash
# 1. Clone the repo
git clone https://github.com/djanderson26/music_logger.git
cd music_logger

# 2. Create the Flutter app (first time only)
flutter create music_logger_app
cd music_logger_app

# 3. Install dependencies
flutter pub get

# 4. Generate Hive adapters (run whenever you modify a @HiveType model)
flutter pub run build_runner build --delete-conflicting-outputs

# 5. Run the app
flutter run
```

### Recommended VS Code Extensions
- Flutter
- Dart
- Flutter Riverpod Snippets
- Error Lens
- GitLens

### Key Dependencies (add to pubspec.yaml)

```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State management
  hive_flutter: ^1.1.0        # Local storage
  http: ^1.2.1                # API calls
  cached_network_image: ^3.3.1 # Image caching
  go_router: ^13.2.0          # Navigation/routing
  youtube_player_flutter: ^9.0.3  # YouTube embeds
  url_launcher: ^6.2.6        # Open Spotify/Apple Music
  flutter_dotenv: ^5.1.0      # Environment variables
  intl: ^0.19.0               # Date/number formatting

dev_dependencies:
  hive_generator: ^2.0.1      # Code gen for Hive models
  build_runner: ^2.4.9        # Dart code generation
  flutter_test:
    sdk: flutter
```

---

## API Keys & Configuration

Create a `.env` file in `music_logger_app/` — **never commit this file**.

```env
LASTFM_API_KEY=your_lastfm_key_here
GENIUS_ACCESS_TOKEN=your_genius_token_here
```

Then add to `.gitignore`:
```
.env
*.env
```

### Getting API Keys

| API | Link | Notes |
|---|---|---|
| Last.fm | https://www.last.fm/api/account/create | Free, instant |
| Genius | https://genius.com/api-clients | Free, instant |
| MusicBrainz | *(no key needed)* | Rate limit: 1 req/sec; add `User-Agent` header |
| Cover Art Archive | *(no key needed)* | Part of MusicBrainz ecosystem |

**MusicBrainz User-Agent requirement:** All requests must include a descriptive `User-Agent` header:
```
User-Agent: MusicLogger/1.0 (github.com/djanderson26/music_logger)
```

---

## GitHub Workflow

### Labels

| Label | Color | Purpose |
|---|---|---|
| `type: feature` | `#0075ca` | New functionality |
| `type: bug` | `#d73a4a` | Something is broken |
| `type: chore` | `#e4e669` | Maintenance/tooling |
| `type: docs` | `#0052cc` | Documentation |
| `priority: high` | `#b60205` | Must-have for milestone |
| `priority: medium` | `#fbca04` | Should-have |
| `priority: low` | `#0e8a16` | Nice-to-have |
| `beginner-friendly` | `#7057ff` | Good first issue |
| `milestone: 1-foundation` | `#c5def5` | Phase 1, Milestone 1 |
| `milestone: 2-api` | `#bfd4f2` | Phase 1, Milestone 2 |
| `milestone: 3-detail-pages` | `#d4c5f9` | Phase 1, Milestone 3 |
| `milestone: 4-catalog` | `#c2e0c6` | Phase 1, Milestone 4 |
| `milestone: 5-ratings` | `#fef2c0` | Phase 1, Milestone 5 |
| `milestone: 6-lists` | `#f9d0c4` | Phase 1, Milestone 6 |
| `milestone: 7-polish` | `#e4c1f9` | Phase 1, Milestone 7 |

### Kanban Board Columns

| Column | Purpose |
|---|---|
| 📋 **Backlog** | All issues not yet started |
| 🔜 **Up Next** | Issues ready to start this week |
| 🚧 **In Progress** | Currently being worked on (limit: 2 max) |
| 👀 **In Review** | PR open, awaiting review |
| ✅ **Done** | Merged and complete |
| 🧊 **Icebox** | Phase 2+ ideas, not currently planned |

### Setting Up the Project Board

Run the included setup script to create all labels, milestones, and issues automatically:

```bash
cd .github
bash setup_github.sh
```

> Requires the [GitHub CLI](https://cli.github.com/) (`gh`) and `gh auth login`.

---

## Terminal Prototype

The original Python CLI lives in `music_logger.py` and works standalone with no dependencies:

```bash
python3 music_logger.py
```

Data is saved to `~/.music_logger.json`. This prototype is kept as a reference for the feature set being rebuilt in Flutter.

---

*Built with ♥ by [@djanderson26](https://github.com/djanderson26)*
