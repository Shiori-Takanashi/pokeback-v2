# Pokemon API v2 - セキュリティ構成詳細解説

## 概要

本プロジェクトでは、就活用ポートフォリオとして企業レベルのセキュリティ基準を満たすため、機密情報の適切な管理と多層防御のアプローチを採用している。

## 🔐 セキュリティアーキテクチャ

### 1. 環境変数ファイル階層構造

プロジェクトでは以下の3段階の環境設定ファイル管理を実装：

```
プロジェクトルート/
├── .env.example     # テンプレート（Git管理対象）
├── .env.local       # ローカル開発用（Git管理外）
├── .env.docker      # Docker環境用（Git管理外）
└── .env             # デフォルト（存在しない - .env.exampleを使用）
```

#### 1.1 読み込み優先順位（settings.py実装）

```python
env_files = [
    BASE_DIR / ".env.local",    # 最優先 - ローカル開発用
    BASE_DIR / ".env.docker",   # 次優先 - Docker環境用
    BASE_DIR / ".env",          # 最低優先 - デフォルト
]

for env_file in env_files:
    if env_file.exists():
        load_dotenv(env_file)
        break
```

この仕組みにより：
- 開発者は`.env.local`で個別設定可能
- Docker環境は`.env.docker`で統一設定
- どちらも存在しない場合はデフォルト値で動作

### 2. SECRET_KEY管理戦略

#### 2.1 多段階フォールバック機構

```python
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")
if not SECRET_KEY:
    if os.getenv("DEBUG") == "True":
        # 開発環境：安全なデフォルトキー
        SECRET_KEY = "django-insecure-dev-key-change-this-in-production"
    else:
        # 本番環境：エラーで停止
        raise RuntimeError("❌ DJANGO_SECRET_KEY環境変数が設定されていません")
```

#### 2.2 セキュリティレベル別対応

| 環境 | SECRET_KEY管理 | 動作 |
|------|----------------|------|
| 開発環境 | デフォルト値許可 | 警告表示して継続 |
| 本番環境 | 必須設定 | 未設定時はアプリ停止 |

### 3. Git管理戦略

#### 3.1 .gitignore設定

```gitignore
# 機密情報を含む可能性のあるファイルを完全除外
.env
.env.*          # すべての.env.xxxファイル
!.env.example   # テンプレートのみ例外的に許可
```

#### 3.2 現在のGit管理状況

```bash
# Git管理対象（安全）
.env.example          # 機密情報なしテンプレート

# Git管理外（機密情報保護）
.env.local           # 実際のローカル設定
.env.docker          # 実際のDocker設定
```

## 🛡️ セキュリティ実装詳細

### 1. 機密情報分離アーキテクチャ

#### 1.1 テンプレートファイル（.env.example）

```bash
# 安全なプレースホルダー値
DJANGO_SECRET_KEY=change-this-to-a-real-secret-key-in-production
POSTGRES_PASSWORD=your-secure-password
```

**特徴：**
- 実際の機密情報は含まない
- 設定項目の説明とセキュリティガイダンス付き
- Git管理対象として安全に公開可能

#### 1.2 実際の設定ファイル（.env.local/.env.docker）

```bash
# 実際の機密情報を含む（Git管理外）
DJANGO_SECRET_KEY=actual-50-character-random-secret-key-here
POSTGRES_PASSWORD=actual-strong-password-here
```

### 2. 本番環境セキュリティ機能

#### 2.1 本番環境検証機構

```python
# 本番環境でのセキュリティチェック
if not DEBUG:
    if SECRET_KEY == "django-insecure-dev-key-change-this-in-production":
        raise RuntimeError("❌ 本番環境でデフォルトSECRET_KEYは使用不可")
    if not ALLOWED_HOSTS:
        raise RuntimeError("❌ 本番環境ではALLOWED_HOSTSの設定が必須")
```

#### 2.2 Django標準セキュリティ設定

```python
MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",  # 静的ファイル配信
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",    # CSRF保護
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",  # XSS保護
]
```

### 3. Docker環境でのセキュリティ

