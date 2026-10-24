# Modifications à proposer sur la maquette

Une ligne = un changement à faire dans `pawrise-figma`. Le détail du débat est dans l'écart lié.

**Légende des références**

| Préfixe | Signifie | Où le trouver |
| --- | --- | --- |
| `S20` | Écran de la maquette | `../pawrise-figma/docs/USER_STORIES_FIGMA.md` (écrans S01 à S26) |
| `US-28` | User story de la maquette | même fichier |
| `D13` | Écart BDD ↔ maquette, avec l'hypothèse retenue | `questions.md` (registre) |
| `RG11` | Règle de gestion de la BDD | `../bdd/mcd-doc.md` |
| `M1` | Ligne de ce fichier | ici |

**Statuts** : `à proposer` · `proposé à l'équipe` · `accepté` · `refusé` · `fait`

| # | Écran | Changement | Pourquoi | Écart | Statut |
| --- | --- | --- | --- | --- | --- |
| M1 | S20 Inscription | Ajouter une case « J'accepte les CGU », obligatoire | Obligation légale (RG11) | D13 | à proposer |
| M2 | S20 Inscription | Mot de passe : 8 caractères minimum au lieu de 6 | Recommandation ANSSI / NIST | D14 | à proposer |
| M3 | S20 Inscription, S17 Mon profil | Séparer « Nom » en prénom + nom | La BDD stocke deux champs | D7 | à proposer |
