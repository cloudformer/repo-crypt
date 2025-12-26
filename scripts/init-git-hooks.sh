#!/bin/bash
HOOKS_DIR=".git/hooks"

if [ ! -d "$HOOKS_DIR" ]; then
  echo "❌ 当前目录不是 git 仓库或没有 .git/hooks 目录"
  exit 1
fi

# pre-push
cat > "$HOOKS_DIR/pre-push" <<'EOF'
#!/bin/bash
cd "$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running encode.sh before push..."
bash scripts/encode.sh
EOF

# post-checkout
cat > "$HOOKS_DIR/post-checkout" <<'EOF'
#!/bin/bash
cd "$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running decode.sh after checkout..."
bash scripts/decode.sh
EOF

# post-merge
cat > "$HOOKS_DIR/post-merge" <<'EOF'
#!/bin/bash
cd "$(git rev-parse --show-toplevel)" || exit 1
echo "[SOPS] Running decode.sh after merge..."
bash scripts/decode.sh
EOF

chmod +x "$HOOKS_DIR/pre-push" "$HOOKS_DIR/post-checkout" "$HOOKS_DIR/post-merge"

echo "✅ Git hooks initialized successfully with encode/decode.sh!"
