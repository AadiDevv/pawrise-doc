# Sommaire des références

Où est **défini** chaque code utilisé dans la doc. Un fichier qui ne fait que citer un code n'est pas listé ici.

**Règle : toute référence citée est un lien.** `S` → lien Figma de l'écran (pris dans `FIGMA_DELIVERY.md`) ; `RG`, `T`, `D`, `Q` → ancre (`mcd-doc.md#RG11`, `questions.md#D13`).

Vérifié le 2026-10-24 sur les fichiers locaux. Les liens Figma viennent de `FIGMA_DELIVERY.md` ; ils n'ont pas pu être ouverts depuis l'agent (pas d'accès au fichier).

## Par où commencer

Document mère → documents filles. En revenant sur le projet, lire de haut en bas.

```
Carte du contrat (artifact, vue d'ensemble) ......... https://claude.ai/artifact/D2uBEcXosYW5a7KR8ZNcAz
└── contrat-interface/README.md ...................... où j'en suis, kanban C1–C11
    ├── ecrans.md ............ C1  écran → données → endpoint
    ├── conventions.md ....... C2  règles communes à tous les endpoints
    ├── openapi.yaml ......... C3–C10  le contrat, domaine par domaine
    ├── questions.md ......... T, D, Q  écarts et questions ouvertes
    └── maquette-a-modifier.md  M  changements à proposer sur la maquette

AGENTS.md ............................................ contexte projet, point d'entrée des agents
├── context/ ......... overview, architecture (I), decisions, links, references (ce fichier)
└── bdd/README.md .... App-DB
    ├── schema.md ........ tables et colonnes (lire en premier)
    ├── mcd-doc.md ....... RG, justifications, points ouverts
    ├── mld-doc.md, sql/, diagrams/ (les .drawio font foi)

pawrise-figma/ (dépôt de la maquette)
├── docs/FIGMA_DELIVERY.md ..... S : index écran → Figma
└── docs/USER_STORIES_FIGMA.md . US
```

## Où est défini chaque code

```
Pawrise/
├── bdd/
│   ├── mcd-doc.md ............ RG1–RG76 (règles de gestion)
│   └── sql/pawrise_app_db.sql  RG appliquées (contraintes, triggers, section 14 = règles applicatives)
├── context/
│   ├── architecture.md ....... I1–I9 (interfaces entre services)
│   ├── decisions.md .......... choix techniques
│   └── links.md .............. liens externes
├── contrat-interface/
│   ├── README.md ............. C1–C11 (étapes du kanban)
│   ├── questions.md .......... T, D, Q (questions et écarts)
│   ├── ecrans.md ............. C-1… (constats sur la maquette) ; écran → endpoint
│   ├── conventions.md ........ conventions 1–9
│   ├── maquette-a-modifier.md  M1… (changements à proposer)
│   └── openapi.yaml .......... le contrat
└── pawrise-figma/docs/        (dépôt de la maquette)
    ├── FIGMA_DELIVERY.md ..... S01–S26 (+ S02n, S15b, S21b–e) : index écran → lien Figma
    ├── USER_STORIES_FIGMA.md . US-01–US-36, avec leurs écrans S
    └── USER_STORIES.md ....... stories sans identifiant : ne pas citer
```

| Code | Signifie | Défini dans | En ligne |
| --- | --- | --- | --- |
| `S` | Écran de la maquette | [FIGMA_DELIVERY.md](../pawrise-figma/docs/FIGMA_DELIVERY.md) | [Figma, visuels](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=4-98) |
| `US` | User story | [USER_STORIES_FIGMA.md](../pawrise-figma/docs/USER_STORIES_FIGMA.md) | [Figma, fiches US](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=11-951) |
| `RG` | Règle de gestion BDD | [mcd-doc.md](../bdd/mcd-doc.md) | [Notion BDD](https://app.notion.com/p/BDD-ARCHITECTURE-2-3df86687ea01803ba363ef644daf658a) |
| `I` | Interface entre services | [architecture.md](architecture.md) | — |
| `C` | Étape du contrat | [README.md](../contrat-interface/README.md) | — |
| `C-` | Constat sur la maquette | [ecrans.md](../contrat-interface/ecrans.md) | — |
| `T` | Question technique | [questions.md](../contrat-interface/questions.md) | — |
| `D` | Écart BDD ↔ maquette | [questions.md](../contrat-interface/questions.md) | — |
| `Q` | Question à trancher en équipe | [questions.md](../contrat-interface/questions.md) | Confluence (à publier) |
| `M` | Modification de maquette | [maquette-a-modifier.md](../contrat-interface/maquette-a-modifier.md) | — |

⚠️ `context/links.md` cite aussi un Figma `33w6Fklug8ywPYh6aDNGCj` (« Pawrise-App ») : il ne contient pas les écrans S. Rôle à confirmer.
