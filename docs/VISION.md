# Vision produit — Quizz

Document de référence : positionnement, concurrence, fonctionnalités indispensables, différenciation, risques et roadmap.

**Stack :** Godot 4 (app shell 5 onglets, FR/EN)  
**Référence inspirante :** QuizUp (fermé 2021)  
**Dernière mise à jour :** 2026-09-03

---

## 1. Positionnement

Quizz est un **trivia social mobile** (et multiplateforme), pas un outil de classe type Kahoot.

| Marché | Acteurs typiques | Besoin | Quizz |
|--------|------------------|--------|-------|
| A — Live / classe / formation | Kahoot, Quizizz/Wayground, Mentimeter, Wooclap, Slido | Host + salle + analytics / LMS | **Hors scope** (sauf pivot B2B tardif) |
| B — Trivia social | Trivia Crack, (ex-)QuizUp, Trivio | Solo, duels, streaks, catégories, méta longue durée | **Cible principale** |
| C — Party / soirée | Jackbox | 1 écran + téléphones, humour | **Adjacent** (mode party en phase avancée) |

### Promesse

> Pas juste savoir — jouer avec ce que tu sais.

### Identité produit (les 10 features originales comme ADN)

> Quizz = trivia social où tu maîtrises un **terrain**, tu **défies**, tu **bluffes**, tu **sabotages** un peu, et tu peux aussi **gagner à deux**.

### Ce qu’on n’est pas

- Un LMS / outil prof (rapports de classe, 20 types pédagogiques, intégrations Moodle)
- Un réseau social avec chat libre (piège coûts + modération de QuizUp)
- Un clone feature-par-feature de Trivia Crack ou Kahoot

---

## 2. Concurrence — synthèse

### Trivia social (rivaux directs)

| Acteur | Forces | Faiblesses / trous |
|--------|--------|---------------------|
| **Trivia Crack** | Duels async, modes, classements, création IA, marque forte | Pubs lourdes, contenu souvent générique, peu de “partie narrative”, peu de party |
| **QuizUp (ex)** | Match 7 Q / 10 s, score vitesse, topics massifs, social, 1v1 amis/random | Fermé : monétisation absente / serveur trop cher, pivot social coûteux |
| **Jackbox** | Party, humour, audience, rejouabilité | Pas de méta quotidienne, pas de progression longue, payant par pack |

### Live / éducation (à comprendre, pas à copier)

- **Kahoot** : live teacher-paced, écran partagé, podium, énergie salle
- **Quizizz / Wayground** : self-paced + homework, rapports détaillés
- **Mentimeter / Slido / Wooclap** : engagement audience, polls, Q&A, pédagogie (Wooclap fort FR / formation)

### Tendances marché (2025–2026)

- Génération / création **IA** devenue table stakes (qualité éditoriale reste le vrai filtre)
- Différenciation difficile sur la checklist de features seule → **contenu, fair-play, boucle sociale, monétisation saine**
- Besoin croissant d’**anti-triche** (bots / IA) dès qu’il y a classements ou récompenses

### Opportunité

QuizUp a laissé un **trou** : matchs synchrones/async style 7 questions, score précision × vitesse, topics, défis amis — surtout côté **francophone soigné**. Quizz peut être l’héritier moderne, avec une identité de jeu plus forte (terrain, bluff, sabotage, co-op).

---

## 3. État actuel du projet (point de départ)

Voir aussi `PROGRESS.md` et `AGENTS.md`.

| Zone | État |
|------|------|
| MVP solo (7 Q, timer, score vitesse + combo, save locale) | Fait |
| App shell 5 onglets (Accueil, Classement, Quiz, Social, Profil) | Fait |
| Contenu (~173 Q, 3 catégories, import OpenTDB + FR) | Fait (qualité FR à renforcer) |
| Classement local (rivaux générés) | Fait |
| Social / multijoueur online | Placeholder |
| Daily challenge | À faire |
| Comptes / sync cloud / backend | À faire |

Roadmap README initiale : daily, 1v1 async, leaderboards, plus de contenu — **conservée et largement étendue** ci-dessous.

---

## 4. Fonctionnalités indispensables (must-have)

Sans ces blocs, pas de rétention durable — indépendamment des features “fraîcheur”.

