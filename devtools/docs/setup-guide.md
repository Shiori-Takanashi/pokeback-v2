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

## ⚙️ セットアップスクリプトの拡張

### 新しいサービスの追加

Redis、Elasticsearch など新しいサービスを自動セットアップ：

```bash
# scripts/setup-redis.sh
#!/bin/bash
setup_redis() {
    echo "🔄 Redis のセットアップを開始..."

    # Redis インストール確認
    if ! command -v redis-server &> /dev/null; then
        echo "📦 Redis をインストール中..."
        sudo apt-get update
        sudo apt-get install -y redis-server
    fi

    # Redis 起動
    sudo systemctl start redis-server
    sudo systemctl enable redis-server

    # 接続テスト
    if redis-cli ping | grep -q "PONG"; then
        echo "✅ Redis セットアップ完了"
    else
        echo "❌ Redis セットアップ失敗"
        exit 1
    fi
}
```

### 環境別設定の自動化

開発・ステージング・本番環境の自動切り替え：

```bash
# scripts/setup-environment.sh
#!/bin/bash
setup_environment() {
    local env_type="$1"

    case "$env_type" in
        "development"|"dev")
            setup_dev_environment
            ;;
        "staging"|"stage")
            setup_staging_environment
            ;;
        "production"|"prod")
            setup_production_environment
            ;;
        *)
            echo "使用方法: $0 [dev|stage|prod]"
            exit 1
            ;;
    esac
}

setup_dev_environment() {
    cp .env.example .env.local
    echo "DEBUG=True" >> .env.local
    echo "DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1" >> .env.local
}

setup_production_environment() {
    echo "⚠️  本番環境設定では手動での機密情報設定が必要です"
    cp .env.example .env.production
    echo "DEBUG=False" >> .env.production
    echo "DJANGO_ALLOWED_HOSTS=yourdomain.com" >> .env.production
}
```

## 🐳 Docker環境の拡張

### 新しいサービスの追加

`docker-compose.yml` に新しいサービスを追加：

```yaml
# docker-compose.yml に追加
services:
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

  elasticsearch:
    image: elasticsearch:8.8.0
    environment:
      - discovery.type=single-node
      - "ES_JAVA_OPTS=-Xms512m -Xmx512m"
    ports:
      - "9200:9200"
    volumes:
      - elasticsearch_data:/usr/share/elasticsearch/data

volumes:
  redis_data:
  elasticsearch_data:
```

### カスタムDockerスクリプト

特定の用途に特化したDockerスクリプト：

```bash
# scripts/docker-dev-tools.sh
#!/bin/bash
start_dev_tools() {
    echo "🛠️  開発ツールを起動中..."

    # データベースとキャッシュのみ起動
    docker-compose up -d db redis

    # ログ監視ツール起動
    docker-compose logs -f db redis &

    echo "✅ 開発ツール起動完了"
}

reset_dev_environment() {
    echo "🔄 開発環境をリセット中..."

    # 全コンテナ停止・削除
    docker-compose down -v

    # イメージ再ビルド
    docker-compose build --no-cache

    # データベース初期化
    docker-compose up -d db
    sleep 5
    docker-compose exec db psql -U postgres -c "DROP DATABASE IF EXISTS pokeback_v2;"
    docker-compose exec db psql -U postgres -c "CREATE DATABASE pokeback_v2;"

    echo "✅ 開発環境リセット完了"
}
```

## 🔧 ユーティリティスクリプトの作成

### ログ解析スクリプト

```bash
# scripts/analyze-logs.sh
#!/bin/bash
analyze_logs() {
    local log_file="$1"
    local timeframe="${2:-24h}"

    echo "📊 ログ解析結果 (過去 $timeframe)"
    echo "================================"

    # エラー数
    echo "🔴 エラー数:"
    grep -c "ERROR" "$log_file" || echo "0"

    # 警告数
    echo "⚠️  警告数:"
    grep -c "WARNING" "$log_file" || echo "0"

    # アクセス数（時間別）
    echo "📈 時間別アクセス数:"
    grep "GET\|POST" "$log_file" | \
    cut -d' ' -f4 | cut -d':' -f2 | \
    sort | uniq -c | sort -nr
}
```

### データベースバックアップスクリプト

