@echo off
echo Setting up AI TradeMaestro development environment...

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

echo Installing frontend dependencies...
cd frontend
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install frontend dependencies.
    pause
    exit /b 1
)

cd ..

echo Building Docker images...
docker-compose -f docker-compose.dev.yml build
if %errorlevel% neq 0 (
    echo ERROR: Failed to build Docker images.
    pause
    exit /b 1
)

echo Setup completed successfully!
echo Run 'start.bat' to start the development environment.
pause