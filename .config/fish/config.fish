source /usr/share/cachyos-fish-config/cachyos-config.fish

# --- Terminal Rice ---
function fish_greeting
    if not set -q FETCH_DONE
        clear
        # Layout now lives in ~/.config/fastfetch/config.jsonc
        # (compact: 68 cols wide instead of 125, so it survives a window resize)
        fastfetch
        
        set -gx FETCH_DONE 1
    end
end

# Starship/Zoxide Setup
# starship init fish | source
zoxide init fish | source

# Productivity Aliases
alias ls="eza --icons --group-directories-first"
alias ll="eza -lh --icons --group-directories-first"
alias la="eza -a --icons --group-directories-first"
alias tree="eza --tree --icons"
alias cat="bat"
alias rm="trash-put"
alias cd="z"
alias zj="zellij"
alias note="micro ~/Notes/terminal_notes.md"

# Auto-attach to zellij session.
# The session name matters: an unnamed `zellij attach -c` grabs whichever
# session was most recent, so Mod+T would hijack the Mod+V dashboard and
# mirror btop/cava instead of giving you a shell. Naming it pins Mod+T to
# "main" and leaves the dashboard session alone.
# Want a bare shell on Mod+T instead? Comment out this whole block.
if status is-interactive
    if not set -q ZELLIJ; and not set -q NO_ZELLIJ
        zellij attach -c main
    end
end

# uv
fish_add_path "/home/winter/.local/bin"
export PATH="$(npm config get prefix)/bin:$PATH"
set -x PATH /opt/cuda/bin $PATH

# --- fzf: Cathedral -------------------------------------------------------
set -gx FZF_DEFAULT_OPTS "\
--color=bg+:#14141b,bg:-1,spinner:#c9a227,hl:#a02c3c \
--color=fg:#7d7a86,header:#a02c3c,info:#c9a227,pointer:#a02c3c \
--color=marker:#c9a227,fg+:#d8d3c8,prompt:#a02c3c,hl+:#c84a58 \
--color=border:#23232e \
--border=sharp --prompt='  ' --pointer='>' --marker='+'"