```bash
# scripts/backup-database.sh
#!/bin/bash
backup_database() {
    local backup_dir="./backups"
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file="$backup_dir/pokeback_v2_$timestamp.sql"

    mkdir -p "$backup_dir"

    echo "💾 データベースバックアップを作成中..."

    if pg_dump -h localhost -U "$POSTGRES_USER" -d "$POSTGRES_DB" > "$backup_file"; then
        echo "✅ バックアップ完了: $backup_file"

        # 古いバックアップを削除（7日以上前）
        find "$backup_dir" -name "*.sql" -mtime +7 -delete
    else
        echo "❌ バックアップ失敗"
        exit 1
    fi
}
```

## 🎛️ 設定管理の高度化

### 設定ファイルテンプレートシステム

```bash
# scripts/generate-config.sh
#!/bin/bash
generate_config() {
    local template_file="$1"
    local output_file="$2"
    local env_type="$3"

    # テンプレート変数を実際の値に置換
    sed -e "s/{{ENV_TYPE}}/$env_type/g" \
        -e "s/{{SECRET_KEY}}/$(generate_secret_key)/g" \
        -e "s/{{DB_PASSWORD}}/$(generate_password)/g" \
        "$template_file" > "$output_file"

    chmod 600 "$output_file"
    echo "✅ 設定ファイル生成完了: $output_file"
}

generate_secret_key() {
    python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
}

generate_password() {
    openssl rand -base64 32
}
```

### 環境変数バリデーション

```bash
# scripts/validate-environment.sh
#!/bin/bash
validate_environment() {
    local env_file="$1"
    local errors=0

    echo "🔍 環境設定を検証中..."

    # 必須変数のチェック
    required_vars=(
        "DJANGO_SECRET_KEY"
        "POSTGRES_DB"
        "POSTGRES_USER"
        "POSTGRES_PASSWORD"
    )

    for var in "${required_vars[@]}"; do
        if ! grep -q "^$var=" "$env_file"; then
            echo "❌ 必須変数が未設定: $var"
            ((errors++))
        fi
    done

    # SECRET_KEYの強度チェック
    local secret_key=$(grep "^DJANGO_SECRET_KEY=" "$env_file" | cut -d'=' -f2)
    if [[ ${#secret_key} -lt 50 ]]; then
        echo "⚠️  SECRET_KEYが短すぎます (推奨: 50文字以上)"
        ((errors++))
    fi

    if [[ $errors -eq 0 ]]; then
        echo "✅ 環境設定は正常です"
    else
        echo "❌ $errors 個の問題が見つかりました"
        exit 1
    fi
}
```

## 📱 モバイル・レスポンシブ対応

### 画面サイズ別プロンプト

```bash
get_terminal_width() {
    tput cols 2>/dev/null || echo 80
}

set_responsive_prompt() {
    local width=$(get_terminal_width)

    if [[ $width -lt 60 ]]; then
        # 狭い画面：最小限の情報
        export PS1="$ "
    elif [[ $width -lt 100 ]]; then
        # 中程度の画面：ディレクトリ名とGit情報
        export PS1="\W\$(get_git_info)$ "
    else
        # 広い画面：詳細情報
        export PS1="\u@\h:\W\$(get_git_info)$ "
    fi
}
```

## 🧪 テスト自動化

### スクリプトのテストフレームワーク

```bash
# scripts/test-scripts.sh
#!/bin/bash
test_prompt_switching() {
    echo "🧪 プロンプト切り替えテスト"

    # バックアップ
    local original_ps1="$PS1"

    # テスト実行
    source scripts/prompt.sh simple
    if [[ "$PS1" == "$ " ]]; then
        echo "✅ simple プロンプトテスト合格"
    else
        echo "❌ simple プロンプトテスト失敗"
    fi

    # 復元
    export PS1="$original_ps1"
}

test_database_connection() {
    echo "🧪 データベース接続テスト"

    if python manage.py dbshell -c "\q" 2>/dev/null; then
        echo "✅ データベース接続テスト合格"
    else
        echo "❌ データベース接続テスト失敗"
    fi
}

run_all_tests() {
    test_prompt_switching
    test_database_connection
    echo "🎯 全テスト完了"
}
```

## 📊 監視・分析機能

