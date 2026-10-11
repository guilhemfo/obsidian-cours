#!/bin/bash
# push.sh — Commit et push automatique vers GitHub
# Usage: ./push.sh "message de commit optionnel"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_DIR"

MSG="${1:-📚 Mise à jour des fiches - $(date '+%Y-%m-%d %H:%M')}"

git add -A
git commit -m "$MSG" && git push origin main

echo "✅ Fiches synchronisées sur GitHub !"
