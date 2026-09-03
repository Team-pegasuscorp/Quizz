# Agent handoff — branche `test`

> Dernière mise à jour : **2026-09-03**  
> Lire aussi : [`PROGRESS.md`](PROGRESS.md), [`docs/CATEGORIES.md`](docs/CATEGORIES.md)

Résumé pour la prochaine session de travail sur Quizz (Godot 4.7, FR/EN).

---

## État du projet

| Zone | Statut |
|------|--------|
| MVP gameplay (quiz 7 Q, timer, score, save) | ✅ |
| App shell 5 onglets (Minimal Premium UI) | ✅ |
| Contenu questions (~173, 3 catégories) | ✅ import OpenTDB |
| **Classement local** | ✅ joueur + 9 rivaux + filtres |
| **Historique profil** | ✅ 30 dernières parties sauvegardées |
| Social / multijoueur en ligne | ⬜ placeholder |
| Daily challenge | ⬜ |

**Scène principale :** `scenes/app_shell.tscn`  
**Branche active :** `test` (remote `origin/test`)

---

## Ce qui a été fait (session 2026-09-03) — passe visuelle « Arcade Premium » lot 1

Branche `visual/arcade-lot1` (partie de `test`). Aucune feature ajoutée, aucun nouveau texte i18n.

### Fondations
- `scripts/config/ui_tokens.gd` — retrait des alias morts (`BRAND_*`), échelle de rayons `RADIUS_SM/MD/LG/PILL`, palette `ANSWER_SLOTS` (4 couleurs réponses), tokens `TIMER_*`, helpers `answer_slot_color()` / `combo_tier()` / `timer_color_for_ratio()`.
- `scripts/config/ui_style.gd` — helpers `answer_tile()`, `answer_tile_state()`, `timer_fill_for_ratio()`, `combo_badge()` ; ombre d'accent des cartes 0.12 → 0.20.
- `themes/quizup_theme.tres` — rayons unifiés, retrait des bordures sur `hover`, police **Nunito** (Bold + ExtraBold) branchée sur `TitleLabel` / `QuestionLabel` / `PrimaryButton` + nouvelle variation `NumberLabel`.
- `shaders/quizup_bg.gdshader` — fond réellement visible (dégradé + 2 halos + vignette basse).
- `assets/fonts/` — ajout `Nunito-Bold.ttf`, `Nunito-ExtraBold.ttf`, `OFL.txt` ; retrait des serif inutilisées (Cinzel, Cormorant, DMMono) + `themes/fableris_theme.tres` + `assets/ui/icon_settings.png`.
  ⚠️ `themes/fableris_bg_material.tres` + `shaders/fableris_bg.gdshader` **conservés** : encore utilisés par `scenes/main_menu.tscn` et `scenes/profile/player_profile.tscn` (scènes legacy hors flux onglets — à repointer/supprimer au lot 2).

### Écran de jeu — `scenes/game/quiz_game.tscn` + `scripts/ui/quiz_game.gd`
- 4 réponses = 4 couleurs pleines (`UiStyle.answer_tile`), texte blanc bold.
- Timer : couleur bleu → ambre → rouge selon le temps + pulse sous 25 %.
- Score : gros chiffre `NumberLabel` avec count-up + punch à chaque gain.
- Combo : pastille `ComboBadge` masquée à x1, apparaît/grossit/change de couleur par palier (x2-3 / x4-5 / x6+).
- Feedback : bonne réponse = punch + fill vert ; mauvaise = shake + fill rouge ; réponses hors résultat estompées. Ancien `_blink_answer` (strobe) supprimé.
- Transition d'entrée de la question (fade + scale) + réponses en fade échelonné.
- Délai de feedback 1,2 s → **0,8 s** + **tap pour enchaîner** (`_input`).