### パフォーマンス監視

```bash
# scripts/monitor-performance.sh
#!/bin/bash
monitor_system() {
    echo "📊 システム監視 $(date)"
    echo "=========================="

    # CPU使用率
    echo "🔥 CPU使用率:"
    top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1

    # メモリ使用量
    echo "💾 メモリ使用量:"
    free -h | grep "Mem:" | awk '{print $3 "/" $2}'

    # ディスク使用量
    echo "💿 ディスク使用量:"
    df -h / | tail -1 | awk '{print $5}'

    # データベース接続数
    echo "🗃️  データベース接続数:"
    python manage.py dbshell -c "SELECT count(*) FROM pg_stat_activity;" 2>/dev/null || echo "取得失敗"
}
```

これらのカスタマイズ例を参考に、プロジェクトの特定のニーズに合わせてスクリプトを拡張してください。


## 📝 次のステップ

セットアップが完了したら：

1. [プロンプト切り替えガイド](prompt-guide.md) でターミナルをカスタマイズ
2. [カスタマイズガイド](customization.md) で開発環境を最適化
3. 実際の開発作業を開始

## 💡 Tips

- **初回セットアップ時**: 全てのスクリプトを順番に実行することを推奨
- **日常の開発**: `run-local.sh` または `docker-compose-run.sh` のみで十分
- **新しいチームメンバー**: このガイドを共有してスムーズなオンボーディングを実現


# トラブルシューディング

## 🗃️ データベース関連の問題

### PostgreSQL接続エラー

**症状**: `FATAL: database "pokeback_v2" does not exist`

**解決策**:

1. **データベースの存在確認**
   ```bash
   sudo -u postgres psql -l | grep pokeback
   ```

2. **データベース作成**
   ```bash
   ./scripts/setup-postgres.sh
   # または手動で作成
   sudo -u postgres createdb pokeback_v2
   ```

3. **接続設定確認**
   ```bash
   # .env.local の設定を確認
   cat .env.local | grep POSTGRES
   ```

### データベース認証エラー

**症状**: `FATAL: password authentication failed for user`

**解決策**:

1. **パスワード確認**
   ```bash
   # .env.local のパスワード設定を確認
   grep POSTGRES_PASSWORD .env.local
   ```

2. **ユーザー権限の再設定**
   ```bash
   sudo -u postgres psql
   ALTER USER your_username PASSWORD 'new_password';
   \q
   ```

3. **PostgreSQL設定確認**
   ```bash
   # pg_hba.conf の設定確認（専門知識が必要）
   sudo cat /etc/postgresql/*/main/pg_hba.conf | grep local
   ```

### マイグレーションエラー

**症状**: `django.db.utils.ProgrammingError: relation does not exist`

**解決策**:

1. **マイグレーションファイルの確認**
   ```bash
   python manage.py showmigrations
   ```

2. **マイグレーションの実行**
   ```bash
   python manage.py makemigrations
   python manage.py migrate
   ```

3. **データベースリセット（最終手段）**
   ```bash
   # ⚠️ データが削除されます
   python manage.py flush
   python manage.py migrate
   ```

## 🐳 Docker関連の問題

### Docker Compose起動エラー

**症状**: `ERROR: Couldn't connect to Docker daemon`

**解決策**:

1. **Dockerサービス確認**
   ```bash
   sudo systemctl status docker
   sudo systemctl start docker
   ```

2. **ユーザー権限確認**
   ```bash
   # Dockerグループに追加
   sudo usermod -aG docker $USER
   # ログアウト・ログインが必要
   ```

3. **Docker Composeファイル確認**
   ```bash
   docker-compose config
   ```

### コンテナ内部での接続エラー

**症状**: Dockerコンテナ内からデータベースに接続できない

**解決策**:

1. **ネットワーク確認**
   ```bash
   docker-compose ps
   docker network ls
   ```

2. **環境変数確認**
   ```bash
   docker-compose exec web env | grep POSTGRES
   ```

3. **サービス間通信テスト**
   ```bash
   docker-compose exec web ping db
   ```

### ポート競合エラー

**症状**: `ERROR: for web Cannot start service web: Ports are not available`

**解決策**:

1. **使用中のポート確認**
   ```bash
   sudo netstat -tulpn | grep :8000
   sudo lsof -i :8000
   ```