| Bloc | Contenu |
|------|---------|
| **Core loop** | Solo par catégorie, timer, score vitesse + combo, feedback immédiat, explications |
| **Contenu** | Volume par catégorie, difficulté, anti-répétition, **qualité FR** revue |
| **Progression** | XP, niveau, stats par catégorie, historique, badges / streaks |
| **Social minimal** | Défis **1v1 async**, liste d’amis, résultats partagés |
| **Classements** | Global + par catégorie + amis (données réelles) |
| **Daily** | Défi du jour identique pour tous |
| **Comptes** | Auth, sync cloud, multi-device |
| **i18n** | FR / EN dès le départ (déjà en place) |
| **Fiabilité** | Offline solo, reconnexion, anti-triche basique dès le ranked |

### Nice-to-have hors ADN (plus tard / optionnel)

Live host massif type Kahoot, 20 types de questions pédagogiques, LMS, Q&A conférences, messagerie type réseau social, tournois payants, réponses audio/vidéo.

---

## 5. Différenciation — les 10 features originales

Toutes font partie de la vision. Elles se livrent **par vagues** (voir roadmap), pas en parallèle le jour 1.  
Règle : **une novelty = une boucle complète** (UI + règles + récompense + partage), pas un proto abandonné.

| # | Feature | Idée | Rôle |
|---|---------|------|------|
| 1 | **Duel narratif** | Le match raconte une mini-scène (territoire, couronne, musée…). Bonne réponse = pièce du plateau ; 7ᵉ Q = événement (double points, vol, brouillage d’option). | Transforme le QCM en *partie* |
| 2 | **Sabotage fair-play** | 1–2 power-ups / match : brouiller une mauvaise option adverse, voler 2 s, forcer une catégorie surprise. Jamais pay-to-win. | Tension sociale sans live obligatoire |
| 3 | **Mode Bluff** | Style Fibbage : fausse réponse inventée / piège ; points pour bluffer ou détecter. | Humour, viralité, share |
| 4 | **Co-op duo** | 2 joueurs vs le jeu : info incomplète (2 options chacun), sync emoji / vote, ou split question / indices. | Social non toxique |
| 5 | **Terrain de maîtrise** | Carte visuelle par catégorie / sous-thèmes ; coloration selon wins ; défis ciblant la zone faible d’un ami. | Socle de progression (le reste s’y accroche) |
| 6 | **Replay culturel du jour** | Daily enrichi : question “ce jour dans l’histoire / ciné / sport”, éditorial léger, vote communauté pour demain. | Habitude + identité FR |
| 7 | **Spectateur actif** | Regarder un duel : paris cosmétiques / XP, cheers (sans triche). | Rétention sans jouer |
| 8 | **Draft de questions** | Avant match : ban 1 catégorie ou pick dans un pool. | Mind games pré-match |
| 9 | **Explication mémorable** | Post-erreur : carte flash 5 s ; rappel espacé ~48 h. | Apprentissage qui colle, sans app scolaire |
| 10 | **Match miroirs** | Best-of-3 règles changeantes : classique → sans timer / 1 vie → bluff ou options cachées. | “Soirée en 10 min”, variété |

### Trio signature (si message marketing unique)

1. Terrain de maîtrise + défis ciblés  
2. Défi async avec 1 sabotage / match  
3. Mode Bluff (hebdo puis permanent)

### Économie unifiée

Sabotage, spectateur, bluff, daily, terrain → **même économie** (XP / cosmétiques / déblocages). Éviter 10 monnaies ou 10 systèmes parallèles.

### Déblocage progressif UX

Ne pas afficher les 10 modes au premier lancement. Ex. : terrain d’abord → sabotage avec le 1v1 → bluff en event hebdo → co-op / miroirs / party ensuite.

---

## 6. Ce qu’il faut trancher (décisions ouvertes)

À figer avant ou pendant la Vague A / B :

| Décision | Options | Impact |
|----------|---------|--------|
| **Plateforme cible** | Mobile (Android/iOS) d’abord vs desktop Godot en attendant | Notifs, party, store, UX tactile |
| **Online** | Backend dès Vague A vs plus tard | Sabotage, draft, spectateur, bluff, classements réels |
| **Ton** | Compétitif “e-sport léger” vs “soirée entre potes” | Wording, UI, dose de sabotage |
| **Contenu** | OpenTDB + revue humaine vs packs 100 % éditoriaux FR | Qualité daily culturel, licence CC BY-SA |

Recommandation de travail : **mobile-first**, backend dès qu’on touche au social réel, ton **compétitif chaleureux** (soirée OK en party), contenu **OpenTDB + revue + packs FR** pour le daily culturel.

---

## 7. Risques et leçons

