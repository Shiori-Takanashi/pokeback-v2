# Scripts Documentation

このディレクトリには、開発効率を向上させるための各種スクリプトとその詳細ドキュメントが含まれています。

## 📁 ディレクトリ構成

```
scripts/
├── docs/                    # ドキュメント
│   ├── prompt-guide.md     # プロンプト切り替えガイド
│   ├── setup-guide.md      # セットアップガイド
│   ├── troubleshooting.md  # トラブルシューティング
│   └── customization.md    # カスタマイズガイド
├── prompt.sh               # プロンプト切り替えメインスクリプト
├── prompt-aliases.sh       # エイリアス定義
├── prompt-config.sh        # 永続設定
├── setup-postgres.sh       # PostgreSQL セットアップ
├── docker-compose-run.sh   # Docker Compose 実行
├── run-local.sh           # ローカル実行
├── startup.sh             # Docker コンテナ起動
└── README.md              # このファイル
```

## 🚀 主要スクリプト

### プロンプト切り替えツール
ターミナルプロンプトを状況に応じて簡単に切り替え

```bash
source scripts/prompt.sh simple  # シンプルプロンプト
source scripts/prompt.sh git     # Git情報付き
```

詳細: [`docs/prompt-guide.md`](docs/prompt-guide.md)

### 開発環境セットアップ
プロジェクトの開発環境を自動セットアップ

```bash
./scripts/setup-postgres.sh      # PostgreSQL セットアップ
./scripts/run-local.sh           # ローカル開発サーバー起動
```

詳細: [`docs/setup-guide.md`](docs/setup-guide.md)

### Docker 関連
Docker環境での開発・デプロイ支援

```bash
./scripts/docker-compose-run.sh  # Docker Compose でアプリ起動
```

## 📚 ドキュメント

- **[プロンプト切り替えガイド](docs/prompt-guide.md)** - ターミナルプロンプトのカスタマイズ
- **[セットアップガイド](docs/setup-guide.md)** - 開発環境の構築手順
- **[トラブルシューティング](docs/troubleshooting.md)** - よくある問題と解決方法
- **[カスタマイズガイド](docs/customization.md)** - スクリプトの拡張・改造方法

## 💡 クイックスタート

### 1. プロンプト切り替え

```bash
# エイリアス読み込み
source scripts/prompt-aliases.sh

# 短縮コマンドで切り替え
pss  # シンプル
psg  # Git情報付き
psl  # 一覧表示
```

### 2. 開発環境起動

```bash
# ローカル開発
./scripts/run-local.sh

# Docker環境
./scripts/docker-compose-run.sh
```

## 🔧 セットアップ

初回利用時は以下を実行：

```bash
# 全スクリプトを実行可能にする
chmod +x scripts/*.sh

# プロンプトエイリアスを永続化
echo 'source /path/to/pokeback-v2/scripts/prompt-aliases.sh' >> ~/.bashrc
```

## 📋 利用シーン

| シーン | 推奨スクリプト | 理由 |
|--------|----------------|------|
| 初回セットアップ | `setup-postgres.sh` | DB環境構築 |
| 日常開発 | `run-local.sh` + `psg` | 開発サーバー + Git情報 |
| デモ・プレゼン | `pss` | 画面をスッキリ表示 |
| Docker開発 | `docker-compose-run.sh` | コンテナ環境での開発 |

## 🎯 Tips

- スクリプトは `source` コマンドで実行するものと、直接実行するものがあります
- プロンプト関連は必ず `source` を使用してください
- エラーが発生した場合は [`docs/troubleshooting.md`](docs/troubleshooting.md) を参照

---

各スクリプトの詳細な使用方法については、対応するドキュメントファイルを参照してください。
