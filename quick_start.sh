#!/usr/bin/env bash
set -euo pipefail

if [ -f config.env ]; then
  # shellcheck disable=SC1091
  source config.env
fi

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ الأمر '$1' غير موجود. ثبّته أولاً ثم أعد المحاولة."
    exit 1
  fi
}

need_cmd heroku
need_cmd git

if [ -z "${HEROKU_APP_NAME:-}" ]; then
  read -r -p "اكتب اسم تطبيق Heroku: " HEROKU_APP_NAME
fi

if [ -z "${HEROKU_APP_NAME:-}" ]; then
  echo "❌ لم تكتب اسم التطبيق."
  exit 1
fi

if [ -z "${XMR_WALLET:-}" ] || [ "$XMR_WALLET" = "PUT_YOUR_XMR_RECEIVE_ADDRESS_HERE" ]; then
  echo "❌ ضع عنوان XMR داخل config.env في السطر XMR_WALLET قبل التشغيل."
  exit 1
fi

XMR_POOL="${XMR_POOL:-pool.supportxmr.com:3333}"
WORKER_NAME="${WORKER_NAME:-heroku-worker-1}"
XMR_THREADS="${XMR_THREADS:-auto}"
XMR_DONATE_LEVEL="${XMR_DONATE_LEVEL:-1}"
DYNO_SIZE="${DYNO_SIZE:-standard-2x}"

echo "🔐 التحقق من تسجيل الدخول في Heroku..."
if ! heroku auth:whoami >/dev/null 2>&1; then
  echo "سيفتح Heroku تسجيل الدخول. أكمل تسجيل الدخول ثم أعد تشغيل السكربت إذا توقف."
  heroku login
fi

echo "📦 التأكد من وجود التطبيق: $HEROKU_APP_NAME"
if ! heroku apps:info -a "$HEROKU_APP_NAME" >/dev/null 2>&1; then
  heroku create "$HEROKU_APP_NAME" --stack container
else
  heroku stack:set container -a "$HEROKU_APP_NAME"
fi

echo "⚙️ ضبط Config Vars..."
heroku config:set \
  XMR_WALLET="$XMR_WALLET" \
  XMR_POOL="$XMR_POOL" \
  WORKER_NAME="$WORKER_NAME" \
  XMR_THREADS="$XMR_THREADS" \
  XMR_DONATE_LEVEL="$XMR_DONATE_LEVEL" \
  -a "$HEROKU_APP_NAME"

echo "🧩 تجهيز Git..."
if [ ! -d .git ]; then
  git init
fi

git checkout -B main >/dev/null 2>&1 || git branch -M main

git add Dockerfile heroku.yml Procfile start.sh start_web.sh health_server.py config.env README_AR.md deploy.sh logs.sh scale_worker.sh stop.sh 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "Add authorized Heroku XMR worker" || true
else
  echo "لا توجد تغييرات جديدة للـ commit."
fi

heroku git:remote -a "$HEROKU_APP_NAME" >/dev/null 2>&1 || true

echo "🚀 رفع الملفات إلى Heroku..."
git push heroku main --force

echo "📏 تشغيل worker وإيقاف web..."
heroku ps:scale web=0 worker=1 -a "$HEROKU_APP_NAME"
heroku ps:resize worker="$DYNO_SIZE" -a "$HEROKU_APP_NAME" || true

echo "✅ تم النشر. راقب السجل، إذا ظهرت accepted فالتعدين يعمل."
echo "أمر السجل: heroku logs --tail --ps worker -a $HEROKU_APP_NAME"
heroku logs --tail --ps worker -a "$HEROKU_APP_NAME"
