# beepify
🔔 Play a sound when your terminal throws an error — activate it like a venv

---

## Installation

### Homebrew (macOS — recommended)

```bash
brew tap jyotisubham1/beepify https://github.com/jyotisubham1/beepify
brew install beepify
```

Then add shell integration to your `~/.zshrc` **(one-time)**:
```bash
echo 'source $(brew --prefix)/opt/beepify/libexec/shell/beepify.zsh' >> ~/.zshrc
source ~/.zshrc
```

That's it. Now use:
```bash
beepify select      # pick a sound
beepify activate    # turn on error sounds
beepify deactivate  # turn off
```

---

### Manual install (Linux / Windows / dev)

Clone the repo and run the installer from the repo root:

**macOS / Linux**
```bash
git clone https://github.com/jyotisubham1/beepify.git
cd beepify
bash mac/install.sh      # macOS
bash linux/install.sh    # Linux
```

**Windows** (PowerShell)
```powershell
git clone https://github.com/jyotisubham1/beepify.git
cd beepify
. .\windows\install.ps1
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

| Category | # | Sound  |
|----------|---|--------|
| error    | 1 | basso  |
| error    | 2 | sosumi |
| warning  | 1 | glass  |
| warning  | 2 | ping   |
| funny    | 1 | funk   |
| funny    | 2 | frog   |
| memes    | 1 | hero   |
| memes    | 2 | bottle |

> **Tip:** Type `p` to preview all sounds in the category before choosing.

---

## Activating in your terminal

**macOS**
```bash
source mac/activate.sh
```

**Linux**
```bash
source linux/activate.sh
```

**Windows** (PowerShell)
```powershell
. .\windows\activate.ps1
```

You must use `source` / `. .\` — this hooks into your current shell session.

When active, you'll see:
```
(beepify) 🔔 error sounds ON [error/1_basso.aiff]
```

From now on, any command that exits with an error will play your chosen sound.

---

## Deactivating

```bash
beepify_deactivate         # macOS / Linux
```
```powershell
beepify_deactivate         # Windows
```

---

## Changing your sound

Re-run the installer, then re-activate:

```bash
bash mac/install.sh && source mac/activate.sh       # macOS
bash linux/install.sh && source linux/activate.sh   # Linux
```
```powershell
. .\windows\install.ps1; . .\windows\activate.ps1   # Windows
```

---

## Adding custom sounds

Start the folder watcher once — then drop any audio file into `sounds/custom/` and it converts automatically to `.aiff`.

### macOS

**One-time dependency:**
```bash
brew install ffmpeg
```

**Start watcher:**
```bash
source mac/watch_custom.sh
```

**Stop watcher:**
```bash
source mac/watch_custom.sh stop
```

**Monitor activity:**
```bash
tail -f /tmp/beepify_watcher.log
```

---

### Linux

**One-time dependencies:**
```bash
# Ubuntu/Debian
sudo apt install ffmpeg inotify-tools

# Fedora/RHEL
sudo dnf install ffmpeg inotify-tools

# Arch
sudo pacman -S ffmpeg inotify-tools
```

**Start watcher:**
```bash
source linux/watch_custom.sh
```

**Stop watcher:**
```bash
source linux/watch_custom.sh stop
```

**Monitor activity:**
```bash
tail -f /tmp/beepify_watcher.log
```

---

### Windows (PowerShell)

**One-time dependency:**
```powershell
winget install ffmpeg
# or: choco install ffmpeg
```

**Start watcher:**
```powershell
. .\windows\watch_custom.ps1
```

**Stop watcher:**
```powershell
. .\windows\watch_custom.ps1 -Stop
```

**Monitor activity:**
```powershell
Get-Content $env:TEMP\beepify_watcher.log -Wait
```

---

### How it works

Drop any audio file into `sounds/custom/` — it auto-converts and the original is removed:

```
📥 Detected: mysound.mp3
✅ Done → sounds/custom/1_mysound.aiff
```

Supported formats: `.mp3` `.wav` `.m4a` `.aac` `.ogg` `.flac` `.wma` `.mp4` `.mov` `.aif`

Then pick it in the installer:
```bash
bash mac/install.sh    # choose category: custom
```

---

## Requirements

| Platform | Shell      | Audio player | Watcher tool         |
|----------|------------|--------------|----------------------|
| macOS    | zsh        | afplay       | launchd (built-in)   |
| Linux    | bash       | aplay/ffplay | inotify-tools        |
| Windows  | PowerShell | —            | FileSystemWatcher (built-in) |

All platforms require `ffmpeg` for custom sound conversion.
