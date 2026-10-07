# Cheatsheet Neovim

`<leader>` = **Espace**. `Ctrl+x` s'écrit aussi `<C-x>`.
Astuce : appuie sur **Espace** et attends une demi-seconde, **which-key** affiche la suite.

---

## ⭐ À retenir en premier

| Touches | Action |
|---|---|
| `Ctrl+p` | Chercher un fichier dans le dossier courant (`:pwd`) |
| `Espace fg` | Chercher du texte dans tous les fichiers du dossier |
| `Ctrl+n` | Ouvrir / fermer l'explorateur (Neo-tree) |
| `gd` | Aller à la définition (fonction, variable…) |
| `K` | Documentation de ce qui est sous le curseur |
| `Ctrl+y` | Accepter la proposition d'autocomplétion |
| `Espace cf` | Formater le fichier |
| `[d` / `]d` | Erreur précédente / suivante |
| `Ctrl+h/j/k/l` | Changer de fenêtre (gauche/bas/haut/droite) |
| `Espace` (attendre) | Voir tous les raccourcis disponibles |

---

## Navigation (dans un fichier)

| Touches | Action |
|---|---|
| `h j k l` | ← ↓ ↑ → |
| `w` / `b` | mot suivant / précédent |
| `0` / `^` / `$` | début de ligne / 1ᵉʳ caractère / fin de ligne |
| `gg` / `G` | début / fin du fichier |
| `42G` ou `:42` | aller à la ligne 42 |
| `5j` / `3k` | descendre de 5 / monter de 3 (voir numéros relatifs) |
| `Ctrl+d` / `Ctrl+u` | descendre / monter d'une demi-page |
| `%` | aller à la parenthèse/accolade correspondante |
| `f x` / `t x` | sauter sur / juste avant le prochain caractère `x` |
| `Ctrl+o` / `Ctrl+i` | position précédente / suivante (après un saut) |
| `zc` / `zo` / `za` | plier / déplier / basculer le bloc (fonction, classe) |
| `zM` / `zR` | tout plier / tout déplier |

## Fichiers

| Touches | Action |
|---|---|
| `:w` | sauvegarder |
| `:q` | quitter (propose de sauvegarder si besoin) |
| `:wq` ou `ZZ` | sauvegarder et quitter |
| `:q!` | quitter sans sauvegarder |
| `:e chemin` | ouvrir un fichier |
| `:pwd` / `:cd chemin` | afficher / changer le dossier de travail |
| `u` / `Ctrl+r` | annuler / refaire (historique conservé après fermeture) |

## Recherche

| Touches | Action |
|---|---|
| `/texte` puis `n` / `N` | chercher dans le fichier, suivant / précédent |
| `*` | chercher le mot sous le curseur |
| `Échap` | effacer le surlignage de la recherche |
| `:%s/ancien/nouveau/g` | remplacer dans tout le fichier |
| `:%s/ancien/nouveau/gc` | idem, en demandant confirmation |

## Telescope (recherche floue)

| Touches | Action |
|---|---|
| `Ctrl+p` | fichiers du **dossier courant uniquement** |
| `Espace ff` | idem (alias) |
| `Espace fh` | fichiers dans **tout le HOME** (plus lent ; ignore Library, .cache…) |
| `Espace fg` | chercher du **texte** dans le dossier (live grep, ripgrep) |
| `Espace fw` | chercher le mot sous le curseur |
| `Espace fb` | buffers ouverts |
| `Espace fr` | fichiers récents |
| `Espace f/` | chercher dans le fichier courant |
| `Espace fs` | symboles du fichier (fonctions, classes) |
| `Espace fd` | liste des erreurs/avertissements |
| `Espace fk` | tous les raccourcis |
| `Espace fH` | chercher dans l'aide de Neovim |
| `Espace f.` | reprendre la dernière recherche |

**Dans la fenêtre Telescope :** `Ctrl+n`/`Ctrl+p` (ou flèches) pour se déplacer, `Entrée` pour ouvrir, `Ctrl+v` / `Ctrl+x` pour ouvrir en split vertical / horizontal, `Ctrl+t` pour un onglet, `Ctrl+q` pour envoyer dans la quickfix, `Échap` pour fermer.

## Neo-tree (explorateur)

| Touches | Action |
|---|---|
| `Ctrl+n` | ouvrir / fermer |
| `Espace e` | ouvrir sur le fichier courant |
| `Espace be` | buffers ouverts (fenêtre flottante) |
| `Espace ge` | fichiers modifiés selon Git (flottant) |
| *dans Neo-tree* `Entrée` | ouvrir le fichier / le dossier |
| `a` | créer un fichier (finir par `/` pour un dossier) |
| `r` / `m` / `c` / `d` | renommer / déplacer / copier / supprimer |
| `H` | afficher / masquer les fichiers ignorés |
| `Retour arrière` / `.` | remonter / définir comme racine |
| `s` / `S` | ouvrir en split vertical / horizontal |
| `?` | aide complète |
| `q` | fermer |

## LSP (intelligence du code : Python, Lua, Bash, C/C++)

