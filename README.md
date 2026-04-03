# autoresume-claude-code

Auto-resume your Claude Code CLI session after a rate limit refill window. Simple, terminal-blocking, no daemons, no background processes.

---

## The Problem

Claude Code CLI displays this when you hit a rate limit:

```
Rate limit reached, will refill at <time>. What do you want to do?
  1: Stop and wait
  ...
```

You know when the limit refills. You want to walk away and have Claude automatically pick up where it left off — without leaving a half-finished task or losing your conversation context.

## How It Works

1. You Ctrl+C out of the rate-limited Claude session
2. You type `resumeclaude` in your terminal
3. It asks three questions:
   - **Minutes to wait** — how long until refill (check the time Claude displayed)
   - **Chat ID** — the conversation ID from your Claude session (Claude shows this)
   - **Command** — what to say when it resumes (defaults to `continue`)
4. The script sleeps for that many minutes, then calls `claude --resume <chat_id> <command>`
5. Claude picks up the conversation exactly where it left off

The terminal is tied up while waiting. On a GUI OS (Mac, Windows, most Linux desktops) this is fine — open a new terminal for other work.

## Finding Your Chat ID

When Claude Code hits a rate limit or when you're in a session, the chat/conversation ID is shown in the CLI output. It looks like a UUID:

```
Session: abc123de-f456-7890-abcd-ef1234567890
```

Copy that ID when prompted by resumeclaude.

---

## Linux

### Script: `resumeclaude`

```bash
#!/bin/bash

read -p "Minutes to wait: " minutes
read -p "Chat ID: " chat_id
read -p "Command (enter for 'continue'): " command
command=${command:-continue}

sleep $((minutes * 60)) && claude --resume "$chat_id" "$command"
```

### Installation

```bash
sudo cp resumeclaude /usr/local/bin/resumeclaude
sudo chmod +x /usr/local/bin/resumeclaude
```

### Usage

```
$ resumeclaude
Minutes to wait: 45
Chat ID: abc123de-f456-7890-abcd-ef1234567890
Command (enter for 'continue'): 
```

Press Enter with no command to default to `continue`.

---

## macOS

### Script: `resumeclaude-mac`

Nearly identical to Linux. macOS ships with bash (older versions) or zsh as default, but the script runs as bash explicitly via the shebang. The mac version adds a status echo before sleeping.

```bash
#!/bin/bash

read -p "Minutes to wait: " minutes
read -p "Chat ID: " chat_id
read -p "Command (enter for 'continue'): " command
command=${command:-continue}

echo "Waiting $minutes minutes..."
sleep $((minutes * 60))
claude --resume "$chat_id" "$command"
```

### Installation

```bash
sudo cp resumeclaude-mac /usr/local/bin/resumeclaude
sudo chmod +x /usr/local/bin/resumeclaude
```

`/usr/local/bin` is on the default PATH for macOS and is writable without disabling SIP.

Verify it's in your PATH:

```bash
which resumeclaude
```

### Usage

```
$ resumeclaude
Minutes to wait: 30
Chat ID: abc123de-f456-7890-abcd-ef1234567890
Command (enter for 'continue'): 
Waiting 30 minutes...
```

---

## Windows

Two options depending on your shell preference.

---

### Option A: Command Prompt (.bat)

**Script: `resumeclaude.bat`**

```bat
@echo off
set /p minutes="Minutes to wait: "
set /p chat_id="Chat ID: "
set /p command="Command (enter for 'continue'): "
if "%command%"=="" set command=continue
set /a seconds=%minutes%*60
echo Waiting %minutes% minutes (%seconds% seconds)...
timeout /t %seconds% /nobreak
claude --resume "%chat_id%" "%command%"
```

#### Installation

Copy `resumeclaude.bat` to any folder on your PATH. The easiest location is:

```
C:\Windows\System32\resumeclaude.bat
```

Or add a folder to your PATH and place it there:

1. Create `C:\Users\<YourName>\bin\` if it doesn't exist
2. Copy `resumeclaude.bat` into it
3. Add that folder to PATH:
   - Search "Environment Variables" in Start
   - Edit `Path` under User variables
   - Add `C:\Users\<YourName>\bin`

#### Usage

Open Command Prompt:

```
C:\> resumeclaude
Minutes to wait: 45
Chat ID: abc123de-f456-7890-abcd-ef1234567890
Command (enter for 'continue'): 
Waiting 45 minutes (2700 seconds)...
```

The `timeout` command shows a live countdown and accepts Ctrl+C to cancel.

---

### Option B: PowerShell (.ps1)

**Script: `resumeclaude.ps1`**

```powershell
$minutes = Read-Host "Minutes to wait"
$chat_id = Read-Host "Chat ID"
$command = Read-Host "Command (enter for 'continue')"
if (-not $command) { $command = "continue" }

$seconds = [int]$minutes * 60
Write-Host "Waiting $minutes minutes ($seconds seconds)..."

$end = (Get-Date).AddSeconds($seconds)
while ((Get-Date) -lt $end) {
    $remaining = [math]::Round(($end - (Get-Date)).TotalMinutes, 1)
    Write-Host -NoNewline "`rResume in: $remaining minutes   "
    Start-Sleep -Seconds 10
}

Write-Host ""
claude --resume $chat_id $command
```

The PowerShell version shows a live countdown updating every 10 seconds.

#### Installation

1. Copy `resumeclaude.ps1` to `C:\Users\<YourName>\bin\` (or any PATH folder)
2. Create a wrapper `.bat` so you can call it by name from any shell:

**`resumeclaude.bat`** (wrapper, place in same folder):
```bat
@echo off
powershell -ExecutionPolicy Bypass -File "%~dp0resumeclaude.ps1"
```

Or run it directly from PowerShell:

```powershell
# Allow script execution (run once as admin if needed)
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned

# Then run
resumeclaude.ps1
```

#### Usage (PowerShell)

```
PS C:\> resumeclaude
Minutes to wait: 30
Chat ID: abc123de-f456-7890-abcd-ef1234567890
Command (enter for 'continue'): 
Waiting 30 minutes (1800 seconds)...
Resume in: 29.8 minutes
```

---

## Tips

- **Custom resume command**: Instead of `continue`, you can pass a specific instruction like `"finish the refactor you were doing"` — Claude will pick up the conversation and act on that message.
- **Multiple terminals**: While resumeclaude is waiting in one terminal, open another for other work. The wait is blocking by design — no background daemons means no cleanup needed.
- **Cancel the wait**: Press Ctrl+C at any time to abort. The Claude session won't be touched.
- **Missed the refill time?**: Just enter `0` for minutes — it will resume immediately.

---

## Files

| File | Platform |
|------|----------|
| `resumeclaude` | Linux |
| `resumeclaude-mac` | macOS |
| `resumeclaude.bat` | Windows (cmd) |
| `resumeclaude.ps1` | Windows (PowerShell) |
