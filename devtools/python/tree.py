# tree.py
# 二〇二五年五月二十五日に作成

from pathlib import Path
from typing import Tuple, List, Optional, Set
import sys
from datetime import datetime


class Config:
    """除外設定を管理するクラス"""

    IGNORE_NAMES: Set[str] = {
        ".git",
        ".hg",
        ".svn",
        "__pycache__",
        ".mypy_cache",
        ".pytest_cache",
        ".coverage",
        "htmlcov",
        ".vscode",
        ".idea",
        ".DS_Store",
        "dist",
        "build",
        "coverage",
        "venv",
        "env",
        ".env",
        "node_modules",
        ".next",
    }

    IGNORE_PREFIXES: Set[str] = {
        "_",
        "legacy",
        "temp",
        "tmp",
        "test",
        "draft",
        "backup",
        "log",
        "old",
        "deprecated",
        "local",
        "private",
    }

    IGNORE_EXTENSIONS: Set[str] = {
        "log",
        "tmp",
        "bak",
        "swp",
        "swo",
        "orig",
        "lock",
        "cache",
        "pyc",
        "pyo",
        "db",
        "sqlite3",
        "png",
        "jpeg",
        "gif",
        "bmp",
        "tiff",
        "webp",
        "svg",
        "mp3",
        "wav",
        "ogg",
        "flac",
        "m4a",
        "aac",
        "mp4",
        "mov",
        "avi",
        "mkv",
        "webm",
        "ttf",
        "otf",
        "woff",
        "woff2",
        "eot",
        "zip",
        "tar",
        "gz",
        "bz2",
        "xz",
        "7z",
        "rar",
        "pdf",
        "doc",
        "docx",
        "xls",
        "xlsx",
        "ppt",
        "pptx",
        "ipynb",
    }


def is_ignored(path: Path) -> bool:
    for part in path.parts:
        if part in Config.IGNORE_NAMES:
            return True
        if any(part.startswith(prefix) for prefix in Config.IGNORE_PREFIXES):
            return True
    if path.is_file() and path.suffix:
        if path.suffix[1:] in Config.IGNORE_EXTENSIONS:
            return True
    return False


def collect_paths(project_root: Path) -> Tuple[List[Path], List[Path]]:
    dirs, files = [], []

    def walk(p: Path):
        if is_ignored(p):
            if p.is_dir():
                dirs.append(p)
            return

        if p.is_dir():
            dirs.append(p)
            if p.name in Config.IGNORE_NAMES:
                return
            for child in p.iterdir():
                walk(child)
        elif p.is_file():
            files.append(p)

    walk(project_root)
    # 根幹自体（ルート）は除外
    dirs = [d for d in dirs if d != project_root]
    files = [f for f in files if f != project_root]
    return dirs, files


def sort_by_depth_then_name(paths: List[Path], root: Path) -> List[Path]:
    return sorted(paths, key=lambda p: (len(p.relative_to(root).parts), str(p).lower()))


def write_result_file(
    project_name: str,
    result_file: Path,
    dirs: List[Path],
    files: List[Path],
    root: Path,
) -> Tuple[bool, Optional[str]]:
    try:
        dirs = sort_by_depth_then_name(dirs, root)
        files = sort_by_depth_then_name(files, root)

        with result_file.open("w", encoding="utf-8") as f:
            f.write("<PROJECT NAME>\n")
            f.write(f"{project_name}\n\n")

            f.write("[DIRS]\n")
            for d in dirs:
                f.write(f"../{d.relative_to(root)}\n")

            f.write("\n[FILES]\n")
            for file in files:
                f.write(f"../{file.relative_to(root)}\n")
        return True, None
    except Exception as e:
        return False, str(e)


def find_next_file_number(out_dir: Path) -> int:
    """既存ファイルから次の番号を決定"""
    existing_files = list(out_dir.glob(f"prj-*.txt"))
    if not existing_files:
        return 1

    numbers = []
    for file in existing_files:
        try:
            name_part = file.stem.replace(f"prj-", "")
            numbers.append(int(name_part))
        except ValueError:
            continue

    return max(numbers) + 1 if numbers else 1


def main() -> int:
    try:
        # 現在地から親ディレクトリ（pokeback-v2）を取得
        current_path = Path.cwd()
        project_root = current_path
        while (
            project_root.name != "pokeback-v2" and project_root.parent != project_root
        ):
            project_root = project_root.parent

        if project_root.name != "pokeback-v2":
            print("[ERROR] pokeback-v2 プロジェクトが見つかりません")
            return 1

        dirs, files = collect_paths(project_root)

        # 出力先ディレクトリ作成
        out_dir = project_root / "devtools" / "outs" / "trees"
        out_dir.mkdir(parents=True, exist_ok=True)

        # 次のファイル番号を決定
        file_number = find_next_file_number(out_dir)
        out_file = out_dir / f"prj-{file_number:02d}.txt"

        success, error = write_result_file("prj", out_file, dirs, files, project_root)

        if success:
            return 0
        else:
            print(f"失敗...\n{error}")
            return 1
    except Exception as e:
        print(f"予期せぬエラー: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