2. **プロセス終了**
   ```bash
   # 該当プロセスを終了
   sudo kill -9 <PID>
   ```

3. **別ポートの使用**
   ```bash
   # docker-compose.yml でポート変更
   ports:
     - "8001:8000"  # 8001ポートを使用
   ```

## ⚙️ Django関連の問題

### SECRET_KEYエラー

**症状**: `RuntimeError: DJANGO_SECRET_KEY環境変数が設定されていません`

**解決策**:

1. **環境変数確認**
   ```bash
   echo $DJANGO_SECRET_KEY
   ```

2. **SECRET_KEY生成**
   ```bash
   python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
   ```

3. **.env.local に設定**
   ```bash
   echo 'DJANGO_SECRET_KEY=your-generated-key' >> .env.local
   ```

### 静的ファイルエラー

**症状**: CSS/JSファイルが読み込まれない

**解決策**:

1. **静的ファイル設定確認**
   ```bash
   python manage.py findstatic admin/css/base.css
   ```

2. **静的ファイル収集**
   ```bash
   python manage.py collectstatic
   ```

3. **開発サーバーでの静的ファイル配信確認**
   ```bash
   # settings.py でDEBUG=Trueであることを確認
   ```

## 🔐 セキュリティ関連の問題

### 環境変数の漏洩

**症状**: Git履歴に機密情報がコミットされている

**解決策**:

1. **即座の対応**
   ```bash
   # 最新コミットから除去（まだプッシュしていない場合）
   git reset --soft HEAD~1
   git reset HEAD .env.local
   git commit -m "Remove sensitive information"
   ```

2. **履歴からの完全除去**
   ```bash
   # ⚠️ 注意: リモートリポジトリを破壊的に変更
   git filter-branch --force --index-filter \
   'git rm --cached --ignore-unmatch .env.local' \
   --prune-empty --tag-name-filter cat -- --all
   ```

3. **機密情報の無効化**
   ```bash
   # SECRET_KEYの再生成
   # パスワードの変更
   # APIキーの再発行
   ```

### ファイル権限問題

**症状**: 機密ファイルが他のユーザーから読み取り可能

**解決策**:

```bash
# 適切な権限設定
chmod 600 .env.local .env.docker
chmod 755 scripts/*.sh

# 権限確認
ls -la .env.*
ls -la scripts/
```

## 🌐 ネットワーク関連の問題

### ポート8000でアクセスできない

**症状**: ブラウザで `localhost:8000` にアクセスできない

**解決策**:

1. **サーバー起動確認**
   ```bash
   # プロセス確認
   ps aux | grep python
   ps aux | grep runserver
   ```

2. **ポート確認**
   ```bash
   netstat -tulpn | grep :8000
   ```

3. **ファイアウォール確認**
   ```bash
   # Ubuntu/Debian
   sudo ufw status
   sudo ufw allow 8000
   ```

4. **ALLOWED_HOSTS設定**
   ```bash
   # .env.local で設定確認
   grep ALLOWED_HOSTS .env.local
   ```

## 📋 一般的なチェックリスト

問題が発生した場合、以下を順番に確認：

### 1. 環境確認
- [ ] 正しいディレクトリにいる
- [ ] 必要なファイルが存在する
- [ ] 権限が適切に設定されている

### 2. 設定確認
- [ ] 環境変数が正しく設定されている
- [ ] データベース接続情報が正確
- [ ] SECRET_KEYが設定されている

### 3. サービス確認
- [ ] PostgreSQLが起動している
- [ ] Dockerサービスが動作している
- [ ] 必要なポートが利用可能

### 4. ログ確認
- [ ] エラーメッセージを詳細に読む
- [ ] Django開発サーバーのログ
- [ ] Dockerコンテナのログ

## 🆘 追加サポート

上記で解決しない場合：

1. **詳細なエラーログを収集**
   ```bash
   python manage.py runserver 2>&1 | tee debug.log
   ```

2. **システム情報の確認**
   ```bash
   python --version
   psql --version
   docker --version
   ```

3. **設定の確認**
   ```bash
   python manage.py diffsettings
   ```

これらの情報を含めて、チームメンバーや技術サポートに相談してください。
