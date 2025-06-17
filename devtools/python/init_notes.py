# ChatGPTアドバイス記録用スクリプト
#
# このスクリプトは、ChatGPTから得た技術的アドバイスやコマンドの内容を
# Obsidianで管理するための空ファイル（note01.md～note99.md）を作成します。
#
# - 本スクリプトはポートフォリオ本体とは無関係で、デプロイ対象には含めません（.gitignoreにて除外）
# - 例外処理は構文練習および構造テストのために残してあります

from pathlib import Path

dpath = Path(__file__).resolve().parent / "notes"

try:
    dpath.mkdir(exist_ok=True)  # check
except FileNotFoundError:
    print(f"階層を確認してください: {e}")
    print(dpath)
    raise

fpaths = [dpath / f"note{i:02d}.md" for i in range(1, 100)]

try:
    for fpath in fpaths:
        if not fpath.exists():
            fpath.write_text("", encoding="utf-8")
except FileNotFoundError as e:
    print("ファイルが存在しません。恐らく親ディレクトリがありません。")
    raise
except Exception as e:
    print("予期しないエラー: {e}")
    raise

# 確認用：CLI実行時の明示出力。ログではなく即時確認のためにprintを使用
print("作成完了")
