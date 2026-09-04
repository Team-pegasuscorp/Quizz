# Plan — Multijoueur mondial

Document de référence pour la mise en place du backend multijoueur (async + live).
Voir aussi [`VISION.md`](VISION.md) (Phase 2/3) et [`PROGRESS.md`](../PROGRESS.md).

**Décidé le 2026-09-04 :**
- Async (défis 1v1 différés) **et** live (matchmaking temps réel) dès le départ.
- Hébergement : VPS Hetzner (self-host), pas de backend managé (Supabase/Firebase) —
  moins cher (~4,35 €/mois vs 25-75 $/mois) et un backend live a de toute façon besoin
  d'un serveur applicatif à soi (Supabase seul ne fait qu'auth/DB/API, pas de logique
  de match autoritaire).
- Dev en local d'abord (Docker Compose sur le PC Arch), migration vers Hetzner ensuite
  sans changement de code — même conteneurs, juste l'adresse appelée par le client.
- Stack serveur : **Python + FastAPI** (cohérent avec `tools/import_opentdb.py`,
  REST + WebSocket dans le même framework).
- OS du VPS (au moment de migrer) : Ubuntu 24.04 LTS ou Debian 12, pas Arch — un
  serveur public sans supervision active bénéficie de mises à jour plus rares.

---

## Architecture

```
Client Godot (scripts/network/*)
   │  HTTPRequest (REST)         WebSocketPeer (live)
   ▼                                   ▼
FastAPI (uvicorn)  ──────────────────────────
   │
   ▼
Postgres (players, matches, leaderboards, daily_challenges, live_queue)
```

- Un seul service applicatif (FastAPI) gère REST + WebSocket.
- Un seul VPS à terme (Postgres + FastAPI + Caddy en reverse proxy HTTPS/WSS).
- Le client ne fait jamais foi pour le score final en mode live : le serveur valide
  timers et réponses.

---

## Phases

### Phase 1 — Infra locale ✅ (2026-09-04, `~/Documents/quizz-backend`)
- [x] `docker-compose.yml` : Postgres + service `api` (FastAPI/uvicorn)
- [x] Endpoint `/health`
- [x] Schéma SQL (`db/init/001_schema.sql`) : `players`, `matches` (leaderboard calculé à la volée sur `matches`, pas de table dédiée pour l'instant)

### Phase 2 — Comptes minimalistes ✅ (2026-09-04)
- [x] `device_id` + pseudo, pas d'email/mot de passe dans un premier temps
- [x] Table `players` (id, device_id, display_name, created_at) — déjà créée en Phase 1
- [x] `POST /players` — upsert idempotent (crée si nouveau `device_id`, sinon met à jour `display_name`)

### Phase 3 — API REST ✅ (2026-09-04)
- [x] `POST /matches` — soumission de score (404 propre si `player_id` inconnu)
- [x] `GET /leaderboard?category=` — classement global (`all` = meilleur score toutes catégories, comme `SaveManager._best_score_global()`) + par catégorie (`MAX(score)` par joueur)
- [x] `GET /daily-challenge` — catégorie + seed déterministes par date UTC (rotation `sport/cinema/history`) ; le set de 7 questions exact sera tiré côté client en Phase 4 à partir du seed (pas de duplication du contenu des questions côté serveur)
- [ ] Remplacer `SaveManager.leaderboard_rivals` par des données réelles dans `leaderboard_tab` → fait en Phase 4

### Phase 4 — Client Godot ✅ (2026-09-04)
- [x] Autoload `scripts/autoload/network_manager.gd` (HTTPRequest wrapper), enregistré dans `project.godot`
- [x] `device_id` généré (UUID v4 via `Crypto`) et persisté dans `user://device_id.txt`, enregistrement idempotent auprès de `POST /players` au démarrage
- [x] `BASE_URL` en dur sur `http://127.0.0.1:8000` (dev local) — seule ligne à changer en Phase 7 pour pointer vers Hetzner
- [x] `game_manager.gd` : soumission du score via `NetworkManager.submit_match(...)` après chaque partie (en plus de la sauvegarde locale existante), `SaveManager.is_match_won()` rendue publique pour éviter la duplication de la règle de victoire
- [x] `leaderboard_tab.gd` : affichage local/démo immédiat (pas de flash vide), puis remplacement en place par les données réelles de `GET /leaderboard` quand elles arrivent ; si le backend est injoignable, le classement local reste affiché (repli silencieux, offline-first)
- [x] Testé en conditions réelles : lancement headless du client → nouveau joueur visible dans Postgres, `device_id.txt` cohérent avec la base
- Limite connue : le classement en ligne n'a pas encore de niveau/titre de rang (le serveur ne stocke pas l'XP) — valeur `level=1` / `UI_RANK_ROOKIE` par défaut, à améliorer si besoin

