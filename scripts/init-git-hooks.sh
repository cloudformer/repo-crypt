#!/bin/bash

# -----------------------
# 配置变量：只需修改这里
# -----------------------
HOOKS_DIR=".git/hooks"          # Git hooks 目录
ENCODE_SCRIPT="scripts/encode.sh"  # 加密脚本路径
DECODE_SCRIPT="scripts/decode.sh"  # 解密脚本路径

# -----------------------
# 检查 Git 仓库
# -----------------------
if [ ! -d "$HOOKS_DIR" ]; then
  echo "❌ 当前目录不是 git 仓库或没有 .git/hooks 目录"
  exit 1
fi

# -----------------------
# pre-push hook (加密)
# -----------------------
cat > "$HOOKS_DIR/pre-push" <<EOF
#!/bin/bash
cd "\$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running $ENCODE_SCRIPT before push..."
bash $ENCODE_SCRIPT
EOF

# -----------------------
# post-checkout hook (解密)
# -----------------------
cat > "$HOOKS_DIR/post-checkout" <<EOF
#!/bin/bash
cd "\$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running $DECODE_SCRIPT after checkout..."
bash $DECODE_SCRIPT
EOF

# -----------------------
# post-merge hook (解密)
# -----------------------
cat > "$HOOKS_DIR/post-merge" <<EOF
#!/bin/bash
cd "\$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running $DECODE_SCRIPT after merge..."
bash $DECODE_SCRIPT
EOF

# -----------------------
# post-rewrite hook (解密)
# -----------------------
cat > "$HOOKS_DIR/post-rewrite" <<EOF
#!/bin/bash
cd "\$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running $DECODE_SCRIPT after rewrite (rebase/fast-forward)..."
bash $DECODE_SCRIPT
EOF

# -----------------------
# 设置可执行权限
# -----------------------
chmod +x "$HOOKS_DIR/pre-push" "$HOOKS_DIR/post-checkout" \
         "$HOOKS_DIR/post-merge" "$HOOKS_DIR/post-rewrite"

echo "✅ Git hooks initialized successfully!"
echo "Hooks: pre-push ($ENCODE_SCRIPT), post-checkout/post-merge/post-rewrite ($DECODE_SCRIPT)"
