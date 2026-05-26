#!/bin/bash
# 从本地 judgment_memory.json 导出数据并推送到 GitHub Pages
set -e

WORKSPACE="/home/admin/.openclaw/workspace"
SKILL_DIR="$WORKSPACE/skills/option-selector"
PAGES_DIR="/tmp/159915-pages-deploy"
SSH_KEY="$HOME/.ssh/github_temp"
REPO="git@github.com:whao79-sudo/159915-option-tracker.git"

# 1. 导出 charts_data.json
cd "$SKILL_DIR"
python3 export_charts_data.py

# 2. 克隆/拉取最新 pages
if [ ! -d "$PAGES_DIR" ]; then
    GIT_SSH_COMMAND="ssh -i $SSH_KEY" git clone "$REPO" "$PAGES_DIR"
fi

cd "$PAGES_DIR"
GIT_SSH_COMMAND="ssh -i $SSH_KEY" git pull origin main

# 3. 复制新文件
cp "$WORKSPACE/option_data/159915/pages/index.html" .
cp "$WORKSPACE/option_data/159915/pages/charts_data.json" .

# 4. 提交推送
git add -A
if git diff --cached --quiet; then
    echo "✅ 没有变化，跳过"
else
    git commit -m "auto: update charts $(date '+%Y-%m-%d %H:%M')"
    GIT_SSH_COMMAND="ssh -i $SSH_KEY" git push origin main
    echo "✅ 已推送到 GitHub Pages"
fi
