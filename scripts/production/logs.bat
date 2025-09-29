@echo off
echo Showing AI TradeMaestro production logs...

rem Get the root directory (go up two levels from scripts\production)
cd /d "%~dp0..\.."


docker-compose logs -f