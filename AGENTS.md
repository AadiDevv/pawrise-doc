# Pawrise Care — contexte projet

Plateforme de santé animale connectée : collier (GPS, accéléromètre, température, BLE/LTE), app mobile propriétaire, Portail Vétérinaire, Care Engine IA (LLM + RAG) avec escalade vers un vétérinaire partenaire. Projet EPITECH T-ESP-800, MVP **à visée de conseil, pas un dispositif médical certifié**.

## Où trouver quoi

Lire uniquement les fichiers utiles à la tâche.

| Besoin | Fichier |
| --- | --- |
| Où est défini chaque code (S, US, RG, D, Q, T, I, C, M) | `context/references.md` |
| Vue d'ensemble, équipe, architecture backend | `context/overview.md` |
| Choix techniques validés et principes | `context/decisions.md` |
| Architecture macroservices (MVP / post-MVP), interfaces entre services | `context/architecture.md` |
| Base de données (schéma, règles RG1–RG76, diagrammes) | `bdd/` — voir son `README.md` |
| Périmètre fonctionnel complet | `context/wbs.md`, `context/functions.md` |
| Liens externes (Figma, Notion, Confluence, Jira, GitHub) | `context/links.md` |
| Maquette de l'app mobile (code) | `pawrise-figma/` — voir son `AGENTS.md` |
| Tâche en cours : contrat d'interface app → API-CORE, divergences BDD ↔ maquette | `contrat-interface/README.md` |

## Règles

- Sources de vérité : `bdd/diagrams/*.drawio` pour la BDD, code `pawrise-figma/` pour l'UI. En cas d'écart avec `context/`, signaler l'écart et suivre la source de vérité.
- MCP (Figma, Notion, draw.io…) : seulement si l'info n'est pas dans le dossier. Le code de la maquette remplace la lecture du fichier Figma.
- Merise : au MCD, pas de FK, ni types, ni tailles (réservés au dictionnaire de données / MLD / MPD).
- Nommage : anglais ; MAJUSCULES au MCD/MLD, snake_case au MPD.
- YAGNI : MVP simple mais extensible, pas de sur-ingénierie.
- Réponses concises, factuelles, sans hypothèses : demander l'info manquante.