#### 3.1 docker-compose.yml での機密情報管理

```yaml
# 環境変数での動的設定
environment:
  POSTGRES_USER: ${POSTGRES_USER:-dbuser}
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-CHANGE_THIS_PASSWORD}
```

**効果：**
- ハードコードされた機密情報なし
- 環境変数での動的設定
- デフォルト値で最低限の動作保証

#### 3.2 Dockerコンテナでのセキュリティ

```dockerfile
# 専用ユーザーでの実行
RUN useradd -m appuser
RUN chown -R appuser:appuser /app
USER appuser  # rootユーザーでの実行を回避
```

## 🔍 セキュリティ検証

### 1. Django標準セキュリティチェック

```bash
# セキュリティ課題の検出
python manage.py check --deploy
```

**主な検証項目：**
- SECRET_KEYの強度
- HTTPS設定
- セキュリティヘッダー
- クッキーセキュリティ
- CSRF保護

### 2. Git履歴でのセキュリティ確認

```bash
# 機密情報の誤コミット検証
git log --grep="password\|secret\|key" --oneline
git log -p | grep -i "password\|secret\|key"
```

### 3. ファイルアクセス権限

```bash
# 機密ファイルの権限確認
ls -la .env.*
# 推奨：600 (所有者のみ読み書き)
chmod 600 .env.local .env.docker
```

## 🏠 ローカル開発環境でのセキュリティ構成

### 1. 初回セットアップ手順

#### 1.1 環境ファイルの初期化

```bash
# プロジェクトクローン後の必須手順
cd pokeback-v2

# 1. テンプレートファイルから実際の設定ファイルを作成
cp .env.example .env.local

# 2. ファイル権限を制限（重要！）
chmod 600 .env.local
chmod 600 .env.docker  # 存在する場合

# 3. 機密情報の設定
nano .env.local  # または好きなエディタで編集
```

#### 1.2 必須の機密情報設定

```bash
# .env.local に以下を設定（実際の値を入力）
DJANGO_SECRET_KEY=<50文字以上のランダムな文字列>
POSTGRES_PASSWORD=<強力なパスワード>
POSTGRES_USER=<データベースユーザー名>
POSTGRES_DB=<データベース名>

# オプション：追加のセキュリティ設定
ALLOWED_HOSTS=localhost,127.0.0.1,0.0.0.0
DEBUG=True
```

#### 1.3 SECRET_KEY生成方法

```python
# Django shell でのSECRET_KEY生成
python manage.py shell
>>> from django.core.management.utils import get_random_secret_key
>>> print(get_random_secret_key())
# 出力された文字列を.env.localに設定

# または、Pythonでの直接生成
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

### 2. ローカル環境でのセキュリティ検証

#### 2.1 設定ファイルのセキュリティチェック

```bash
# 1. 環境変数の読み込み確認
python manage.py shell
>>> import os
>>> from django.conf import settings
>>> print(f"SECRET_KEY: {settings.SECRET_KEY[:10]}...")  # 最初の10文字のみ表示
>>> print(f"DEBUG: {settings.DEBUG}")
>>> print(f"ALLOWED_HOSTS: {settings.ALLOWED_HOSTS}")

# 2. セキュリティ設定の検証
python manage.py check --deploy
# 本番環境向けのセキュリティ警告を確認

# 3. ファイル権限の確認
ls -la .env.*
# -rw------- (600) が理想的
```

#### 2.2 機密情報の漏洩防止確認

```bash
# Git管理状況の確認
git status
# .env.local, .env.docker がUntracked filesに表示されることを確認

# .gitignoreの効果確認
git add .
git status
# .env.local, .env.docker が staged changesに含まれないことを確認

# 過去のコミット履歴での機密情報チェック
git log --oneline | head -10
git show <commit-hash> | grep -i "secret\|password\|key"
```

### 3. チーム開発でのセキュリティ協調

#### 3.1 新メンバーのオンボーディング

```markdown
# 新メンバー向けセキュリティチェックリスト

