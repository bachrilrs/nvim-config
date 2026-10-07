-- ============================================================================
-- Catppuccin : le thème de couleurs
-- https://github.com/catppuccin/nvim
-- ============================================================================
-- Variantes : latte (clair), frappe, macchiato, mocha (le plus sombre).
-- Pour essayer une autre variante sans toucher à la config :
--   :colorscheme catppuccin-latte
-- ============================================================================

return {
  "catppuccin/nvim",
  name = "catppuccin", -- le dépôt s'appelle "nvim", on lui donne un nom lisible
  lazy = false, -- le thème doit être chargé dès le démarrage…
  priority = 1000, -- …et avant tous les autres plugins
  opts = {
    flavour = "mocha",
    -- Couleurs adaptées pour chacun de nos plugins, listés explicitement.
    -- On n'utilise PAS `auto_integrations` (activé par défaut) : la détection
    -- automatique appelle vim.pack.get(), qui crée un dossier vide
    -- ~/.local/share/nvim/site/pack/core et provoque un avertissement dans
    -- :checkhealth vim.pack (alors qu'on n'utilise pas vim.pack).
    auto_integrations = false,
    integrations = {
      blink_cmp = true,
      gitsigns = true,
      neotree = true,
      telescope = true,
      which_key = true,
    },
  },
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin")
  end,
}
