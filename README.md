# pokeback-v2

本プロジェクトは、Djangoによるポケモン対戦支援用バックエンドAPIです。
フロントエンドとの連携を想定し、型安全・高信頼性を重視した設計になっています。
pokeback-v1で、アーキテクチャ設計の大枠は完成したので、
プロジェクトの進捗を丁寧に記録しながら、v2を完成させていきます。

## 🚀 クイックスタート

### Docker環境での起動（推奨）

```bash
# 1. Docker Composeで起動
docker compose up -d

# または起動スクリプトを使用
./scripts/docker-compose-run.sh
```

### ローカル環境での起動（PostgreSQL）

```bash
# 1. PostgreSQLセットアップ（初回のみ）
./scripts/setup-postgres.sh

# 2. 仮想環境をアクティベート
source .venv/bin/activate

# 3. ローカルサーバー起動
./scripts/run-local.sh
```

## � セキュリティ設定

### 初回セットアップ
```bash
# 1. 環境設定ファイルの作成
cp .env.example .env.local  # ローカル環境用
cp .env.example .env.docker # Docker環境用

# 2. 機密情報の設定（必須）
nano .env.local  # SECRET_KEYとパスワードを変更
```

### ⚠️ 重要事項
- `.env.*`ファイルには実際の機密情報を設定してください
- これらのファイルはGitにコミットされません（`.gitignore`で除外済み）
- 詳細は [`docs/SECURITY.md`](docs/SECURITY.md) を参照

## �📁 ファイル構成

### 設定ファイル
- `.env.example` - 設定テンプレート（機密情報なし）
- `.env.local` - ローカル開発環境用（要設定）
- `.env.docker` - Docker環境用（要設定）

設定の優先順位: `.env.local` > `.env.docker` > デフォルト値

### スクリプトファイル
- `scripts/` - 各種起動・セットアップスクリプト
- 詳細は [`scripts/README.md`](scripts/README.md) を参照


## 第01項目（必須機能）

バックエンドの基盤を構成する必須の機能です。

1. **PokeAPIデータ取得コマンド**
   Django管理コマンドにより、PokeAPIからのデータ取得・抽出・加工・保存を自動化します。
   ここが最も注力した部分です。

2. **API提供（DRF）**
   Django REST Frameworkを用いて、フロントエンド（Next.js）からアクセス可能なAPIを提供します。

3. **堅牢性の確保**
   - 静的型チェック（`mypy`）
   - リトライ処理（`asyncio`, `aiohttp` などに`try-except`を徹底）
   - トランザクション制御（`@transaction.atomic`）

4. **ログ出力の徹底**
   PokeAPI側の仕様変更や不具合を、ロギングによって検知可能にします。


## 第02項目（補助機能）

信頼性のため、網羅性のための補助的機能です。

1. **取得完了の保証**
   全ポケモンデータが取得・登録されていることを、スキーマ上で確認できる仕組み。

2. **限定フォームの翻訳処理**
   規則性に基づいた限定フォーム（例: アローラ、ガラル等）の自動翻訳処理。


## 第03項目（拡張予定）

今後の発展に向けた追加機能です。

1. **技・図鑑データの統合**
   データベースにポケモンの技・図鑑データを追加して、ポケモンデータと統合します。

2. **ユーザー管理・カスタム登録**
   ログイン認証とCRUD機能により、ユーザー独自のポケモン登録・編集を可能にします。


## 使用技術スタック（抜粋）

- Python 3.12+
- Django 5.x / Django REST Framework
- PostgreSQL
- aiohttp / asyncio
- mypy / flake8 / isort
- Gunicorn + Nginx (本番環境)


## 備考

- フロントエンドとはNext.jsを想定しており、別リポジトリで管理予定です。
- データベース設計やモデル構造の詳細は `/docs/schema/` に記載予定です。

---

最新更新：2025/06/12
