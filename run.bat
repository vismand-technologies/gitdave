@echo off
setlocal enabledelayedexpansion
rem Cross-platform Windows launcher for the Electron app in app\
rem - Use in Windows PowerShell/CMD (not WSL)

set SCRIPT_DIR=%~dp0
set APP_DIR=%SCRIPT_DIR%app

if not exist "%APP_DIR%\package.json" (
  echo [err] Could not find app\package.json. Ensure you run this script from the repo root.
  exit /b 1
)

pushd "%APP_DIR%" >nul

rem Prefer Node installed on Windows (Node.js LTS)
where npm >nul 2>&1
if errorlevel 1 (
  echo [err] npm not found. Please install Node.js LTS for Windows from https://nodejs.org/
  popd >nul
  exit /b 1
)

if not exist node_modules (
  echo [run] Installing dependencies (npm install)
  call npm install || goto :error
)

echo [run] Building (npm run build:dev)
call npm run build:dev || goto :error

echo [run] Starting app (npm start)
call npm start || goto :error

popd >nul
exit /b 0

:error
set EC=%errorlevel%
popd >nul
exit /b %EC%
