#!/usr/bin/env python3
"""
🎵 Music Logger — A terminal music journal
Log albums, rate songs, add notes, and track your listening history.
"""

import json
import os
import sys
from datetime import datetime
from pathlib import Path

# ── Storage ──────────────────────────────────────────────────────────────────

DATA_FILE = Path.home() / ".music_logger.json"

def load_data() -> dict:
    if DATA_FILE.exists():
        with open(DATA_FILE, "r") as f:
            return json.load(f)
    return {"albums": []}

def save_data(data: dict):
    with open(DATA_FILE, "w") as f:
        json.dump(data, f, indent=2)

# ── Display helpers ───────────────────────────────────────────────────────────

RESET  = "\033[0m"
BOLD   = "\033[1m"
DIM    = "\033[2m"
GREEN  = "\033[32m"
CYAN   = "\033[36m"
YELLOW = "\033[33m"
MAGENTA= "\033[35m"
RED    = "\033[31m"
WHITE  = "\033[97m"

def header(text: str):
    width = 56
    print(f"\n{CYAN}{'━' * width}{RESET}")
    print(f"{BOLD}{WHITE}  {text}{RESET}")
    print(f"{CYAN}{'━' * width}{RESET}")

def subheader(text: str):
    print(f"\n{MAGENTA}▸ {BOLD}{text}{RESET}")

def info(label: str, value: str):
    print(f"  {DIM}{label:<14}{RESET} {WHITE}{value}{RESET}")

def stars(rating: float, max_rating: float = 10) -> str:
    filled = round(rating / max_rating * 5)
    return f"{YELLOW}{'★' * filled}{'☆' * (5 - filled)}{RESET} {DIM}({rating:.1f}/10){RESET}"

def prompt(text: str, default: str = "") -> str:
    hint = f" [{default}]" if default else ""
    val = input(f"  {CYAN}→{RESET} {text}{DIM}{hint}{RESET}: ").strip()
    return val if val else default

def prompt_float(text: str, min_val=0, max_val=10) -> float:
    while True:
        raw = prompt(text)
        try:
            val = float(raw)
            if min_val <= val <= max_val:
                return round(val, 1)
            print(f"  {RED}Enter a number between {min_val} and {max_val}.{RESET}")
        except ValueError:
            print(f"  {RED}Please enter a valid number.{RESET}")

def prompt_int(text: str, min_val=1, max_val=999) -> int:
    while True:
        raw = prompt(text)
        try:
            val = int(raw)
            if min_val <= val <= max_val:
                return val
            print(f"  {RED}Enter a number between {min_val} and {max_val}.{RESET}")
        except ValueError:
            print(f"  {RED}Please enter a valid number.{RESET}")

def pick(options: list, text: str = "Choose") -> int:
    for i, opt in enumerate(options, 1):
        print(f"  {DIM}{i}.{RESET} {opt}")
    while True:
        raw = prompt(f"{text} (1-{len(options)})")
        try:
            choice = int(raw)
            if 1 <= choice <= len(options):
                return choice - 1
        except ValueError:
            pass
        print(f"  {RED}Invalid choice.{RESET}")

# ── Core actions ──────────────────────────────────────────────────────────────

def add_album(data: dict):
    header("Log a New Album")

    album = {
        "id": int(datetime.now().timestamp() * 1000),
        "title":       prompt("Album title"),
        "artist":      prompt("Artist"),
        "genre":       prompt("Genre"),
        "year":        prompt("Release year"),
        "date_logged": datetime.now().strftime("%Y-%m-%d"),
        "rating":      None,
        "notes":       "",
        "songs":       [],
    }

    if not album["title"] or not album["artist"]:
        print(f"\n  {RED}Album title and artist are required.{RESET}")
        return

    subheader("Album rating & notes")
    rate_now = prompt("Rate the album now? (y/n)", "y").lower()
    if rate_now == "y":
        album["rating"] = prompt_float("Album rating (0-10)")
    album["notes"] = prompt("Notes (optional)")

    subheader("Track listing")
    num_songs = prompt_int("How many tracks?", 1, 99)
    print(f"\n  {DIM}Enter each track. Press Enter to skip rating/notes.{RESET}\n")

    for i in range(1, num_songs + 1):
        print(f"  {CYAN}Track {i}{RESET}")
        title = prompt("  Title")
        if not title:
            title = f"Track {i}"
        raw_rating = prompt("  Rating (0-10, or Enter to skip)")
        rating = float(raw_rating) if raw_rating else None
        notes  = prompt("  Notes (optional)")
        album["songs"].append({
            "track":  i,
            "title":  title,
            "rating": rating,
            "notes":  notes,
        })
        print()

    data["albums"].append(album)
    save_data(data)
    print(f"\n  {GREEN}✓ \"{album['title']}\" by {album['artist']} logged!{RESET}\n")


