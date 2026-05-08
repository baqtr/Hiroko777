#!/usr/bin/env sh
set -eu

if [ -z "${XMR_WALLET:-}" ] || [ "${XMR_WALLET:-}" = "PUT_YOUR_XMR_RECEIVE_ADDRESS_HERE" ]; then
  echo "❌ XMR_WALLET is missing. Set it in Heroku config vars or config.env before deploy."
  echo "Example: heroku config:set XMR_WALLET='YOUR_XMR_RECEIVE_ADDRESS' -a YOUR_APP_NAME"
  exit 1
fi

POOL="${XMR_POOL:-pool.supportxmr.com:3333}"
WORKER="${WORKER_NAME:-heroku-worker}"
DONATE="${XMR_DONATE_LEVEL:-1}"
THREADS="${XMR_THREADS:-auto}"

THREAD_ARGS=""
if [ "$THREADS" != "auto" ] && [ -n "$THREADS" ]; then
  THREAD_ARGS="--threads=$THREADS"
fi

echo "🚀 Starting authorized XMR miner on Heroku"
echo "Pool   : $POOL"
echo "Worker : $WORKER"
echo "Threads: $THREADS"
echo "Donate : $DONATE%"
echo "Wallet : ${XMR_WALLET%%??????????}**********"

exec /opt/xmrig/xmrig \
  -o "$POOL" \
  -u "$XMR_WALLET" \
  -p "$WORKER" \
  --coin monero \
  --donate-level "$DONATE" \
  $THREAD_ARGS
