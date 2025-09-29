@echo off
echo Stopping AI TradeMaestro development environment...

rem Get the root directory (go up two levels from scripts\dev)
cd /d "%~dp0..\.."

docker-compose -f docker-compose.dev.yml down
if %errorlevel% neq 0 (
    echo ERROR: Failed to stop services.
    pause
    exit /b 1
)

echo Services stopped successfully!
pause