def view_album(album: dict):
    header(f"{album['title']}")
    info("Artist",   album["artist"])
    info("Genre",    album["genre"])
    info("Year",     album["year"])
    info("Logged",   album["date_logged"])
    if album["rating"] is not None:
        info("Rating",  "")
        print(f"  {'':14} {stars(album['rating'])}")
    if album["notes"]:
        info("Notes",   album["notes"])

    if album["songs"]:
        subheader("Tracklist")
        for s in album["songs"]:
            rating_str = stars(s["rating"]) if s["rating"] is not None else f"{DIM}(unrated){RESET}"
            print(f"  {DIM}{s['track']:>2}.{RESET}  {WHITE}{s['title']:<30}{RESET} {rating_str}")
            if s["notes"]:
                print(f"        {DIM}{s['notes']}{RESET}")
    print()


def browse_albums(data: dict):
    albums = data["albums"]
    if not albums:
        print(f"\n  {DIM}No albums logged yet.{RESET}\n")
        return

    header("Your Albums")
    for i, a in enumerate(albums, 1):
        rating_str = f"{YELLOW}{a['rating']:.1f}{RESET}" if a["rating"] is not None else f"{DIM}—{RESET}"
        print(f"  {DIM}{i:>2}.{RESET}  {WHITE}{a['title']:<30}{RESET}  {DIM}{a['artist']:<22}{RESET}  {rating_str}")
    print()

    choice = prompt("View details? (enter number, or Enter to go back)", "")
    if choice:
        try:
            idx = int(choice) - 1
            if 0 <= idx < len(albums):
                view_album(albums[idx])
                _album_actions(data, idx)
        except ValueError:
            pass


def _album_actions(data: dict, idx: int):
    album = data["albums"][idx]
    subheader("Options")
    options = ["Edit album rating / notes", "Edit a song", "Delete album", "Back"]
    choice = pick(options)

    if choice == 0:
        album["rating"] = prompt_float("New album rating (0-10)")
        album["notes"]  = prompt("New notes", album["notes"])
        save_data(data)
        print(f"\n  {GREEN}✓ Updated.{RESET}\n")

    elif choice == 1:
        if not album["songs"]:
            print(f"  {DIM}No songs to edit.{RESET}\n")
            return
        for i, s in enumerate(album["songs"], 1):
            print(f"  {i}. {s['title']}")
        sidx = prompt_int("Song number", 1, len(album["songs"])) - 1
        song = album["songs"][sidx]
        raw = prompt(f"New rating (0-10)", str(song["rating"]) if song["rating"] else "")
        song["rating"] = float(raw) if raw else song["rating"]
        song["notes"]  = prompt("New notes", song["notes"])
        save_data(data)
        print(f"\n  {GREEN}✓ Updated.{RESET}\n")

    elif choice == 2:
        confirm = prompt(f"Delete \"{album['title']}\"? (yes/n)", "n")
        if confirm.lower() == "yes":
            data["albums"].pop(idx)
            save_data(data)
            print(f"\n  {GREEN}✓ Deleted.{RESET}\n")


