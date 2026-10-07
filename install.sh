#!/usr/bin/env bash
# ============================================================================
# install.sh — installe cette config Neovim et ses outils SANS sudo (Linux)
# ============================================================================
# Prévu pour : Fedora (bash), x86_64 ou aarch64. Fonctionne sur la plupart des
# distributions Linux récentes (glibc).
#
# Tout est installé dans ton HOME :
#   ~/.local/opt/<outil>/   programmes décompressés
#   ~/.local/bin/           liens vers les exécutables (doit être dans le PATH)
#   ~/.config/nvim          -> lien symbolique vers le dossier nvim/ du dépôt
#
# Utilisation :
#   ./install.sh               outils + config + plugins
#   ./install.sh --tools-only  seulement les outils
#   ./install.sh --config-only seulement le lien de config + plugins
#   ./install.sh --fonts       ajoute la police JetBrainsMono Nerd Font
#                              (~/.local/share/fonts ; utile seulement si tu
#                              utilises Neovim sur l'écran de CETTE machine)
#
# Le script est idempotent : on peut le relancer, il saute ce qui est déjà là.
# ============================================================================
set -euo pipefail

# --- Versions (identiques à la config macOS d'origine) ----------------------
NVIM_VERSION="v0.12.5"
TS_VERSION="v0.27.0"
FD_VERSION="v10.5.0"
RG_VERSION="15.2.0"
LUALS_VERSION="3.19.1"
STYLUA_VERSION="v2.5.2"
SHELLCHECK_VERSION="v0.11.0"
SHFMT_VERSION="v3.14.1"
NODE_VERSION="v24.21.0" # LTS, seulement pour bash-language-server
NERDFONT_VERSION="v3.4.0"

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OPT="$HOME/.local/opt"
BIN="$HOME/.local/bin"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

# --- Affichage ---------------------------------------------------------------
info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
ok() { printf '\033[1;32m ✓\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m !\033[0m %s\n' "$*"; }
die() {
  printf '\033[1;31m ✗\033[0m %s\n' "$*" >&2
  exit 1
}

have() { command -v "$1" >/dev/null 2>&1; }

# --- Architecture ------------------------------------------------------------
case "$(uname -m)" in
  x86_64)
    A_NVIM=x86_64 A_TS=x64 A_RUST=x86_64 A_LUALS=x64 A_SC=x86_64 A_SHFMT=amd64 A_NODE=x64
    ;;
  aarch64 | arm64)
    A_NVIM=arm64 A_TS=arm64 A_RUST=aarch64 A_LUALS=arm64 A_SC=aarch64 A_SHFMT=arm64 A_NODE=arm64
    ;;
  *) die "Architecture non supportée : $(uname -m)" ;;
esac
[[ "$(uname -s)" == "Linux" ]] || die "Ce script est prévu pour Linux. Sur macOS, voir README (Homebrew)."

# --- Téléchargement ----------------------------------------------------------
fetch() { # fetch URL DEST
  curl -fL --retry 3 --progress-bar -o "$2" "$1" || die "Téléchargement impossible : $1"
}
gh() { echo "https://github.com/$1/releases/download/$2/$3"; }

# Décompresse un .zip sans dépendre de `unzip` (python3 est présent sur Fedora)
unzip_to() { # unzip_to ARCHIVE DIR
  if have unzip; then
    unzip -qo "$1" -d "$2"
  else
    python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$1" "$2"
  fi
}

link() { # link CIBLE NOM
  ln -sfn "$1" "$BIN/$2"
  chmod +x "$1"
}

