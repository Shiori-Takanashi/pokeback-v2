from pathlib import Path
import os
import sys

from dotenv import load_dotenv

# ===================================================================
# 環境変数ファイルの読み込み
# ===================================================================
# 複数の環境設定ファイルに対応:
# 1. .env.local (ローカル開発用) - 最優先
# 2. .env.docker (Docker環境用)
# 3. .env (デフォルト)
# ===================================================================

BASE_DIR = Path(__file__).resolve().parent.parent

# 環境設定ファイルの優先順位で読み込み
env_files = [
    BASE_DIR / ".env.local",  # ローカル開発用（最優先）
    BASE_DIR / ".env.docker",  # Docker環境用
    BASE_DIR / ".env",  # デフォルト
]

for env_file in env_files:
    if env_file.exists():
        load_dotenv(env_file)
        if os.getenv("DEBUG") == "True":
            print(f"🔧 環境設定ファイルを読み込みました: {env_file.name}")
        break
else:
    # 環境変数ファイルが見つからない場合の警告
    print("⚠️  環境設定ファイルが見つかりません。デフォルト設定を使用します。")

# SECRET_KEYの設定（必須項目）
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")
if not SECRET_KEY:
    if os.getenv("DEBUG") == "True":
        # 開発環境用のデフォルトキー
        SECRET_KEY = "django-insecure-dev-key-change-this-in-production"
        print("🔑 開発用のデフォルトSECRET_KEYを使用中（本番環境では変更必須）")
    else:
        # 本番環境では必須
        raise RuntimeError("❌ DJANGO_SECRET_KEY環境変数が設定されていません")

# ===================================================================
# デバッグとセキュリティ設定
# ===================================================================

DEBUG = os.getenv("DJANGO_DEBUG", "False").lower() in ["true", "1", "yes", "on"]

# ALLOWED_HOSTSの設定
allowed_hosts_str = os.getenv("DJANGO_ALLOWED_HOSTS", "")
ALLOWED_HOSTS = [host.strip() for host in allowed_hosts_str.split(",") if host.strip()]

# 開発環境でのデフォルトホスト設定
if DEBUG and not ALLOWED_HOSTS:
    ALLOWED_HOSTS = ["localhost", "127.0.0.1", "0.0.0.0"]
    if os.getenv("DEBUG") == "True":
        print("🌐 開発環境用のデフォルトALLOWED_HOSTSを使用中")

# 本番環境でのセキュリティチェック
if not DEBUG:
    if SECRET_KEY == "django-insecure-dev-key-change-this-in-production":
        raise RuntimeError(
            "❌ 本番環境でデフォルトのSECRET_KEYを使用することはできません"
        )
    if not ALLOWED_HOSTS:
        raise RuntimeError("❌ 本番環境ではALLOWED_HOSTSの設定が必須です")

INSTALLED_APPS = [
    "django.contrib.admin",
    "django.contrib.auth",
    "django.contrib.contenttypes",
    "django.contrib.sessions",
    "django.contrib.messages",
    "django.contrib.staticfiles",
]

MIDDLEWARE = [
    "django.middleware.security.SecurityMiddleware",
    "whitenoise.middleware.WhiteNoiseMiddleware",
    "django.contrib.sessions.middleware.SessionMiddleware",
    "django.middleware.common.CommonMiddleware",
    "django.middleware.csrf.CsrfViewMiddleware",
    "django.contrib.auth.middleware.AuthenticationMiddleware",
    "django.contrib.messages.middleware.MessageMiddleware",
    "django.middleware.clickjacking.XFrameOptionsMiddleware",
]

ROOT_URLCONF = "config.urls"

TEMPLATES = [
    {
        "BACKEND": "django.template.backends.django.DjangoTemplates",
        "DIRS": [],
        "APP_DIRS": True,
        "OPTIONS": {
            "context_processors": [
                "django.template.context_processors.request",
                "django.contrib.auth.context_processors.auth",
                "django.contrib.messages.context_processors.messages",
            ],
        },
    },
]

WSGI_APPLICATION = "config.wsgi.application"

# ===================================================================
# データベース設定
# ===================================================================
# 優先順位:
# 1. DATABASE_URL (完全なURL形式)
# 2. 個別の環境変数 (POSTGRES_*)
# 3. デフォルト値 (ローカルPostgreSQL)
# ===================================================================

import dj_database_url

DATABASE_URL = os.getenv("DATABASE_URL")
if DATABASE_URL:
    # DATABASE_URLが設定されている場合（Docker環境など）
    DATABASES = {"default": dj_database_url.parse(DATABASE_URL)}
    if DEBUG:
        parsed_url = dj_database_url.parse(DATABASE_URL)
        print(f"🗄️  DATABASE_URLを使用: {parsed_url['NAME']}@{parsed_url['HOST']}")
else:
    # 個別の環境変数を使用（ローカル開発環境など）
    DATABASES = {
        "default": {
            "ENGINE": "django.db.backends.postgresql",
            "NAME": os.getenv("POSTGRES_DB", "pokeback_v2"),
            "USER": os.getenv("POSTGRES_USER", "shiori"),
            "PASSWORD": os.getenv("POSTGRES_PASSWORD", ""),
            "HOST": os.getenv("POSTGRES_HOST", "localhost"),
            "PORT": os.getenv("POSTGRES_PORT", "5432"),
        }
    }

    # ローカル環境でパスワードが設定されていない場合の警告
    if not DATABASES["default"]["PASSWORD"] and DEBUG:
        print("⚠️  PostgreSQLパスワードが設定されていません")
        print("💡 .env.localファイルにPOSTGRES_PASSWORDを設定してください")

    if DEBUG:
        db_config = DATABASES["default"]
        print(f"🗄️  PostgreSQL設定:")
        print(f"   データベース: {db_config['NAME']}")
        print(f"   ユーザー: {db_config['USER']}")
        print(f"   ホスト: {db_config['HOST']}:{db_config['PORT']}")

AUTH_PASSWORD_VALIDATORS = [
    {
        "NAME": "django.contrib.auth.password_validation.UserAttributeSimilarityValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.MinimumLengthValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.CommonPasswordValidator",
    },
    {
        "NAME": "django.contrib.auth.password_validation.NumericPasswordValidator",
    },
]

LANGUAGE_CODE = "ja"

TIME_ZONE = "Asia/Tokyo"

USE_I18N = True

USE_TZ = True

STATIC_URL = "/static/"
STATIC_ROOT = BASE_DIR / "staticfiles"

# WhiteNoiseを使用して静的ファイルを提供
STATICFILES_STORAGE = "whitenoise.storage.CompressedManifestStaticFilesStorage"

# 静的ファイルの収集用ディレクトリ
STATICFILES_DIRS = []
if (BASE_DIR / "static").exists():
    STATICFILES_DIRS.append(BASE_DIR / "static")

DEFAULT_AUTO_FIELD = "django.db.models.BigAutoField"
