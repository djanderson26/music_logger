# 🎮 gamelog

A personal game tracker that runs entirely in your terminal. Log play sessions, track your backlog, and visualize your stats — no accounts, no internet required.

---

## Requirements

- Python 3.6 or newer
- No external packages needed

---

## Setup

No installation required. Just put `gamelog.py` in a folder and run it:

```
python3 gamelog.py
```

Your data is stored automatically in `~/.gamelog.db` (a SQLite file in your home directory). It's created on first run.

---

## Commands

| Command | What it does |
|---|---|
| `add` | Add a game to your library |
| `log` | Log a play session |
| `done` | Mark a game as completed and rate it |
| `list` | List all games (optionally filter by status) |
| `stats` | Show stats and visualizations |
| `search` | Search your library by title |
| `edit` | Edit any field on a game |
| `delete` | Remove a game and all its sessions |
| `export` | Export your full library to a JSON file |
| `help` | Show command reference |

---

## Usage

### Adding a game

```
python3 gamelog.py add
```

Walks you through a short form. Only the title is required — everything else can be skipped with Enter.

- **Title** — name of the game
- **Platform** — PC, PS5, PS4, Xbox, Switch, iOS, Android, Other
- **Genre** — free text, e.g. RPG, FPS, Puzzle
- **Status** — defaults to `backlog`
- **HowLongToBeat times** — main story, main + extras, completionist (in hours)
- **Notes** — anything you want to remember

### Logging a session

```
python3 gamelog.py log
python3 gamelog.py log elden        # pre-filter by name
```

Pick a game from the list, then enter:

- **Duration** — in minutes (`90`) or hours (`1.5h`)
- **Date** — defaults to today
- **Notes** — optional

After saving, it shows your total playtime and a progress bar against your HowLongToBeat estimate (if set).

> If a game is in your `backlog` or `wishlist`, logging a session automatically moves it to `playing`.

### Marking a game as completed

```
python3 gamelog.py done
```

Pick a game, then enter a rating (1–10), optional notes, and the finished date (defaults to today).

### Viewing stats

```
python3 gamelog.py stats
```

No inputs needed. Shows:

- Overview (total time, sessions, average rating)
- Library breakdown by status
- Top 10 games by time played
- Genre and platform breakdowns
- 8-week activity heatmap
- HowLongToBeat progress bars for games you're currently playing
- Top rated completions

### Filtering your library

```
python3 gamelog.py list
python3 gamelog.py list playing
python3 gamelog.py list completed
python3 gamelog.py list backlog
```

### Exporting your data

```
python3 gamelog.py export
python3 gamelog.py export my_games.json
```

Exports everything — games, sessions, and totals — to a JSON file. Useful for backups or if you ever want to build something on top of this data.

---

## Game statuses

| Status | Meaning |
|---|---|
| `playing` | Currently active |
| `completed` | Finished |
| `dropped` | Started but stopped |
| `backlog` | Owned or planned, not started |
| `wishlist` | Want to play someday |

---

## Data storage

Everything lives in `~/.gamelog.db`. To back it up, just copy that file. To start fresh, delete it.

---

## Future ideas

- Auto-fill game info from RAWG or IGDB API on `add`
- Weekly summary / recap command
- Web dashboard using the same SQLite data
- Import from Steam, Backloggd, or HowLongToBeat
