# Suivi d'avancement — Quizz

Document de référence pour l'état du projet. Basé sur :

- [`README.md`](README.md) — MVP, structure, roadmap
- [`.cursor/rules/tab-pages.mdc`](.cursor/rules/tab-pages.mdc) — architecture des onglets
- [`.cursor/rules/visual-da.mdc`](.cursor/rules/visual-da.mdc) — direction artistique Minimal Premium

**Branche suivie :** `test`  
**Dernier commit :** `9282a7a` — *Apply Minimal Premium UI with independent tab pages and a full-width top bar.*

---

## Vue d'ensemble

| Zone | État | Notes |
|------|------|-------|
| MVP gameplay | ✅ Fait | Quiz 7 questions, timer, score, sauvegarde locale |
| App shell (5 onglets) | ✅ Fait | Navigation swipe + barre du bas + FAB Quiz |
| Direction artistique | ✅ Fait | `UiTokens`, `UiStyle`, thème, shader fond |
| Profil joueur | ✅ Fait | Stats, badges, avatar, historique (données démo si vide) |
| Classement | 🟡 UI seule | Podium visuel + message « Bientôt disponible » |
| Social | 🟡 UI seule | Cartes amis fictives + message « Bientôt disponible » |
| Roadmap post-MVP | ⬜ À faire | Voir section Roadmap |

---

## MVP (README)

| Fonctionnalité | État | Détail |
|----------------|------|--------|
| Menu principal + langue FR/EN | ✅ | Réglages langue dans l'app shell (plus de scène `main_menu` au lancement) |
| Sélection de catégorie | ✅ | Sport, Cinéma, Histoire — intégrée dans l'onglet Quiz |
| Partie 7 questions, timer 10 s | ✅ | `quiz_game.tscn` + `GameManager` |
| Score vitesse + combo | ✅ | `ScoringSystem` |
| Sauvegarde locale (niveau, XP, stats) | ✅ | `SaveManager` |
| Contenu bilingue (JSON + CSV) | ✅ | 3 catégories, 2 questions chacune pour l'instant |

**Scène de lancement :** `scenes/app_shell.tscn` (Godot 4.7)

---

## Architecture des onglets (tab-pages.mdc)

Chaque page est une scène + script dédiés. L'`app_shell` ne contient que le chrome (top bar, nav, réglages).

| Onglet | Scène | Script | État |
|--------|-------|--------|------|
| Accueil | `scenes/tabs/home_tab.tscn` | `scripts/ui/home_tab.gd` | ✅ Cartes progression, streak, rang |
| Classement | `scenes/tabs/leaderboard_tab.tscn` | `scripts/ui/leaderboard_tab.gd` | 🟡 Placeholder |
| Quiz | `scenes/tabs/quiz_tab.tscn` | `scripts/ui/quiz_tab.gd` | ✅ Embarque `category_select` |
| Social | `scenes/tabs/social_tab.tscn` | `scripts/ui/social_tab.gd` | 🟡 Placeholder |
| Profil | `scenes/tabs/profile_tab.tscn` | `scripts/ui/profile_tab.gd` | ✅ Complet |

Ordre swipe / nav : Accueil → Classement → **Quiz (centre)** → Social → Profil  
(`ScenePaths.TAB_PAGE_ORDER`)

Hook disponible sur chaque onglet : `on_tab_shown()`.

---

## Direction artistique (visual-da.mdc)

| Élément | État | Fichiers |
|---------|------|----------|
| Fond blanc / brume + glow cyan-lavande | ✅ | `shaders/quizup_bg.gdshader` |
| Cartes blanches arrondies, ombres douces | ✅ | `UiStyle`, `quizup_theme.tres` |
| Texte encre `#1E2126` + gris secondaire | ✅ | `UiTokens` |
| Accents par onglet (teal, gold, bleu, magenta, violet) | ✅ | `UiTokens.TAB_ACCENTS` |
| Top app bar pleine largeur (logo + réglages) | ✅ | `scenes/ui/top_app_bar.tscn` |
| Nav flottante + FAB Quiz circulaire | ✅ | `scenes/ui/bottom_nav_bar.tscn` |
| Pas de tuile « jouer » sur Accueil | ✅ | FAB Quiz = action principale |

---

## Contenu & données

| Élément | Quantité | État |
|---------|----------|------|
| Catégories | 3 (sport, cinema, history) | ✅ |
| Questions par catégorie | 2 | ⚠️ Peu de contenu — roadmap « More categories and questions » |
| Traductions UI (FR/EN) | `locale/ui.csv` | ✅ |
| Profil démo (si aucune partie jouée) | `ProfileSnapshot` | ✅ Aperçu avec données fictives |

---

## Roadmap (README)

| Item | État | Notes |
|------|------|-------|
| Daily challenge mode | ⬜ | Non commencé |
| Async 1v1 challenges | ⬜ | Onglet Social = placeholder UI |
| Leaderboards | 🟡 | Onglet Classement = UI podium, pas de données réelles |
| More categories and questions | ⬜ | 6 questions au total aujourd'hui |

---

## Branches GitHub

| Branche | Contenu doc | Usage |
|---------|-------------|-------|
| `main` | `README.md` | Branche par défaut, MVP initial |
| `test` | `README.md` + `.cursor/rules/*.mdc` + **ce fichier** | UI Minimal Premium, app shell |
| `profil-joueur` | `README.md` | Travail profil (antérieur, fusionné dans `test`) |
| `cursor/quiz-godot-setup-8935` | `README.md` | Setup initial Cursor |

---

## Prochaines étapes suggérées

1. **Contenu** — Ajouter des questions (objectif : rounds variés sans répétition immédiate).
2. **Classement** — Brancher des données (local puis en ligne) sur `leaderboard_tab`.
3. **Social** — Définir le flux défi 1v1 async et remplacer les cartes fictives.
4. **Daily challenge** — Mode quotidien partagé (nouvelle scène / règles dédiées).
5. **README** — Mettre à jour la structure projet et la scène principale (`app_shell` au lieu de `main_menu`).

---

## Historique récent (`test`)

- branche `visual/arcade-lot1` — Passe « Arcade Premium » (lot 1) : réponses 4 couleurs, timer d'urgence (rampe + pulse), combo/score animés, feedback net (punch / shake), écran résultats (note S–D, count-up, burst sans-faute), fond visible, nettoyage tokens/thème + police Nunito, retrait des assets morts (`fableris_theme`, polices serif)
- `9282a7a` — UI Minimal Premium, onglets indépendants, top bar
- `e8b1fa8` — Tailles icônes / labels nav
- `00d066d` — App shell, onglet Quiz mis en avant, refresh UI QuizUp
- `8d45334` — Écran profil joueur (stats, avatar)

---

*Mis à jour le 2026-09-02 — branche `test`.*
