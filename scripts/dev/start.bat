@echo off
echo Starting AI TradeMaestro development environment...

rem Get the root directory (go up two levels from scripts\dev)
cd /d "%~dp0..\.."

echo Checking Docker Desktop...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Desktop is not installed or not running.
    echo Please install Docker Desktop and ensure it's running.
    pause
    exit /b 1
)

echo Starting services...
docker-compose -f docker-compose.dev.yml up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start services.
    pause
    exit /b 1
)

echo Services started successfully!
echo Frontend: http://localhost:3000
echo Backend API: http://localhost:8000
echo Backend Docs: http://localhost:8000/docs
echo.
echo To stop services, run 'stop.bat'
echo To view logs, run 'logs.bat'
pause