-- ============================================================================
-- Neo-tree : explorateur de fichiers en arborescence
-- https://github.com/nvim-neo-tree/neo-tree.nvim  (branche v3.x)
-- ============================================================================
-- Dans Neo-tree (appuie sur ? pour l'aide complète) :
--   Entrée / o  ouvrir          a  créer (finir par / pour un dossier)
--   d  supprimer                r  renommer          m  déplacer
--   c  copier                   y  copier le nom     H  afficher fichiers cachés
--   <BS>  remonter d'un dossier  .  faire du dossier sélectionné la racine
--   s / S  ouvrir en split vertical / horizontal      q  fermer
-- ============================================================================

return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x", -- branche stable recommandée par le README officiel
  dependencies = {
    "nvim-lua/plenary.nvim", -- fonctions utilitaires Lua
    "MunifTanjim/nui.nvim", -- composants d'interface (fenêtres, popups)
    "nvim-tree/nvim-web-devicons", -- icônes (nécessite une Nerd Font : OK)
  },
  -- Le README demande lazy = false : Neo-tree se charge lui-même à la demande
  -- et peut ainsi remplacer netrw quand on fait `nvim .`
  lazy = false,
  keys = {
    { "<C-n>", "<Cmd>Neotree toggle<CR>", desc = "Explorateur : ouvrir/fermer" },
    { "<leader>e", "<Cmd>Neotree reveal<CR>", desc = "Explorateur : montrer le fichier courant" },
    { "<leader>be", "<Cmd>Neotree buffers float toggle<CR>", desc = "Explorateur des buffers" },
    { "<leader>ge", "<Cmd>Neotree git_status float toggle<CR>", desc = "Git : arbre des fichiers modifiés" },
  },
  opts = {
    close_if_last_window = true, -- quitter Neovim si Neo-tree est la dernière fenêtre
    window = { width = 32 },
    filesystem = {
      follow_current_file = { enabled = true }, -- suit le fichier ouvert
      use_libuv_file_watcher = true, -- se met à jour si un fichier change sur le disque
      filtered_items = {
        hide_dotfiles = false, -- montre .gitignore, .env…
        hide_gitignored = true,
        hide_by_name = { ".git", ".DS_Store", "__pycache__" },
      },
    },
  },
}
