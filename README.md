# JSON Scratch Pad

A lightweight tool for capturing and archiving JSON snippets on the fly — built around Stream Deck buttons and a simple folder structure.

---

## How It Works

Copy some JSON to your clipboard, hit a button, and a new dated file lands in this folder, ready to edit in VS Code. When you're done, a second button sweeps all the loose files into the archive. That's it.

---

## Commands

All scripts live in the `app/` folder. Use the `.bat` files for Stream Deck or double-click; use the `.ps1` files directly from a terminal for extra options.

### New JSON — `app/new-json.bat`

Creates a new dated JSON file in the `scratchpad/` folder and opens it in VS Code.

- File names follow the pattern `MMddyy-##.json` (e.g. `052726-01.json` for May 27, 2026)
- The increment (`-01`, `-02`, ...) auto-advances based on what already exists — both in `scratchpad/` and in the archive — so numbers never repeat on the same day
- If the clipboard contains text, it's written to the file as-is
- If the clipboard is empty, the file starts blank

**Terminal:**
```
.\app\new-json.ps1
```

---

### Clean JSON — `app/clean-json.bat`

Parses and pretty-prints the most recently modified dated JSON file in `scratchpad/`.

Useful when the JSON was pasted in escaped form (e.g. a quoted string with `\"` instead of raw `"`). The script detects that case and unwraps it automatically.

**Terminal (most recent file):**
```
.\app\clean-json.ps1
```

**Terminal (specific file):**
```
.\app\clean-json.ps1 -Path "scratchpad\052726-01.json"
```

---

### Collect — `app/collect.bat`

Moves all dated JSON files from `scratchpad/` into `filing-cabinet/_dated/`, organized by date:

```
filing-cabinet/
  _dated/
    2026/
      05/
        27/
          052726-01.json
          052726-02.json
```

Skips any file that already exists at the destination and reports what was skipped.

**Terminal (scratchpad):**
```
.\app\collect.ps1
```

**Terminal (custom source folder):**
```
.\app\collect.ps1 -SourceDir "C:\some\other\folder"
```

---

## Stream Deck Setup

| Button | Action | Target |
|--------|--------|--------|
| New JSON | System > Open | `app\new-json.bat` |
| Clean JSON | System > Open | `app\clean-json.bat` |
| Collect | System > Open | `app\collect.bat` |

If you move this folder to a new machine, just re-point these three paths. Nothing inside the scripts needs to change.

---

## Folder Structure

```
json-scratch/
  app/                   scripts (don't edit unless customizing)
  scratchpad/            active scratch files land here, get collected
    MMddyy-##.json
  filing-cabinet/
    _dated/              archive, organized by year/month/day
  README.md              this file
  .gitignore             ignores dated JSON files in scratchpad/
```
