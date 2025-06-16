# ===================================================================
# Dockerfile - Pokemon API バックエンドサーバー用
# ===================================================================
# このDockerfileはDjangoアプリケーションを実行するためのコンテナイメージを
# 構築します。Python 3.12をベースに必要な依存関係をインストールし、
# セキュリティのためにアプリケーション専用ユーザーを作成します。
# ===================================================================

# Python 3.12のslimイメージをベースとして使用
FROM python:3.12-slim

# システムレベルの依存関係をインストール
# - build-essential: C/C++コンパイラ（一部のPythonパッケージビルドに必要）
# - libpq-dev: PostgreSQL開発ライブラリ（psycopgパッケージに必要）
# - postgresql-client: PostgreSQL CLIツール（データベース接続テスト用）
RUN apt-get update && apt-get install -y build-essential libpq-dev postgresql-client

# アプリケーションディレクトリを設定
WORKDIR /app

# Pythonの依存関係をインストール
# requirements.txtを先にコピーして、Dockerのレイヤーキャッシュを活用
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# アプリケーションのソースコードをコピー
COPY . .

# セキュリティのためのアプリケーション専用ユーザーを作成
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser

# デフォルトコマンド（scripts/startup.shスクリプトを実行）
CMD ["bash", "scripts/startup.sh"]