□ .env.example から .env.local を作成
□ 独自のSECRET_KEYを生成・設定
□ データベースパスワードを設定
□ ファイル権限を600に設定
□ git status で.env.localが管理外であることを確認
□ python manage.py check --deploy でセキュリティチェック実行
□ 初回コミット前に git add . && git status で機密情報が含まれないことを確認
```

#### 3.2 コードレビューでのセキュリティ観点

```bash
# プルリクエスト前のセルフチェック
# 1. 機密情報の誤コミット防止
git diff --cached | grep -i "password\|secret\|key\|token"

# 2. 新しい設定項目が.env.exampleに追加されているか確認
git diff --cached .env.example

# 3. 新しい機密情報が適切に環境変数化されているか確認
git diff --cached config/settings.py | grep -i "os.getenv\|env("
```

## 🔄 Git管理での機密情報の完全分離戦略

### 1. 段階的セキュリティアプローチ

#### レベル1: 基本的な分離
```gitignore
# 基本的な.gitignore設定
.env
.env.local
.env.production
```

#### レベル2: 包括的な除外（現在の実装）
```gitignore
# すべての.env系ファイルを除外
.env*
!.env.example  # テンプレートのみ例外
```

#### レベル3: パターンベース除外
```gitignore
# より広範囲な機密情報の除外
.env*
*.key
*.pem
secrets/
local_settings.py
```

### 2. Git Hooksを活用したセキュリティ強化

#### 2.1 pre-commit フックの設定

```bash
# .git/hooks/pre-commit ファイルを作成
#!/bin/bash
# 機密情報の誤コミット防止

# 1. 機密キーワードの検出
if git diff --cached --name-only | xargs grep -l "DJANGO_SECRET_KEY\|password.*=" 2>/dev/null; then
    echo "❌ エラー: 機密情報が含まれている可能性があります"
    echo "以下のファイルを確認してください:"
    git diff --cached --name-only | xargs grep -l "DJANGO_SECRET_KEY\|password.*=" 2>/dev/null
    exit 1
fi

# 2. .env ファイルの誤追加防止
if git diff --cached --name-only | grep -E "\.env$|\.env\.local$|\.env\.docker$" 2>/dev/null; then
    echo "❌ エラー: 機密設定ファイルがコミットに含まれています"
    echo "git reset HEAD <file> でステージングから除外してください"
    exit 1
fi

echo "✅ セキュリティチェック: 合格"
```

```bash
# フックファイルを実行可能にする
chmod +x .git/hooks/pre-commit
```

#### 2.2 commit-msg フックでのメッセージ検証

```bash
# .git/hooks/commit-msg ファイルを作成
#!/bin/bash
# コミットメッセージでの機密情報言及防止

commit_msg=$(cat "$1")