# ============================================================================
# 1. Prérequis système (ne peuvent pas être installés sans sudo)
# ============================================================================
check_prereqs() {
  info "Vérification des prérequis"
  local missing=()
  for t in curl tar git gzip python3; do
    if have "$t"; then ok "$t"; else missing+=("$t"); fi
  done
  ((${#missing[@]} == 0)) || die "Manquant(s) : ${missing[*]} (à demander à l'administrateur)"

  # Compilateur C + make : pour les parsers Treesitter et telescope-fzf-native.
  # La config fonctionne sans, mais avec la coloration classique et un tri
  # Telescope plus lent.
  if have cc || have gcc || have clang; then ok "compilateur C"; else
    warn "Aucun compilateur C (gcc). Sans lui : pas de parsers Treesitter."
    warn "  -> demander à l'admin : sudo dnf install gcc make"
    warn "  -> ou sans sudo, via conda/micromamba : micromamba install -c conda-forge c-compiler make"
  fi
  if have make; then ok "make"; else
    warn "make absent (telescope-fzf-native sera désactivé automatiquement)"
  fi

  for t in wl-copy xclip xsel; do have "$t" && {
    ok "presse-papier : $t"
    return
  }; done
  warn "Aucun outil de presse-papier (wl-copy/xclip/xsel) : la config utilisera le"
  warn "  presse-papier du terminal (OSC 52) via \"+y — voir README."
}

# ============================================================================
# 2. Outils
# ============================================================================
install_nvim() {
  if have nvim && nvim --version | head -1 | grep -qE 'v0\.(1[2-9]|[2-9][0-9])'; then
    ok "neovim déjà présent : $(nvim --version | head -1)"
    return
  fi
  info "Neovim $NVIM_VERSION"
  fetch "$(gh neovim/neovim "$NVIM_VERSION" "nvim-linux-$A_NVIM.tar.gz")" "$TMP/nvim.tgz"
  rm -rf "$OPT/nvim" && mkdir -p "$OPT/nvim"
  tar -xzf "$TMP/nvim.tgz" -C "$OPT/nvim" --strip-components=1
  link "$OPT/nvim/bin/nvim" nvim
  ok "$("$BIN/nvim" --version | head -1)"
}

install_tree_sitter() {
  if have tree-sitter; then
    ok "tree-sitter déjà présent : $(tree-sitter --version)"
    return
  fi
  info "tree-sitter-cli $TS_VERSION"
  mkdir -p "$OPT/tree-sitter"
  fetch "$(gh tree-sitter/tree-sitter "$TS_VERSION" "tree-sitter-linux-$A_TS.gz")" "$TMP/ts.gz"
  gzip -dc "$TMP/ts.gz" >"$OPT/tree-sitter/tree-sitter"
  link "$OPT/tree-sitter/tree-sitter" tree-sitter
  ok "$("$BIN/tree-sitter" --version)"
}

install_fd() {
  if have fd; then
    ok "fd déjà présent"
    return
  fi
  info "fd $FD_VERSION"
  local name="fd-$FD_VERSION-$A_RUST-unknown-linux-musl"
  fetch "$(gh sharkdp/fd "$FD_VERSION" "$name.tar.gz")" "$TMP/fd.tgz"
  rm -rf "$OPT/fd" && mkdir -p "$OPT/fd"
  tar -xzf "$TMP/fd.tgz" -C "$OPT/fd" --strip-components=1
  link "$OPT/fd/fd" fd
  ok "$("$BIN/fd" --version)"
}

install_rg() {
  if have rg; then
    ok "ripgrep déjà présent"
    return
  fi
  info "ripgrep $RG_VERSION"
  local name="ripgrep-$RG_VERSION-$A_RUST-unknown-linux-musl"
  fetch "$(gh BurntSushi/ripgrep "$RG_VERSION" "$name.tar.gz")" "$TMP/rg.tgz"
  rm -rf "$OPT/ripgrep" && mkdir -p "$OPT/ripgrep"
  tar -xzf "$TMP/rg.tgz" -C "$OPT/ripgrep" --strip-components=1
  link "$OPT/ripgrep/rg" rg
  ok "$("$BIN/rg" --version | head -1)"
}

install_uv_tools() {
  # uv : gestionnaire Python moderne, s'installe dans ~/.local/bin sans sudo
  if ! have uv; then
    info "uv (gestionnaire d'outils Python)"
    curl -LsSf https://astral.sh/uv/install.sh | env UV_NO_MODIFY_PATH=1 sh
  fi
  ok "uv : $(uv --version)"
  # basedpyright (PyPI) embarque sa propre copie de Node.js
  for tool in ruff basedpyright; do
    if have "$tool"; then ok "$tool déjà présent"; else
      info "$tool (via uv tool install)"
      uv tool install "$tool"
    fi
  done
}

install_luals() {
  if have lua-language-server; then
    ok "lua-language-server déjà présent"
    return
  fi
  info "lua-language-server $LUALS_VERSION"
  fetch "$(gh LuaLS/lua-language-server "$LUALS_VERSION" "lua-language-server-$LUALS_VERSION-linux-$A_LUALS.tar.gz")" "$TMP/luals.tgz"
  rm -rf "$OPT/lua-language-server" && mkdir -p "$OPT/lua-language-server"
  tar -xzf "$TMP/luals.tgz" -C "$OPT/lua-language-server"
  # Petit script lanceur (le binaire doit être appelé depuis son dossier d'origine)
  cat >"$BIN/lua-language-server" <<EOF
#!/usr/bin/env bash
exec "$OPT/lua-language-server/bin/lua-language-server" "\$@"
EOF
  chmod +x "$BIN/lua-language-server"
  ok "lua-language-server $("$BIN/lua-language-server" --version)"
}

install_stylua() {
  if have stylua; then
    ok "stylua déjà présent"
    return
  fi
  info "stylua $STYLUA_VERSION"
  fetch "$(gh JohnnyMorganz/StyLua "$STYLUA_VERSION" "stylua-linux-$A_RUST-musl.zip")" "$TMP/stylua.zip"
  mkdir -p "$OPT/stylua" && unzip_to "$TMP/stylua.zip" "$OPT/stylua"
  link "$OPT/stylua/stylua" stylua
  ok "$("$BIN/stylua" --version)"
}

install_shellcheck() {
  if have shellcheck; then
    ok "shellcheck déjà présent"
    return
  fi
  info "shellcheck $SHELLCHECK_VERSION"
  fetch "$(gh koalaman/shellcheck "$SHELLCHECK_VERSION" "shellcheck-$SHELLCHECK_VERSION.linux.$A_SC.tar.gz")" "$TMP/sc.tgz"
  rm -rf "$OPT/shellcheck" && mkdir -p "$OPT/shellcheck"
  tar -xzf "$TMP/sc.tgz" -C "$OPT/shellcheck" --strip-components=1
  link "$OPT/shellcheck/shellcheck" shellcheck
  ok "shellcheck $("$BIN/shellcheck" --version | sed -n 2p)"
}

install_shfmt() {
  if have shfmt; then
    ok "shfmt déjà présent"
    return
  fi
  info "shfmt $SHFMT_VERSION"
  mkdir -p "$OPT/shfmt"
  fetch "$(gh mvdan/sh "$SHFMT_VERSION" "shfmt_${SHFMT_VERSION}_linux_$A_SHFMT")" "$OPT/shfmt/shfmt"
  link "$OPT/shfmt/shfmt" shfmt
  ok "shfmt $("$BIN/shfmt" --version)"
}

install_bashls() {
  if have bash-language-server; then
    ok "bash-language-server déjà présent"
    return
  fi
  # bash-language-server est un paquet npm : il faut Node.js (installé dans ~/.local/opt)
  if ! have npm; then
    info "Node.js $NODE_VERSION (pour bash-language-server)"
    fetch "https://nodejs.org/dist/$NODE_VERSION/node-$NODE_VERSION-linux-$A_NODE.tar.gz" "$TMP/node.tgz"
    rm -rf "$OPT/node" && mkdir -p "$OPT/node"
    tar -xzf "$TMP/node.tgz" -C "$OPT/node" --strip-components=1
    for b in node npm npx; do link "$OPT/node/bin/$b" "$b"; done
  fi
  info "bash-language-server (npm, dans ~/.local)"
  npm install --global --prefix "$HOME/.local" bash-language-server >/dev/null
  ok "bash-language-server $("$BIN/bash-language-server" --version)"
}

install_fonts() {
  info "JetBrainsMono Nerd Font $NERDFONT_VERSION (~/.local/share/fonts)"
  fetch "$(gh ryanoasis/nerd-fonts "$NERDFONT_VERSION" JetBrainsMono.tar.xz)" "$TMP/font.txz"
  mkdir -p "$HOME/.local/share/fonts/JetBrainsMonoNerd"
  tar -xJf "$TMP/font.txz" -C "$HOME/.local/share/fonts/JetBrainsMonoNerd"
  have fc-cache && fc-cache -f "$HOME/.local/share/fonts" >/dev/null
  ok "Police installée : choisis « JetBrainsMono Nerd Font » dans ton terminal"
}

ensure_path() {
  case ":$PATH:" in
    *":$BIN:"*) ok "$BIN est dans le PATH" ;;
    *)
      warn "$BIN n'est pas dans le PATH : ajout dans ~/.bashrc"
      # shellcheck disable=SC2016
      printf '\n# Ajouté par nvim-config/install.sh\nexport PATH="$HOME/.local/bin:$PATH"\n' >>"$HOME/.bashrc"
      ;;
  esac
  export PATH="$BIN:$PATH"
}

# ============================================================================
# 3. Config + plugins
# ============================================================================
install_config() {
  info "Lien ~/.config/nvim -> $REPO_DIR/nvim"
  mkdir -p "$HOME/.config"
  local target="$HOME/.config/nvim"
  if [[ -L "$target" && "$(readlink "$target")" == "$REPO_DIR/nvim" ]]; then
    ok "déjà en place"
  else
    if [[ -e "$target" || -L "$target" ]]; then
      local backup
      backup="$target.backup-$(date +%Y%m%d-%H%M%S)"
      mv "$target" "$backup"
      warn "ancienne config sauvegardée dans $backup"
    fi
    ln -s "$REPO_DIR/nvim" "$target"
    ok "lien créé"
  fi

  info "Installation des plugins (versions exactes de lazy-lock.json)"
  nvim --headless "+Lazy! restore" +qa

  info "Binaire de blink.cmp (autocomplétion)"
  cat >"$TMP/blink.lua" <<'LUA'
require("lazy").load({ plugins = { "blink.cmp" } })
local done, err = false, nil
require("blink.cmp.fuzzy.download").ensure_downloaded(function(e)
  err = e
  done = true
end)
vim.wait(120000, function() return done end, 200)
io.stdout:write(err and ("ERREUR : " .. tostring(err) .. "\n") or "ok\n")
LUA
  nvim --headless -c "luafile $TMP/blink.lua" -c qa

  if have tree-sitter && (have cc || have gcc || have clang); then
    info "Parsers Treesitter (compilation, ~1 min)"
    # Même liste que dans nvim/lua/plugins/treesitter.lua
    cat >"$TMP/ts.lua" <<'LUA'
local parsers = { "python", "lua", "bash", "c", "cpp", "r", "snakemake", "csv",
  "json", "yaml", "toml", "markdown", "markdown_inline", "vim", "vimdoc", "query",
  "diff", "gitcommit", "git_config", "gitignore", "regex" }
require("nvim-treesitter").install(parsers):wait(600000)
LUA
    nvim --headless -c "luafile $TMP/ts.lua" -c qa
  else
    warn "Parsers Treesitter non installés (tree-sitter ou compilateur C manquant)"
  fi
  ok "Config installée"
}

summary() {
  info "Vérification"
  for t in nvim git fd rg tree-sitter basedpyright-langserver ruff lua-language-server \
    bash-language-server shellcheck stylua shfmt clangd; do
    if have "$t"; then ok "$t"; else warn "$t absent"; fi
  done
  echo
  info "Terminé. Ouvre un NOUVEAU terminal (ou : source ~/.bashrc), puis :"
  echo "    nvim"
  echo "    :checkhealth"
  echo "Aide-mémoire : ~/.config/nvim/cheatsheet.md"
}

# ============================================================================
main() {
  local tools=1 config=1 fonts=0
  for arg in "$@"; do
    case "$arg" in
      --tools-only) config=0 ;;
      --config-only) tools=0 ;;
      --fonts) fonts=1 ;;
      -h | --help)
        sed -n '2,24p' "$0"
        exit 0
        ;;
      *) die "Option inconnue : $arg" ;;
    esac
  done

  mkdir -p "$OPT" "$BIN"
  check_prereqs
  ensure_path
  if ((tools)); then
    install_nvim
    install_tree_sitter
    install_fd
    install_rg
    install_uv_tools
    install_luals
    install_stylua
    install_shellcheck
    install_shfmt
    install_bashls
  fi
  ((fonts)) && install_fonts
  ((config)) && install_config
  summary
}

main "$@"
