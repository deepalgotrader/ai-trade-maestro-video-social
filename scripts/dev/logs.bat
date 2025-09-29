@echo off
echo Showing AI TradeMaestro development logs...

rem Get the root directory (go up two levels from scripts\dev)
cd /d "%~dp0..\.."

docker-compose -f docker-compose.dev.yml logs -f