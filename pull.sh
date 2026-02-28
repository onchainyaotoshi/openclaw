#!/usr/bin/env bash
set -euo pipefail

DEV_REPO="/root/workspace/openclaw-dev"
PROD_REPO="/root/workspace/openclaw"
DEV_BRANCH="dev/local"
PROD_BRANCH="main"

echo "========================================"
echo " Deploy dev -> prod OpenClaw"
echo " DEV : $DEV_REPO ($DEV_BRANCH)"
echo " PROD: $PROD_REPO ($PROD_BRANCH)"
echo "========================================"

cd "$PROD_REPO"
git fetch origin

echo
echo "Commit log yang akan masuk ke prod:"
git log --oneline --decorate "${PROD_BRANCH}..origin/${DEV_BRANCH}" || true
echo

read -r -p "Yakin lanjut deploy? (y/N): " CONFIRM
case "${CONFIRM:-N}" in
  y|Y|yes|YES) ;;
  *) echo "Dibatalkan user."; exit 0 ;;
esac

echo "==> [1/7] Push perubahan dari dev branch"
cd "$DEV_REPO"
git add -A
if ! git diff --cached --quiet; then
  git commit -m "chore: sync dev to prod $(date '+%Y-%m-%d %H:%M:%S')"
else
  echo "Tidak ada perubahan staged, skip commit."
fi
git push origin "$DEV_BRANCH"

echo "==> [2/7] Fetch terbaru di prod"
cd "$PROD_REPO"
git checkout "$PROD_BRANCH"
git fetch origin

echo "==> [3/7] Merge dev -> prod"
git merge --no-ff "origin/$DEV_BRANCH" -m "merge: $DEV_BRANCH -> $PROD_BRANCH"

echo "==> [4/7] Install deps"
pnpm install

echo "==> [5/7] Build"
pnpm build

echo "==> [6/7] Restart gateway prod"
openclaw gateway restart

echo "==> [7/7] Status check"
openclaw gateway status
openclaw status

echo "✅ Deploy selesai"
