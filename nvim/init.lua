-- ============================================================================
-- init.lua : point d'entrée de Neovim
-- ============================================================================
-- Neovim lit ce fichier au démarrage. On le garde volontairement minuscule :
-- il charge seulement les modules du dossier lua/config/, dans cet ordre.
--
--   lua/config/options.lua   -> réglages de l'éditeur (numéros, tabulations…)
--   lua/config/keymaps.lua   -> raccourcis qui ne dépendent d'aucun plugin
--   lua/config/autocmds.lua  -> actions automatiques (ex : surligner un yank)
--   lua/config/lazy.lua      -> installe lazy.nvim puis charge lua/plugins/*.lua
--
-- `require("config.options")` = charger le fichier lua/config/options.lua
-- ============================================================================

-- La touche <leader> doit être définie AVANT de charger les plugins,
-- sinon leurs raccourcis utiliseraient l'ancienne valeur.
vim.g.mapleader = " " -- <leader> = Espace
vim.g.maplocalleader = "\\"

require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.lazy")
