#!/usr/bin/env python3
"""
gamelog.py — Personal game tracker & stats CLI
Usage: python3 gamelog.py [command] [args]

Commands:
  log       Log a game session
  add       Add a game to your library
  done      Mark a game as completed
  stats     Show stats & visualizations
  list      List all games
  search    Search your library
  edit      Edit a game entry
  delete    Delete a game
  export    Export to JSON
  help      Show this help
"""

import sqlite3
import json
import os
import sys
import datetime
import math
from collections import defaultdict

DB_PATH = os.path.expanduser("~/.gamelog.db")

# ─── ANSI Colors ──────────────────────────────────────────────────────────────
R  = "\033[0m"
B  = "\033[1m"
DIM= "\033[2m"
U  = "\033[4m"

FG = {
    "black":   "\033[30m", "red":     "\033[31m", "green":  "\033[32m",
    "yellow":  "\033[33m", "blue":    "\033[34m", "magenta":"\033[35m",
    "cyan":    "\033[36m", "white":   "\033[37m",
    "bblack":  "\033[90m", "bred":    "\033[91m", "bgreen": "\033[92m",
    "byellow": "\033[93m", "bblue":   "\033[94m", "bmagenta":"\033[95m",
    "bcyan":   "\033[96m", "bwhite":  "\033[97m",
}

def c(text, color=None, bold=False, dim=False, underline=False):
    out = ""
    if bold:      out += B
    if dim:       out += DIM
    if underline: out += U
    if color:     out += FG.get(color, "")
    return out + str(text) + R

def box(title, width=60):
    print(c("┌" + "─"*(width-2) + "┐", "bblack"))
    pad = (width - 2 - len(title)) // 2
    print(c("│", "bblack") + " "*pad + c(title, "bcyan", bold=True) + " "*(width-2-pad-len(title)) + c("│", "bblack"))
    print(c("└" + "─"*(width-2) + "┘", "bblack"))

def divider(width=60, char="─"):
    print(c(char * width, "bblack"))

def bar(value, max_value, width=30, fill="█", empty="░", color="bgreen"):
    if max_value == 0: filled = 0
    else: filled = int((value / max_value) * width)
    filled = min(filled, width)
    return c(fill * filled, color) + c(empty * (width - filled), "bblack")

# ─── Database ─────────────────────────────────────────────────────────────────
def get_db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db()
    conn.executescript("""
        CREATE TABLE IF NOT EXISTS games (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT NOT NULL,
            platform    TEXT,
            genre       TEXT,
            status      TEXT DEFAULT 'playing',
            rating      REAL,
            hltb_main   REAL,
            hltb_extra  REAL,
            hltb_complete REAL,
            notes       TEXT,
            cover_url   TEXT,
            added_at    TEXT DEFAULT (date('now')),
            started_at  TEXT,
            finished_at TEXT
        );
        CREATE TABLE IF NOT EXISTS sessions (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            game_id     INTEGER NOT NULL,
            date        TEXT DEFAULT (date('now')),
            duration_min INTEGER NOT NULL,
            notes       TEXT,
            FOREIGN KEY(game_id) REFERENCES games(id)
        );
    """)
    conn.commit()
    conn.close()

# ─── Helpers ──────────────────────────────────────────────────────────────────
STATUSES = ["playing", "completed", "dropped", "backlog", "wishlist"]
PLATFORMS = ["PC", "PS5", "PS4", "Xbox", "Switch", "iOS", "Android", "Other"]

def prompt(label, default=None, options=None, required=False):
    hint = ""
    if options:
        hint = c(f" [{'/'.join(options)}]", "bblack")
    if default is not None:
        hint += c(f" (default: {default})", "bblack")
    sys.stdout.write(c("  → ", "bcyan") + c(label, "bwhite") + hint + ": ")
    sys.stdout.flush()
    val = input().strip()
    if not val and default is not None:
        return default
    if options and val and val not in options:
        # fuzzy match
        matches = [o for o in options if o.lower().startswith(val.lower())]
        if matches:
            return matches[0]
    if required and not val:
        print(c("  ✗ This field is required.", "bred"))
        return prompt(label, default, options, required)
    return val or None

