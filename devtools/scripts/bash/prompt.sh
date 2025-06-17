#!/bin/bash
"""
Terminal Prompt Switcher
ターミナルプロンプト切り替えスクリプト

使用方法:
    source scripts/prompt.sh simple     # シンプルなプロンプト
    source scripts/prompt.sh detailed   # 詳細なプロンプト
    source scripts/prompt.sh git        # Git情報付きプロンプト
    source scripts/prompt.sh reset      # デフォルトに戻す
    source scripts/prompt.sh list       # 利用可能なプロンプト一覧
"""

# 色の定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Git情報を取得する関数
get_git_info() {
    local git_status=""
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null)
        local status=$(git status --porcelain 2>/dev/null)

        if [[ -n "$status" ]]; then
            git_status=" (${branch}*)"
        else
            git_status=" (${branch})"
        fi
    fi
    echo "$git_status"
}

# プロンプト設定関数
set_simple_prompt() {
    export PS1="$ "
    echo -e "${GREEN}✅ シンプルプロンプトに変更しました${NC}"
}

set_minimal_prompt() {
    export PS1="\W$ "
    echo -e "${GREEN}✅ ミニマルプロンプト（ディレクトリ名のみ）に変更しました${NC}"
}

set_detailed_prompt() {
    export PS1="\u@\h:\W$ "
    echo -e "${GREEN}✅ 詳細プロンプト（ユーザー@ホスト:ディレクトリ）に変更しました${NC}"
}

set_git_prompt() {
    export PS1="\W\$(get_git_info)$ "
    echo -e "${GREEN}✅ Git情報付きプロンプトに変更しました${NC}"
}

set_colorful_prompt() {
    export PS1="\[${BLUE}\]\W\[${PURPLE}\]\$(get_git_info)\[${NC}\]$ "
    echo -e "${GREEN}✅ カラフルプロンプトに変更しました${NC}"
}

set_default_prompt() {
    export PS1="\u@\h:\w$ "
    echo -e "${GREEN}✅ デフォルトプロンプトに戻しました${NC}"
}

show_prompt_list() {
    echo -e "${CYAN}利用可能なプロンプト設定:${NC}"
    echo ""
    echo -e "${YELLOW}simple${NC}    - シンプル: $ "
    echo -e "${YELLOW}minimal${NC}   - ミニマル: ディレクトリ名$ "
    echo -e "${YELLOW}detailed${NC}  - 詳細: ユーザー@ホスト:ディレクトリ$ "
    echo -e "${YELLOW}git${NC}       - Git情報付き: ディレクトリ(ブランチ)$ "
    echo -e "${YELLOW}colorful${NC}  - カラフル: 色付きGit情報"
    echo -e "${YELLOW}default${NC}   - デフォルト: フルパス表示"
    echo -e "${YELLOW}reset${NC}     - デフォルトに戻す"
    echo ""
    echo -e "${CYAN}使用方法:${NC} source scripts/prompt.sh [オプション]"
    echo -e "${CYAN}例:${NC} source scripts/prompt.sh simple"
}

show_current_prompt() {
    echo -e "${CYAN}現在のプロンプト設定:${NC} $PS1"
}

# メイン処理
main() {
    case "${1:-list}" in
        "simple"|"s")
            set_simple_prompt
            ;;
        "minimal"|"m")
            set_minimal_prompt
            ;;
        "detailed"|"d")
            set_detailed_prompt
            ;;
        "git"|"g")
            set_git_prompt
            ;;
        "colorful"|"c")
            set_colorful_prompt
            ;;
        "default"|"reset"|"r")
            set_default_prompt
            ;;
        "list"|"l"|"help"|"h")
            show_prompt_list
            ;;
        "current"|"status")
            show_current_prompt
            ;;
        *)
            echo -e "${RED}❌ 不明なオプション: $1${NC}"
            echo ""
            show_prompt_list
            return 1
            ;;
    esac
}

# スクリプトが直接実行された場合の警告
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    echo -e "${RED}❌ このスクリプトは source コマンドで実行してください${NC}"
    echo -e "${YELLOW}正しい使用方法:${NC} source scripts/prompt.sh [オプション]"
    echo ""
    show_prompt_list
    exit 1
fi

# メイン処理を実行
main "$@"
