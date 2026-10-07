-- ============================================================================
-- LSP (Language Server Protocol) : l'intelligence du code
-- ============================================================================
-- Un "serveur de langage" est un programme externe qui analyse ton code
-- (erreurs, définition d'une fonction, renommage…). Neovim 0.12 sait lui
-- parler nativement : AUCUN plugin n'est nécessaire pour le LSP lui-même.
--
-- nvim-lspconfig sert uniquement de "catalogue" : il fournit la bonne
-- commande et les bons réglages pour chaque serveur (fichiers lsp/*.lua).
-- On n'utilise PLUS `require("lspconfig").xxx.setup()` (ancienne API, encore
-- visible dans neovim-for-newbs) mais l'API native :
--     vim.lsp.config("serveur", { réglages })   -- personnaliser
--     vim.lsp.enable({ "serveur", ... })        -- activer
--
-- Serveurs installés via Homebrew sur macOS, ou via install.sh sous Linux
-- (pas de Mason) :
--   basedpyright  -> Python : types, complétion, définition, hover
--   ruff          -> Python : lint (erreurs de style/bugs), imports, format
--   lua_ls        -> Lua (ta config Neovim)
--   bashls        -> Bash/Zsh (utilise shellcheck pour les diagnostics)
--   clangd        -> C/C++ (fourni par les Command Line Tools d'Apple)
--
-- Diagnostic : `:checkhealth vim.lsp`  (ou `:LspInfo`)
-- ============================================================================

-- Liste des serveurs à activer : ajouter un nom ici suffit (s'il est installé)
-- Clé = nom de la config lspconfig ; valeur = programme à trouver dans le PATH.
local servers = {
  basedpyright = "basedpyright-langserver",
  ruff = "ruff",
  lua_ls = "lua-language-server",
  bashls = "bash-language-server",
  clangd = "clangd",
}

return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" }, -- chargé à l'ouverture d'un fichier
  -- blink.cmp doit être chargé AVANT le démarrage des serveurs : il annonce
  -- aux serveurs les capacités de complétion supplémentaires.
  dependencies = { "saghen/blink.cmp" },
  config = function()
    -- Python : basedpyright -------------------------------------------------
    vim.lsp.config("basedpyright", {
      settings = {
        basedpyright = {
          -- Ruff s'occupe du tri des imports : on évite le doublon
          disableOrganizeImports = true,
          analysis = {
            -- "recommended" (défaut de basedpyright) est très strict et bavard.
            -- "standard" = même niveau que Pylance/VS Code. Modifiable par
            -- projet dans pyproject.toml : [tool.basedpyright] typeCheckingMode
            typeCheckingMode = "standard",
          },
        },
      },
    })

    -- Python : ruff --------------------------------------------------------
    -- Ruff choisirait l'encodage UTF-8 et basedpyright UTF-16 : deux serveurs
    -- sur le même fichier avec des encodages différents (avertissement dans
    -- :checkhealth vim.lsp). On demande UTF-16 à ruff pour qu'ils s'accordent.
    vim.lsp.config("ruff", {
      capabilities = { general = { positionEncodings = { "utf-16" } } },
    })

    -- C/C++ : clangd ---------------------------------------------------------
    -- Liste des types de fichiers limitée à ceux que Neovim connaît
    -- (le catalogue ajoute "c.doxygen"/"cpp.doxygen" -> avertissement health).
    vim.lsp.config("clangd", {
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    })

    -- Lua : faire connaître l'API de Neovim (`vim.*`) au serveur ----------------
    vim.lsp.config("lua_ls", {
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          workspace = {
            checkThirdParty = false,
            library = { vim.env.VIMRUNTIME },
          },
        },
      },
    })

    -- On n'active que les serveurs réellement installés : la même config
    -- fonctionne ainsi sur une machine où il en manque (ex : pas de clangd).
    local available = {}
    for name, exe in pairs(servers) do
      if vim.fn.executable(exe) == 1 then
        table.insert(available, name)
      end
    end
    vim.lsp.enable(available)

    -- Apparence des diagnostics (erreurs, avertissements) ---------------------
    vim.diagnostic.config({
      virtual_text = { spacing = 2, source = "if_many" }, -- message en fin de ligne
      severity_sort = true, -- les erreurs passent avant les avertissements
      float = { source = true }, -- montre quel outil a produit le message
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "",
          [vim.diagnostic.severity.WARN] = "",
          [vim.diagnostic.severity.INFO] = "",
          [vim.diagnostic.severity.HINT] = "󰌵",
        },
      },
    })

    -- Raccourcis actifs uniquement quand un serveur est attaché au buffer ----
    -- Neovim 0.12 fournit DÉJÀ ces raccourcis LSP par défaut :
    --   K     documentation (hover)       grn  renommer
    --   grr   références                  gra  actions de code
    --   gri   implémentation              grt  définition du type
    --   gO    symboles du fichier         Ctrl+s (insertion) signature
    --   [d ]d diagnostic précédent/suivant
    -- On ajoute seulement les classiques manquants + des alias <leader>c…
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
      callback = function(args)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = args.buf, desc = "LSP : " .. desc })
        end
        map("gd", vim.lsp.buf.definition, "aller à la définition")
        map("gD", vim.lsp.buf.declaration, "aller à la déclaration")
        map("<leader>cr", vim.lsp.buf.rename, "renommer")
        map("<leader>ca", vim.lsp.buf.code_action, "actions de code")

        -- Ruff et basedpyright fournissent tous deux le hover : on garde
        -- seulement celui de basedpyright (recommandé par la doc de Ruff).
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == "ruff" then
          client.server_capabilities.hoverProvider = false
        end
      end,
    })
  end,
}
