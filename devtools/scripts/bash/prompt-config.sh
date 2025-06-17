# Prompt Configuration
# プロンプト設定ファイル
#
# このファイルを ~/.bashrc に追加することで、
# 起動時に自動的にお気に入りのプロンプトが設定されます

# デフォルトプロンプト設定 (お好みに変更してください)
DEFAULT_PROMPT_TYPE="simple"

# プロジェクトディレクトリでのプロンプト自動設定
if [[ "$PWD" == *"pokeback-v2"* ]]; then
    # プロジェクトディレクトリ内では自動的に設定
    case "$DEFAULT_PROMPT_TYPE" in
        "simple")
            export PS1="$ "
            ;;
        "minimal")
            export PS1="\W$ "
            ;;
        "git")
            # Git情報取得関数
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
            export PS1="\W\$(get_git_info)$ "
            ;;
    esac
fi

# プロンプト切り替えスクリプトのパスを設定
if [[ -f "scripts/prompt.sh" ]]; then
    alias load-prompts='source scripts/prompt.sh'
fi
