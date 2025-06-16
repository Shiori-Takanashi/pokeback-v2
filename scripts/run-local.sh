#!/bin/bash
# ===================================================================
# ローカル環境起動スクリプト (PostgreSQL使用)
# ===================================================================
# このスクリプトはDocker無しでローカル環境でPokemon APIを起動します。
#
# 前提条件:
# - Python仮想環境がアクティベート済み
# - PostgreSQLがローカルにインストール・起動済み
# - .env.localファイルが適切に設定済み
#
# 使用方法:
#   chmod +x run-local.sh
#   ./run-local.sh
# ===================================================================

set -e  # エラー時に即座に終了

echo "🚀 ローカル環境でPokemon APIを起動します..."

# ===================================================================
# 1. 環境確認
# ===================================================================

# .env.localファイルの存在確認
if [ ! -f ".env.local" ]; then
    echo "❌ .env.localファイルが見つかりません"
    echo ""
    echo "💡 設定手順:"
    echo "1. .env.localファイルを作成"
    echo "2. PostgreSQLの接続情報を設定"
    echo "3. 再度実行してください"
    echo ""
    echo "📄 .env.localの最小設定例:"
    echo "DJANGO_DEBUG=True"
    echo "DJANGO_SECRET_KEY=your-secret-key"
    echo "POSTGRES_DB=pokeback_v2"
    echo "POSTGRES_USER=shiori"
    echo "POSTGRES_PASSWORD=your-password"
    exit 1
fi

# 仮想環境の確認
if [ -z "$VIRTUAL_ENV" ]; then
    echo "⚠️  Python仮想環境がアクティベートされていません"
    echo ""
    echo "💡 以下のコマンドで仮想環境をアクティベート:"
    echo "source .venv/bin/activate  # または"
    echo "source venv/bin/activate"
    echo ""
    exit 1
fi

echo "✅ 仮想環境: $VIRTUAL_ENV"

# PostgreSQL接続テスト用の環境変数を読み込み
source .env.local

# ===================================================================
# 2. PostgreSQL接続確認
# ===================================================================

echo "🗄️  PostgreSQL接続を確認中..."

# PostgreSQLサービスの確認
if ! systemctl is-active --quiet postgresql 2>/dev/null; then
    echo "⚠️  PostgreSQLサービスが起動していません"
    echo ""
    echo "💡 PostgreSQLを起動するコマンド:"
    echo "sudo systemctl start postgresql"
    echo ""
    read -p "PostgreSQLを起動しますか? (y/n): " start_pg
    if [ "$start_pg" = "y" ] || [ "$start_pg" = "Y" ]; then
        sudo systemctl start postgresql
        echo "✅ PostgreSQLを起動しました"
    else
        echo "❌ PostgreSQLが起動していないため処理を中断します"
        exit 1
    fi
fi

# データベース接続テスト
echo "🔌 データベース接続をテスト中..."
if ! PGPASSWORD="$POSTGRES_PASSWORD" psql -h "$POSTGRES_HOST" -p "$POSTGRES_PORT" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q' 2>/dev/null; then
    echo "❌ データベース接続に失敗しました"
    echo ""
    echo "💡 以下を確認してください:"
    echo "1. PostgreSQLが起動しているか"
    echo "2. .env.localの接続情報が正しいか"
    echo "3. データベースとユーザーが作成済みか"
    echo ""
    echo "🔧 データベース作成コマンド例:"
    echo "sudo -u postgres psql"
    echo "CREATE DATABASE $POSTGRES_DB;"
    echo "CREATE USER $POSTGRES_USER WITH ENCRYPTED PASSWORD '$POSTGRES_PASSWORD';"
    echo "GRANT ALL PRIVILEGES ON DATABASE $POSTGRES_DB TO $POSTGRES_USER;"
    echo "\\q"
    exit 1
fi

echo "✅ データベース接続成功"

# ===================================================================
# 3. 依存関係とアプリケーション準備
# ===================================================================

echo "📦 Python依存関係をインストール中..."
pip install -r requirements_dev.txt

echo "🔄 データベースマイグレーションを実行中..."
python manage.py makemigrations
python manage.py migrate

echo "📁 静的ファイルを収集中..."
python manage.py collectstatic --noinput

# ===================================================================
# 4. スーパーユーザー作成（オプション）
# ===================================================================

if ! python manage.py shell -c "from django.contrib.auth import get_user_model; User = get_user_model(); print('exists' if User.objects.filter(is_superuser=True).exists() else 'none')" | grep -q "exists"; then
    echo ""
    echo "👤 管理者ユーザーが存在しません"
    read -p "管理者ユーザーを作成しますか? (y/n): " create_user
    if [ "$create_user" = "y" ] || [ "$create_user" = "Y" ]; then
        python manage.py createsuperuser
    fi
fi

# ===================================================================
# 5. 開発サーバー起動
# ===================================================================

echo ""
echo "🌐 Django開発サーバーを起動中..."
echo "📍 アクセス先: http://localhost:8000"
echo "👤 管理画面: http://localhost:8000/admin"
echo "🛑 停止: Ctrl+C"
echo ""
echo "=====================================
python manage.py runserver
