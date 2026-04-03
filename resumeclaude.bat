@echo off
set /p minutes="Minutes to wait: "
set /p chat_id="Chat ID: "
set /p command="Command (enter for 'continue'): "
if "%command%"=="" set command=continue
set /a seconds=%minutes%*60
echo Waiting %minutes% minutes (%seconds% seconds)...
timeout /t %seconds% /nobreak
claude --resume "%chat_id%" "%command%"
