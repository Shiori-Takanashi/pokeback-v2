

---

> ## ステップ0：前提

* OS：Linux または WSL（Windows Subsystem for Linux）
* Django プロジェクトは既に作成済みと仮定（なければ `django-admin startproject` から開始）
* `.env` ファイルを使う or 使わない、どちらも説明します

---

> ## ステップ1：ランダムな SECRET\_KEY を生成

まず、安全な鍵を作成：

```bash
python -c "import secrets; print(secrets.token_urlsafe(50))"
```

出力された鍵を控えておく。例：

```
WaKzNYyJp1uRAnoN1UpXvd6eZXZEFWz_RsmUw8dAe1qKV6LHTi
```

---

> ## ステップ2：環境変数を設定

### 方法A：**一時的に export する（シェルセッション限定）**

```bash
export DJANGO_SECRET_KEY="WaKzNYyJp1uRAnoN1UpXvd6eZXZEFWz_RsmUw8dAe1qKV6LHTi"
```

※ この環境変数は「現在のターミナルセッションでのみ有効」。再起動すると消える。

---

### 方法B：**`.env` ファイルを使う（推奨）**

#### 1. プロジェクトルートに `.env` ファイルを作成：

```
DJANGO_SECRET_KEY=WaKzNYyJp1uRAnoN1UpXvd6eZXZEFWz_RsmUw8dAe1qKV6LHTi
```

#### 2. `.gitignore` に追記：

```
.env
```

#### 3. `python-dotenv` を導入：

```bash
pip install python-dotenv
```

#### 4. `settings.py` の先頭付近に追加：

```python
import os
from dotenv import load_dotenv
load_dotenv()  # .env ファイルを読み込む

SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")
if not SECRET_KEY:
    raise RuntimeError("SECRET_KEY が環境変数に設定されていません")
```

---

> ## ステップ3：Django を起動して確認

```bash
python manage.py runserver
```

* エラーが出なければ環境変数の読み込み成功。
* `SECRET_KEY` を出力して確認する場合（本番では絶対やらない）：

```python
print(f"SECRET_KEY = {SECRET_KEY}")
```

---

> ## ステップ4：セッション跨ぎでも有効にしたい場合（永続化）

### `.bashrc` or `.zshrc` に追記（非推奨ではないが、.envの方が便利）

```bash
export DJANGO_SECRET_KEY=WaKzNY...
```

その後：

```bash
source ~/.bashrc  # or ~/.zshrc
```

---

> ## ステップ5：Django 側で保険をかける

```python
SECRET_KEY = os.getenv("DJANGO_SECRET_KEY")
if not SECRET_KEY:
    from django.core.management.utils import get_random_secret_key
    print("警告: 開発用の鍵を自動生成して使用しています")
    SECRET_KEY = get_random_secret_key()
```

---

> ## 練習のまとめ

* 本番と同じ運用思想で `os.getenv()` を使うことで、**後でCI/CDに載せるときにもそのまま適用可能**。
* `.env` ファイルと `python-dotenv` の組み合わせは、開発練習に最適。
* 読み込みに失敗したときの代替処理（例：ランダム鍵の生成）も練習しておくと良い。

---

必要があれば `.env` の複数環境対応（開発/本番）や `systemd` 経由での注入方法も対応可能です。
