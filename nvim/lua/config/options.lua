-- ============================================================================
-- Options de l'éditeur
-- ============================================================================
-- `vim.opt.X = valeur` équivaut à `:set X=valeur` en Vimscript.
-- Aide détaillée pour n'importe quelle option : `:help 'nomoption'`
-- (ex : `:help 'relativenumber'`).
--
-- Rappel : Neovim 0.12 active déjà par défaut `syntax on`, `filetype plugin
-- indent on`, `termguicolors` (si le terminal le supporte), `hlsearch`,
-- `incsearch`, `autoindent`… Inutile de les répéter ici.
-- ============================================================================

local opt = vim.opt

-- Numéros de ligne -----------------------------------------------------------
opt.number = true -- numéro de la ligne courante

-- Indentation (4 espaces par défaut, convention Python / PEP 8) -------------
-- Lua, YAML, JSON, Markdown passent à 2 espaces : voir autocmds.lua
opt.expandtab = true -- Tab insère des espaces
opt.shiftwidth = 4 -- largeur d'un niveau d'indentation (>>, <<)
opt.tabstop = 4 -- largeur d'affichage d'un vrai caractère Tab
opt.softtabstop = 4
opt.smartindent = true

-- Recherche ------------------------------------------------------------------
opt.ignorecase = true -- /foo trouve Foo…
opt.smartcase = true -- …sauf si on tape une majuscule : /Foo ne trouve que Foo

-- Interface ------------------------------------------------------------------
opt.cursorline = true -- surligne la ligne du curseur
opt.signcolumn = "yes" -- colonne de signes toujours visible (Git, erreurs LSP)
opt.scrolloff = 8 -- garde 8 lignes visibles au-dessus/dessous du curseur
opt.sidescrolloff = 8
opt.wrap = false -- pas de retour à la ligne visuel (tableaux, FASTA, CSV…)
opt.splitright = true -- :vsplit ouvre à droite
opt.splitbelow = true -- :split ouvre en bas
opt.showmode = false -- le mode (INSERT…) est déjà affiché par lualine
opt.list = true -- rend visibles les caractères invisibles suivants :
opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.winborder = "rounded" -- bordure arrondie pour les fenêtres flottantes (hover LSP…)

-- Presse-papier --------------------------------------------------------------
-- Partage le presse-papier du système : `y` copie, `p` colle (Cmd+C / Cmd+V
-- sur macOS, Ctrl+Shift+C / V sous Linux).
-- Activé seulement si un outil de presse-papier existe : macOS (pbcopy),
-- Linux Wayland (wl-copy) ou X11 (xclip / xsel). Sinon (ex : connexion SSH
-- sans ces outils) on laisse l'option vide : Neovim utilise alors tout seul
-- le presse-papier du terminal (OSC 52) pour le registre "+ -> `"+y`.
local function has_clipboard_tool()
  for _, tool in ipairs({ "pbcopy", "wl-copy", "xclip", "xsel" }) do
    if vim.fn.executable(tool) == 1 then
      return true
    end
  end
  return false
end
if has_clipboard_tool() then
  opt.clipboard = "unnamedplus"
end

-- Fichiers -------------------------------------------------------------------
opt.undofile = true -- historique d'annulation conservé après fermeture
opt.confirm = true -- demande de sauvegarder au lieu d'échouer sur :q

-- Réactivité -----------------------------------------------------------------
opt.updatetime = 250 -- délai avant affichage des infos (Git, diagnostics)
opt.timeoutlen = 400 -- délai pour finir un raccourci multi-touches (which-key)

-- Providers -------------------------------------------------------------------
-- Les "providers" permettent d'écrire des plugins en Python/Node/Ruby/Perl
-- (ancienne méthode). Aucun de nos plugins n'en a besoin : on les désactive
-- (démarrage plus rapide, et plus d'avertissements dans :checkhealth).
-- NB : ça n'a AUCUN rapport avec le développement Python (LSP, ruff…).
vim.g.loaded_python3_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0

-- Pliage (folding) via Treesitter --------------------------------------------
-- La méthode est activée par buffer dans plugins/treesitter.lua.
-- foldlevel = 99 : tout est déplié à l'ouverture d'un fichier.
opt.foldlevel = 99
opt.foldlevelstart = 99