# 機密情報キーワードの検出
if echo "$commit_msg" | grep -iE "(password|secret|key|token)" >/dev/null; then
    echo "⚠️  警告: コミットメッセージに機密情報関連のキーワードが含まれています"
    echo "意図的でない場合は、メッセージを修正してください"
    echo "現在のメッセージ: $commit_msg"
    read -p "続行しますか？ (y/N): " confirm
    if [[ ! $confirm =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi
```

### 3. リポジトリレベルでのセキュリティ管理

#### 3.1 GitHub設定でのセキュリティ強化

```yaml
# .github/workflows/security-check.yml
name: Security Check
on: [push, pull_request]

jobs:
  security:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Check for secrets
      run: |
        # 機密情報の検出
        if grep -r "DJANGO_SECRET_KEY.*=" . --exclude-dir=.git; then
          echo "❌ 機密情報が検出されました"
          exit 1
        fi
        echo "✅ セキュリティチェック: 合格"
```

#### 3.2 ブランチ保護ルール

```json
{
  "protection": {
    "required_status_checks": {
      "contexts": ["security-check"]
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1
    }
  }
}
```

### 4. セキュリティインシデント対応

#### 4.1 機密情報の誤コミット時の対処法

```bash
# 機密情報が誤ってコミットされた場合の緊急対応

# 1. 最新コミットからの除去（まだプッシュしていない場合）
git reset --soft HEAD~1
git reset HEAD <機密ファイル>
git commit -m "Remove sensitive information"

# 2. 履歴からの完全除去（すでにプッシュしている場合）
git filter-branch --force --index-filter \
'git rm --cached --ignore-unmatch <機密ファイル>' \
--prune-empty --tag-name-filter cat -- --all

# 3. リモートリポジトリの強制更新
git push origin --force --all

# 4. 影響を受けた機密情報の無効化
# - SECRET_KEYの再生成
# - パスワードの変更
# - APIキーの再発行
```

#### 4.2 セキュリティ監査ログ

```bash
# 定期的なセキュリティ監査のためのコマンド集

# 1. Git履歴での機密情報検索
git log --all --source --grep="password" --grep="secret" --grep="key" -i

# 2. ファイル内容での機密情報検索
git log --all -S "password" -S "secret" -S "key" --oneline

# 3. コミット差分での機密情報確認
git log --all -p | grep -n -C 3 -i "password\|secret\|key"

# 4. 現在のリポジトリ状態確認
find . -name "*.env*" -not -path "./.git/*" | xargs ls -la
```

## 🎯 就活ポートフォリオとしての価値

### 1. 技術的アピールポイント

- **セキュリティファースト設計**: 機密情報を適切に分離
- **企業レベルの実装**: 実際の開発現場で使用される手法
- **包括的なドキュメント**: セキュリティガイドラインの整備
- **継続的改善**: セキュリティ成熟度の段階的向上

### 2. 面接での説明例

> 「このプロジェクトでは、企業レベルのセキュリティ基準を意識して設計しました。特に機密情報管理では、Git管理から完全に分離したテンプレート方式を採用し、開発環境と本番環境で異なるセキュリティレベルを実装しています。また、OWASP Top 10に対応したセキュリティ対策と、継続的なセキュリティ改善のためのフレームワークも整備しています。」

## 📋 実装されたセキュリティ機能の検証

### 1. 現在のプロジェクト状態確認

#### 1.1 ファイル管理状況

```bash
# 環境ファイルの存在確認
$ find . -name ".env*" -not -path "./.git/*"
./.env.example     # ✅ テンプレートファイル（Git管理対象）
./.env.local       # ✅ ローカル設定（Git管理外）
./.env.docker      # ✅ Docker設定（Git管理外）

# Git管理状況の確認
$ git ls-files | grep -E "\.env"
# 結果なし = .env.example のみが管理対象（正常）
```

#### 1.2 .gitignore設定の確認

```gitignore
# 機密情報保護設定（実装済み）
.env          # 基本の.envファイル
.env.*        # すべての.env.xxxファイル
!.env.example # テンプレートファイルのみ例外的に許可
```

**効果の確認:**
- ❌ `.env.local` → Git管理外（機密情報保護）
- ❌ `.env.docker` → Git管理外（機密情報保護）
- ✅ `.env.example` → Git管理対象（テンプレートとして安全）

### 2. セキュリティ設定の動作確認

#### 2.1 環境変数読み込み優先順位テスト

```python
# settings.py での実装確認
env_files = [
    BASE_DIR / ".env.local",    # 最優先
    BASE_DIR / ".env.docker",   # 次優先
    BASE_DIR / ".env",          # 最低優先
]

# 実際の動作テスト
$ python manage.py shell
>>> from django.conf import settings
>>> print("Environment loaded successfully")
>>> # SECRET_KEYが正しく読み込まれているか確認（値は表示しない）
>>> print(f"SECRET_KEY length: {len(settings.SECRET_KEY)}")
>>> print(f"DEBUG mode: {settings.DEBUG}")
```

#### 2.2 セキュリティ設定の本番準備確認

```bash
# 本番環境想定でのセキュリティチェック
$ DEBUG=False python manage.py check --deploy

# 期待される結果：
# ✅ SECRET_KEYの強度チェック
# ✅ HTTPS設定の確認
# ✅ セキュリティヘッダーの設定
# ⚠️ 本番環境特有の警告（ローカル環境では正常）
```

### 3. 実際の運用シナリオ

#### 3.1 新規開発者のプロジェクト参加手順

```bash
# 1. リポジトリクローン
git clone <repository-url>
cd pokeback-v2

# 2. 環境設定ファイルの準備
cp .env.example .env.local

# 3. セキュリティ設定
chmod 600 .env.local

# 4. 機密情報の設定（実際の値に変更）
nano .env.local
# DJANGO_SECRET_KEY=<新しく生成したキー>
# POSTGRES_PASSWORD=<安全なパスワード>

# 5. 設定の確認
python manage.py check
python manage.py check --deploy

# 6. Gitの状態確認（機密情報が含まれていないこと）
git status
# .env.local が Untracked files に表示される（正常）
```

#### 3.2 本番環境デプロイ時の手順

```bash
# 本番環境での環境変数設定例（AWS/Heroku/Dockerなど）
export DJANGO_SECRET_KEY="<本番用の強力なキー>"
export DJANGO_DEBUG="False"
export DJANGO_ALLOWED_HOSTS="your-domain.com,www.your-domain.com"
export POSTGRES_PASSWORD="<本番用の強力なパスワード>"

# 本番環境でのセキュリティチェック
python manage.py check --deploy --fail-level WARNING

# データベースマイグレーション（本番環境）
python manage.py migrate

# 静的ファイル収集（本番環境）
python manage.py collectstatic --noinput
```

### 4. セキュリティ監査とメンテナンス

#### 4.1 定期的なセキュリティチェック

```bash
# 月次セキュリティ監査チェックリスト

# 1. 依存関係の脆弱性チェック
pip audit

# 2. Django セキュリティアップデート確認
pip list --outdated | grep -i django

# 3. 機密情報の漏洩チェック
git log --all --source --grep="password\|secret\|key" -i --since="1 month ago"

# 4. ファイルアクセス権限の確認
find . -name ".env*" -exec ls -la {} \;

# 5. セキュリティ設定の確認
python manage.py check --deploy
```

#### 4.2 セキュリティインシデント対応手順

```markdown
# セキュリティインシデント対応プロセス

## Phase 1: 検知・分析
1. 異常な動作やアクセスの確認
2. ログファイルの詳細分析
3. 影響範囲の特定

## Phase 2: 封じ込め
1. 該当するサービス・機能の一時停止
2. 不正アクセスの遮断
3. 証拠の保全

## Phase 3: 除去・復旧
1. 脆弱性の修正
2. 機密情報の更新（パスワード、APIキーなど）
3. システムの段階的復旧

## Phase 4: 事後対応
1. インシデントレポートの作成
2. 再発防止策の実装
3. セキュリティポリシーの見直し
```

### 5. チーム開発でのセキュリティベストプラクティス

#### 5.1 コードレビューでのセキュリティチェックポイント

```markdown
# セキュリティレビューチェックリスト

## 設定関連
□ 新しい機密情報が適切に環境変数化されている
□ ハードコードされた機密情報がない
□ .env.example に新しい設定項目が追加されている

## コード品質
□ SQLインジェクション対策（ORM使用、パラメータ化クエリ）
□ XSS対策（適切なエスケープ処理）
□ CSRF保護の実装

## アクセス制御
□ 認証・認可の適切な実装
□ 管理者権限の適切な制限
□ APIエンドポイントのアクセス制御
```

#### 5.2 開発フローでのセキュリティ統合

```yaml
# CI/CDパイプラインでのセキュリティチェック例
name: Security Pipeline
on: [push, pull_request]

jobs:
  security-scan:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Python Security Check
      run: |
        pip install bandit
        bandit -r . -x tests/

    - name: Dependency Vulnerability Check
      run: |
        pip install safety
        safety check

    - name: Django Security Check
      run: |
        python manage.py check --deploy --fail-level WARNING

    - name: Secret Detection
      run: |
        git diff --name-only ${{ github.event.before }} ${{ github.sha }} | \
        xargs grep -l "password\|secret\|key" || true
```
