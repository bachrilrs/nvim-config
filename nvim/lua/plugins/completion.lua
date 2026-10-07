-- ============================================================================
-- blink.cmp : autocomplétion
-- https://github.com/saghen/blink.cmp
-- ============================================================================
-- Pourquoi blink.cmp plutôt que nvim-cmp (utilisé dans neovim-for-newbs) ?
--   - 1 seul plugin au lieu de 5 (nvim-cmp + cmp-nvim-lsp + cmp-buffer +
--     LuaSnip + cmp_luasnip)
--   - configuration très courte, sources LSP/chemins/buffer intégrées
--   - tri ultra rapide (binaire Rust précompilé, téléchargé automatiquement)
--   - configure tout seul les "capabilities" LSP sous Neovim 0.11+
--
-- Version : on reste sur la branche stable 1.x (la v2 est en développement
-- avec des changements cassants, d'après le README officiel).
--
-- Touches (preset "default", même logique que la complétion native de Vim) :
--   Ctrl+n / Ctrl+p   élément suivant / précédent (ou flèches)
--   Ctrl+y            ACCEPTER la proposition
--   Ctrl+e            fermer le menu
--   Ctrl+Espace       ouvrir le menu / la documentation
--   Tab / Shift+Tab   sauter au champ suivant d'un snippet
--   Ctrl+k            afficher/masquer la signature de la fonction
-- ============================================================================

return {
  "saghen/blink.cmp",
  version = "1.*", -- tag de version -> binaire précompilé téléchargé
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    keymap = { preset = "default" },
    completion = {
      -- affiche la documentation de l'élément sélectionné après 300 ms
      documentation = { auto_show = true, auto_show_delay_ms = 300 },
    },
    -- aide sur les paramètres pendant qu'on tape un appel de fonction
    signature = { enabled = true },
    sources = {
      -- lsp = serveur de langage, path = chemins de fichiers,
      -- snippets = modèles fournis par le LSP, buffer = mots du fichier
      default = { "lsp", "path", "snippets", "buffer" },
    },
    fuzzy = { implementation = "prefer_rust_with_warning" },
  },
}
