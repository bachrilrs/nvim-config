# nvim-config

Configuration Neovim **pédagogique et légère** (15 plugins), pensée pour
Python, la bioinformatique, les scripts shell et l'édition de fichiers de
configuration. Basée sur l'idée de
[neovim-for-newbs](https://github.com/cpow/neovim-for-newbs), mais réécrite
avec les APIs actuelles (Neovim 0.12, nvim-treesitter `main`, LSP natif).

Fonctionne sur **macOS** (Homebrew) et **Linux sans droits sudo** (prévu
pour Fedora / bash ; config testée sur macOS, y compris avec un PATH réduit
simulant une machine sans compilateur ni presse-papier — `install.sh`
vérifié par shellcheck, mais pas encore exécuté sur une vraie Fedora).

- Aide-mémoire des raccourcis : [`nvim/cheatsheet.md`](nvim/cheatsheet.md)
- Journal complet de l'installation d'origine (décisions, erreurs, tests) :
  [`docs/setup-log-macos.txt`](docs/setup-log-macos.txt).
  Depuis ce journal, la config a été rendue portable : presse-papier
  conditionnel, serveurs LSP activés seulement s'ils sont installés,
  fzf-native et parsers Treesitter ignorés sans compilateur.

## Contenu

```
nvim-config/
├── install.sh            installation Linux sans sudo (outils + config + plugins)
├── docs/setup-log-macos.txt
└── nvim/                 ← la config elle-même (= ~/.config/nvim)
    ├── init.lua
    ├── lazy-lock.json    versions exactes des plugins
    ├── cheatsheet.md
    └── lua/
        ├── config/       options, keymaps, autocmds, lazy (bootstrap)
        └── plugins/      un fichier par sujet
```

| Plugin | Rôle |
|---|---|
| lazy.nvim | gestionnaire de plugins |
| catppuccin | thème |
| telescope (+ fzf-native) | recherche floue : fichiers, texte, buffers |
| nvim-treesitter (`main`) | parsers → coloration précise, pliage |
| neo-tree | explorateur de fichiers |
| nvim-lspconfig | configs des serveurs LSP (le LSP est natif) |
| blink.cmp | autocomplétion |
| conform.nvim | formatage (ruff, stylua, shfmt) |
| gitsigns | Git dans la marge |
| which-key, lualine | aide aux raccourcis, barre de statut |

Serveurs LSP : basedpyright + ruff (Python), lua_ls, bashls, clangd.

## Installation — Linux sans sudo (Fedora…)

```bash
git clone https://github.com/<toi>/nvim-config.git ~/nvim-config
cd ~/nvim-config
./install.sh            # ou ./install.sh --fonts pour la Nerd Font
source ~/.bashrc        # ou ouvrir un nouveau terminal
nvim
```

Le script :

1. vérifie les prérequis (`curl`, `tar`, `git`, `gzip`, `python3`, compilateur C, `make`) ;
2. télécharge les binaires officiels dans `~/.local/opt/` et les lie dans
   `~/.local/bin/` : Neovim 0.12.5, tree-sitter-cli, fd, ripgrep,
   lua-language-server, stylua, shellcheck, shfmt, Node.js (pour bashls) ;
3. installe `uv`, puis `ruff` et `basedpyright` via `uv tool install` ;
4. installe `bash-language-server` via npm dans `~/.local` ;
5. sauvegarde l'éventuel `~/.config/nvim` existant et crée le lien
   `~/.config/nvim → <dépôt>/nvim` (un `git pull` met donc la config à jour) ;
6. installe les plugins aux versions de `lazy-lock.json`, le binaire de
   blink.cmp et les parsers Treesitter.

Il est **idempotent** : relance-le sans risque, il saute ce qui est déjà installé.
Options : `--tools-only`, `--config-only`, `--fonts`, `--help`.

### Ce qui ne peut pas s'installer sans sudo

| Manque | Conséquence | Solution |
|---|---|---|
| `gcc` / `make` | pas de parsers Treesitter (coloration classique de Vim), Telescope un peu plus lent | demander `sudo dnf install gcc make`, ou `micromamba install -c conda-forge c-compiler make` |
| `wl-copy` / `xclip` | `y` / `p` n'utilisent pas le presse-papier système | voir ci-dessous |
| `clangd` | pas de LSP C/C++ | `clang-tools-extra` (admin) — sinon simplement ignoré |

La config **s'adapte automatiquement** : elle n'active que les serveurs LSP
installés, désactive fzf-native sans compilateur, et prévient une seule fois
si des parsers Treesitter ne peuvent pas être compilés.

### Presse-papier

- Si `pbcopy` (macOS), `wl-copy` (Wayland) ou `xclip`/`xsel` (X11) existe :
  `y` et `p` utilisent directement le presse-papier système.
- Sinon (ex : connexion **SSH**) : copie vers le presse-papier de ton
  terminal local avec `"+y` (protocole OSC 52, géré nativement par Neovim ;
  supporté par WezTerm, kitty, iTerm2, Ghostty, foot…).

### Police (icônes)

Les icônes de Neo-tree / Telescope / lualine nécessitent une **Nerd Font
dans le terminal que tu regardes** :
- en SSH : sur ta machine locale (déjà le cas sur le Mac) ;
- en local sur Fedora : `./install.sh --fonts` puis choisir
  « JetBrainsMono Nerd Font » dans les préférences du terminal.

## Installation — macOS (Homebrew)

```bash
brew install neovim git fd ripgrep tree-sitter-cli basedpyright ruff \
  lua-language-server stylua bash-language-server shellcheck shfmt
git clone https://github.com/<toi>/nvim-config.git ~/nvim-config
mv ~/.config/nvim ~/.config/nvim.backup 2>/dev/null
ln -s ~/nvim-config/nvim ~/.config/nvim
nvim     # lazy.nvim installe les plugins au 1er lancement
```

(clang et make viennent des Command Line Tools : `xcode-select --install`.)

## Mise à jour et maintenance

```vim
:Lazy update      " met à jour les plugins (et lazy-lock.json → à committer)
:Lazy restore     " revient aux versions de lazy-lock.json
:TSUpdate         " met à jour les parsers Treesitter
:checkhealth      " diagnostic complet
```

Sur une autre machine : `git pull` puis `:Lazy restore` pour avoir
exactement les mêmes versions.

Environnements virtuels Python : lancer `nvim` depuis le venv activé
(`source .venv/bin/activate` ou `uv run nvim`) pour que basedpyright trouve
les paquets du projet.

## Désinstaller (Linux)

```bash
rm ~/.config/nvim                       # le lien (la sauvegarde reste en ~/.config/nvim.backup-*)
rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim
rm -rf ~/.local/opt/{nvim,tree-sitter,fd,ripgrep,lua-language-server,stylua,shellcheck,shfmt,node}
uv tool uninstall ruff basedpyright
# puis supprimer les liens correspondants dans ~/.local/bin
```