| Risque | Mitigation |
|--------|------------|
| Mort QuizUp = **coûts serveurs + 0 monétisation claire** | Cosmétiques / remove-ads / premium **avant** 10 modes online lourds ; pas de chat libre type réseau social |
| Bluff + UGC | Modération, signalement, queue de review |
| Sabotage frustrant | Hard cap 1–2 / match ; jamais payant pour l’avantage compétitif |
| Trop de modes trop tôt | Unlock progressif ; une grosse novelty à la fois |
| IA générative non relue | Casse la confiance ; génération OK, **publication seulement après review** |
| Triche ranked (bots / IA) | Réponses et timers **côté serveur** ; détection latence anormale |
| Contenu FR faible (trad auto) | Pipeline éditorial ; daily culturel non délégué à OpenTDB seul |

### À éviter sous couvert d’originalité

- Chat libre / feed social lourd  
- Crypto / paris argent réel  
- Course aux features EdTech (LMS, 20 question types)  
- Pubs agressives dès le jour 1 **ou** monétisation nulle indéfiniment  

---

## 8. Technique (contraintes stack)

- **Godot** : excellent pour duel narratif, terrain, feedback, party, UI jeu.
- **Backend séparé** (API + WebSocket) pour : auth, matchmaking, état de match, classements, anti-triche. Ne pas tout faire “dans Godot seul” pour le online.
- **Solo offline** reste possible (core loop + une partie du terrain local).
- **Fair-play** : dès qu’il y a enjeu (ranked, saisons, récompenses), le client ne fait pas foi pour la bonne réponse / le score final.
- Licence OpenTDB : **CC BY-SA 4.0** — créditer si redistribution ; voir `docs/CATEGORIES.md`.

---

## 9. Métriques de succès

Une feature “fraîcheur” réussie **améliore** au moins une métrique, pas seulement une démo interne.

| Métrique | Pourquoi |
|----------|----------|
| D1 / D7 retention | Habitude |
| Taux de complétion du daily / streak | Stickiness |
| % joueurs qui lancent un 1v1 | Social vivant |
| % matchs terminés | Friction / frustration |
| Partages post-match | Viralité |
| Retour sur une carte “à retenir” (feature 9) | Apprentissage réel |

---

## 10. Principes de livraison

1. **Les 10 features = vision complète** — on les vise toutes.  
2. **Pas les 10 en parallèle** — vagues ordonnées, dépendances respectées.  
3. **Max 1 grosse novelty à la fois.**  
4. **Must-have d’abord** quand une novelty en dépend (ex. comptes avant sabotage online).  
5. Contenu FR et fair-play sont des **features produit**, pas des “plus tard si on a le temps”.

---

## 11. Roadmap

> Section à extraire plus tard dans un fichier dédié si besoin.  
> Ordre de build : contenu & fondations → identité → tension sociale → signature & party → plateforme & business.

### Dépendances clés

```
Contenu qualité FR → Daily + streaks → Comptes + 1v1 async
  → Classements réels → Live 1v1 → Création / IA assistée
  → Party mode → Monétisation cosmetics
```

Les 10 novelty se greffent ainsi :

```
Vague A (socle)     → (rien des 10 encore, ou terrain local minimal)
Vague B (identité)  → #5 Terrain, #6 Daily culturel, #1 Duel narratif, #9 Cartes à retenir
Vague C (tension)   → #2 Sabotage, #8 Draft, #7 Spectateur
Vague D (signature) → #3 Bluff, #4 Co-op duo, #10 Match miroirs
```

---

### Phase 0 — Fondations contenu (maintenant)

- [ ] 6–8 catégories (ex. gaming, musique, géo, science, culture générale…)
- [ ] Objectif ~80–150 questions jouables / catégorie, revue FR
- [ ] Difficulté (easy / medium / hard) + anti-répétition intelligente
- [ ] Crédit OpenTDB + pipeline éditorial
- [ ] Explications systématiques après réponse

---

### Phase 1 — Rétention solo (MVP+)

- [ ] Daily challenge (même set, classement du jour)
- [ ] Streaks quotidiens + récompenses
- [ ] Modes : Classic / Survival / Time Attack
- [ ] Badges réels (perfect round, streak 7, expert catégorie…)
- [ ] Écran post-match shareable (score, combo, catégorie)

---

### Phase 2 — Social async (cœur type QuizUp)

