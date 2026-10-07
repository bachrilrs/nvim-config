-- ============================================================================
-- Raccourcis généraux (indépendants des plugins)
-- ============================================================================
-- Les raccourcis des plugins sont définis dans le fichier du plugin concerné
-- (lua/plugins/*.lua) pour que tout ce qui concerne un plugin soit au même
-- endroit.
--
-- Logique des raccourcis <leader> (Espace) :
--   <leader>f…  = Find      (Telescope : fichiers, texte, buffers…)
--   <leader>g…  = Git       (gitsigns)
--   <leader>c…  = Code      (format, diagnostics)
--   <leader>b…  = Buffers
--   <leader>t…  = Tabs / Terminal
--   <leader>e   = Explorateur (Neo-tree)
-- Appuie sur Espace et attends : which-key affiche la liste.
--
-- `vim.keymap.set(mode, touches, action, options)`
--   mode "n" = normal, "i" = insertion, "v"/"x" = visuel, "t" = terminal
-- ============================================================================

local map = vim.keymap.set

-- Effacer le surlignage de recherche avec Échap
map("n", "<Esc>", "<Cmd>nohlsearch<CR>", { desc = "Effacer le surlignage" })

-- Fenêtres (splits) : Ctrl + h/j/k/l pour se déplacer
map("n", "<C-h>", "<C-w>h", { desc = "Fenêtre de gauche" })
map("n", "<C-j>", "<C-w>j", { desc = "Fenêtre du bas" })
map("n", "<C-k>", "<C-w>k", { desc = "Fenêtre du haut" })
map("n", "<C-l>", "<C-w>l", { desc = "Fenêtre de droite" })

-- Buffers (fichiers ouverts). Neovim fournit déjà [b et ]b (précédent/suivant).
map("n", "<leader>bd", "<Cmd>bdelete<CR>", { desc = "Fermer le buffer" })
map("n", "<leader>bo", "<Cmd>%bdelete|edit#|bdelete#<CR>", { desc = "Fermer les autres buffers" })

-- Tabs (onglets). Neovim fournit déjà gt / gT (suivant/précédent).
map("n", "<leader>tn", "<Cmd>tabnew<CR>", { desc = "Nouvel onglet" })
map("n", "<leader>tc", "<Cmd>tabclose<CR>", { desc = "Fermer l'onglet" })

-- Terminal intégré
map("n", "<leader>tt", "<Cmd>botright 12split | terminal<CR>", { desc = "Terminal en bas" })
-- En mode terminal, Échap deux fois revient en mode normal
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Quitter le mode terminal" })

-- Mode visuel : garder la sélection après une indentation avec < ou >
map("v", "<", "<gv", { desc = "Désindenter" })
map("v", ">", ">gv", { desc = "Indenter" })

-- Diagnostics (erreurs/avertissements LSP)
-- Déjà fournis par Neovim : [d / ]d (précédent/suivant), <C-w>d (détail)
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Détail du diagnostic" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Liste des diagnostics" })
