#!/bin/bash
DIR="environment"

timestamp() {
  date +"%Y%m%d%H%M%S"
}

encrypt_file() {
  local f="$1"
  local ext="$2"
  local enc_file="${f}.enc"

  # 计算明文 hash
  local plain_hash
  plain_hash=$(sha256sum "$f" | awk '{print $1}')

  # 如果加密文件存在，解密再算 hash
  if [ -f "$enc_file" ]; then
    local enc_hash
    enc_hash=$(sops -d "${enc_file}" $( [[ "$ext" == "yaml" ]] && echo "--input-type yaml --output-type yaml" || [[ "$ext" == "json" ]] && echo "--output-type json") 2>/dev/null | sha256sum | awk '{print $1}')
    if [ "$plain_hash" == "$enc_hash" ]; then
      echo "💡 $f 未修改，跳过加密"
      return
    fi

    # 备份旧 .enc
    cp "$enc_file" "${enc_file}.bak"
  fi

  # 执行加密
  case "$ext" in
    yaml)
      if sops -e --input-type yaml "$f" > "$enc_file"; then
        echo "✅ 加密成功: $enc_file"
        rm "$f"
      else
        echo "❌ 加密失败: $f → 原文件保留"
      fi
      ;;
    json)
      if sops -e --input-type json "$f" > "$enc_file"; then
        echo "✅ 加密成功: $enc_file"
        rm "$f"
      else
        echo "❌ 加密失败: $f → 原文件保留"
      fi
      ;;
    tfvars)
      if sops -e "$f" > "$enc_file"; then
        echo "✅ 加密成功: $enc_file"
        rm "$f"
      else
        echo "❌ 加密失败: $f → 原文件保留"
      fi
      ;;
    *)
      echo "⚠️ 跳过未知文件类型: $f"
      ;;
  esac
}

# 遍历文件
for f in "$DIR"/*; do
  [ ! -f "$f" ] && continue
  ext="${f##*.}"
  encrypt_file "$f" "$ext"
done
