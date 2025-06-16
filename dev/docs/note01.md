# mv
`mv` は Unix/Linux 系OSにおいて「ファイルやディレクトリの移動」あるいは「名前の変更（リネーム）」を行うコマンドです。基本的な構文と用途は以下のとおりです。

---

## 基本構文

```bash
mv [オプション] <移動元> <移動先>
```

---

## 使用例

### 1. ファイルの移動（ディレクトリ間）

```bash
mv file.txt /path/to/target/
```

* `file.txt` を `/path/to/target/` ディレクトリに移動。
* 移動先に同名ファイルがあれば上書きされる（※警告なし）。

---

### 2. ファイルのリネーム

```bash
mv oldname.txt newname.txt
```

* ファイル `oldname.txt` を `newname.txt` に名前変更。
* 同一ディレクトリ内での操作。

---

### 3. ディレクトリの移動

```bash
mv dir1 /path/to/destination/
```

* `dir1` ディレクトリを `/path/to/destination/` に移動。

---

### 4. 複数ファイルを一括移動

```bash
mv file1.txt file2.txt /path/to/target/
```

* `file1.txt` と `file2.txt` を `/path/to/target/` に移動。

---

## よく使うオプション

| オプション | 意味                             |
| ----- | ------------------------------ |
| `-i`  | 上書き時に確認を求める（interactive）       |
| `-f`  | 上書き時に強制的に実行（force）             |
| `-n`  | 既存ファイルがある場合は上書きしない（no-clobber） |
| `-v`  | 処理を表示（verbose）                 |

---

## 注意点

* `mv` は移動元のファイルを**削除して移動**するため、コピー（`cp`）と異なり元データは残りません。
* 上書き防止のためには `-i` を付けるか、事前に存在確認を行うべきです。

---
