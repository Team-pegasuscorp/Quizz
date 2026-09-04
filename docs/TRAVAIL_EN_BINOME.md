# Travail en binôme — Quizz

Découpage pour que **deux personnes** avancent en parallèle **sans se marcher dessus**.

Complète : [`VISION.md`](VISION.md) (produit + roadmap).  
À figer ensemble dès le jour 1 : les **contrats** (§3) — idéalement dans `docs/CONTRACTS.md`.

**Dernière mise à jour :** 2026-09-03

---

## 1. Principe

| Piste | Rôle | Zone principale | Ne touche pas |
|-------|------|-----------------|---------------|
| **A — Solo & Identité** | Client Godot : quiz, progression, contenu, terrain, daily, narratif, cartes | `data/`, `tools/`, `scripts/quiz/`, home / quiz / progression | Auth réelle, API, matchmaking, WebSockets |
| **B — Social & Online** | Backend + Social / Classement online + couche client mince | `server/` (ou repo API), `scripts/online/`, social / leaderboard réseau | Contenu questions, scoring solo, redesign des écrans solo |

**Règle d’or :** A livre des features avec **stubs / mocks** ; B branche le vrai réseau derrière les **mêmes interfaces**.

---

## 2. Qui fait quoi (vue rapide)

### Piste A — Solo & Identité

- Contenu (catégories, volume, difficulté, anti-répétition, explications, revue FR)
- Daily local, streaks, badges, carte de share post-match
- Features originales : **#5 Terrain**, **#6 Daily culturel** (UX + contenu), **#1 Duel narratif**, **#9 Cartes à retenir**
- Modes Classic / Survival / Time Attack
- Écrans “prêts online” branchés sur un **`OnlineClient` mock**
- DA / UI tokens (un seul owner DA — par défaut **A**)

### Piste B — Social & Online

- Stack backend : auth, profils, DB, API
- Amis, **1v1 async**, submit score serveur, push
- Classements réels (global / catégorie / amis)
- Anti-triche basique (ranked : pas de confiance au client)
- Implémentation réelle de `OnlineClient` (remplace le mock)
- Features originales côté protocole : **#2 Sabotage**, **#8 Draft**, **#7 Spectateur** (A fait l’UI / VFX)

### Features “à deux” (plus tard, après socle)

| Feature | A | B |
|---------|---|---|
| **#3 Bluff** | Règles + UI | Sync + modération |
| **#4 Co-op duo** | UX / input local | Sync / rooms |
| **#10 Miroirs** | Règles locales d’abord | Ranked miroirs si besoin |

Atelier commun (1 session) **après** Vague A3 + B2, puis split UI (A) / protocole (B).

---

## 3. Contrats partagés (propriété commune)

À écrire **ensemble** (30–60 min), puis modification **uniquement à deux** (ou PR review croisée).

Fichier cible : `docs/CONTRACTS.md`.

| Contrat | Contenu minimal |
|---------|-----------------|
| **`MatchPayload`** | id, catégorie, ids des 7 questions, seed, règles (classic / narratif / draft…) |
| **`MatchResult`** | scores, combo, correct[], durées, effets sabotage utilisés |
| **`PlayerPublic`** | id, pseudo, avatar, stats résumé, terrain résumé |
| **Événements online** | noms stables : `challenge_create`, `challenge_accept`, `match_submit`, `leaderboard_get`, … |
| **Économie** | noms monnaies / cosmétiques / déblocages (même si A les gagne en local d’abord) |

A consomme ces schémas via mock.  
B les implémente côté serveur.  
**Interdit** de changer un champ sans sync binôme.

---

## 4. Vagues parallèles

### Piste A

| Vague | Livrables | Zones typiques |
|-------|-----------|----------------|
| **A0** | Contenu : +catégories, difficulté, anti-répétition, explications, revue FR | `data/`, `tools/`, `QuestionLoader` |
| **A1** | Daily local, streaks, badges, share post-match | `quiz_tab`, `home_tab`, `SaveManager` |
| **A2** | **#5 Terrain** (local), **#9 Cartes à retenir** + rappel | scènes progression |
| **A3** | **#1 Duel narratif** (vs bot / fantôme), modes Classic / Survival / Time Attack | `GameManager`, scènes match |
| **A4** | UI prête online : défi / résultat via **mock** des contrats | stubs `OnlineClient` |

**A ne fait pas :** vrai login, push, matchmaking, classements serveur.

**Mocks OK :** adversaire fantôme, classement fake, “ami” local.

### Piste B

| Vague | Livrables | Zones typiques |
|-------|-----------|----------------|
| **B0** | Backend : auth, profils, DB, API REST de base | `server/` ou repo API |
| **B1** | Amis (code/lien), **1v1 async**, submit score serveur | API + branchement `social_tab` |
| **B2** | Classements globaux / catégorie / amis ; fin des rivaux locaux | `leaderboard_tab` + API |
| **B3** | Push (défi / résultat), anti-triche basique | notifs + validation serveur |
| **B4** | `OnlineClient` réel (drop-in remplace le mock A) | `scripts/online/` uniquement (couche mince) |

**B ne fait pas :** réécrire le scoring solo, importer des questions, redesign home / quiz / terrain.

