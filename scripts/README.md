# Scripts Directory

このディレクトリには、Pokemon API プロジェクトで使用する各種スクリプトファイルが含まれています。

## 📁 スクリプト一覧

### 🚀 アプリケーション起動スクリプト

#### `run-local.sh` - ローカル環境起動
```bash
./scripts/run-local.sh
```
- **目的**: Docker無しでローカル環境でアプリケーションを起動
- **前提条件**:
  - Python仮想環境がアクティベート済み
  - PostgreSQLがインストール・起動済み
  - `.env.local`ファイルが設定済み
- **機能**:
  - 環境確認（仮想環境、PostgreSQL接続）
  - 依存関係インストール
  - データベースマイグレーション
  - 静的ファイル収集
  - スーパーユーザー作成（オプション）
  - Django開発サーバー起動

#### `docker-compose-run.sh` - Docker環境起動
```bash
./scripts/docker-compose-run.sh
```
- **目的**: Docker Composeでアプリケーションを起動
- **機能**:
  - Docker Composeサービスをビルド・起動
  - バックグラウンド実行

### 🔧 セットアップスクリプト

#### `setup-postgres.sh` - PostgreSQLセットアップ
```bash
./scripts/setup-postgres.sh
```
- **目的**: ローカル環境にPostgreSQLをセットアップ
- **機能**:
  - PostgreSQLのインストール（未インストールの場合）
  - PostgreSQLサービスの起動・有効化
  - プロジェクト用データベースとユーザーの作成
  - `.env.local`ファイルの生成・更新
  - データベース接続テスト

### 🐳 Docker関連スクリプト

#### `startup.sh` - Dockerコンテナ内起動スクリプト
- **目的**: Dockerコンテナ内でDjangoアプリケーションを起動
- **使用場面**: Dockerfileから自動実行
- **機能**:
  - 環境変数の確認・表示
  - PostgreSQL接続待機
  - データベースマイグレーション
  - 静的ファイル収集
  - Django開発サーバー起動

## 🔄 使用フロー

### 初回セットアップ（ローカル環境）
```bash
# 1. PostgreSQLセットアップ
./scripts/setup-postgres.sh

# 2. 仮想環境アクティベート
source .venv/bin/activate

# 3. アプリケーション起動
./scripts/run-local.sh
```

### 初回セットアップ（Docker環境）
```bash
# Docker Composeで起動
./scripts/docker-compose-run.sh
```

### 2回目以降の起動
```bash
# ローカル環境
source .venv/bin/activate && ./scripts/run-local.sh

# Docker環境
docker compose up -d
```

## 📝 注意事項

1. **実行権限**: すべてのスクリプトには実行権限が付与されています
2. **環境分離**: ローカル環境とDocker環境は独立して動作します
3. **設定ファイル**: 各環境に応じた`.env.*`ファイルが使用されます
4. **エラーハンドリング**: 各スクリプトには詳細なエラーメッセージと修正方法が含まれています

## 🛠 開発者向け情報

スクリプトを編集する際は、以下の点に注意してください：

- `set -e`: エラー時の即座終了設定
- 詳細なログ出力とエラーメッセージ
- 前提条件の確認ロジック
- ユーザーフレンドリーな説明文
