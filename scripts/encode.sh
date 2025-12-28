#!/bin/bash
# encode.sh - 安全加密明文文件为 .enc
# 永不覆盖原加密文件，生产安全版

set -euo pipefail

DIR="./environment"   # 明文文件目录，可修改

# 查找明文文件
files=("$DIR"/*.json "$DIR"/*.yaml "$DIR"/*.yml)

if [ ${#files[@]} -eq 0 ]; then
  echo "⚠️ 没有找到任何明文文件在 $DIR 下"
  exit 0
fi

echo "🔹 找到 ${#files[@]} 个明文文件，开始加密..."

# 遍历明文文件
for f in "${files[@]}"; do
  [ ! -f "$f" ] && continue

  enc="$f.enc"
  tmp_enc="$enc.tmp"

  echo "🔐 加密中: $f"

  # 使用 sops 加密到临时文件
  if sops -e "$f" > "$tmp_enc"; then
    # 成功则覆盖 .enc
    mv "$tmp_enc" "$enc"
    echo "✅ 加密成功: $enc"
  else
    # 失败则删除临时文件，不影响原 enc
    rm -f "$tmp_enc"
    echo "❌ 加密失败: $f → 原文件保留"
  fi
done