---

## 5. Mapping des 10 features

| # | Feature | Owner principal | L’autre |
|---|---------|-----------------|---------|
| 5 | Terrain de maîtrise | **A** | B : “terrain résumé” sur profil public |
| 6 | Replay culturel du jour | **A** (contenu + UX) | B : classement daily serveur quand prêt |
| 1 | Duel narratif | **A** | B : sync états si live plus tard |
| 9 | Explication mémorable | **A** | — |
| 2 | Sabotage fair-play | **B** (règles serveur) | A : VFX / UX des effets |
| 8 | Draft | **B** (état pré-match) | A : UI draft |
| 7 | Spectateur actif | **B** | A : UI spectateur |
| 3 | Bluff | **Les deux** (Vague D) | sync obligatoire |
| 4 | Co-op duo | **Les deux** (Vague D) | sync obligatoire |
| 10 | Match miroirs | **A** (local d’abord) | B si ranked |

---

## 6. Anti-collision Git / fichiers

| Zone | Owner |
|------|--------|
| `data/`, `tools/`, `scripts/quiz/`, `home_tab`, terrain, cartes | **A** |
| `server/` (ou repo API), `scripts/online/`, parties réseau de `social_tab` / `leaderboard_tab` | **B** |
| `docs/CONTRACTS.md`, économie, IDs features | **Les deux** |
| `docs/VISION.md`, ce fichier | **Les deux** (modifs produit à deux) |
| `SaveManager` / `GameManager` | **A** owner ; B passe par `OnlineClient` / hooks |
| UI tokens / DA | **A** (évite le yo-yo visuel) |

Si B doit toucher `GameManager` ou le cœur quiz : **PR courte + review A obligatoire**.  
Si A doit toucher l’API ou les schémas réseau : **review B obligatoire**.

Branches suggérées :

- `feature/a-…` pour la piste A  
- `feature/b-…` pour la piste B  
- Merge vers `test` (ou branche d’intégration) après point sync  

---

## 7. Cadence & sync

### Point sync hebdo (30 min)

1. Contrats inchangés ? Sinon : quoi changer, à deux.  
2. Mock → réel : quels endpoints branchés cette semaine ?  
3. Blocages croisés (A attend B ou inverse).  
4. Revue rapide des PR qui touchent une zone frontière.

### Intégration “premier vrai duo”

Quand B a `challenge_create` + `match_submit` **et** A expose match via `MatchPayload` / `MatchResult` :

→ brancher le **duel narratif** sur un **vrai défi async** (mêmes questions, narratif côté client).

---

## 8. Definition of Done (pour ne pas se bloquer)

### A est “prêt online” quand

- [ ] Un match se lance depuis un `MatchPayload` (même en mock)
- [ ] Un résultat sort en `MatchResult` standard
- [ ] Terrain + daily + narratif marchent en solo

### B est “prêt client” quand

- [ ] Auth + créer / accepter défi + soumettre score + lire classement
- [ ] Ranked : réponses / score final validés **côté serveur**
- [ ] Flux prouvé (client Godot minimal, ou tests API + mock UI)

---

## 9. Démarrage — première semaine

### Dev A

1. Phase 0 contenu (catégories + volume + revue FR)  
2. Daily + streak  
3. Esquisse terrain (données locales)  
4. Session contrats avec B  

### Dev B

1. Choisir stack backend + auth  
2. Session contrats avec A → `docs/CONTRACTS.md`  
3. Endpoints : profil, amis, challenge async CRUD  
4. Squelette `scripts/online/` (interface vide + mock compatible A)  

---

## 10. Lien avec la roadmap vision

| Roadmap `VISION.md` | Piste |
|---------------------|--------|
| Phase 0–1 (contenu, daily solo, badges) | **A** |
| Phase 2 (comptes, 1v1 async, classements) | **B** (+ A branche UI) |
| Vague B identité (#5 #6 #1 #9) | **A** (B daily board serveur) |
| Vague C tension (#2 #8 #7) | **B** protocole + **A** UI |
| Phase 3 live / anti-triche | **B** (+ A polish match) |
| Vague D (#3 #4 #10) | **Les deux** |
| Phase 4–5 contenu / party | A contenu & party UX ; B rooms / scale |
| Phase 6 business / conformité | **Les deux** (produit) ; B infra / comptes |

Ordre rappelé :

```
A : contenu → daily → terrain → narratif → cartes
B : auth → amis/1v1 → classements → push/anti-triche → OnlineClient réel
Puis ensemble : sabotage/draft/spectateur UI+protocole → bluff/co-op/miroirs
```

---

## 11. Checklist “on ne se marche pas dessus”

- [ ] `CONTRACTS.md` existe et est à jour  
- [ ] Chaque ticket a un owner A ou B (ou “binôme” explicite)  
- [ ] Pas de modif `GameManager` par B sans review A  
- [ ] Pas de modif schéma API par A sans review B  
- [ ] Une seule personne touche la DA / `UiTokens` par sprint  
- [ ] Les novelty online passent d’abord par mock côté A  

---

*Aligné sur la vision produit du 2026-09-03. Mettre à jour quand les owners A/B sont nommés ou qu’un contrat change.*
