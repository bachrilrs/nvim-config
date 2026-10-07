-- ============================================================================
-- gitsigns.nvim : Git dans la marge
-- https://github.com/lewis6991/gitsigns.nvim
-- ============================================================================
-- Affiche dans la colonne de gauche les lignes ajoutées (│ vert),
-- modifiées (│ orange) et supprimées (_ rouge) depuis le dernier commit.
-- Un "hunk" = un bloc de lignes modifiées.
--
-- Choix volontaire : pas de vim-fugitive ni de neogit. Pour commit, push,
-- rebase… le terminal reste l'outil le plus simple et le plus transparent
-- (<leader>tt ouvre un terminal dans Neovim, ou utilise WezTerm à côté).
-- Telescope ajoute <leader>gS (fichiers modifiés) et <leader>gl (commits).
-- ============================================================================

return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    on_attach = function(bufnr)
      local gs = require("gitsigns")
      local function map(mode, keys, fn, desc)
        vim.keymap.set(mode, keys, fn, { buffer = bufnr, desc = "Git : " .. desc })
      end

      -- Navigation entre les hunks (même logique que [d ]d pour les diagnostics)
      map("n", "]h", function() gs.nav_hunk("next") end, "hunk suivant")
      map("n", "[h", function() gs.nav_hunk("prev") end, "hunk précédent")

      -- Voir / annuler / valider un hunk
      map("n", "<leader>gp", gs.preview_hunk, "aperçu du hunk")
      map("n", "<leader>gs", gs.stage_hunk, "stage / unstage le hunk")
      map("n", "<leader>gr", gs.reset_hunk, "annuler le hunk")
      map("x", "<leader>gs", function() gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "stage la sélection")
      map("x", "<leader>gr", function() gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end, "annuler la sélection")

      -- Comprendre
      map("n", "<leader>gb", function() gs.blame_line({ full = true }) end, "blame de la ligne")
      map("n", "<leader>gB", gs.toggle_current_line_blame, "blame permanent on/off")
      map("n", "<leader>gd", gs.diffthis, "diff du fichier")
    end,
  },
}
