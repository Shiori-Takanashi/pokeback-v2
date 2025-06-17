# プロンプト切り替えガイド

ターミナルプロンプトを簡単に切り替えるためのツールとその使用方法について説明します。

## 🎯 概要

このツールセットは、開発作業の効率性とターミナル画面の見やすさを向上させるために作成されました。

## 📋 利用可能なプロンプト

### 基本プロンプト

| コマンド | 表示例 | 使用場面 |
|----------|--------|----------|
| `simple` | `$ ` | デモ・プレゼン・画面録画 |
| `minimal` | `pokeback-v2$ ` | 通常作業 |
| `detailed` | `user@host:pokeback-v2$ ` | 詳細情報が必要な時 |

### Git連携プロンプト

| コマンド | 表示例 | 機能 |
|----------|--------|------|
| `git` | `pokeback-v2(main)$ ` | ブランチ名表示 |
| `git` | `pokeback-v2(main*)$ ` | 未コミット変更あり |
| `colorful` | <span style="color:blue">pokeback-v2</span><span style="color:purple">(main)</span>$ | カラー版 |

## 🚀 基本的な使用方法

### 1. プロンプト切り替え

```bash
# シンプルなプロンプトに変更
source scripts/prompt.sh simple

# Git情報付きプロンプトに変更
source scripts/prompt.sh git

# 利用可能な設定一覧を表示
source scripts/prompt.sh list

# デフォルトに戻す
source scripts/prompt.sh reset
```

### 2. エイリアスの活用

```bash
# エイリアスを読み込み（一度だけ実行）
source scripts/prompt-aliases.sh

# 短縮コマンドで切り替え
pss    # simple
psm    # minimal
psd    # detailed
psg    # git
psc    # colorful
psr    # reset
psl    # list
```

## ⚙️ 永続化設定

### 自動設定（推奨）

お気に入りの設定を起動時に自動適用：

```bash
# ~/.bashrc に追加
echo 'export PS1="$ "' >> ~/.bashrc

# または、プロジェクト固有の設定を使用
echo 'source /path/to/pokeback-v2/scripts/prompt-config.sh' >> ~/.bashrc
```

### プロジェクト固有設定

`prompt-config.sh` を使用すると、プロジェクトディレクトリ内では自動的に適切なプロンプトが設定されます：

```bash
# pokeback-v2 ディレクトリ内では自動的にGitプロンプトを使用
cd pokeback-v2
# → 自動的に Git情報付きプロンプトに変更
```

## 🎨 特殊機能

### Git情報の詳細表示

Git情報付きプロンプトでは以下の情報が表示されます：

- **ブランチ名**: 現在のGitブランチ
- **変更状態**:
  - `(main)` - クリーンな状態
  - `(main*)` - 未コミットの変更あり

### カラープロンプト

`colorful` オプションでは色分けされた情報が表示されます：

- **青色**: ディレクトリ名
- **紫色**: Git情報
- **緑色**: 成功メッセージ
- **赤色**: エラーメッセージ

## 💡 使用シーン別推奨設定

### 開発作業時

```bash
psg  # Git情報でブランチと変更状態を常に確認
```

**メリット**:
- 現在のブランチが一目でわかる
- 未コミット変更の存在を即座に把握

### デモ・プレゼンテーション時

```bash
pss  # 画面をスッキリと表示
```

**メリット**:
- 余計な情報が表示されない
- 視聴者の注意が分散しない
- 画面録画時にもクリーン

### ペアプログラミング時

```bash
psm  # 適度な情報量で見やすい
```

**メリット**:
- ディレクトリ位置がわかる
- 画面が煩雑にならない

### デバッグ・調査時

```bash
psd  # 詳細情報で現在位置を明確に
```

**メリット**:
- ホスト名、ユーザー名が確認できる
- フルパス情報で位置を把握

## 🔧 高度な使用方法

### 条件付きプロンプト設定

特定の条件でプロンプトを自動変更：

```bash
# Git リポジトリ内では自動的にGitプロンプト
if git rev-parse --git-dir > /dev/null 2>&1; then
    psg
else
    psm
fi
```

### 時間帯別プロンプト

```bash
# 時間帯に応じてプロンプトを変更
hour=$(date +%H)
if [[ $hour -ge 9 && $hour -le 17 ]]; then
    psg  # 業務時間はGit情報付き
else
    pss  # それ以外はシンプル
fi
```

## 📝 カスタマイズ

独自のプロンプト設定を追加したい場合は、[`customization.md`](customization.md) を参照してください。

