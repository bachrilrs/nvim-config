-- ============================================================================
-- Autocommandes : du code exécuté automatiquement sur un événement
-- ============================================================================
-- Exemples d'événements : ouverture d'un type de fichier (FileType),
-- copie de texte (TextYankPost), sauvegarde (BufWritePre)…
-- Liste complète : `:help autocmd-events`
-- ============================================================================

local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Surligne brièvement le texte copié (yank) pour voir ce qui a été copié
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function()
    vim.hl.on_yank()
  end,
})

-- Indentation de 2 espaces pour les langages où c'est la convention
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "lua", "yaml", "json", "jsonc", "markdown", "r" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
  end,
})

-- Markdown / texte : retour à la ligne visuel et correcteur orthographique
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true -- coupe entre les mots, pas au milieu
  end,
})

-- Revenir à la dernière position du curseur à la réouverture d'un fichier
vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local lines = vim.api.nvim_buf_line_count(args.buf)
    if mark[1] > 0 and mark[1] <= lines and vim.bo[args.buf].filetype ~= "gitcommit" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Le terminal intégré démarre directement en mode insertion, sans numéros
vim.api.nvim_create_autocmd("TermOpen", {
  group = group,
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = "no"
    vim.cmd.startinsert()
  end,
})