def pick_game(conn, query=None):
    if query:
        rows = conn.execute(
            "SELECT id, title, platform, status FROM games WHERE title LIKE ? ORDER BY title",
            (f"%{query}%",)
        ).fetchall()
    else:
        rows = conn.execute(
            "SELECT id, title, platform, status FROM games ORDER BY title"
        ).fetchall()
    if not rows:
        print(c("  No games found.", "bred"))
        return None
    if len(rows) == 1:
        return rows[0]["id"]
    print()
    for i, r in enumerate(rows, 1):
        status_color = {"playing":"bgreen","completed":"bcyan","dropped":"bred","backlog":"byellow","wishlist":"bmagenta"}.get(r["status"],"bwhite")
        print(f"  {c(str(i).rjust(2),'bblack')}  {c(r['title'],'bwhite',bold=True)}  {c(r['platform'] or '','bblack')}  {c(r['status'],status_color)}")
    sys.stdout.write(c("  → ", "bcyan") + "Pick number: ")
    sys.stdout.flush()
    try:
        n = int(input().strip())
        return rows[n-1]["id"]
    except:
        print(c("  Invalid selection.", "bred"))
        return None

def fmt_hours(minutes):
    if minutes is None: return c("—", "bblack")
    h = minutes // 60
    m = minutes % 60
    if h == 0: return c(f"{m}m", "byellow")
    if m == 0: return c(f"{h}h", "byellow")
    return c(f"{h}h {m}m", "byellow")

def total_minutes(game_id, conn):
    row = conn.execute("SELECT SUM(duration_min) FROM sessions WHERE game_id=?", (game_id,)).fetchone()
    return row[0] or 0

# ─── Commands ─────────────────────────────────────────────────────────────────

def cmd_add(args):
    conn = get_db()
    print()
    box("ADD GAME TO LIBRARY")
    print()
    title    = prompt("Title", required=True)
    platform = prompt("Platform", options=PLATFORMS)
    genre    = prompt("Genre (e.g. RPG, FPS, Puzzle)")
    status   = prompt("Status", default="backlog", options=STATUSES)
    hltb_m   = prompt("HowLongToBeat — Main Story (hours)")
    hltb_e   = prompt("HowLongToBeat — Main + Extras (hours)")
    hltb_c   = prompt("HowLongToBeat — Completionist (hours)")
    notes    = prompt("Notes")

    def to_float(v):
        try: return float(v) * 60 if v else None
        except: return None

    conn.execute("""
        INSERT INTO games (title, platform, genre, status, hltb_main, hltb_extra, hltb_complete, notes, started_at)
        VALUES (?,?,?,?,?,?,?,?,?)
    """, (title, platform, genre, status,
          to_float(hltb_m), to_float(hltb_e), to_float(hltb_c),
          notes,
          str(datetime.date.today()) if status == "playing" else None))
    conn.commit()
    game_id = conn.execute("SELECT last_insert_rowid()").fetchone()[0]
    print()
    print(c(f"  ✓ Added: ", "bgreen") + c(title, "bwhite", bold=True) + c(f" (id={game_id})", "bblack"))
    print()
    conn.close()

def cmd_log(args):
    conn = get_db()
    print()
    box("LOG SESSION")
    print()

    query = " ".join(args) if args else None
    game_id = pick_game(conn, query)
    if not game_id: return

    game = conn.execute("SELECT * FROM games WHERE id=?", (game_id,)).fetchone()
    print()
    print(c(f"  Logging session for: ", "bblack") + c(game["title"], "bwhite", bold=True))
    print()

    dur_str  = prompt("Duration (e.g. 90 for 90min, or 1.5h)", required=True)
    date_str = prompt("Date", default=str(datetime.date.today()))
    snotes   = prompt("Session notes")

    # parse duration
    dur_str = dur_str.strip().lower()
    if dur_str.endswith("h"):
        try: minutes = int(float(dur_str[:-1]) * 60)
        except: minutes = 60
    else:
        try: minutes = int(float(dur_str))
        except: minutes = 60

    conn.execute("INSERT INTO sessions (game_id, date, duration_min, notes) VALUES (?,?,?,?)",
                 (game_id, date_str, minutes, snotes))

    # auto-update status to playing if backlog/wishlist
    if game["status"] in ("backlog", "wishlist"):
        conn.execute("UPDATE games SET status='playing', started_at=? WHERE id=?",
                     (date_str, game_id))

    conn.commit()
    total = total_minutes(game_id, conn)
    print()
    print(c(f"  ✓ Logged {fmt_hours(minutes)}", "bgreen") +
          c(f"  •  Total played: ", "bblack") + fmt_hours(total))

    # show progress vs hltb
    if game["hltb_main"]:
        pct = min(total / game["hltb_main"] * 100, 100)
        print(c(f"\n  Progress vs Main Story: ", "bblack") +
              bar(total, game["hltb_main"], width=25) +
              c(f"  {pct:.0f}%", "bwhite"))
    print()
    conn.close()