def search_albums(data: dict):
    header("Search & Filter")
    options = ["By artist", "By genre", "By minimum rating", "By title keyword"]
    choice = pick(options, "Search by")

    albums = data["albums"]
    results = []

    if choice == 0:
        q = prompt("Artist name").lower()
        results = [a for a in albums if q in a["artist"].lower()]
    elif choice == 1:
        q = prompt("Genre").lower()
        results = [a for a in albums if q in a["genre"].lower()]
    elif choice == 2:
        min_r = prompt_float("Minimum rating (0-10)")
        results = [a for a in albums if a["rating"] is not None and a["rating"] >= min_r]
    elif choice == 3:
        q = prompt("Title keyword").lower()
        results = [a for a in albums if q in a["title"].lower()]

    if not results:
        print(f"\n  {DIM}No results found.{RESET}\n")
        return

    print(f"\n  {GREEN}{len(results)} result(s):{RESET}\n")
    for i, a in enumerate(results, 1):
        rating_str = f"{YELLOW}{a['rating']:.1f}{RESET}" if a["rating"] is not None else f"{DIM}—{RESET}"
        print(f"  {DIM}{i:>2}.{RESET}  {WHITE}{a['title']:<30}{RESET}  {DIM}{a['artist']:<22}{RESET}  {rating_str}")

    print()
    choice_v = prompt("View details? (number, or Enter to skip)", "")
    if choice_v:
        try:
            idx = int(choice_v) - 1
            if 0 <= idx < len(results):
                view_album(results[idx])
        except ValueError:
            pass


def stats_dashboard(data: dict):
    albums = data["albums"]
    header("Stats Dashboard")

    if not albums:
        print(f"  {DIM}No data yet. Log some albums first!{RESET}\n")
        return

    rated = [a for a in albums if a["rating"] is not None]
    all_songs = [s for a in albums for s in a["songs"]]
    rated_songs = [s for s in all_songs if s["rating"] is not None]

    info("Albums logged",   str(len(albums)))
    info("Total tracks",    str(len(all_songs)))
    info("Rated albums",    str(len(rated)))
    info("Rated songs",     str(len(rated_songs)))

    if rated:
        avg_album = sum(a["rating"] for a in rated) / len(rated)
        top = max(rated, key=lambda a: a["rating"])
        low = min(rated, key=lambda a: a["rating"])
        subheader("Album ratings")
        info("Average",  f"{avg_album:.2f}/10")
        info("Top rated",  f"{top['title']} by {top['artist']} ({top['rating']:.1f})")
        info("Lowest",     f"{low['title']} by {low['artist']} ({low['rating']:.1f})")

    if rated_songs:
        avg_song = sum(s["rating"] for s in rated_songs) / len(rated_songs)
        top_s = max(rated_songs, key=lambda s: s["rating"])
        subheader("Song ratings")
        info("Average",    f"{avg_song:.2f}/10")
        info("Top song",   f"{top_s['title']} ({top_s['rating']:.1f})")

    # Genre breakdown
    genres: dict[str, int] = {}
    for a in albums:
        g = a["genre"] or "Unknown"
        genres[g] = genres.get(g, 0) + 1
    if genres:
        subheader("Genre breakdown")
        for g, count in sorted(genres.items(), key=lambda x: -x[1]):
            bar = "█" * count
            print(f"  {WHITE}{g:<20}{RESET} {GREEN}{bar}{RESET} {DIM}{count}{RESET}")

    # Recent logs
    subheader("Recently logged")
    recent = sorted(albums, key=lambda a: a["date_logged"], reverse=True)[:5]
    for a in recent:
        print(f"  {DIM}{a['date_logged']}{RESET}  {WHITE}{a['title']}{RESET} — {DIM}{a['artist']}{RESET}")

    print()


# ── Main menu ─────────────────────────────────────────────────────────────────

def main():
    data = load_data()

    while True:
        print(f"\n{CYAN}{'━' * 56}{RESET}")
        print(f"{BOLD}{WHITE}  🎵  Music Logger{RESET}  {DIM}({len(data['albums'])} albums){RESET}")
        print(f"{CYAN}{'━' * 56}{RESET}")
        print(f"  {DIM}1.{RESET}  Log a new album")
        print(f"  {DIM}2.{RESET}  Browse albums")
        print(f"  {DIM}3.{RESET}  Search & filter")
        print(f"  {DIM}4.{RESET}  Stats dashboard")
        print(f"  {DIM}5.{RESET}  Quit")
        print()

        choice = prompt("Choose (1-5)")

        if choice == "1":
            add_album(data)
        elif choice == "2":
            browse_albums(data)
        elif choice == "3":
            search_albums(data)
        elif choice == "4":
            stats_dashboard(data)
        elif choice == "5":
            print(f"\n  {DIM}Later. 🎵{RESET}\n")
            sys.exit(0)
        else:
            print(f"  {RED}Pick 1-5.{RESET}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n\n  {DIM}Exited.{RESET}\n")
