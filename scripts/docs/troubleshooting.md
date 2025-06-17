# トラブルシューティングガイド

よくある問題とその解決方法について説明します。

## 🎯 概要

開発中に遭遇する可能性のある一般的な問題と、その解決策を体系的にまとめています。

## 🔧 プロンプト関連の問題

### プロンプトが変更されない

**症状**: `source scripts/prompt.sh simple` を実行してもプロンプトが変わらない

**原因と解決策**:

1. **sourceコマンドを使用していない**
   ```bash
   # ❌ 間違い
   ./scripts/prompt.sh simple
   bash scripts/prompt.sh simple

   # ✅ 正しい
   source scripts/prompt.sh simple
   ```

2. **スクリプトのパスが間違っている**
   ```bash
   # 現在のディレクトリを確認
   pwd
   ls scripts/prompt.sh

   # 正しいパスで実行
   source scripts/prompt.sh simple
   ```

3. **権限問題**
   ```bash
   # スクリプトを実行可能にする
   chmod +x scripts/prompt.sh
   ```

### Git情報が表示されない

**症状**: `psg` を実行してもGit情報（ブランチ名）が表示されない

**解決策**:

1. **Gitリポジトリ内にいることを確認**
   ```bash
   git status
   # "not a git repository" エラーが出る場合は、Gitリポジトリ外
   ```

2. **Git情報取得関数の再読み込み**
   ```bash
   source scripts/prompt.sh git
   ```

3. **手動でのGit情報確認**
   ```bash
   git branch --show-current
   git status --porcelain
   ```

### エイリアスが動作しない

**症状**: `pss`, `psg` などのエイリアスが認識されない

**解決策**:

1. **エイリアスを読み込み**
   ```bash
   source scripts/prompt-aliases.sh
   ```

2. **エイリアスの確認**
   ```bash
   alias | grep ps
   ```

3. **永続化**
   ```bash
   echo 'source /path/to/pokeback-v2/scripts/prompt-aliases.sh' >> ~/.bashrc
   ```

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
