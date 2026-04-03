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
