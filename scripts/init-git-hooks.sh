#!/bin/bash

# Git hooks 目录
HOOKS_DIR=".git/hooks"

# 检查是否在 git 仓库
if [ ! -d "$HOOKS_DIR" ]; then
  echo "❌ 当前目录不是 git 仓库或没有 .git/hooks 目录"
  exit 1
fi

# 创建 pre-push hook（push 前加密）
cat > "$HOOKS_DIR/pre-push" <<'EOF'
#!/bin/bash
echo "[SOPS] Running encrypt.sh before push..."
bash scripts/encrypt.sh
EOF

# 创建 post-checkout hook（checkout 后解密）
cat > "$HOOKS_DIR/post-checkout" <<'EOF'
#!/bin/bash
echo "[SOPS] Running decrypt.sh after checkout..."
bash scripts/decrypt.sh
EOF

# 创建 post-merge hook（merge/pull 后解密）
cat > "$HOOKS_DIR/post-merge" <<'EOF'
#!/bin/bash
echo "[SOPS] Running decrypt.sh after merge..."
bash scripts/decrypt.sh
EOF

# 设置可执行权限
chmod +x "$HOOKS_DIR/pre-push" "$HOOKS_DIR/post-checkout" "$HOOKS_DIR/post-merge"

echo "✅ Git hooks initialized successfully!"
echo "Hooks: pre-push (encrypt), post-checkout (decrypt), post-merge (decrypt)"
