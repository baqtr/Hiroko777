#!/usr/bin/env bash
set -euo pipefail
source ./config.env
: "${HEROKU_APP_NAME:?ضع HEROKU_APP_NAME داخل config.env}"
heroku ps:scale worker=0 web=0 -a "$HEROKU_APP_NAME"
heroku ps -a "$HEROKU_APP_NAME"
