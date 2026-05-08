#!/usr/bin/env bash
set -euo pipefail
source ./config.env
: "${HEROKU_APP_NAME:?ضع HEROKU_APP_NAME داخل config.env}"
heroku logs --tail --ps worker -a "$HEROKU_APP_NAME"
