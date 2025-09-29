@echo off
echo Setting up AI TradeMaestro production environment...

rem Get the root directory (go up two levels from scripts\production)
cd /d "%~dp0..\.."

echo Checking Docker Desktop...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Docker Desktop is not installed or not running.
    echo Please install Docker Desktop and ensure it's running.
    pause
    exit /b 1
)

echo Building production Docker images...
docker-compose build --no-cache
if %errorlevel% neq 0 (
    echo ERROR: Failed to build production Docker images.
    pause
    exit /b 1
)

echo Production setup completed successfully!
echo Run 'deploy.bat' to deploy the production environment.
pause