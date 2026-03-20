# 🎵 Music Logger

A terminal-based music journal. Log albums, rate songs, write notes, and track your listening history — all from the command line.

---

## Requirements

- Python 3.6 or higher
- No external libraries needed

---

## Setup

1. Download `music_logger.py` and place it wherever you keep your personal projects.
2. Open a terminal and navigate to that folder:

```bash
cd path/to/your/projects/folder
```

3. Run it:

```bash
python3 music_logger.py
```

> **Windows users:** If `python3` doesn't work, try `python music_logger.py` instead.

---

## Data Storage

All your data is automatically saved to a single JSON file in your home directory:

```
~/.music_logger.json
```

This file is created on first use. You can back it up, copy it to another machine, or open it in any text editor to view the raw data.

---

## Features

### Log a New Album
Walk through entering an album's details step by step:
- Title, artist, genre, and release year
- Overall album rating (0–10) and notes
- Full tracklist with per-song ratings and notes

All fields except title and artist are optional — skip anything by pressing Enter.

### Browse Albums
View all logged albums in a table. Select any album to see:
- Full details and tracklist
- Star ratings rendered visually
- Options to edit the album, edit individual songs, or delete the entry

### Search & Filter
Find albums in your library four ways:
- By artist name
- By genre
- By minimum rating (e.g. everything rated 8.0 or above)
- By keyword in the title

### Stats Dashboard
An overview of your entire library:
- Total albums and tracks logged
- Average album and song ratings
- Top-rated and lowest-rated album
- Top-rated song
- Genre breakdown with a bar chart
- 5 most recently logged albums

---

## Usage Example

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  🎵  Music Logger  (12 albums)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  1.  Log a new album
  2.  Browse albums
  3.  Search & filter
  4.  Stats dashboard
  5.  Quit

  → Choose (1-5): 1

  → Album title: Blonde
  → Artist: Frank Ocean
  → Genre: R&B
  → Release year: 2016
  → Rate the album now? (y/n) [y]: y
  → Album rating (0-10): 9.5
  → Notes (optional): Masterpiece front to back

  ✓ "Blonde" by Frank Ocean logged!
```

---

## Tips

- Press **Ctrl+C** at any time to exit cleanly.
- You can exit mid-session without losing data — everything saves automatically after each album is logged.
- To edit an album after logging it, use **Browse albums**, select the album, and choose an edit option from the menu.