def cmd_done(args):
    conn = get_db()
    print()
    box("MARK COMPLETED")
    print()

    query = " ".join(args) if args else None
    game_id = pick_game(conn, query)
    if not game_id: return

    game = conn.execute("SELECT * FROM games WHERE id=?", (game_id,)).fetchone()
    print()
    print(c(f"  Completing: ", "bblack") + c(game["title"], "bwhite", bold=True))
    print()

    rating = prompt("Your rating (1–10)", options=[str(i) for i in range(1,11)])
    notes  = prompt("Final thoughts / notes")
    date   = prompt("Finished date", default=str(datetime.date.today()))

    conn.execute("""
        UPDATE games SET status='completed', rating=?, notes=?, finished_at=? WHERE id=?
    """, (float(rating) if rating else None, notes, date, game_id))
    conn.commit()

    total = total_minutes(game_id, conn)
    print()
    print(c(f"  🎮 Completed: ", "bgreen", bold=True) + c(game["title"], "bwhite", bold=True))
    print(c(f"     Total time: ", "bblack") + fmt_hours(total))
    if rating:
        stars = "★" * int(float(rating)//2) + "☆" * (5 - int(float(rating)//2))
        print(c(f"     Rating: ", "bblack") + c(stars, "byellow") + c(f" {rating}/10", "byellow"))
    print()
    conn.close()

def cmd_list(args):
    conn = get_db()
    print()
    box("YOUR LIBRARY")
    print()

    filter_status = args[0] if args else None
    if filter_status:
        rows = conn.execute("SELECT * FROM games WHERE status=? ORDER BY title", (filter_status,)).fetchall()
    else:
        rows = conn.execute("SELECT * FROM games ORDER BY status, title").fetchall()

    if not rows:
        print(c("  No games found. Use `add` to get started!", "bblack"))
        print()
        return

    status_color = {"playing":"bgreen","completed":"bcyan","dropped":"bred","backlog":"byellow","wishlist":"bmagenta"}
    current_status = None

    for r in rows:
        if r["status"] != current_status:
            current_status = r["status"]
            print(c(f"  {current_status.upper()}", status_color.get(current_status,"bwhite"), bold=True))
            divider(50)

        mins = total_minutes(r["id"], conn)
        rating_str = ""
        if r["rating"]:
            stars = "★" * int(r["rating"]//2)
            rating_str = c(f" {stars} {r['rating']}/10", "byellow")

        print(c(f"  {str(r['id']).rjust(3)} ", "bblack") +
              c(r["title"], "bwhite", bold=True) +
              c(f"  {r['platform'] or ''}", "bblack") +
              rating_str)

        time_str = fmt_hours(mins) if mins else c("no sessions yet", "bblack", dim=True)
        hltb_str = ""
        if r["hltb_main"] and mins:
            pct = min(mins / r["hltb_main"] * 100, 100)
            hltb_str = c(f"  {pct:.0f}% of main story", "bblack")
        print(c(f"       Time logged: ", "bblack") + time_str + hltb_str)
        print()

    conn.close()

def cmd_stats(args):
    conn = get_db()
    print()
    box("STATS & VISUALIZATIONS", width=65)
    print()

    games    = conn.execute("SELECT * FROM games").fetchall()
    sessions = conn.execute("SELECT * FROM sessions ORDER BY date").fetchall()

    if not games:
        print(c("  No data yet. Start adding games!", "bblack"))
        return

    total_games     = len(games)
    completed_games = [g for g in games if g["status"] == "completed"]
    playing_games   = [g for g in games if g["status"] == "playing"]
    all_minutes     = sum(s["duration_min"] for s in sessions)

    # ── Overview ──
    print(c("  OVERVIEW", "bcyan", bold=True))
    divider(50)
    stats_rows = [
        ("Total games",     str(total_games)),
        ("Completed",       str(len(completed_games))),
        ("Currently playing", str(len(playing_games))),
        ("Total time played", fmt_hours(all_minutes)),
        ("Total sessions",   str(len(sessions))),
    ]
    if sessions:
        avg = all_minutes // len(sessions)
        stats_rows.append(("Avg session length", fmt_hours(avg)))
    if completed_games:
        rated = [g for g in completed_games if g["rating"]]
        if rated:
            avg_r = sum(g["rating"] for g in rated) / len(rated)
            stats_rows.append(("Avg rating", c(f"{avg_r:.1f}/10", "byellow")))

    for label, val in stats_rows:
        print(f"  {c(label.ljust(22), 'bblack')} {val}")
    print()

    # ── Status breakdown ──
    print(c("  LIBRARY BREAKDOWN", "bcyan", bold=True))
    divider(50)
    status_counts = defaultdict(int)
    for g in games:
        status_counts[g["status"]] += 1
    status_color = {"playing":"bgreen","completed":"bcyan","dropped":"bred","backlog":"byellow","wishlist":"bmagenta"}
    for status in STATUSES:
        count = status_counts.get(status, 0)
        if count:
            b = bar(count, total_games, width=25, color=status_color.get(status,"bwhite"))
            print(f"  {c(status.ljust(12), status_color.get(status,'bwhite'))}  {b}  {c(str(count),'bwhite')}")
    print()

    # ── Time per game (top 10) ──
    if sessions:
        print(c("  TIME PER GAME (top 10)", "bcyan", bold=True))
        divider(50)
        game_mins = {}
        for g in games:
            m = total_minutes(g["id"], conn)
            if m > 0:
                game_mins[g["title"]] = m
        top = sorted(game_mins.items(), key=lambda x: -x[1])[:10]
        if top:
            max_m = top[0][1]
            for title, m in top:
                trunc = title[:22] + "…" if len(title) > 23 else title.ljust(23)
                b = bar(m, max_m, width=22, color="bblue")
                print(f"  {c(trunc,'bwhite')}  {b}  {fmt_hours(m)}")
        print()

    # ── Genre breakdown ──
    genre_counts = defaultdict(int)
    for g in games:
        if g["genre"]:
            genre_counts[g["genre"]] += 1
    if genre_counts:
        print(c("  GENRES", "bcyan", bold=True))
        divider(50)
        max_g = max(genre_counts.values())
        for genre, cnt in sorted(genre_counts.items(), key=lambda x: -x[1]):
            b = bar(cnt, max_g, width=20, color="bmagenta")
            print(f"  {c(genre.ljust(18),'bwhite')}  {b}  {c(str(cnt),'bwhite')}")
        print()

    # ── Platform breakdown ──
    plat_counts = defaultdict(int)
    for g in games:
        if g["platform"]:
            plat_counts[g["platform"]] += 1
    if plat_counts:
        print(c("  PLATFORMS", "bcyan", bold=True))
        divider(50)
        max_p = max(plat_counts.values())
        for plat, cnt in sorted(plat_counts.items(), key=lambda x: -x[1]):
            b = bar(cnt, max_p, width=20, color="bblue")
            print(f"  {c(plat.ljust(12),'bwhite')}  {b}  {c(str(cnt),'bwhite')}")
        print()

    # ── Sessions heatmap (last 8 weeks) ──
    if sessions:
        print(c("  ACTIVITY — LAST 8 WEEKS", "bcyan", bold=True))
        divider(50)
        today = datetime.date.today()
        week_mins = defaultdict(int)
        for s in sessions:
            try:
                d = datetime.date.fromisoformat(s["date"])
                delta = (today - d).days
                week = delta // 7
                if week < 8:
                    week_mins[week] += s["duration_min"]
            except: pass

        if week_mins:
            max_w = max(week_mins.values()) if week_mins else 1
            # most recent week on the right
            print("  " + c("older", "bblack", dim=True))
            row = "  "
            for week in range(7, -1, -1):
                m = week_mins.get(week, 0)
                if m == 0:
                    row += c("░░", "bblack")
                elif m < max_w * 0.33:
                    row += c("▒▒", "bblue")
                elif m < max_w * 0.66:
                    row += c("▓▓", "bcyan")
                else:
                    row += c("██", "bgreen")
                row += " "
            print(row + c("← now", "bblack", dim=True))
            print()

    # ── Completion rate over time ──
    if completed_games:
        print(c("  TOP RATED COMPLETIONS", "bcyan", bold=True))
        divider(50)
        rated = sorted([g for g in completed_games if g["rating"]], key=lambda x: -x["rating"])[:5]
        for g in rated:
            stars = "★" * int(g["rating"]//2) + "☆" * (5 - int(g["rating"]//2))
            mins = total_minutes(g["id"], conn)
            title = g["title"][:28] + "…" if len(g["title"]) > 29 else g["title"].ljust(29)
            print(f"  {c(title,'bwhite')}  {c(stars,'byellow')} {c(str(g['rating'])+'/10','byellow')}  {fmt_hours(mins)}")
        print()

    # ── HowLongToBeat progress ──
    hltb_games = [g for g in games if g["hltb_main"] and g["status"] == "playing"]
    if hltb_games:
        print(c("  HLTB PROGRESS (currently playing)", "bcyan", bold=True))
        divider(50)
        for g in hltb_games:
            mins = total_minutes(g["id"], conn)
            pct = min(mins / g["hltb_main"] * 100, 100)
            title = g["title"][:22] + "…" if len(g["title"]) > 23 else g["title"].ljust(23)
            b = bar(mins, g["hltb_main"], width=22, color="bgreen")
            remaining = max(0, g["hltb_main"] - mins)
            print(f"  {c(title,'bwhite')}  {b}  {c(f'{pct:.0f}%','bwhite')}")
            print(c(f"  {'':23}  Main story: {fmt_hours(int(g['hltb_main']))}  •  Remaining: {fmt_hours(int(remaining))}", "bblack"))
        print()

    conn.close()

def cmd_search(args):
    query = " ".join(args) if args else prompt("Search title")
    if not query: return
    conn = get_db()
    print()
    box(f"SEARCH: {query}")
    print()
    rows = conn.execute("SELECT * FROM games WHERE title LIKE ?", (f"%{query}%",)).fetchall()
    if not rows:
        print(c("  No matches found.", "bblack"))
    for r in rows:
        mins = total_minutes(r["id"], conn)
        status_color = {"playing":"bgreen","completed":"bcyan","dropped":"bred","backlog":"byellow","wishlist":"bmagenta"}
        print(c(f"  #{r['id']} ", "bblack") + c(r["title"], "bwhite", bold=True) +
              c(f"  {r['platform'] or ''}", "bblack") +
              c(f"  [{r['status']}]", status_color.get(r["status"],"bwhite")))
        if r["genre"]:    print(c(f"     Genre: ","bblack") + c(r["genre"],"bwhite"))
        if mins:          print(c(f"     Played: ","bblack") + fmt_hours(mins))
        if r["rating"]:   print(c(f"     Rating: ","bblack") + c(f"{r['rating']}/10","byellow"))
        if r["notes"]:    print(c(f"     Notes: ","bblack") + c(r["notes"],"bwhite"))
        print()
    conn.close()

def cmd_delete(args):
    conn = get_db()
    print()
    box("DELETE GAME")
    print()
    query = " ".join(args) if args else None
    game_id = pick_game(conn, query)
    if not game_id: return
    game = conn.execute("SELECT * FROM games WHERE id=?", (game_id,)).fetchone()
    print()
    confirm = prompt(f"Delete '{game['title']}'? This also removes all sessions. (yes/no)", default="no")
    if confirm and confirm.lower() in ("yes", "y"):
        conn.execute("DELETE FROM sessions WHERE game_id=?", (game_id,))
        conn.execute("DELETE FROM games WHERE id=?", (game_id,))
        conn.commit()
        print(c(f"  ✓ Deleted: {game['title']}", "bred"))
    else:
        print(c("  Cancelled.", "bblack"))
    print()
    conn.close()

def cmd_export(args):
    conn = get_db()
    games = [dict(r) for r in conn.execute("SELECT * FROM games").fetchall()]
    for g in games:
        g["sessions"] = [dict(s) for s in conn.execute(
            "SELECT * FROM sessions WHERE game_id=?", (g["id"],)).fetchall()]
        g["total_minutes"] = sum(s["duration_min"] for s in g["sessions"])
    path = args[0] if args else "gamelog_export.json"
    with open(path, "w") as f:
        json.dump(games, f, indent=2)
    print(c(f"\n  ✓ Exported {len(games)} games to {path}\n", "bgreen"))
    conn.close()

def cmd_edit(args):
    conn = get_db()
    print()
    box("EDIT GAME")
    print()
    query = " ".join(args) if args else None
    game_id = pick_game(conn, query)
    if not game_id: return
    game = conn.execute("SELECT * FROM games WHERE id=?", (game_id,)).fetchone()
    print()
    print(c(f"  Editing: ", "bblack") + c(game["title"], "bwhite", bold=True))
    print(c("  (Press Enter to keep current value)", "bblack", dim=True))
    print()

    def maybe(label, field, options=None):
        cur = game[field]
        val = prompt(f"{label}", default=cur, options=options)
        return val

    title    = maybe("Title",    "title")
    platform = maybe("Platform", "platform", PLATFORMS)
    genre    = maybe("Genre",    "genre")
    status   = maybe("Status",   "status",   STATUSES)
    rating   = maybe("Rating",   "rating")
    notes    = maybe("Notes",    "notes")

    def to_float_min(v):
        try: return float(v) * 60 if v else None
        except: return None

    hltb_m = prompt("HLTB Main Story (hours)", default=str(game["hltb_main"]/60) if game["hltb_main"] else None)
    hltb_e = prompt("HLTB Main+Extras (hours)", default=str(game["hltb_extra"]/60) if game["hltb_extra"] else None)
    hltb_c = prompt("HLTB Completionist (hours)", default=str(game["hltb_complete"]/60) if game["hltb_complete"] else None)

    conn.execute("""
        UPDATE games SET title=?,platform=?,genre=?,status=?,rating=?,notes=?,
        hltb_main=?,hltb_extra=?,hltb_complete=? WHERE id=?
    """, (title, platform, genre, status,
          float(rating) if rating else None,
          notes,
          to_float_min(hltb_m), to_float_min(hltb_e), to_float_min(hltb_c),
          game_id))
    conn.commit()
    print()
    print(c(f"  ✓ Updated: {title}", "bgreen"))
    print()
    conn.close()

def cmd_help(args=None):
    print()
    box("GAMELOG — HELP", width=55)
    print()
    cmds = [
        ("add",    "Add a game to your library"),
        ("log",    "Log a play session"),
        ("done",   "Mark a game as completed + rate it"),
        ("list",   "List all games  [status filter]"),
        ("stats",  "Visualize your stats"),
        ("search", "Search by title"),
        ("edit",   "Edit a game entry"),
        ("delete", "Delete a game"),
        ("export", "Export library to JSON  [filename]"),
        ("help",   "Show this help"),
    ]
    for cmd, desc in cmds:
        print(f"  {c(cmd.ljust(10), 'bcyan', bold=True)}  {c(desc, 'bwhite')}")
    print()
    print(c("  Examples:", "bblack"))
    print(c("    python3 gamelog.py add", "bblack"))
    print(c("    python3 gamelog.py log elden", "bblack"))
    print(c("    python3 gamelog.py list playing", "bblack"))
    print(c("    python3 gamelog.py stats", "bblack"))
    print()

# ─── Entry point ──────────────────────────────────────────────────────────────
COMMANDS = {
    "add":    cmd_add,
    "log":    cmd_log,
    "done":   cmd_done,
    "list":   cmd_list,
    "ls":     cmd_list,
    "stats":  cmd_stats,
    "search": cmd_search,
    "edit":   cmd_edit,
    "delete": cmd_delete,
    "del":    cmd_delete,
    "export": cmd_export,
    "help":   cmd_help,
    "--help": cmd_help,
    "-h":     cmd_help,
}

def main():
    init_db()
    args = sys.argv[1:]
    if not args:
        cmd_help()
        return
    cmd = args[0].lower()
    fn = COMMANDS.get(cmd)
    if fn:
        fn(args[1:])
    else:
        print(c(f"\n  Unknown command: '{cmd}'. Run `help` for usage.\n", "bred"))

if __name__ == "__main__":
    main()