### Écran résultats — `scenes/results/results_screen.tscn` + `scripts/ui/results_screen.gd`
- Note **S / A / B / C / D** dérivée de `correct/total` (lettres neutres, pas d'i18n), couleur par note, punch à l'entrée.
- Score + bonnes réponses en count-up.
- Sans-faute → `PerfectBanner` (réutilise `UI_ACH_PERFECT`) + burst de particules.
- `Spacer` corrigé (double sizing).

### Vérif faite / à faire
- ✅ Parse GDScript validé (`godot --headless --check-only`) sur les 4 scripts modifiés.
- ✅ Structure des `.tscn` / `.tres` validée (refs de ressources, arbre de nœuds).
- ⚠️ **Impossible de lancer Godot dans l'env proot/Termux** (`double free` du générateur de thème éditeur, 4.6 comme 4.7) → test visuel à faire dans un vrai éditeur : ouvrir le projet (laisse importer les 2 `.ttf`), F5 sur `app_shell`, jouer une manche catégorie **Histoire** (réponses longues), vérifier couleurs / timer / combo / feedback / résultats / sans-faute, puis basculer FR↔EN.

---

## Ce qui a été fait (session 2026-09-02)

### 1. Documentation
- `PROGRESS.md` — suivi MVP / roadmap / onglets
- `docs/CATEGORIES.md` — mapping Quizz ↔ OpenTDB (24 catégories API)

### 2. Contenu questions (OpenTDB + traduction locale)
- Script `tools/import_opentdb.py` — fetch OpenTDB → traduction FR offline via **Argos Translate** → JSON Quizz
- `data/categories.json` — champ `opentdb_id` par catégorie
- ~**59 sport**, **57 cinema**, **57 history** (FR + EN)

```bash
python3 -m venv tools/.venv
tools/.venv/bin/pip install -r tools/requirements.txt
tools/.venv/bin/python tools/import_opentdb.py --install-models   # une fois
tools/.venv/bin/python tools/import_opentdb.py --amount 30
```

Licence OpenTDB : **CC BY-SA 4.0** — créditer la source si redistribution.

### 3. Classement local (`leaderboard_tab`)
- `scripts/profile/leaderboard_snapshot.gd` — construit le classement
- `SaveManager.leaderboard_rivals` — 9 rivaux générés au 1er lancement
- Filtres : Toutes | Sport | Cinéma | Histoire
- Podium top 3 + liste 4–10, rang du joueur mis en avant
- **Démo** si aucune partie jouée (`USE_DEMO_WHEN_EMPTY`)

Score classement = **meilleur score** (`category_stats.best_score`).

### 4. Historique profil
- `SaveManager.match_history` — 30 dernières parties (`played_at`, score, catégorie, won…)
- `ProfileSnapshot` — historique réel dans l’onglet Profil
- Stats réelles : wins, losses, streaks, win rate (plus de faux 55 %)
- Victoire = **strictement > 50 %** de bonnes réponses (`correct * 2 > total`)

---

## Fichiers clés à ne pas casser

| Fichier | Rôle |
|---------|------|
| `scripts/config/scene_paths.gd` | Ordre et chemins des 5 onglets |
| `scripts/config/ui_tokens.gd` / `ui_style.gd` | DA Minimal Premium |
| `scripts/quiz/question_loader.gd` | Charge catégories + questions JSON |
| `scripts/autoload/save_manager.gd` | Save `user://save.json` |
| `scripts/profile/profile_snapshot.gd` | Données profil + historique |
| `scripts/profile/leaderboard_snapshot.gd` | Données classement |
| `.cursor/rules/tab-pages.mdc` | 1 scène + 1 script par onglet |
| `.cursor/rules/visual-da.mdc` | Règles visuelles |

---

## Structure save (`user://save.json`)

```json
{
  "player_name": "...",
  "level": 1,
  "xp": 0,
  "category_stats": { "sport": { "games_played", "best_score", ... } },
  "leaderboard_rivals": [ { "name", "level", "scores": { "all", "sport", ... } } ],
  "match_history": [ { "category_id", "score", "correct_count", "total_count", "max_combo", "won", "played_at" } ],
  "wins": 0,
  "losses": 0,
  "current_win_streak": 0,
  "best_win_streak": 0,
  "has_perfect_round": false
}
```

---

## Prochaines étapes suggérées

1. **Social** — défis 1v1 async (onglet Social = placeholder)
2. **Classement en ligne** — remplacer rivaux locaux par une API
3. **Daily challenge** — mode défi du jour
4. **Contenu** — réimporter ou relire les traductions Argos (qualité variable)
5. **README** — mettre à jour (scène principale `app_shell`, structure actuelle)

---

## Conventions

- Ne pas mutualiser les onglets : 1 paire `.tscn` + `.gd` par page (`tab-pages.mdc`)
- Chrome (top bar, nav) dans `app_shell` seulement
- Traductions UI : `locale/ui.csv` → regénérer `.translation` dans Godot si besoin
- Commits : messages en anglais impératif (style repo existant)

---

## Lancer le projet

```bash
godot --path .
# F5 — scène principale app_shell.tscn
```
