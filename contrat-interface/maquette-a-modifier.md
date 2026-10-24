# Modifications à proposer sur la maquette

Une ligne = un changement à faire dans `pawrise-figma`. Le détail du débat est dans l'écart lié.

**Légende des références**

| Préfixe | Signifie | Où le trouver |
| --- | --- | --- |
| `S` | Écran | [Figma Pawrise-App](https://www.figma.com/design/33w6Fklug8ywPYh6aDNGCj/Pawrise-App) · [USER_STORIES_FIGMA.md](../pawrise-figma/docs/USER_STORIES_FIGMA.md) |
| `US` | User story | [USER_STORIES_FIGMA.md](../pawrise-figma/docs/USER_STORIES_FIGMA.md) |
| `D` | Écart BDD ↔ maquette | [questions.md](questions.md) |
| `RG` | Règle de gestion BDD | [mcd-doc.md](../bdd/mcd-doc.md) |
| `M` | Modification de maquette | ce fichier |

**Statuts** : `à proposer` · `proposé à l'équipe` · `accepté` · `refusé` · `fait`

| # | Écran | Changement | Pourquoi | Écart | Statut |
| --- | --- | --- | --- | --- | --- |
| M1 | S20 Inscription | Ajouter une case « J'accepte les CGU », obligatoire | Obligation légale (RG11) | D13 | à proposer |
| M2 | S20 Inscription | Mot de passe : 8 caractères minimum au lieu de 6 | Recommandation ANSSI / NIST | D14 | à proposer |
| M3 | S20 Inscription, S17 Mon profil | Séparer « Nom » en prénom + nom | La BDD stocke deux champs | D7 | à proposer |
