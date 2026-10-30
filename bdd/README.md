# BDD — App-DB

Base relationnelle (PostgreSQL / Neon) de l'app mobile propriétaire. 27 tables.

## Fichiers

| Besoin | Fichier |
| --- | --- |
| Tables, colonnes, types, clés, relations | `schema.md` (lire en premier) |
| Règles de gestion RG1–RG85, justifications, points ouverts | `mcd-doc.md` |
| Passage MCD → MLD, choix des liaisons | `mld-doc.md` |
| Script SQL de création | `sql/pawrise_app_db.sql` |
| Diagrammes (sources de vérité) | `diagrams/mcd.drawio`, `diagrams/mld.drawio`, `diagrams/mpd.drawio` |

Les `.drawio` font foi. `schema.md` est généré depuis `mpd.drawio` ; `mcd-doc.md` et `mld-doc.md` sont des copies de la page Notion « BDD ARCHITECTURE 2 » (voir `../context/links.md`). Après une modification, mettre à jour le fichier dérivé.

## Périmètre

- **App-DB** (ici) : comptes propriétaires, animaux, colliers, carnet de santé, géozones, alertes, chat IA, escalades, abonnements, annuaire vétérinaire.
- **Vet-DB** (séparée) : comptes du Portail Vet, abonnement des vétos partenaires. Lien applicatif par `ordinal_number`, sans FK entre les deux bases.
- **TimescaleDB** (séparée) : mesures continues (GPS, capteurs, batterie). Références logiques vers l'App-DB, sans FK.

## Conventions

- Nommage anglais : MAJUSCULES au MCD/MLD, snake_case au MPD.
- MCD strictement Merise : ni FK, ni types, ni tailles.
- Référentiels identifiés par un code (`species_code`, `breed_code`, `breed_type_code`), vétérinaires par `ordinal_number`, colliers par `serial_number`, le reste par uuid.
- Documenter une table non évidente par rôle, besoin, forme, règles ; marqueurs ✅ ⚠️ ❓ 💡.

## Diagrammes

Enregistrer en `.drawio` **non compressé** (Fichier > Propriétés > décocher « Compressé »), sinon le XML est illisible pour l'IA.
