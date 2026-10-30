# Contrat d'interface — App mobile → API-CORE

Mission sprint 1 : contrat REST entre l'app propriétaire et l'API-CORE. Le Portail Vet est hors périmètre (pas de Vet-DB ni de maquette pour l'instant).

## Où j'en suis

- **Fait (2026-10-24 → 30)** : C2 validé. `openapi.yaml` créé : `POST /auth/register`, `/auth/login`, `/auth/refresh`, `/auth/logout` (provisoires). Écarts D13, D14, D15 ajoutés ; `maquette-a-modifier.md` (M1–M3) ; sommaire `../context/references.md`.
- **Question en cours** : D15 — stocker les jetons de rafraîchissement en BDD (table `refresh_token`, révocation possible) ou JWT sans état (pas de table, aucune session révocable) ? Recommandation : table, pour les seuls jetons de rafraîchissement.
- **Ensuite** : C3 suite → `GET/PATCH /me` (S17 Mon profil), `GET/PATCH /me/preferences`, `DELETE /me`. Puis C4 Animaux.
- **Méthode** : un endpoint à la fois ; à chaque avancée, mettre à jour `openapi.yaml`, `questions.md`, la carte (`carte-contrat.html`, puis republier l'artifact avec son URL), puis commit + push (github.com/AadiDevv/pawrise-doc).
- **En attente de l'équipe** : T1, Q1, Q2, Q3 (voir `questions.md`).

## À synchroniser en fin de session

Les appels Notion / Confluence / MCP se font en fin de session uniquement. File d'attente :

- [ ] Notion « BDD ARCHITECTURE 2 » : reporter la section 3 du MCD (D1, RG15, RG16, RG73–RG76, `/!\`) dans les **deux** blocs dépliables « Doc Explicative du métier et des choix » de la page parente. La sous-page « Pawrise Care — MCD App-DB » est déjà à jour (2026-10-18).
- [ ] Notion « BDD ARCHITECTURE 2 » : bloc « Doc explicative MLD » (PET_OWNER.owner_role, table INVITATION, `/!\`).
- [ ] Confluence (espace PC) : page « Questions à trancher en équipe » avec Q1–Q3 (contenu à valider avant publication).

## Fichiers

| Fichier | Rôle |
| --- | --- |
| `README.md` | Où j'en suis + Kanban (à lire en revenant) |
| `questions.md` | Registre des divergences et questions, avec hypothèses de travail |
| `maquette-a-modifier.md` | Changements à proposer sur la maquette, une ligne par écran (M1, M2…) |
| `conventions.md` | Règles communes à tous les endpoints (dates, ids, erreurs, pagination…) |
| `ecrans.md` | Lien US / écran / overlay → données lues et écrites → endpoint (ordre du Figma) |
| `openapi.yaml` | Le contrat (à créer, étape C3) |
| `carte-contrat.html` | Source de la carte visuelle (avancement, endpoints ↔ écrans, registre). Modifier ce fichier puis le publier sur l'artifact https://claude.ai/artifact/D2uBEcXosYW5a7KR8ZNcAz (passer cette URL en `url`) |

Sources croisées pour chaque sujet : BDD `../bdd/`, maquette `../pawrise-figma/` (`src/`, `docs/USER_STORIES_FIGMA.md`), architecture `../context/architecture.md`.

## Méthode

1. Pour chaque domaine : écrans de la maquette → données nécessaires → croisement BDD.
2. Divergence ou question → `questions.md` avec une hypothèse de travail. On ne bloque pas : l'endpoint est marqué `provisoire`.
3. Règle BDD modifiée → Notion + `../bdd/` en même temps (dont `.drawio` local), avec `/!\ draw.io cloud pas à jour` aux deux endroits jusqu'au report sur le cloud.
4. Endpoints écrits dans `openapi.yaml`, domaine par domaine.

## Kanban

### À faire

- [ ] **C3** OpenAPI — Compte & auth (inscription, connexion, profil, suppression)
- [ ] **C4** OpenAPI — Animaux (ajout, édition, liste)
- [ ] **C5** OpenAPI — Colliers (association QR / code, état, remplacement)
- [ ] **C6** OpenAPI — Santé (indicateurs, périodes, score, rappels)
- [ ] **C7** OpenAPI — Localisation & géozones
- [ ] **C8** OpenAPI — Alertes & notifications
- [ ] **C9** OpenAPI — Chat IA & escalade
- [ ] **C10** OpenAPI — Partage & co-propriété (invitation, rôles, transfert)
- [ ] **C11** Relecture équipe (Yassine : archi ; Ibrahim, Adam : app)
- [ ] **B2** Publier Q1–Q3 sur Confluence

### En cours

- [ ] **B1** BDD co-propriété (D1) : local fait (`mcd-doc.md`, `mld-doc.md`, `.drawio`, `schema.md`, SQL) ; Notion en fin de session

### En attente de l'équipe

- [ ] **T1** Type de jeton
- [ ] **Q1** Données à la suppression du compte (RGPD, avocate)
- [ ] **Q2** Droits d'un second
- [ ] **Q3** Acceptation d'une invitation

### Hors sprint

- Rendez-vous et disponibilités (dépendent de l'API du Portail, RG42)
- Contrat Portail Vet → API-CORE

### Fait

- [x] **C2** Conventions transverses validées (`conventions.md`, 9 sujets)

- [x] **C1** Inventaire des écrans → données (`ecrans.md`, ordre du Figma, overlays compris) ; écarts D2–D12 ouverts

- [x] Architecture macroservices documentée (`../context/architecture.md`)
- [x] Registre des questions ouvert
