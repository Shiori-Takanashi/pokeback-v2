# セットアップガイド

開発環境の構築とスクリプトの初期設定について説明します。

## 🎯 概要

このガイドでは、pokeback-v2プロジェクトの開発環境を効率的にセットアップする方法を説明します。

## 📋 前提条件

以下がシステムにインストールされていることを確認してください：

- **Python 3.8+**
- **PostgreSQL 12+**
- **Docker & Docker Compose** (Docker環境を使用する場合)
- **Git**
- **Bash** (Linux/macOS/WSL)

## 🚀 クイックセットアップ

### 1. プロジェクトのクローン

```bash
git clone <repository-url>
cd pokeback-v2
```

### 2. スクリプトを実行可能にする

```bash
chmod +x scripts/*.sh
```

### 3. 環境設定ファイルの準備

```bash
# テンプレートから実際の設定ファイルを作成
cp .env.example .env.local

# ファイル権限を制限（セキュリティ）
chmod 600 .env.local

# 必要な設定を編集
nano .env.local
```

### 4. データベースのセットアップ

```bash
# PostgreSQL の自動セットアップ
./scripts/setup-postgres.sh
```

### 5. 開発サーバーの起動

```bash
# ローカル開発サーバー
./scripts/run-local.sh

# または Docker 環境
./scripts/docker-compose-run.sh
```

## 🗃️ データベースセットアップ詳細

### 自動セットアップ（推奨）

```bash
./scripts/setup-postgres.sh
```

このスクリプトは以下を自動実行します：
- PostgreSQL サービスの確認・起動
- データベースとユーザーの作成
- 基本的なアクセス権限の設定
- 接続テスト

### 手動セットアップ

```bash
# PostgreSQL にスーパーユーザーとして接続
sudo -u postgres psql

# データベースとユーザーを作成
CREATE DATABASE pokeback_v2;
CREATE USER your_username WITH PASSWORD 'your_password';
GRANT ALL PRIVILEGES ON DATABASE pokeback_v2 TO your_username;
\q
```

## 🐳 Docker環境セットアップ

### 1. Docker Compose での起動

```bash
# アプリケーション + データベースを同時起動
./scripts/docker-compose-run.sh
```

### 2. 個別コンテナでの起動

```bash
# データベースのみ
docker-compose up -d db

# アプリケーションのみ
docker-compose up web
```

### 3. Docker環境の設定確認

```bash
# コンテナの状態確認
docker-compose ps

# ログの確認
docker-compose logs web
docker-compose logs db
```

## ⚙️ 環境変数の設定

### 必須設定項目

`.env.local` ファイルで以下を設定：

```bash
# Django 基本設定
DJANGO_SECRET_KEY=your-secret-key-here
DJANGO_DEBUG=True
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# データベース設定
POSTGRES_DB=pokeback_v2
POSTGRES_USER=your_username
POSTGRES_PASSWORD=your_secure_password
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
```

### SECRET_KEY の生成

```bash
# Django shell で生成
python manage.py shell
>>> from django.core.management.utils import get_random_secret_key
>>> print(get_random_secret_key())

# または、コマンドラインで直接生成
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## 🛠️ 開発ツールの設定

### プロンプト切り替えツール

```bash
# エイリアスを永続化
echo 'source /path/to/pokeback-v2/scripts/prompt-aliases.sh' >> ~/.bashrc

# 即座に使用開始
source scripts/prompt-aliases.sh
psg  # Git情報付きプロンプトに変更
```

### VS Code設定

```bash
# ワークスペース設定（推奨）
mkdir -p .vscode
cat > .vscode/settings.json << 'EOF'
{
    "python.defaultInterpreterPath": "./venv/bin/python",
    "files.associations": {
        "*.env*": "dotenv"
    }
}
EOF
```

## 🧪 セットアップの確認

### 1. 基本動作テスト

```bash
# Django設定の確認
python manage.py check

# データベース接続テスト
python manage.py dbshell
\q

# 開発サーバー起動テスト
python manage.py runserver 0.0.0.0:8000
# Ctrl+C で停止
```

### 2. セキュリティチェック

```bash
# セキュリティ設定の確認
python manage.py check --deploy

# 環境変数の確認（値は表示されない）
python manage.py shell
>>> from django.conf import settings
>>> print(f"SECRET_KEY length: {len(settings.SECRET_KEY)}")
>>> print(f"DEBUG: {settings.DEBUG}")
```

### 3. Git設定の確認

```bash
# 機密情報が除外されていることを確認
git status
# .env.local が Untracked files に表示される（正常）

# プロンプトでGit情報が表示されることを確認
psg
git branch
```

## 🎯 環境別セットアップ

### ローカル開発環境

```bash
# Python仮想環境
python -m venv venv
source venv/bin/activate  # Linux/macOS
# venv\Scripts\activate   # Windows

# 依存関係インストール
pip install -r requirements_dev.txt

# データベースマイグレーション
python manage.py migrate

# 開発サーバー起動
./scripts/run-local.sh
```

### Docker開発環境

```bash
# イメージのビルド
docker-compose build

# サービス起動
./scripts/docker-compose-run.sh

# マイグレーション（初回のみ）
docker-compose exec web python manage.py migrate
```

### 本番環境（参考）

```bash
# 環境変数設定
export DJANGO_DEBUG=False
export DJANGO_SECRET_KEY="production-secret-key"
export DJANGO_ALLOWED_HOSTS="yourdomain.com"

# 静的ファイル収集
python manage.py collectstatic --noinput

# マイグレーション
python manage.py migrate

# セキュリティチェック
python manage.py check --deploy --fail-level WARNING
```

## 🔧 トラブルシューティング

セットアップ中に問題が発生した場合は [`troubleshooting.md`](troubleshooting.md) を参照してください。

## 📝 次のステップ

セットアップが完了したら：

1. [プロンプト切り替えガイド](prompt-guide.md) でターミナルをカスタマイズ
2. [カスタマイズガイド](customization.md) で開発環境を最適化
3. 実際の開発作業を開始

## 💡 Tips

- **初回セットアップ時**: 全てのスクリプトを順番に実行することを推奨
- **日常の開発**: `run-local.sh` または `docker-compose-run.sh` のみで十分
- **新しいチームメンバー**: このガイドを共有してスムーズなオンボーディングを実現
