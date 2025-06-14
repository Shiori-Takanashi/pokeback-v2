> # git pull

---

## > 概要

`git pull` は、**リモートリポジトリの変更をローカルに取り込む**コマンド。
内部的には以下2つの操作を順番に行う：

```
git fetch      # リモートの変更を取得（ローカルには未反映）
git merge      # 取得した変更を現在のブランチにマージ
```

---

## > 基本構文

```
git pull <remote> <branch>
```

例：

```
git pull origin main
```

省略時は、カレントブランチと追跡関係にあるリモートブランチから取得する。

---

## > fetchとpullの違い

| 操作          | 内容                   | ローカルの変更に影響？ |
| ----------- | -------------------- | ----------- |
| `git fetch` | リモートの変更を取得するが、マージしない | 影響なし（安全）    |
| `git pull`  | リモートの変更を取得し、マージも行う   | マージにより影響あり  |

---

## > pullが危険になるケース

* ローカルで未コミットの変更がある場合
* ローカルの履歴がリモートと競合している場合
* `pull` によって予期せぬ **マージコミット** が発生する場合

---

## > 対策と応用

### > 1. `--rebase` オプション

```bash
git pull --rebase
```

マージではなくリベースにより変更を取り込む。
履歴が直線的になるため、ログが綺麗。

### > 2. `git config` で常時リベース設定

```bash
git config --global pull.rebase true
```

今後の `git pull` が自動的に `--rebase` を使用。

---

## > よくあるエラーと対処法

### > 「You have unstaged changes...」

→ ステージされていない変更がある状態で `pull` をすると拒否される。

対処例：

```bash
git stash        # 一時退避
git pull         # プル後
git stash pop    # 退避内容を戻す
```

---

## > GUIやIDEとの連携

* VSCode：`Source Control` → `...` → `Pull`
* GitKraken：GUI上で `pull` 実行可能
* 注意：GUIは勝手にマージコミットを作る場合がある

---

## > 応用：特定ブランチの追跡設定

```bash
git branch --set-upstream-to=origin/feature-x feature-x
```

これで `git pull` 実行時に `origin/feature-x` からの変更が自動的に取り込まれる。

---

## > 応用：fetch + rebase手動運用

```bash
git fetch origin
git rebase origin/main
```

`pull` より細かく制御したい場合に有効。

---

## > 推奨運用（個人開発者・面接対策向け）

* `git pull --rebase` を基本とする
* `pull` 前に `stash` を使う習慣を持つ
* 明示的に追跡設定されたブランチのみで `pull` を行う
* チーム開発では `fetch` から始め、diff確認後に `rebase` や `merge` を選択

---
