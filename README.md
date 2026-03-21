# beepify
🔔 Play a sound when your terminal throws an error — activate it like a venv

---

## Installation

Clone the repo and run the installer from the repo root:

```bash
git clone https://github.com/jyotisubham1/beepify.git
cd beepify
bash mac/install.sh
```

The installer walks you through two steps:

### Step 1 — Choose a category

```
  [1] error      🔴  classic error beeps and buzzes
  [2] warning    🟡  soft alerts and chimes
  [3] funny      😄  quirky and fun sounds
  [4] memes      😂  internet meme sounds
  [5] custom     📁  your own sounds
```

Type the number and press Enter.

### Step 2 — Choose a sound

Each category has sounds to pick from:

| Category | # | Sound     |
|----------|---|-----------|
| error    | 1 | basso     |
| error    | 2 | sosumi    |
| warning  | 1 | glass     |
| warning  | 2 | ping      |
| funny    | 1 | funk      |
| funny    | 2 | frog      |
| memes    | 1 | hero      |
| memes    | 2 | bottle    |

> **Tip:** Type `p` to preview all sounds in the category before choosing.

---

## Activating in your terminal

After installation, activate beepify in your current terminal session:

```bash
source mac/activate.sh
```

You must use `source` (not `bash`) — this hooks into your current shell session.

When active, you'll see:

```
(beepify) 🔔 error sounds ON [error/1_basso.aiff]
```

From now on, any command that exits with an error will play your chosen sound.

---

## Deactivating

To turn off sounds in the current session:

```bash
beepify_deactivate
```

You'll see:

```
(beepify) 🔕 error sounds OFF
```

---

## Changing your sound

Run the installer again to pick a different category or sound:

```bash
bash mac/install.sh
```

Then re-activate:

```bash
source mac/activate.sh
```

---

## Adding custom sounds

Start the folder watcher once — then just drop any audio file into `sounds/custom/` and it converts automatically.

**One-time setup** (only ffmpeg needed — no extra tools):
```bash
brew install ffmpeg
```

**Start the watcher** (registers a background macOS launchd agent):
```bash
source mac/watch_custom.sh
```

You'll see:
```
(beepify) 👁  custom watcher active
  Drop any audio file into sounds/custom/
  It will auto-convert to .aiff — no command needed.
```

Now drag and drop (or copy) any audio file into `sounds/custom/` — it converts automatically in the background. The original file is removed after conversion.

Supported formats: `.mp3` `.wav` `.m4a` `.aac` `.ogg` `.flac` `.wma` `.mp4` `.mov` `.aif`

To see conversion activity:
```bash
tail -f /tmp/beepify_watcher.log
```

**Stop the watcher:**
```bash
source mac/watch_custom.sh stop
```

Then pick your sound in the installer:
```bash
bash mac/install.sh   # choose category: custom
```

---

## Requirements

- macOS (uses `afplay`)
- zsh
