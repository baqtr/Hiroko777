#!/usr/bin/env bash
set -euo pipefail
source ./config.env
: "${HEROKU_APP_NAME:?ضع HEROKU_APP_NAME داخل config.env}"
heroku stack:set container -a "$HEROKU_APP_NAME"
heroku config:set XMR_WALLET="$XMR_WALLET" XMR_POOL="$XMR_POOL" WORKER_NAME="$WORKER_NAME" XMR_THREADS="$XMR_THREADS" XMR_DONATE_LEVEL="$XMR_DONATE_LEVEL" -a "$HEROKU_APP_NAME"
git init >/dev/null 2>&1 || true
git checkout -B main >/dev/null 2>&1 || git branch -M main
git add .
git commit -m "Deploy authorized miner" || true
heroku git:remote -a "$HEROKU_APP_NAME" >/dev/null 2>&1 || true
git push heroku main --force
heroku ps:scale web=0 worker=1 -a "$HEROKU_APP_NAME"
