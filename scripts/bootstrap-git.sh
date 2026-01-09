#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔧 Configuring git sops filter in:"
echo "   $REPO_ROOT"

git -C "$REPO_ROOT" config --local filter.sops.clean  "$REPO_ROOT/scripts/encrypt.sh"
git -C "$REPO_ROOT" config --local filter.sops.smudge "$REPO_ROOT/scripts/decrypt.sh"
git -C "$REPO_ROOT" config --local filter.sops.required true

echo "✅ Git sops filter configured successfully"
echo
echo "ℹ️  Make sure you have:"
echo "   - sops installed"
echo "   - age / gpg / kms credentials available"
