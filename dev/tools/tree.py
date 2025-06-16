# tree.py
# 二〇二五年五月二十五日に作成

from pathlib import Path
from typing import List, Set


class Config:
    """除外設定を管理する階級"""

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
        ".venv",
        "env",
        ".env",
        "node_modules",
        ".next",
        "json",
        "trash",
        "keys",
        "key",
        "monster",
        "pokemon",
        "species",
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

        # ユーザー指定の除外パターン
        for pattern in self.exclude_patterns:
            if pattern in name:
                return True

        # 隠しファイル・ディレクトリ（.で始まる）
        if name.startswith(".") and name not in {
            ".env.example",
            ".gitignore",
            ".dockerignore",
        }:
            return True

        return False

    def generate_tree(
        self, root_path: Path, prefix: str = "", current_depth: int = 0
    ) -> List[str]:
        """ディレクトリツリーを生成"""
        if self.max_depth is not None and current_depth >= self.max_depth:
            return []

        tree_lines = []

        try:
            # ディレクトリ内容を取得してソート
            items = sorted(
                [item for item in root_path.iterdir() if not self.should_exclude(item)],
                key=lambda x: (x.is_file(), x.name.lower()),
            )

            for i, item in enumerate(items):
                is_last = i == len(items) - 1

                # 現在のアイテムの表示
                current_prefix = "└── " if is_last else "├── "
                item_display = f"{prefix}{current_prefix}{item.name}"

                # ファイルサイズ情報を追加
                if item.is_file():
                    try:
                        size = item.stat().st_size
                        size_str = self.format_file_size(size)
                        item_display += f" ({size_str})"
                    except OSError:
                        pass

                tree_lines.append(item_display)

                # ディレクトリの場合は再帰的に処理
                if item.is_dir():
                    next_prefix = prefix + ("    " if is_last else "│   ")
                    subtree = self.generate_tree(item, next_prefix, current_depth + 1)
                    tree_lines.extend(subtree)

        except PermissionError:
            tree_lines.append(f"{prefix}[Permission Denied]")

        return tree_lines

    def format_file_size(self, size: int) -> str:
        """ファイルサイズを読みやすい形式でフォーマット"""
        for unit in ["B", "KB", "MB", "GB"]:
            if size < 1024.0:
                return f"{size:.1f}{unit}"
            size /= 1024.0
        return f"{size:.1f}TB"

    def print_tree(self, root_path: Path):
        """ディレクトリツリーを出力"""
        print(f"\n📁 {root_path.absolute()}")
        print("=" * 50)

        tree_lines = self.generate_tree(root_path)

        if not tree_lines:
            print("(Empty directory or all files excluded)")
        else:
            for line in tree_lines:
                print(line)

        # 統計情報
        total_files = sum(1 for line in tree_lines if not line.strip().endswith("/"))
        total_dirs = sum(1 for line in tree_lines if line.strip().endswith("/"))

        print(f"\n📊 統計: {total_dirs} directories, {total_files} files")


def main():
    """メイン関数"""
    parser = argparse.ArgumentParser(
        description="ディレクトリ構造を視覚的に表示します",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
使用例:
  %(prog)s                          # 現在のディレクトリを表示
  %(prog)s /path/to/directory       # 指定ディレクトリを表示
  %(prog)s --max-depth 2            # 最大深度2まで表示
  %(prog)s --exclude "*.tmp"        # 特定パターンを除外
  %(prog)s --include-hidden         # 隠しファイルも表示
        """,
    )

    parser.add_argument(
        "directory",
        nargs="?",
        default=".",
        help="表示するディレクトリのパス (デフォルト: 現在のディレクトリ)",
    )

    parser.add_argument("--max-depth", "-d", type=int, help="表示する最大深度")

    parser.add_argument(
        "--exclude",
        "-e",
        action="append",
        default=[],
        help="除外するファイル/ディレクトリのパターン (複数指定可能)",
    )

    parser.add_argument(
        "--include-hidden",
        action="store_true",
        help="隠しファイル・ディレクトリも表示する",
    )

    args = parser.parse_args()

    # ディレクトリパスの検証
    root_path = Path(args.directory).resolve()
    if not root_path.exists():
        print(f"❌ エラー: ディレクトリが存在しません: {root_path}", file=sys.stderr)
        sys.exit(1)

    if not root_path.is_dir():
        print(
            f"❌ エラー: 指定されたパスはディレクトリではありません: {root_path}",
            file=sys.stderr,
        )
        sys.exit(1)

    # ツリージェネレータの作成
    tree = DirectoryTree(max_depth=args.max_depth, exclude_patterns=args.exclude)

    # 隠しファイル表示オプション
    if args.include_hidden:
        tree.default_excludes = {
            pattern for pattern in tree.default_excludes if not pattern.startswith(".")
        }

    try:
        tree.print_tree(root_path)
    except KeyboardInterrupt:
        print("\n\n⚠️ 処理が中断されました")
        sys.exit(1)
    except Exception as e:
        print(f"予期せぬ過誤が発生しました: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())