### Phase 5 — Défis 1v1 async ✅ backend (2026-09-04), client en cours
- [x] Table `challenges` (`db/init/002_challenges.sql`) : code court (6 car., alphabet sans caractères ambigus), `challenger_id`, `opponent_id`, scores des deux côtés, `status` (`pending` → `accepted` → `completed`)
- [x] `POST /challenges` (créer), `POST /challenges/{code}/join` (rejoindre, refuse de rejoindre son propre défi, 409 si déjà accepté), `POST /challenges/{code}/result` (soumettre son score ; passe à `completed` seulement quand les deux scores sont présents), `GET /challenges/{code}` (état) — testés en bout en bout via curl (2 joueurs, tous les cas d'erreur)
- [x] Même set de 7 questions pour les deux joueurs : pas de duplication du contenu des questions côté serveur — le **code du défi sert de seed déterministe** pour `QuestionLoader.load_questions_for_category()` côté client (comme pour le daily challenge)
- [x] Branchement `social_tab` (remplace les cartes fictives) : sélection catégorie, création (code affiché + copie presse-papier), rejoindre par code, statut/rafraîchir, résultat gagné/perdu/égalité une fois les deux scores soumis
- [x] `question_loader.gd` : `load_questions_for_category(..., seed_value)` — shuffle déterministe (Fisher-Yates seedé) quand un seed est fourni, sinon comportement solo inchangé
- [x] `game_manager.gd` : `start_round(category, challenge_code)` + `active_challenge_code`, soumission auto du résultat de défi dans `finish_round()`
- [x] Locale : 18 nouvelles clés FR/EN dans `locale/ui.csv`, `.translation` régénérés (`godot --headless --import`)
- [x] Vérifié : backend testé en bout en bout via curl (2 joueurs simulés, tous les cas d'erreur), client headless compile et tourne sans erreur
- [x] **Vérifié manuellement** (2026-09-04) : défi async créé/rejoint/joué/résultat affiché, testé avec deux vraies fenêtres du jeu en parallèle sur la même machine (voir Phase 6 pour la technique d'isolation des profils)

### Phase 6 — Matchmaking live ✅ (2026-09-04)
- [x] Le contenu des questions (`data/categories.json` + `data/questions/*.json`) est **copié** dans `quizz-backend/app/data/` — nécessaire ici (contrairement à l'async) car le serveur doit connaître la bonne réponse pour valider en temps réel. **À resynchroniser manuellement si le contenu du jeu change** (pas de lien automatique entre les deux dépôts)
- [x] `question_bank.py` (charge/localise les questions), `scoring.py` (réplique exactement `scripts/quiz/scoring_system.gd` pour des scores comparables solo/async/live)
- [x] `live_match.py` : file d'attente en mémoire par catégorie (mono-process — cassera si l'API tourne un jour avec plusieurs workers uvicorn, noter pour Phase 7), `LiveMatch` authoritatif (un seul des deux sockets — le premier en file — pilote la partie ; l'autre attend via un `asyncio.Event`)
- [x] `ws://.../ws/live` : `join_queue` → `match_found` → 7×(`question` → `answer` du client → `reveal`) → `match_over` ; timer sur l'écoulement réel mesuré côté serveur (`time.monotonic()`), jamais sur une valeur envoyée par le client ; résultat persisté dans la table `matches` existante (compte donc aussi pour le classement global)
- [x] Client : `NetworkManager` gère le `WebSocketPeer` (poll dans `_process`), `social_tab.gd` a une section "Match en direct" (recherche/annuler, question+choix+compte à rebours, révélation colorée, écran de fin)
- [x] **Testé en conditions réelles** : un vrai client Godot headless contre un bot Python simulant l'adversaire, partie complète de 7 questions, scores et `won` cohérents des deux côtés, résultat bien inséré dans `matches`
- [x] Bug trouvé et corrigé pendant ce test : `NetworkManager._process()` plantait après `match_over` (le socket passait à `null` en plein milieu de la boucle de lecture des paquets)
- Outils de test ajoutés : `quizz-backend/tools/test_live_match.py` (+ `test_live_opponent.py`), `Quizz-main/tools/test_live_client.gd`/`.tscn` — utiles pour revalider ce flux après un futur changement
- [x] **Vérifié manuellement dans l'UI réelle** (2026-09-04) : deux fenêtres du jeu lancées en parallèle sur la même machine se sont trouvées et ont joué un match complet via l'onglet Social
- **Technique pour tester avec 2 "joueurs" sur une seule machine** : il n'existe pas de flag `--user-data-dir` dans cette build Godot (piège : ce flag n'existe pas, à ne pas réutiliser). La bonne méthode sur Linux est de surcharger `XDG_DATA_HOME` avant de lancer la deuxième instance, ex. :
  ```bash
  XDG_DATA_HOME=/tmp/quizz-player2-data godot --path . scenes/app_shell.tscn
  ```
  Godot range son dossier `user://` sous `$XDG_DATA_HOME/godot/app_userdata/<Projet>/` — sans ça, les deux fenêtres partagent le même `device_id.txt` et donc le même joueur (le matchmaking live plante silencieusement côté serveur si les deux moitiés d'un match ont le même `player_id`, à ne pas confondre avec un vrai bug du matchmaking)

### Phase 7 — Migration Hetzner + durcissement
- [ ] Créer le VPS (Ubuntu/Debian), domaine pointé dessus
- [ ] Caddy (HTTPS/WSS automatique)
- [ ] `docker compose up -d` sur le VPS (même compose qu'en local)
- [ ] Backups Postgres (cron `pg_dump`)
- [ ] Rate limiting, logs/monitoring basique, anti-abus

---

## Décisions encore ouvertes

| Décision | À trancher quand |
|----------|-------------------|
| Nom de domaine | Avant la Phase 7 (migration) |
| Compte Hetzner | Avant la Phase 7 |
| Format des comptes (upgrade device-id → email plus tard ?) | Phase 2, si besoin de multi-device |
| Anti-triche détaillé (latence, replay) | Phase 6, avant tout mode classé |

---

*Document créé le 2026-09-04, à faire évoluer phase par phase.*
