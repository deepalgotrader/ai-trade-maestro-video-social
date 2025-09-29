@echo off
echo Deploying AI TradeMaestro to production...

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

echo Starting production services...
docker-compose up -d
if %errorlevel% neq 0 (
    echo ERROR: Failed to start production services.
    pause
    exit /b 1
)

echo Production deployment completed successfully!
echo Application is running at: http://aitrademaestro.com
echo API is running at: http://api.aitrademaestro.com
echo.
echo To stop services, run 'stop.bat'
echo To view logs, run 'logs.bat'
pause