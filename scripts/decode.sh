#!/bin/bash
set -euo pipefail

DIR="environment"
: "${ENVIRONMENT_ADMIN_ROLE:?ENVIRONMENT_ADMIN_ROLE is not set}"
export AWS_PROFILE="$ENVIRONMENT_ADMIN_ROLE"
shopt -s nullglob

timestamp() { date +"%Y%m%d%H%M%S"; }
file_hash() { sha256sum "$1" | awk '{print $1}'; }

# -----------------------------
# 解密函数
# -----------------------------
decrypt_file() {
  local enc="$1"
  local ext="$2"
  local out="${enc%.enc}"

  echo "🔓 尝试解密: $enc → $out"

  local sops_cmd
  case "$ext" in
    json) sops_cmd=(sops -d --output-type json "$enc") ;;
    yaml) sops_cmd=(sops -d --input-type yaml --output-type yaml "$enc") ;;
    tfvars) sops_cmd=(sops -d "$enc") ;;
    *)
      echo "⚠️ 未知文件类型: $enc"
      return
      ;;
  esac

  local tmp_out="${out}.tmp.$(timestamp)"
  if "${sops_cmd[@]}" > "$tmp_out" 2>err.log; then
    # 检查原文件是否存在并计算 hash
    if [ -f "$out" ]; then
      local hash_old hash_new
      hash_old=$(file_hash "$out")
      hash_new=$(file_hash "$tmp_out")
      if [ "$hash_old" == "$hash_new" ]; then
        printf "\e[32m➡️  %s hash unchanged, skipping\e[0m\n" "$out"
        rm "$tmp_out"
        return
      else
        mv "$out" "${out}.bak"
        echo "🔹 原文件已备份为: ${out}.bak"
      fi
    fi
    mv "$tmp_out" "$out"
    echo "✅ 解密成功: $out"
  else
    echo "❌ 解密失败: $enc → 明文未生成"
    echo "🔹 错误日志:"
    cat err.log | sed 's/^/   /'
    rm -f "$tmp_out"
    echo "🔒 原文件未被覆盖，请检查权限或密钥"
  fi
}

# -----------------------------
# 遍历加密文件
# -----------------------------
files=("$DIR"/*.json.enc "$DIR"/*.yaml.enc "$DIR"/*.tfvars.enc)

if [ ${#files[@]} -eq 0 ]; then
  echo "⚠️ 没有找到任何加密文件在 $DIR 下"
else
  echo "🔹 找到 ${#files[@]} 个加密文件，开始解密..."
  for enc in "${files[@]}"; do
    [ ! -f "$enc" ] && continue
    filename=$(basename "$enc")
    # 提取原始扩展名
    ext="${filename%.enc}"
    ext="${ext##*.}"
    decrypt_file "$enc" "$ext"
  done
fi
