#!/usr/bin/env bash
set -euo pipefail
source ./config.env
: "${HEROKU_APP_NAME:?ضع HEROKU_APP_NAME داخل config.env}"
COUNT="${1:-1}"
SIZE="${2:-${DYNO_SIZE:-standard-2x}}"
heroku ps:scale worker="$COUNT" web=0 -a "$HEROKU_APP_NAME"
heroku ps:resize worker="$SIZE" -a "$HEROKU_APP_NAME" || true
heroku ps -a "$HEROKU_APP_NAME"
