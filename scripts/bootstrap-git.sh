#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "🔧 Configuring git sops filter in:"
echo "   $REPO_ROOT"

# ————————————————
# 1) 配置 Git filter
# ————————————————
git -C "$REPO_ROOT" config --local filter.sops.clean  "$REPO_ROOT/scripts/encrypt.sh"
git -C "$REPO_ROOT" config --local filter.sops.smudge "$REPO_ROOT/scripts/decrypt.sh"
git -C "$REPO_ROOT" config --local filter.sops.required true

echo "✅ Git filter.sops configured"

# ————————————————
# 2) 写 .gitattributes
# ————————————————
GITATTR="$REPO_ROOT/.gitattributes"

cat > "$GITATTR" <<EOF
# 自动 SOPS 过滤 JSON/YAML

# environment 目录及其子目录
environment/**/*.json   filter=sops
environment/**/*.yaml   filter=sops
environment/**/*.yml    filter=sops

# modules/secrets_manager/apply_diff 目录及其子目录
modules/secrets_manager/apply_diff/**/*.json   filter=sops
modules/secrets_manager/apply_diff/**/*.yaml   filter=sops
modules/secrets_manager/apply_diff/**/*.yml    filter=sops
EOF

echo "✅ .gitattributes written:"
sed -n '1,200p' "$GITATTR"

echo
echo "ℹ️ 现在请运行："
echo "      git add .gitattributes"
echo "      git add <你的 secrets 文件>"
echo "      git commit -m 'Enable sops filters'"
echo
echo "   再配合 clean/smudge filter，Git 将自动加密/解密 JSON/YAML"
