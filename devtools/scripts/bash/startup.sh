#!/bin/bash
# ===================================================================
# Django アプリケーション起動スクリプト
# ===================================================================
# このスクリプトはDockerコンテナ内でDjangoアプリケーションを起動します。
#
# 実行内容：
# 1. 環境変数の確認・表示
# 2. データベース接続の待機
# 3. Djangoデータベースマイグレーション
# 4. 静的ファイル収集
# 5. 開発サーバーの起動
# ===================================================================

# デバッグ情報を表示
echo "=== Environment variables ==="
echo "POSTGRES_HOST: $POSTGRES_HOST"
echo "POSTGRES_PORT: $POSTGRES_PORT"
echo "POSTGRES_DB: $POSTGRES_DB"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "DATABASE_URL: $DATABASE_URL"
echo "=============================="

# データベースの準備を待つ
echo "Waiting for database..."
echo "Testing database connection..."

# PostgreSQL接続を直接テスト
# データベースが準備完了するまで待機
until PGPASSWORD=$POSTGRES_PASSWORD psql -h "$POSTGRES_HOST" -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c '\q'; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done

echo "PostgreSQL is up - executing command"

# Django database checkも実行
# Djangoレベルでのデータベース接続確認
while ! python manage.py check --database default; do
  echo "Django database check failed - sleeping"
  sleep 1
done

# マイグレーションを実行
echo "Running migrations..."
python manage.py migrate

# 静的ファイルを収集
# WhiteNoiseを使用して静的ファイルを効率的に配信
echo "Collecting static files..."
python manage.py collectstatic --noinput

# Djangoサーバーを起動
# すべてのネットワークインターフェースでリッスン（Docker環境用）
echo "Starting Django server..."
python manage.py runserver 0.0.0.0:8000
