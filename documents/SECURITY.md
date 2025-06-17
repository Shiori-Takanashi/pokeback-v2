# セキュリティガイドライン

このプロジェクトにおけるセキュリティ上の重要事項とベストプラクティスをまとめています。

## 🔐 機密情報の管理

### 環境変数ファイル

1. **テンプレートファイル**: `.env.example`
   - 機密情報を含まないサンプル設定
   - Gitリポジトリにコミット済み

2. **実際の設定ファイル**: `.env.local`, `.env.docker`
   - 実際の機密情報を含む
   - `.gitignore`で除外済み（Gitにコミットされない）

### SECRET_KEY管理

```python
# 安全なSECRET_KEYの生成方法
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

## 🚫 やってはいけないこと

1. **機密情報をGitにコミット**
   ```bash
   # ❌ 危険
   git add .env.local
   git commit -m "Add local settings"
   ```

2. **ハードコードされたパスワード**
   ```python
   # ❌ 危険
   DATABASES = {
       'default': {
           'PASSWORD': 'mypassword123',  # ハードコード
       }
   }
   ```

3. **本番環境でDEBUG=True**
   ```python
   # ❌ 危険
   DEBUG = True  # 本番環境では絶対にFalse
   ```

## ✅ 推奨事項

### 開発環境

1. **環境変数ファイルの設定**
   ```bash
   # .env.exampleをコピー
   cp .env.example .env.local

   # 実際の値で編集
   nano .env.local
   ```

2. **強力なパスワード**
   - 最低12文字以上
   - 英数字 + 特殊文字の組み合わせ
   - 他のサービスと同じパスワードを使用しない

### 本番環境

1. **環境変数の使用**
   ```bash
   # システム環境変数として設定
   export DJANGO_SECRET_KEY="production-secret-key"
   export POSTGRES_PASSWORD="secure-production-password"
   ```

2. **シークレット管理サービス**
   - AWS Secrets Manager
   - Azure Key Vault
   - Google Secret Manager
   - HashiCorp Vault

## 🛡️ セキュリティチェックリスト

### 開発時
- [ ] `.env.*`ファイルがGitにコミットされていない
- [ ] 機密情報がソースコードにハードコードされていない
- [ ] 強力なパスワードを使用している
- [ ] SECRET_KEYが適切に生成されている

### デプロイ時
- [ ] `DEBUG=False`に設定
- [ ] `ALLOWED_HOSTS`が適切に設定
- [ ] HTTPS接続を強制
- [ ] セキュリティヘッダーが設定済み
- [ ] データベースアクセスが制限されている

## 📝 就活ポートフォリオとしての評価ポイント

### ✅ 良い点
1. **セキュリティ意識**: 機密情報の適切な管理
2. **ベストプラクティス**: 業界標準の手法を採用
3. **ドキュメント化**: セキュリティガイドラインの提供
4. **環境分離**: 開発・本番環境の適切な分離

### 🔍 アピールポイント
- 「セキュリティファーストの開発」
- 「機密情報管理のベストプラクティス実装」
- 「企業レベルのセキュリティ対策」
- 「セキュリティドキュメントの整備」

## 🎯 さらなる改善提案

1. **セキュリティテスト**
   ```bash
   # Django security checkの実行
   python manage.py check --deploy
   ```

2. **依存関係の脆弱性チェック**
   ```bash
   # pipの脆弱性チェック
   pip-audit
   ```

3. **定期的なセキュリティ更新**
   - 依存関係の定期更新
   - セキュリティパッチの適用

このガイドラインに従うことで、企業レベルのセキュリティ基準を満たすポートフォリオとなります。
