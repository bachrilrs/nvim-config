-- ============================================================================
-- lazy.nvim : le gestionnaire de plugins
-- ============================================================================
-- 1. Si lazy.nvim n'est pas encore installé, on le clone depuis GitHub.
-- 2. On l'ajoute au runtimepath (les chemins où Neovim cherche du code).
-- 3. On lui demande de charger chaque fichier de lua/plugins/.
--    Chaque fichier y retourne une "spec" : quel plugin, quand le charger,
--    comment le configurer.
--
-- Commande utile : `:Lazy` ouvre l'interface (U = mettre à jour,
-- S = synchroniser, X = nettoyer, P = profiler le démarrage).
-- Les versions exactes sont figées dans lazy-lock.json (à garder !).
-- ============================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
  local out = vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Échec du clonage de lazy.nvim :\n", "ErrorMsg" },
      { out, "WarningMsg" },
    }, true, {})
    return
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- Charge automatiquement tous les fichiers lua/plugins/*.lua
  spec = { { import = "plugins" } },

  -- Aucun de nos plugins n'a besoin de luarocks : on le désactive
  -- (sinon :checkhealth lazy affiche une erreur inutile).
  rocks = { enabled = false },

  -- Thème utilisé pendant la toute première installation
  install = { colorscheme = { "catppuccin", "habamax" } },

  -- Pas de vérification automatique des mises à jour en arrière-plan :
  -- tu mets à jour quand TU le décides avec :Lazy update
  checker = { enabled = false },

  -- Ne pas afficher de notification à chaque modification d'un fichier de config
  change_detection = { notify = false },

  performance = {
    rtp = {
      -- Plugins Vim intégrés inutiles pour nous (démarrage plus rapide)
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "zipPlugin",
        "tohtml",
        "netrwPlugin", -- remplacé par Neo-tree
      },
    },
  },
})