| Touches | Action |
|---|---|
| `gd` | aller à la définition |
| `gD` | aller à la déclaration |
| `grr` | voir toutes les références |
| `gri` | aller à l'implémentation |
| `grt` | aller à la définition du type |
| `K` | documentation (hover) |
| `grn` ou `Espace cr` | renommer partout |
| `gra` ou `Espace ca` | actions de code (corriger, importer…) |
| `gO` | plan du fichier (symboles) |
| `Ctrl+s` *(insertion)* | signature de la fonction |
| `[d` / `]d` | diagnostic précédent / suivant |
| `Espace cd` | détail du diagnostic sous le curseur |
| `Espace cq` | liste des diagnostics du fichier |
| `Espace cf` | formater le fichier (ou la sélection en visuel) |

**Autocomplétion (blink.cmp)** : `Ctrl+n`/`Ctrl+p` pour choisir, **`Ctrl+y` pour accepter**, `Ctrl+e` pour fermer, `Ctrl+Espace` pour ouvrir manuellement, `Tab` pour passer au champ suivant d'un snippet.

## Git (gitsigns + Telescope)

| Touches | Action |
|---|---|
| `]h` / `[h` | modification (hunk) suivante / précédente |
| `Espace gp` | aperçu de la modification |
| `Espace gs` | stage / unstage la modification (ou la sélection) |
| `Espace gr` | annuler la modification (ou la sélection) |
| `Espace gb` | qui a écrit cette ligne (blame) |
| `Espace gB` | blame permanent en fin de ligne on/off |
| `Espace gd` | diff du fichier avec le dernier commit |
| `Espace gS` | liste des fichiers modifiés (Telescope) |
| `Espace gl` | historique des commits (Telescope) |
| `Espace ge` | arbre des fichiers modifiés (Neo-tree) |

Marge : `│` vert = ajouté, `│` orange = modifié, `_` rouge = supprimé.
Pour commit / push : `Espace tt` (terminal) puis `git …`.

## Buffers (fichiers ouverts)

| Touches | Action |
|---|---|
| `]b` / `[b` | buffer suivant / précédent |
| `Espace fb` | choisir un buffer (Telescope) |
| `Ctrl+^` | revenir au buffer précédent |
| `Espace bd` | fermer le buffer |
| `Espace bo` | fermer tous les autres buffers |

## Tabs (onglets)

| Touches | Action |
|---|---|
| `Espace tn` | nouvel onglet |
| `Espace tc` | fermer l'onglet |
| `gt` / `gT` | onglet suivant / précédent |
| `3gt` | aller à l'onglet 3 |

## Splits (fenêtres)

| Touches | Action |
|---|---|
| `:vsplit` ou `Ctrl+w v` | split vertical (à droite) |
| `:split` ou `Ctrl+w s` | split horizontal (en bas) |
| `Ctrl+h/j/k/l` | aller à la fenêtre ← ↓ ↑ → |
| `Ctrl+w q` | fermer la fenêtre |
| `Ctrl+w o` | garder seulement la fenêtre courante |
| `Ctrl+w =` | égaliser les tailles |
| `Ctrl+w >` / `<` / `+` / `-` | élargir / rétrécir / agrandir / réduire |

## Terminal

| Touches | Action |
|---|---|
| `Espace tt` | ouvrir un terminal en bas |
| `Échap Échap` | quitter le mode terminal (pour naviguer/copier) |
| `i` | revenir taper dans le terminal |
| `:terminal` | terminal plein écran |

## Treesitter

| Commande | Action |
|---|---|
| `:InspectTree` | voir l'arbre syntaxique du fichier (pédagogique) |
| `:Inspect` | groupe de couleur sous le curseur |
| `:TSInstall langage` | installer un parser (ex : `:TSInstall javascript`) |
| `:TSUpdate` | mettre à jour les parsers |

## Plugins

| Commande | Action |
|---|---|
| `:Lazy` | interface des plugins |
| `:Lazy update` | mettre à jour les plugins |
| `:Lazy profile` | temps de chargement de chaque plugin |
| `:ConformInfo` | formateurs disponibles pour le fichier |
| `:checkhealth` | diagnostic complet |
| `:checkhealth vim.lsp` | état des serveurs LSP |

## Commandes Neovim utiles

| Commande | Action |
|---|---|
| `:help sujet` | aide (ex : `:help motion`) — `Ctrl+]` pour suivre un lien |
| `:Tutor` | tutoriel interactif intégré (30 min, recommandé !) |
| `:messages` | revoir les messages / erreurs |
| `:noh` | effacer le surlignage (ou `Échap`) |
| `.` | répéter la dernière modification |
| `ciw` / `di"` / `ya(` | changer le mot / effacer dans "" / copier dans () |
| `>>` / `<<` | indenter / désindenter (en visuel : `>` / `<`) |
| `gcc` / `gc` (visuel) | commenter / décommenter (natif) |
| `v` / `V` / `Ctrl+v` | sélection caractère / ligne / bloc (colonnes) |
| `q a` … `q` puis `@a` | enregistrer puis rejouer une macro |
