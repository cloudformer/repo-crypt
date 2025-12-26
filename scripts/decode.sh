#!/bin/bash
DIR="environment"

timestamp() {
  date +"%Y%m%d%H%M%S"
}

decrypt_file() {
  local enc_file="$1"
  local ext="$2"
  local plain_file="${enc_file%.enc}"

  if [ -f "$plain_file" ]; then
    # hash 对比，判断是否需要覆盖
    local plain_hash enc_hash
    plain_hash=$(sha256sum "$plain_file" | awk '{print $1}')
    enc_hash=$(sops -d "$enc_file" $( [[ "$ext" == "yaml" ]] && echo "--input-type yaml --output-type yaml" || [[ "$ext" == "json" ]] && echo "--output-type json") 2>/dev/null | sha256sum | awk '{print $1}')
    if [ "$plain_hash" == "$enc_hash" ]; then
      echo "💡 $plain_file 已经是最新，跳过解密"
      return
    fi

    # 备份旧明文
    cp "$plain_file" "${plain_file}.bak"
  fi

  echo "🔓 解密: $enc_file → $plain_file"

  case "$ext" in
    yaml)
      if sops -d --input-type yaml --output-type yaml "$enc_file" > "$plain_file"; then
        echo "✅ 解密成功: $plain_file"
      else
        echo "❌ 解密失败: $enc_file → 明文未生成"
        [ -f "$plain_file" ] && rm "$plain_file"
      fi
      ;;
    json)
      if sops -d --output-type json "$enc_file" > "$plain_file"; then
        echo "✅ 解密成功: $plain_file"
      else
        echo "❌ 解密失败: $enc_file → 明文未生成"
        [ -f "$plain_file" ] && rm "$plain_file"
      fi
      ;;
    tfvars)
      if sops -d "$enc_file" > "$plain_file"; then
        echo "✅ 解密成功: $plain_file"
      else
        echo "❌ 解密失败: $enc_file → 明文未生成"
        [ -f "$plain_file" ] && rm "$plain_file"
      fi
      ;;
    *)
      echo "⚠️ 跳过未知文件类型: $enc_file"
      ;;
  esac
}

# 遍历加密文件
for enc_file in "$DIR"/*.enc; do
  [ ! -f "$enc_file" ] && continue
  base_ext="${enc_file##*.}"
  case "$base_ext" in
    enc)
      # 获取原始扩展名
      fname=$(basename "$enc_file" .enc)
      ext="${fname##*.}"
      decrypt_file "$enc_file" "$ext"
      ;;
  esac
done
