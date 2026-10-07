-- ============================================================================
-- conform.nvim : formatage du code
-- https://github.com/stevearc/conform.nvim
-- ============================================================================
-- Formater = réécrire automatiquement le code selon un style standard
-- (indentation, espaces, longueur de ligne, ordre des imports…).
--
-- Choix volontaire : PAS de formatage automatique à la sauvegarde.
-- En bioinformatique on édite souvent des scripts écrits par d'autres :
-- un formatage automatique créerait d'énormes diffs Git involontaires.
-- -> on formate quand on le décide : <leader>cf
--
-- Pas de plugin de linting séparé (nvim-lint) : les diagnostics viennent
-- déjà des serveurs LSP (ruff pour Python, shellcheck via bashls pour Bash).
--
-- `:ConformInfo` montre les formateurs disponibles pour le fichier courant.
-- ============================================================================

return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>cf",
      function()
        require("conform").format({ async = true })
      end,
      mode = { "n", "x" }, -- en visuel : formate seulement la sélection
      desc = "Formater le fichier / la sélection",
    },
  },
  opts = {
    formatters_by_ft = {
      -- Ruff : trie les imports puis formate (compatible Black, 30x plus rapide)
      python = { "ruff_organize_imports", "ruff_format" },
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
    },
    -- Pour les autres langages (C/C++ via clangd…), utilise le formateur
    -- du serveur LSP s'il en propose un.
    default_format_opts = { lsp_format = "fallback" },
  },
}
