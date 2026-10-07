-- ============================================================================
-- Telescope : recherche floue (fichiers, texte, buffers, aide…)
-- https://github.com/nvim-telescope/telescope.nvim
-- ============================================================================
-- Dans la fenêtre Telescope :
--   taper        -> filtre les résultats
--   Ctrl+n/p     -> résultat suivant / précédent (ou flèches)
--   Entrée       -> ouvrir
--   Ctrl+v / x   -> ouvrir dans un split vertical / horizontal
--   Ctrl+t       -> ouvrir dans un nouvel onglet
--   Ctrl+q       -> envoyer les résultats dans la quickfix list
--   Échap        -> fermer
--
-- Outils externes utilisés (Homebrew sur macOS, install.sh sous Linux) :
--   fd -> lister les fichiers (rapide, respecte .gitignore)
--   rg -> chercher dans le contenu des fichiers (ripgrep)
-- ============================================================================

-- Recherche de fichiers dans le répertoire de travail courant (:pwd) uniquement
local function find_files_cwd()
  local cwd = vim.uv.cwd()
  require("telescope.builtin").find_files({
    cwd = cwd,
    prompt_title = "Fichiers dans " .. vim.fn.fnamemodify(cwd, ":~"),
  })
end

-- Dossiers lourds à ignorer quand on cherche dans tout le HOME
-- (Library / .Trash = macOS ; ignorés sans effet sous Linux)
local home_excludes = {
  "Library", ".Trash", ".cache", ".npm", ".cargo", ".rustup", ".local",
  "node_modules", ".git", ".venv", "venv", "__pycache__", "miniconda3", "anaconda3",
}

-- Recherche de fichiers dans tout le HOME (plus lent : raccourci séparé)
local function find_files_home()
  local cmd = { "fd", "--type", "f", "--hidden" }
  for _, dir in ipairs(home_excludes) do
    vim.list_extend(cmd, { "--exclude", dir })
  end
  require("telescope.builtin").find_files({
    cwd = vim.env.HOME,
    find_command = cmd,
    prompt_title = "Fichiers dans ~ (HOME)",
  })
end

return {
  "nvim-telescope/telescope.nvim",
  version = "*", -- dernière version publiée (tag), recommandé par le README
  dependencies = {
    "nvim-lua/plenary.nvim", -- bibliothèque de fonctions Lua utilisée par Telescope
    -- Tri des résultats en C : beaucoup plus rapide que l'algorithme Lua par défaut.
    -- `build = "make"` le compile à l'installation (nécessite make + gcc/clang).
    -- Ignoré si make ou le compilateur manque : Telescope marche quand même.
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
      enabled = vim.fn.executable("make") == 1
        and (vim.fn.executable("cc") == 1 or vim.fn.executable("gcc") == 1 or vim.fn.executable("clang") == 1),
    },
  },
  cmd = "Telescope", -- chargé seulement à la 1ʳᵉ utilisation (démarrage plus rapide)
  keys = {
    -- Ctrl+P : fichiers du répertoire de travail courant UNIQUEMENT (:pwd)
    { "<C-p>", find_files_cwd, desc = "Fichiers (répertoire courant)" },
    { "<leader>ff", find_files_cwd, desc = "Fichiers (répertoire courant)" },
    { "<leader>fh", find_files_home, desc = "Fichiers dans tout le HOME" },
    { "<leader>fg", "<Cmd>Telescope live_grep<CR>", desc = "Chercher du texte (grep)" },
    { "<leader>fw", "<Cmd>Telescope grep_string<CR>", mode = { "n", "x" }, desc = "Chercher le mot sous le curseur" },
    { "<leader>fb", "<Cmd>Telescope buffers<CR>", desc = "Buffers ouverts" },
    { "<leader>fr", "<Cmd>Telescope oldfiles<CR>", desc = "Fichiers récents" },
    { "<leader>f/", "<Cmd>Telescope current_buffer_fuzzy_find<CR>", desc = "Chercher dans le fichier" },
    { "<leader>fd", "<Cmd>Telescope diagnostics<CR>", desc = "Diagnostics (erreurs LSP)" },
    { "<leader>fs", "<Cmd>Telescope lsp_document_symbols<CR>", desc = "Symboles du fichier (fonctions…)" },
    { "<leader>fk", "<Cmd>Telescope keymaps<CR>", desc = "Tous les raccourcis" },
    { "<leader>fH", "<Cmd>Telescope help_tags<CR>", desc = "Aide de Neovim" },
    { "<leader>f.", "<Cmd>Telescope resume<CR>", desc = "Reprendre la dernière recherche" },
    { "<leader>gS", "<Cmd>Telescope git_status<CR>", desc = "Git : fichiers modifiés" },
    { "<leader>gl", "<Cmd>Telescope git_commits<CR>", desc = "Git : historique des commits" },
  },
  config = function()
    local telescope = require("telescope")
    telescope.setup({
      defaults = {
        -- live_grep : inclut les fichiers cachés (.env, .github/…) mais pas .git/
        vimgrep_arguments = {
          "rg", "--color=never", "--no-heading", "--with-filename",
          "--line-number", "--column", "--smart-case",
          "--hidden", "--glob", "!**/.git/*",
        },
        path_display = { "truncate" },
      },
      pickers = {
        -- find_files : fd, fichiers cachés inclus, .git/ exclu, .gitignore respecté
        find_files = {
          find_command = { "fd", "--type", "f", "--hidden", "--exclude", ".git" },
        },
        buffers = { sort_mru = true, ignore_current_buffer = true },
      },
    })
    -- pcall = "essaie sans planter" : si fzf-native n'est pas compilé,
    -- Telescope fonctionne quand même avec le tri Lua.
    pcall(telescope.load_extension, "fzf")
  end,
}
