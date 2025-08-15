#!/usr/bin/env bash
set -euo pipefail

# Cross-platform runner for the Electron app under app/
# - Linux/macOS/WSL: loads nvm if available
# - WSL: uses headless mode if DISPLAY is not set
# - Falls back to normal start otherwise

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_DIR="$ROOT_DIR/app"
START_SCRIPT="start"
HEADLESS=${HEADLESS:-}

log() { echo -e "\033[1;34m[run]\033[0m $*"; }
warn() { echo -e "\033[1;33m[warn]\033[0m $*"; }
err() { echo -e "\033[1;31m[err]\033[0m  $*"; }

# Load nvm if present
enable_nvm() {
  if [ -n "${NVM_DIR:-}" ] && [ -s "$NVM_DIR/nvm.sh" ]; then
    # shellcheck disable=SC1090
    . "$NVM_DIR/nvm.sh"
    return
  fi
  if [ -s "$HOME/.nvm/nvm.sh" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.nvm/nvm.sh"
    return
  fi
  # Common global path (brew, etc.)
  if [ -s "/usr/local/opt/nvm/nvm.sh" ]; then
    # shellcheck disable=SC1091
    . "/usr/local/opt/nvm/nvm.sh"
    return
  fi
}

detect_env() {
  OS="$(uname -s || echo unknown)"
  case "$OS" in
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        ENV_KIND="WSL"
      else
        ENV_KIND="Linux"
      fi
      ;;
    Darwin)
      ENV_KIND="macOS"
      ;;
    *)
      ENV_KIND="$OS"
      ;;
  esac
  echo "$ENV_KIND"
}

main() {
  cd "$APP_DIR"

  ENV_KIND=$(detect_env)
  log "Environment detected: $ENV_KIND"

  # Prefer nvm if available
  enable_nvm || true

  if command -v nvm >/dev/null 2>&1; then
    # Use LTS if available; otherwise ignore
    nvm use --lts >/dev/null 2>&1 || true
  fi

  # Decide start mode
  if [ -n "${HEADLESS}" ]; then
    START_SCRIPT="start:headless"
  else
    if [ "${ENV_KIND}" = "WSL" ]; then
      if [ -z "${DISPLAY:-}" ]; then
        warn "DISPLAY is not set in WSL; falling back to headless." \
             "(Install WSLg or run a Windows X server for GUI)"
        START_SCRIPT="start:headless"
      fi
      export LIBGL_ALWAYS_SOFTWARE=1
    fi
  fi

  # Install deps if needed
  if [ ! -d node_modules ]; then
    log "Installing dependencies (npm install)"
    npm install
  fi

  # Build dev bundles (fast)
  log "Building (npm run build:dev)"
  npm run build:dev

  # Start
  log "Starting app (npm run ${START_SCRIPT})"
  npm run "${START_SCRIPT}"
}

main "$@"
