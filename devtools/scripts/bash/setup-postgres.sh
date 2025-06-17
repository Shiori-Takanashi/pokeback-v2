#!/bin/bash
# ===================================================================
# PostgreSQL セットアップスクリプト
# ===================================================================
# このスクリプトはローカル環境にPostgreSQLをセットアップし、
# Pokemon API用のデータベースとユーザーを作成します。
#
# 🔐 セキュリティ注意事項:
# - このスクリプトで設定するパスワードは開発環境用です
# - 本番環境では強力なパスワードを使用してください
# - 生成される .env.local ファイルはGitにコミットしないでください
#
# 使用方法:
#   chmod +x setup-postgres.sh
#   ./setup-postgres.sh
# ===================================================================

set -e

echo "🐘 PostgreSQLセットアップを開始します..."
echo "🔐 注意: このスクリプトは開発環境用です"
echo ""

# ===================================================================
# 1. PostgreSQLのインストール確認
# ===================================================================

if ! command -v psql &> /dev/null; then
    echo "📦 PostgreSQLをインストール中..."

    # Ubuntu/Debian系の場合
    if command -v apt &> /dev/null; then
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
    # CentOS/RHEL系の場合
    elif command -v yum &> /dev/null; then
        sudo yum install -y postgresql-server postgresql-contrib
        sudo postgresql-setup initdb
    # macOS (Homebrew)の場合
    elif command -v brew &> /dev/null; then
        brew install postgresql
        brew services start postgresql
    else
        echo "❌ パッケージマネージャーが見つかりません"
        echo "💡 手動でPostgreSQLをインストールしてください"
        exit 1
    fi

    echo "✅ PostgreSQLインストール完了"
else
    echo "✅ PostgreSQLは既にインストール済み"
fi

# ===================================================================
# 2. PostgreSQLサービスの起動
# ===================================================================

echo "🔄 PostgreSQLサービスを起動中..."

if systemctl is-active --quiet postgresql; then
    echo "✅ PostgreSQLは既に起動済み"
else
    sudo systemctl start postgresql
    sudo systemctl enable postgresql
    echo "✅ PostgreSQLサービスを起動しました"
fi

# ===================================================================
# 3. データベースとユーザーの作成
# ===================================================================

echo "🗄️  データベース設定を行います..."

# .env.localから設定を読み込み
if [ -f ".env.local" ]; then
    source .env.local
else
    # デフォルト値
    POSTGRES_DB="pokeback_v2"
    POSTGRES_USER="shiori"
    echo "⚠️  .env.localが見つかりません。デフォルト値を使用します。"
fi

# パスワードの入力
echo ""
echo "📝 データベースユーザー '${POSTGRES_USER}' のパスワードを設定してください:"
read -s -p "パスワード: " POSTGRES_PASSWORD
echo ""
read -s -p "パスワード（確認）: " POSTGRES_PASSWORD_CONFIRM
echo ""

if [ "$POSTGRES_PASSWORD" != "$POSTGRES_PASSWORD_CONFIRM" ]; then
    echo "❌ パスワードが一致しません"
    exit 1
fi

# PostgreSQLにデータベースとユーザーを作成
echo "🔧 データベースとユーザーを作成中..."

sudo -u postgres psql << EOF
-- データベースが存在する場合は削除
DROP DATABASE IF EXISTS ${POSTGRES_DB};
DROP USER IF EXISTS ${POSTGRES_USER};

-- 新しくデータベースとユーザーを作成
CREATE DATABASE ${POSTGRES_DB};
CREATE USER ${POSTGRES_USER} WITH ENCRYPTED PASSWORD '${POSTGRES_PASSWORD}';
GRANT ALL PRIVILEGES ON DATABASE ${POSTGRES_DB} TO ${POSTGRES_USER};

-- 接続確認
\c ${POSTGRES_DB}
GRANT ALL ON SCHEMA public TO ${POSTGRES_USER};

\q
EOF

echo "✅ データベース '${POSTGRES_DB}' とユーザー '${POSTGRES_USER}' を作成しました"

# ===================================================================
# 4. .env.localファイルの更新
# ===================================================================

echo "📄 .env.localファイルを更新中..."

# .env.localファイルのパスワード部分を更新
if [ -f ".env.local" ]; then
    # パスワード行を更新
    sed -i "s/^POSTGRES_PASSWORD=.*/POSTGRES_PASSWORD=${POSTGRES_PASSWORD}/" .env.local
    echo "✅ .env.localのパスワードを更新しました"
else
    # .env.localファイルを新規作成
    cat > .env.local << EOF
# ローカル開発環境用設定
DJANGO_DEBUG=True
DJANGO_SECRET_KEY=django-dev-secret-key-$(date +%s)
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0

# PostgreSQL設定
POSTGRES_DB=${POSTGRES_DB}
POSTGRES_USER=${POSTGRES_USER}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
EOF
    echo "✅ .env.localファイルを作成しました"
fi

# ===================================================================
# 5. 接続テスト
# ===================================================================

echo "🔌 データベース接続をテスト中..."

if PGPASSWORD="$POSTGRES_PASSWORD" psql -h localhost -p 5432 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; then
    echo "✅ データベース接続テスト成功"
else
    echo "❌ データベース接続テスト失敗"
    exit 1
fi

# ===================================================================
# 完了メッセージ
# ===================================================================

echo ""
echo "🎉 PostgreSQLセットアップ完了！"
echo ""
echo "📋 設定情報:"
echo "   データベース名: ${POSTGRES_DB}"
echo "   ユーザー名: ${POSTGRES_USER}"
echo "   ホスト: localhost"
echo "   ポート: 5432"
echo ""
echo "🚀 次の手順:"
echo "1. Python仮想環境をアクティベート: source .venv/bin/activate"
echo "2. ローカルサーバー起動: ./run-local.sh"
echo ""
