if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

if test -f ./custom.fish
    source ./custom.fish
end

function fish_greeting
    fastfetch --config fish-greetings
end

function fish_right_prompt
    if test $CMD_DURATION -lt 500
        return
    end

    set -l ms $CMD_DURATION
    set -l s (math -s0 "$ms / 1000 % 60")
    set -l m (math -s0 "$ms / 60000 % 60")
    set -l h (math -s0 "$ms / 3600000")

    set_color brblack

    if test $h -gt 0
        printf '%sh ' $h
    end
    if test $m -gt 0
        printf '%sm ' $m
    end
    if test $s -gt 0
        printf '%ss' $s
    end

    set_color normal
end

if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g EZA_FLAGS --color=always --group-directories-first --icons --git

alias ls="eza -al $EZA_FLAGS"
alias la="eza -a $EZA_FLAGS"
alias ll="eza -l $EZA_FLAGS"
alias lt="eza -aT $EZA_FLAGS"
alias l.="eza -d .* $EZA_FLAGS"

alias h="start-hyprland"

alias i="paru -S"
alias s="paru -Ss"
alias d="paru -Rns"
alias u="paru -Syu"

function m
    sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
    sudo reflector -c Russia -p https --age 12 --latest 10 --sort rate --number 5 --verbose --save /etc/pacman.d/mirrorlist
    and begin
        echo
        echo "Active mirrors:"
        grep '^Server' /etc/pacman.d/mirrorlist
    end
end
