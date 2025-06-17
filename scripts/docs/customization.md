# カスタマイズガイド

スクリプトの拡張とカスタマイズ方法について説明します。

## 🎯 概要

このガイドでは、既存のスクリプトを改造したり、新しい機能を追加したりする方法を説明します。

## 🎨 プロンプトのカスタマイズ

### 新しいプロンプトスタイルの追加

`scripts/prompt.sh` に新しいプロンプト設定を追加する方法：

```bash
# scripts/prompt.sh に追加する関数
set_custom_prompt() {
    export PS1="[$(date +%H:%M)] \W$ "
    echo -e "${GREEN}✅ 時刻付きプロンプトに変更しました${NC}"
}

# main関数のcase文に追加
case "${1:-list}" in
    # ...existing cases...
    "time"|"t")
        set_custom_prompt
        ;;
    # ...
esac
```

### 条件付きプロンプト設定

環境や状況に応じて自動的にプロンプトを変更：

```bash
# プロジェクト別プロンプト
set_project_prompt() {
    local project_name=$(basename "$PWD")
    case "$project_name" in
        "pokeback-v2")
            export PS1="🐾 \W\$(get_git_info)$ "
            ;;
        "frontend-app")
            export PS1="⚛️  \W\$(get_git_info)$ "
            ;;
        *)
            export PS1="\W$ "
            ;;
    esac
}
```

### 高度なGit情報表示

Git情報をより詳細に表示：

```bash
get_advanced_git_info() {
    local git_info=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        local status=$(git status --porcelain 2>/dev/null)
        local ahead=$(git rev-list --count @{upstream}..HEAD 2>/dev/null)
        local behind=$(git rev-list --count HEAD..@{upstream} 2>/dev/null)

        git_info=" ($branch"

        # 未コミット変更
        if [[ -n "$status" ]]; then
            git_info+="*"
        fi

        # リモートとの差分
        if [[ -n "$ahead" && "$ahead" -gt 0 ]]; then
            git_info+="↑$ahead"
        fi
        if [[ -n "$behind" && "$behind" -gt 0 ]]; then
            git_info+="↓$behind"
        fi

        git_info+=")"
    fi
    echo "$git_info"
}
```

### カラーテーマのカスタマイズ

独自のカラーテーマを作成：

```bash
# カスタムカラー定義
ORANGE='\033[0;33m'
PINK='\033[1;35m'
GRAY='\033[0;37m'

set_custom_colorful_prompt() {
    export PS1="\[${ORANGE}\]\u\[${GRAY}\]@\[${PINK}\]\h\[${GRAY}\]:\[${BLUE}\]\W\[${PURPLE}\]\$(get_git_info)\[${NC}\]$ "
    echo -e "${GREEN}✅ カスタムカラープロンプトに変更しました${NC}"
}
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
