#!/usr/bin/env bash
#
# 設計規範機檢 — CLAUDE.md「任務完成前的自檢」四項可機檢紅線
#
# 用法：  ./scripts/check-design.sh [檔名]
# 預設檢查 ui-restyle-demo-latest.html
#
# 只驗 latest。歷史版本檔（B8 以前）本來就含硬編色，那是當時的實況，
# 拿現在的標準去驗會全部紅掉，也不該去改它們（CLAUDE.md 規則 6：不覆蓋歷史版本）。
#
set -uo pipefail

FILE="${1:-ui-restyle-demo-latest.html}"

# ── 基準值（2026-08-21 實測，B9）─────────────────────────────
MAX_EXTERNAL=0        # 紅線：外部 CDN／字體／JS／圖片連結
MAX_HARDCODED=0       # 紅線：<style> 內 :root 以外的硬編色
MAX_FONTSIZES=57      # 不重複字級數，不應變多
MAX_RGBA=31           # rgba() 半透明疊層，不應變多

if [ ! -f "$FILE" ]; then
  echo "✗ 找不到檔案：$FILE"
  exit 1
fi

# ── 動態定位 :root 與 </style> ────────────────────────────────
# 不寫死行號：:root 一增減 token，寫死的行段就會驗錯範圍。
ROOT_START=$(grep -n ':root{' "$FILE" | head -1 | cut -d: -f1)
STYLE_END=$(grep -n '</style>' "$FILE" | head -1 | cut -d: -f1)

if [ -z "$ROOT_START" ] || [ -z "$STYLE_END" ]; then
  echo "✗ 找不到 :root{ 或 </style>，檔案結構可能已改變"
  exit 1
fi

# :root 區塊的結尾＝其後第一個只有 } 的行
ROOT_END=$(awk -v s="$ROOT_START" \
  'NR>s && /^[[:space:]]*}[[:space:]]*$/ {print NR; exit}' "$FILE")

if [ -z "$ROOT_END" ]; then
  echo "✗ 找不到 :root 區塊的結尾"
  exit 1
fi

BODY_START=$((ROOT_END + 1))
BODY_END=$((STYLE_END - 1))

echo "檔案：$FILE（共 $(wc -l < "$FILE") 行）"
echo ":root 區塊：${ROOT_START}–${ROOT_END}　│　<style> 結束：${STYLE_END}"
echo "檢查範圍（:root 以外的樣式）：${BODY_START}–${BODY_END}"
echo "────────────────────────────────────────────────────────"

STYLE_BODY=$(sed -n "${BODY_START},${BODY_END}p" "$FILE")

# ── 四項檢查 ──────────────────────────────────────────────────
EXTERNAL=$(grep -c 'src="http\|href="http\|@import' "$FILE" || true)
HARDCODED=$(printf '%s\n' "$STYLE_BODY" | grep -c '#[0-9A-Fa-f]\{3,6\}\b' || true)
FONTSIZES=$(grep -o 'font-size:[^;]*' "$FILE" | sort -u | wc -l | tr -d ' ')
RGBA=$(printf '%s\n' "$STYLE_BODY" | grep -o 'rgba\?(' | wc -l | tr -d ' ')

FAIL=0

report() {  # 名稱 實際值 上限 是否紅線
  local name="$1" got="$2" max="$3" redline="$4"
  if [ "$got" -le "$max" ]; then
    printf '✓ %-28s %4s  (上限 %s)\n' "$name" "$got" "$max"
  else
    printf '✗ %-28s %4s  (上限 %s)%s\n' "$name" "$got" "$max" \
      "$([ "$redline" = "紅線" ] && echo '  ← 紅線' || echo '')"
    FAIL=1
  fi
}

report "外部資源連結"      "$EXTERNAL"  "$MAX_EXTERNAL"  "紅線"
report "硬編色（:root 以外）" "$HARDCODED" "$MAX_HARDCODED" "紅線"
report "不重複字級數"      "$FONTSIZES" "$MAX_FONTSIZES" ""
report "rgba() 半透明疊層" "$RGBA"      "$MAX_RGBA"      ""

echo "────────────────────────────────────────────────────────"

if [ "$FAIL" -ne 0 ]; then
  echo "✗ 未通過。違規位置："
  if [ "$EXTERNAL" -gt "$MAX_EXTERNAL" ]; then
    echo ""; echo "【外部資源】單檔離線可開是硬需求，不可引入外部連結："
    grep -n 'src="http\|href="http\|@import' "$FILE" | head -20
  fi
  if [ "$HARDCODED" -gt "$MAX_HARDCODED" ]; then
    echo ""; echo "【硬編色】請改用 :root token（白色用 var(--on-accent) 或 var(--card)）："
    grep -n '#[0-9A-Fa-f]\{3,6\}\b' "$FILE" \
      | awk -F: -v a="$BODY_START" -v b="$BODY_END" '$1>=a && $1<=b' | head -20
  fi
  if [ "$FONTSIZES" -gt "$MAX_FONTSIZES" ]; then
    echo ""; echo "【字級】不可自創新的字級數值，請沿用同類元件既有值。目前全部值："
    grep -o 'font-size:[^;]*' "$FILE" | sort -u | tr '\n' ' '; echo ""
  fi
  if [ "$RGBA" -gt "$MAX_RGBA" ]; then
    echo ""; echo "【rgba()】新增半透明疊層前請先詢問（CLAUDE.md §2b 記錄有案的例外）。"
  fi
  echo ""
  echo "基準值定義在本腳本開頭，與 CLAUDE.md 自檢清單一致。"
  echo "若這是刻意的設計決策，請先取得共識，再一併更新基準值與 CLAUDE.md。"
  exit 1
fi

echo "✓ 四項機檢全數通過"