- [ ] Comptes + sync cloud
- [ ] Amis (code / lien / contacts)
- [ ] Défi **1v1 async** (même set de 7 Q, scores comparés)
- [ ] Notifications push (défi reçu / résultat)
- [ ] Classement amis + global (API)
- [ ] Remplacer rivaux locaux par joueurs réels
- [ ] Profil public (stats, catégories fortes)

---

### Vague A — Fondation (indispensable avant le fun online)

Recouvre Phase 0 → 2 (contenu, daily basique, comptes, 1v1 async, classements réels).  
Sans ça : sabotage, draft, spectateur et bluff n’ont pas de terrain de jeu.

---

### Vague B — Identité (features 5, 6, 1, 9)

Produit déjà *différent* de Trivia Crack.

- [ ] **#5 Terrain de maîtrise** (carte, sous-thèmes, défis ciblés)
- [ ] **#6 Replay culturel du jour** (branché terrain / éditorial FR)
- [ ] **#1 Duel narratif** (remplace le match “score sec”)
- [ ] **#9 Explication mémorable** + rappel ~48 h

---

### Vague C — Tension sociale (features 2, 8, 7)

- [ ] **#2 Sabotage fair-play** (1–2 / match, économie unifiée)
- [ ] **#8 Draft** pré-match
- [ ] **#7 Spectateur actif** (paris cosmétiques / XP sur duels amis)

---

### Phase 3 — Compétition live

- [ ] Matchmaking temps réel 1v1 (même question, même timer)
- [ ] Mode random opponent
- [ ] Saisons / ranks (Bronze → Master)
- [ ] Tournois hebdo (bracket ou ladder)
- [ ] Spectateur branché sur le live (lien avec #7)
- [ ] Anti-triche : serveur authoritative, latence, flag bots / IA

---

### Phase 4 — Contenu & création

- [ ] Packs thématiques saisonniers (JO, rentrée, Noël…)
- [ ] Créateur de quiz (manuel) + partage lien
- [ ] Assist IA (génération + **relecture humaine** obligatoire)
- [ ] UGC modéré (signalement, queue review)
- [ ] Médias : image dans question (puis audio)

---

### Vague D — Signature & party (features 3, 4, 10)

- [ ] **#3 Mode Bluff** (event hebdo d’abord, puis mode permanent)
- [ ] **#4 Co-op duo**
- [ ] **#10 Match miroirs** (Classic → Survival → Bluff / sabotage)

---

### Phase 5 — Party & multiplateforme

- [ ] Mode soirée : host écran + rejoindre par code (phones)
- [ ] Équipes 2v2 / free-for-all 4–8
- [ ] Export mobile (Android / iOS) + desktop
- [ ] Cross-play

---

### Phase 6 — Plateforme & business

- [ ] Battle pass / cosmetics (avatars, cadres) — **pas de pay-to-win**
- [ ] Pub optionnelle ou remove-ads
- [ ] Abonnement premium (sans pub, bonus daily, packs)
- [ ] Analytics produit (funnel, churn, D1/D7)
- [ ] Modération, RGPD, suppression de compte
- [ ] (Option) B2B léger : packs quiz entreprise privés — **seulement si traction B2C**

---

### Matrice cible “eux vs nous”

| Feature | Trivia Crack | Kahoot | Jackbox | Quizz (cible) |
|---------|--------------|--------|---------|---------------|
| Solo rapide | Oui | Partiel | Non | Oui |
| 1v1 async | Oui | Partiel | Non | Oui (priorité Phase 2) |
| Live 1v1 sync | Partiel | Non | Non | Oui (Phase 3) |
| Host salle | Partiel | Oui | Oui | Party Phase 5 |
| Contenu FR soigné | Partiel | Partiel | EN | Oui (diff) |
| Fair-play ranked | Partiel | n/a | n/a | Oui (diff) |
| Terrain / narratif / bluff / co-op | Non / faible | Non | Partiel humour | Oui (ADN 10) |
| Édition / LMS | Non | Oui | Non | Hors scope |

---

### Ordre de priorité résumé

1. Contenu FR + Phase 0–1  
2. Vague A (comptes, 1v1 async, classements)  
3. Vague B (terrain, daily culturel, narratif, cartes)  
4. Vague C (sabotage, draft, spectateur)  
5. Phase 3 live + anti-triche  
6. Vague D (bluff, co-op, miroirs)  
7. Phase 4–5 contenu / party  
8. Phase 6 monétisation & conformité  

---

*Document figé à partir des sessions produit du 2026-09-03. À faire évoluer quand une décision ouverte (§6) est tranchée ou qu’une vague est terminée.*
