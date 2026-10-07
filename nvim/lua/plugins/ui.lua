-- ============================================================================
-- Interface : which-key + lualine
-- ============================================================================

return {
  -- which-key : aide-mémoire interactif -----------------------------------------
  -- https://github.com/folke/which-key.nvim
  -- Appuie sur Espace (ou g, z, ], [, Ctrl+w…) et attends ~0,4 s : une fenêtre
  -- liste les suites possibles avec leur description. Idéal pour apprendre.
  -- `<leader>?` affiche les raccourcis propres au buffer courant.
  {
    "folke/which-key.nvim",
    event = "VeryLazy", -- chargé juste après l'affichage de l'interface
    opts = {
      preset = "helix", -- petite fenêtre en bas à droite, ne cache pas le code
      spec = {
        -- Noms des groupes affichés après <leader>
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>b", group = "Buffers" },
        { "<leader>t", group = "Tabs / Terminal" },
      },
    },
    keys = {
      {
        "<leader>?",
        function() require("which-key").show({ global = false }) end,
        desc = "Raccourcis du buffer",
      },
    },
  },

  -- lualine : barre de statut -----------------------------------------------
  -- https://github.com/nvim-lualine/lualine.nvim
  -- Affiche en bas : mode (NORMAL/INSERT…), branche Git, fichier,
  -- diagnostics, type de fichier, position. Couleurs reprises du thème.
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        theme = "auto", -- suit automatiquement le colorscheme (catppuccin)
        globalstatus = true, -- une seule barre pour toutes les fenêtres
      },
      sections = {
        lualine_c = { { "filename", path = 1 } }, -- chemin relatif au projet
      },
      extensions = { "neo-tree", "lazy" },
    },
  },
}
