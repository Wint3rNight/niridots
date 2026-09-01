#!/usr/bin/env bash
# Put this setup on a fresh machine.
#
#   git clone https://github.com/Wint3rNight/niridots.git ~/dotfiles
#   ~/dotfiles/scripts/bootstrap.sh
#
# Safe to re-run: it backs up whatever it is about to replace.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP="$HOME/.config/.pre-bootstrap-$(date +%Y%m%d-%H%M%S)"
ORIGIN_HOME="/home/winter"   # the home path baked into the committed configs

say() { printf '\033[1;33m==>\033[0m %s\n' "$*"; }

# ---------------------------------------------------------------------------
# 1. packages
# ---------------------------------------------------------------------------
if command -v pacman >/dev/null; then
    say "Installing packages from pkglist.txt"
    sudo pacman -S --needed --noconfirm - < "$REPO/pkglist.txt" || {
        echo "Some packages failed (AUR ones need yay/paru). Continuing." >&2
    }
else
    echo "Not an Arch box - install the pkglist.txt equivalents by hand." >&2
fi

# ---------------------------------------------------------------------------
# 2. configs
# ---------------------------------------------------------------------------
say "Backing up existing configs to $BACKUP"
mkdir -p "$BACKUP"
for d in "$REPO"/.config/*; do
    name="$(basename "$d")"
    [ -e "$HOME/.config/$name" ] && cp -a "$HOME/.config/$name" "$BACKUP/"
done
[ -e "$HOME/.config/nvim" ] && cp -a "$HOME/.config/nvim" "$BACKUP/"

say "Copying configs into ~/.config"
mkdir -p "$HOME/.config" "$HOME/.local/bin"
cp -a "$REPO"/.config/. "$HOME/.config/"
rm -rf "$HOME/.config/nvim"
cp -a "$REPO/nvim" "$HOME/.config/nvim"
install -m755 "$REPO"/scripts/* "$HOME/.local/bin/" 2>/dev/null || true

# ---------------------------------------------------------------------------
# 3. rewrite the baked-in home path if this machine uses a different user
# ---------------------------------------------------------------------------
if [ "$HOME" != "$ORIGIN_HOME" ]; then
    say "Rewriting $ORIGIN_HOME -> $HOME in configs"
    grep -rl "$ORIGIN_HOME" "$HOME/.config" 2>/dev/null | while read -r f; do
        sed -i "s|$ORIGIN_HOME|$HOME|g" "$f"
        echo "    patched $f"
    done
fi

# ---------------------------------------------------------------------------
# 4. locale - btop and other TUIs string-match $LANG for "UTF-8" and refuse to
#    start without it, even when the locale really is UTF-8 underneath.
# ---------------------------------------------------------------------------
if ! printf '%s' "${LANG:-}" | grep -qiE 'utf-?8'; then
    say "\$LANG ($LANG) has no UTF-8 suffix - fixing /etc/locale.conf"
    sudo cp /etc/locale.conf /etc/locale.conf.pre-bootstrap 2>/dev/null || true
    sudo sed -i -E 's/^(LANG=[a-zA-Z_]+)$/\1.UTF-8/' /etc/locale.conf
    echo "    now: $(grep '^LANG=' /etc/locale.conf)  (takes effect next login)"
fi

# ---------------------------------------------------------------------------
# 5. DMS plugins - 21MB of git clones, so they are installed rather than vendored
# ---------------------------------------------------------------------------
if command -v dms >/dev/null && [ -f "$REPO/dms-plugins.txt" ]; then
    say "Installing DMS plugins"
    while read -r id; do
        [ -z "$id" ] && continue
        dms plugins install "$id" >/dev/null 2>&1 \
            && echo "    installed $id" || echo "    FAILED $id" >&2
    done < "$REPO/dms-plugins.txt"
fi

# ---------------------------------------------------------------------------
# 6. dsearch - the DMS launcher's file search backend. Not in any repo or the
#    AUR; without it file search in the launcher silently returns nothing.
# ---------------------------------------------------------------------------
if ! command -v dsearch >/dev/null; then
    say "Installing dsearch (DMS launcher file search)"
    tmp=$(mktemp -d)
    if curl -fsSL -o "$tmp/d.tar.gz" \
        https://github.com/AvengeMedia/danksearch/releases/latest/download/dsearch-linux-amd64.tar.gz \
       && curl -fsSL -o "$tmp/d.sha256" \
        https://github.com/AvengeMedia/danksearch/releases/latest/download/dsearch-linux-amd64.tar.gz.sha256
    then
        if [ "$(awk '{print $1}' "$tmp/d.sha256")" = "$(sha256sum "$tmp/d.tar.gz" | awk '{print $1}')" ]; then
            tar xzf "$tmp/d.tar.gz" -C "$tmp"
            install -Dm755 "$tmp/dsearch-linux-amd64" "$HOME/.local/bin/dsearch"
            echo "    installed - run 'dsearch index generate' once after login"
        else
            echo "    checksum MISMATCH - not installing" >&2
        fi
    else
        echo "    download failed - install by hand from github.com/AvengeMedia/danksearch" >&2
    fi
    rm -rf "$tmp"
fi

# ---------------------------------------------------------------------------
# 7. fonts
# ---------------------------------------------------------------------------
if [ -d "$REPO/fonts" ]; then
    say "Installing fonts"
    mkdir -p "$HOME/.local/share/fonts"
    cp -r "$REPO"/fonts/. "$HOME/.local/share/fonts/"
    fc-cache -f >/dev/null 2>&1 || true
fi

# ---------------------------------------------------------------------------
# done
# ---------------------------------------------------------------------------
cat <<EOF

$(say "Done.")  Backup of what was replaced: $BACKUP

Next:
  1. Log out and back in (picks up the locale and the niri config).
  2. DankMaterialShell starts automatically via spawn-at-startup in niri.
     Check it with:  dms doctor
  3. Neovim: run 'nvim' once - lazy.nvim installs plugins pinned in lazy-lock.json.
     The tree-sitter CLI is needed:
       npm i -g --allow-scripts=tree-sitter-cli tree-sitter-cli
  4. Copilot: ':Copilot auth' inside nvim.
  5. Set your weather city in DMS settings (Mod+Shift+D -> settings).

EOF
