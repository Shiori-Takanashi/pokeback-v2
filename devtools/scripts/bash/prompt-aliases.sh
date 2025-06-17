#!/bin/bash
# Prompt Switcher Aliases
# プロンプト切り替え用のエイリアス設定

# このファイルを ~/.bashrc に追加するか、以下をコピーして使用してください

# プロンプト切り替えエイリアス
alias ps-simple='source scripts/prompt.sh simple'
alias ps-minimal='source scripts/prompt.sh minimal'
alias ps-detailed='source scripts/prompt.sh detailed'
alias ps-git='source scripts/prompt.sh git'
alias ps-colorful='source scripts/prompt.sh colorful'
alias ps-default='source scripts/prompt.sh default'
alias ps-list='source scripts/prompt.sh list'
alias ps-current='source scripts/prompt.sh current'

# 短縮版エイリアス
alias pss='source scripts/prompt.sh simple'
alias psm='source scripts/prompt.sh minimal'
alias psd='source scripts/prompt.sh detailed'
alias psg='source scripts/prompt.sh git'
alias psc='source scripts/prompt.sh colorful'
alias psr='source scripts/prompt.sh reset'
alias psl='source scripts/prompt.sh list'

echo "プロンプト切り替えエイリアスが読み込まれました"
echo "使用例: pss (シンプル), psg (Git), psl (一覧表示)"
