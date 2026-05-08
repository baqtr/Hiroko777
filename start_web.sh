#!/usr/bin/env sh
set -eu

# Web mode exists only so the app can bind to Heroku's $PORT when you intentionally scale web=1.
# Recommended mode for mining is worker=1 web=0.
/app/start.sh &
MINER_PID=$!
python3 /app/health_server.py &
WEB_PID=$!

trap 'kill $MINER_PID $WEB_PID 2>/dev/null || true; wait' INT TERM
wait $MINER_PID