## ⚠️ 注意事項

1. **sourceコマンドの使用**: プロンプト変更は必ず `source` コマンドを使用
2. **セッション限定**: 設定はターミナルセッション終了まで有効
3. **Git情報の更新**: ブランチ変更後は手動でプロンプトを再設定することを推奨


## カスタマイズガイド

スクリプトの拡張とカスタマイズ方法について説明します。


### 新しいプロンプトスタイルの追加

`scripts/prompt.sh` に新しいプロンプト設定を追加する方法：

```bash
# scripts/prompt.sh に追加する関数
set_custom_prompt() {
    export PS1="[$(date +%H:%M)] \W$ "
    echo -e "${GREEN}✅ 時刻付きプロンプトに変更しました${NC}"
}

# main関数のcase文に追加
case "${1:-list}" in
    # ...existing cases...
    "time"|"t")
        set_custom_prompt
        ;;
    # ...
esac
```

### 条件付きプロンプト設定

環境や状況に応じて自動的にプロンプトを変更：

```bash
# プロジェクト別プロンプト
set_project_prompt() {
    local project_name=$(basename "$PWD")
    case "$project_name" in
        "pokeback-v2")
            export PS1="🐾 \W\$(get_git_info)$ "
            ;;
        "frontend-app")
            export PS1="⚛️  \W\$(get_git_info)$ "
            ;;
        *)
            export PS1="\W$ "
            ;;
    esac
}
```

### 高度なGit情報表示

Git情報をより詳細に表示：

```bash
get_advanced_git_info() {
    local git_info=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        local status=$(git status --porcelain 2>/dev/null)
        local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
        local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)

        git_info=" ($branch"

        # 未コミット変更
        if [[ -n "$status" ]]; then
            git_info+="*"
        fi

        # リモートとの差分
        if [[ -n "$ahead" && "$ahead" -gt 0 ]]; then
            git_info+="↑$ahead"
        fi
        if [[ -n "$behind" && "$behind" -gt 0 ]]; then
            git_info+="↓$behind"
        fi

        git_info+=")"
    fi
    echo "$git_info"
}
```

### カラーテーマのカスタマイズ

独自のカラーテーマを作成：

```bash
# カスタムカラー定義
ORANGE='\033[0;33m'
PINK='\033[1;35m'
GRAY='\033[0;37m'

set_custom_colorful_prompt() {
    export PS1="\[${ORANGE}\]\u\[${GRAY}\]@\[${PINK}\]\h\[${GRAY}\]:\[${BLUE}\]\W\[${PURPLE}\]\$(get_git_info)\[${NC}\]$ "
    echo -e "${GREEN}✅ カスタムカラープロンプトに変更しました${NC}"
}
```


## トラブルシューティングガイド

### プロンプトが変更されない

**症状**: `source scripts/prompt.sh simple` を実行してもプロンプトが変わらない

**原因と解決策**:

1. **sourceコマンドを使用していない**
   ```bash
   # ❌ 間違い
   ./scripts/prompt.sh simple
   bash scripts/prompt.sh simple

   # ✅ 正しい
   source scripts/prompt.sh simple
   ```

2. **スクリプトのパスが間違っている**
   ```bash
   # 現在のディレクトリを確認
   pwd
   ls scripts/prompt.sh

   # 正しいパスで実行
   source scripts/prompt.sh simple
   ```

3. **権限問題**
   ```bash
   # スクリプトを実行可能にする
   chmod +x scripts/prompt.sh
   ```

### Git情報が表示されない

**症状**: `psg` を実行してもGit情報（ブランチ名）が表示されない

**解決策**:

1. **Gitリポジトリ内にいることを確認**
   ```bash
   git status
   # "not a git repository" エラーが出る場合は、Gitリポジトリ外
   ```

2. **Git情報取得関数の再読み込み**
   ```bash
   source scripts/prompt.sh git
   ```

3. **手動でのGit情報確認**
   ```bash
   git branch --show-current
   git status --porcelain
   ```

### エイリアスが動作しない

**症状**: `pss`, `psg` などのエイリアスが認識されない

**解決策**:

1. **エイリアスを読み込み**
   ```bash
   source scripts/prompt-aliases.sh
   ```

2. **エイリアスの確認**
   ```bash
   alias | grep ps
   ```

3. **永続化**
   ```bash
   echo 'source /path/to/pokeback-v2/scripts/prompt-aliases.sh' >> ~/.bashrc
   ```
---
