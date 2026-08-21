<!--
  建案客資 CRM 視覺重設計 demo — PR 說明
  單檔 HTML 專案，兩人同時開發。動到共用區塊請在 PR 標題加 [共用]。
-->

## 做了什麼

<!-- 一到三句。只寫改了什麼，不要寫思考過程 -->

## 為什麼這樣做

<!-- 設計或實作上的取捨。審核者主要看這段 -->

## 畫面

<!-- 一定要附。有調整 RWD 請附桌機與手機各一張（斷點只有 900 / 1020）-->

## 版本

- 是否出新版本檔：☐ 否　☐ 是 → 新檔名：`ui-restyle-demo-B__-YYYY-MM-DD.html`
- 已同步 `ui-restyle-demo-latest.html`（md5 與新版本檔相同）：☐

## 影響範圍

- 動到的頁面：<!-- 例：leads、analytics -->
- 動到的行段與區塊：<!-- 例：style 338–372 來客卡、body 1440–1486 leads 頁 -->
- 是否動到共用區塊：☐ 否　☐ 是 → 標題已加 `[共用]`：☐　已通知協作者：☐
  <!-- 共用區塊＝ :root token／.rail／.topbar／.page-holder／
       .chip .pillbtn .circlebtn .kpi .lead .sec .view .drawer .slot／
       設計規範頁 #page-guide／JS 頁面切換與 ⌘K -->
- 改了 token → 設計規範頁已同步：☐ 不適用　☐ 已同步

## 自檢

- [ ] 只包含與本次任務相關的修改，沒有順手格式化、重排 CSS 或重構無關 JS
- [ ] 顏色／間距／圓角／陰影全部取自 `:root` token，白色用 `var(--on-accent)`／`var(--card)` 而非 `#fff`
- [ ] 沒有自創新的字級數值，也沒有自設中繼字級
- [ ] 沒有重複建立已存在的元件；改共用 class 時只加修飾子，未改既有預設外觀
- [ ] 新增的 class 名稱已 grep 確認沒撞到既有名稱
- [ ] 沒有引入任何外部 CDN／字體／JS／圖片連結（單檔離線可開）
- [ ] 沒有覆蓋或刪改歷史版本檔
- [ ] 已在瀏覽器實際開啟並逐頁看過（看過哪幾頁：__________）
- [ ] 建案首頁底圖仍為佔位漸層或業主實景照，未使用 AI 生成影像
- [ ] `git status` 沒有出現 `design-refs/` 或內部商業文件

### 機檢四項（貼上輸出）

```bash
grep -c 'src="http\|href="http\|@import' ui-restyle-demo-latest.html
```
基準 `0`（紅線）　→ 實際：______

```bash
sed -n '45,945p' ui-restyle-demo-latest.html | grep -c "#[0-9A-Fa-f]\{3,6\}\b"
```
基準 `0`（紅線，v9 已清零）　→ 實際：______

```bash
grep -o "font-size:[^;]*" ui-restyle-demo-latest.html | sort -u | wc -l
```
基準 `57`，不應變多　→ 實際：______

```bash
sed -n '45,945p' ui-restyle-demo-latest.html | grep -o "rgba\?(" | wc -l
```
基準 `31`，不應變多　→ 實際：______

> 第 2、4 項的行段 `45,945` 會隨 `:root` 與 `<style>` 長度變動，
> 跑之前先 `grep -n ":root{\|</style>" ui-restyle-demo-latest.html` 確認範圍。

## 需要人工確認的畫面行為

<!-- 例：抽屜開闔動畫、⌘K 快查結果排序、hover 浮起層級——這些截圖看不出來 -->
