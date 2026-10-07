-- ============================================================================
-- nvim-treesitter : parsers pour la coloration syntaxique moderne
-- https://github.com/nvim-treesitter/nvim-treesitter  (branche `main`)
-- ============================================================================
-- ⚠️  API ACTUELLE (branche main, réécriture de 2025) :
--   - `require("nvim-treesitter.configs")` N'EXISTE PLUS (ancienne branche
--     `master`, utilisée par les vieux tutoriels et neovim-for-newbs).
--   - Le plugin ne fait plus qu'INSTALLER les parsers et les "queries".
--   - La coloration, le pliage, etc. sont fournis par Neovim lui-même :
--     on les active avec vim.treesitter.start() (voir plus bas).
--   - Prérequis : Neovim >= 0.12, tree-sitter-cli >= 0.26.1, curl, tar,
--     un compilateur C. Tous présents sur ta machine.
--   - Le plugin ne supporte PAS le lazy-loading (lazy = false obligatoire).
--
-- Commandes utiles :
--   :TSInstall <langage>   installer un parser
--   :TSUpdate              mettre à jour les parsers
--   :checkhealth nvim-treesitter
--   :InspectTree           voir l'arbre syntaxique du fichier (pédagogique !)
--   :Inspect               voir le groupe de couleur sous le curseur
-- ============================================================================

-- Parsers installés : uniquement ceux utiles pour ton profil.
local parsers = {
  -- Programmation
  "python", "lua", "bash", "c", "cpp", "r",
  -- Bioinformatique / données
  "snakemake", "csv",
  -- Fichiers de configuration et données
  "json", "yaml", "toml",
  -- Documentation
  "markdown", "markdown_inline",
  -- Neovim lui-même (config Vimscript, :help, requêtes Treesitter)
  "vim", "vimdoc", "query",
  -- Git
  "diff", "gitcommit", "git_config", "gitignore",
  -- Utilisé par d'autres parsers (regex dans Python, Lua…)
  "regex",
}

return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false,
  build = ":TSUpdate", -- met à jour les parsers quand le plugin est mis à jour
  config = function()
    local ts = require("nvim-treesitter")
    ts.setup() -- valeurs par défaut : parsers installés dans ~/.local/share/nvim/site
    -- Installation des parsers (asynchrone, ne fait rien si déjà installés).
    -- Nécessite tree-sitter-cli et un compilateur C : s'ils manquent, on
    -- prévient une fois au lieu d'afficher des erreurs de compilation.
    local missing = {}
    if vim.fn.executable("tree-sitter") == 0 then
      table.insert(missing, "tree-sitter (CLI)")
    end
    if vim.fn.executable("cc") == 0 and vim.fn.executable("gcc") == 0 and vim.fn.executable("clang") == 0 then
      table.insert(missing, "compilateur C (gcc/clang)")
    end
    -- Parsers de la liste pas encore installés
    local installed = ts.get_installed("parsers")
    local todo = vim.tbl_filter(function(p)
      return not vim.tbl_contains(installed, p)
    end, parsers)
    if #missing == 0 then
      ts.install(parsers)
    elseif #todo > 0 then -- on ne prévient que s'il manque vraiment des parsers
      vim.notify(
        "Treesitter : parsers non installés, il manque " .. table.concat(missing, ", ")
          .. ".\nLa coloration classique de Vim reste active.",
        vim.log.levels.WARN
      )
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
      callback = function(args)
        -- Démarre la coloration Treesitter si un parser existe pour ce
        -- type de fichier. Sinon (pcall échoue) on garde la coloration
        -- classique de Vim : aucune erreur affichée.
        if not pcall(vim.treesitter.start, args.buf) then
          return
        end
        -- Pliage basé sur la structure du code (fonctions, classes…).
        -- Fourni par Neovim, stable. zc = plier, zo = déplier, za = basculer.
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        -- NB : l'indentation Treesitter est encore "expérimentale" selon la
        -- doc officielle -> on garde l'indentation native de Neovim, fiable
        -- pour Python, Lua, Bash, C.
      end,
    })
  end,
}
