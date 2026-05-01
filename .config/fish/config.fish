source /usr/share/cachyos-fish-config/cachyos-config.fish

# --- Terminal Rice ---
function fish_greeting
    if not set -q FETCH_DONE
        clear
        # Full Fastfetch info with openSUSE Tumbleweed logo
        fastfetch --logo opensuse-tumbleweed_old --structure Title:Separator:OS:Host:Board:Chassis:Kernel:Uptime:Processes:Packages:Shell:Display:DE:WM:WMTheme:Theme:Icons:Font:Cursor:Terminal:TerminalFont:CPU:GPU:Memory:Swap:Disk:Battery:PowerAdapter:Locale:Break:Colors
        
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

# Auto-attach to zellij session
if status is-interactive
    if not set -q ZELLIJ
        zellij attach -c
    end
end

# uv
fish_add_path "/home/winter/.local/bin"
export PATH="$(npm config get prefix)/bin:$PATH"
