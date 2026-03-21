# ─────────────────────────────────────────
#  beepify - windows/watch_custom.ps1
#  Watches sounds\custom\ for new audio files
#  and auto-converts them to .aiff
#
#  Usage (from repo root):
#    . .\windows\watch_custom.ps1          # start watching
#    . .\windows\watch_custom.ps1 -Stop    # stop watching
# ─────────────────────────────────────────

param(
    [switch]$Stop
)

$BeepifyRoot = (Get-Location).Path
$CustomDir   = Join-Path $BeepifyRoot "sounds\custom"
$LogFile     = "$env:TEMP\beepify_watcher.log"
$JobName     = "BeepifyCustomWatcher"
$Supported   = @("mp3","wav","m4a","aac","ogg","flac","wma","mp4","mov","aif")

# ── Stop ──────────────────────────────────
if ($Stop) {
    $job = Get-Job -Name $JobName -ErrorAction SilentlyContinue
    if ($job) {
        Stop-Job  -Name $JobName
        Remove-Job -Name $JobName
        Write-Host "(beepify) custom watcher stopped" -ForegroundColor Red
    } else {
        Write-Host "(beepify) watcher is not running" -ForegroundColor Yellow
    }
    return
}

# ── Check existing job ────────────────────
$existing = Get-Job -Name $JobName -ErrorAction SilentlyContinue
if ($existing -and $existing.State -eq "Running") {
    Write-Host "(beepify) watcher is already running" -ForegroundColor Yellow
    return
}

# ── Check ffmpeg ──────────────────────────
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Host "❌ ffmpeg not found. Install it with:" -ForegroundColor Red
    Write-Host "     winget install ffmpeg" -ForegroundColor White
    Write-Host "   or: choco install ffmpeg" -ForegroundColor White
    return
}

# ── Ensure custom dir exists ──────────────
New-Item -ItemType Directory -Force -Path $CustomDir | Out-Null

# ── Background watcher job ────────────────
$watcherJob = Start-Job -Name $JobName -ScriptBlock {
    param($CustomDir, $LogFile, $Supported)

    function Get-NextIndex {
        $idx = 1
        Get-ChildItem "$CustomDir\*.aiff" -ErrorAction SilentlyContinue | ForEach-Object {
            if ($_.BaseName -match '^(\d+)_') {
                $n = [int]$Matches[1]
                if ($n -ge $idx) { $idx = $n + 1 }
            }
        }
        return $idx
    }

    function Convert-AudioFile {
        param($FilePath)

        $fname = Split-Path $FilePath -Leaf
        $ext   = [System.IO.Path]::GetExtension($FilePath).TrimStart('.').ToLower()
        $base  = [System.IO.Path]::GetFileNameWithoutExtension($FilePath)

        if ($ext -eq "aiff") { return }
        if ($fname.StartsWith('.')) { return }
        if ($Supported -notcontains $ext) {
            Add-Content $LogFile "[$([datetime]::Now)] Skipped (unsupported): $fname"
            return
        }

        Start-Sleep -Milliseconds 800

        $name   = $base -replace '\s+', '_'
        $idx    = Get-NextIndex
        $output = Join-Path $CustomDir "${idx}_${name}.aiff"

        Add-Content $LogFile "[$([datetime]::Now)] Converting: $fname → ${idx}_${name}.aiff"

        $proc = Start-Process ffmpeg `
            -ArgumentList "-y -i `"$FilePath`" -c:a pcm_s16be -ar 44100 `"$output`"" `
            -Wait -PassThru -WindowStyle Hidden `
            -RedirectStandardError "$env:TEMP\beepify_ffmpeg_err.txt"

        if ($proc.ExitCode -eq 0) {
            Remove-Item $FilePath -Force
            Add-Content $LogFile "[$([datetime]::Now)] Done: ${idx}_${name}.aiff"
        } else {
            $err = Get-Content "$env:TEMP\beepify_ffmpeg_err.txt" -Raw
            Add-Content $LogFile "[$([datetime]::Now)] Failed: $fname`n$err"
        }
    }

    $watcher = New-Object System.IO.FileSystemWatcher
    $watcher.Path   = $CustomDir
    $watcher.Filter = "*.*"
    $watcher.EnableRaisingEvents = $true

    Add-Content $LogFile "[$([datetime]::Now)] Watcher started on $CustomDir"

    while ($true) {
        $result = $watcher.WaitForChanged(
            [System.IO.WatcherChangeTypes]::Created -bor
            [System.IO.WatcherChangeTypes]::Renamed,
            1000
        )
        if (-not $result.TimedOut) {
            $full = Join-Path $CustomDir $result.Name
            if (Test-Path $full) {
                Convert-AudioFile $full
            }
        }
    }

} -ArgumentList $CustomDir, $LogFile, $Supported

Write-Host ""
Write-Host "(beepify)  custom watcher active" -ForegroundColor Red
Write-Host "  Drop any audio file into sounds\custom\"
Write-Host "  It will auto-convert to .aiff — no command needed."
Write-Host ""
Write-Host "  Supported: mp3  wav  m4a  aac  ogg  flac  wma  mp4  mov  aif"
Write-Host ""
Write-Host "  To stop:  . .\windows\watch_custom.ps1 -Stop"
Write-Host "  Log:      Get-Content $LogFile -Wait"
Write-Host ""
