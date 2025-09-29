@echo off
echo Stopping AI TradeMaestro production environment...

rem Get the root directory (go up two levels from scripts\production)
cd /d "%~dp0..\.."


docker-compose down
if %errorlevel% neq 0 (
    echo ERROR: Failed to stop production services.
    pause
    exit /b 1
)

echo Production services stopped successfully!
pause