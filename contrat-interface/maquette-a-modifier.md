# Modifications à proposer sur la maquette

Une ligne = un changement à faire dans `pawrise-figma`. Le détail du débat est dans l'écart lié.

**Légende des références** (sommaire complet : [references.md](../context/references.md))

| Code | Signifie | Où le trouver |
| --- | --- | --- |
| `S` | Écran | [FIGMA_DELIVERY.md](../pawrise-figma/docs/FIGMA_DELIVERY.md) (index S → lien Figma) |
| `US` | User story | [USER_STORIES_FIGMA.md](../pawrise-figma/docs/USER_STORIES_FIGMA.md) |
| `D` | Écart BDD ↔ maquette | [questions.md](questions.md) |
| `RG` | Règle de gestion BDD | [mcd-doc.md](../bdd/mcd-doc.md) |
| `M` | Modification de maquette | ce fichier |

**Statuts** : `à proposer` · `proposé à l'équipe` · `accepté` · `refusé` · `fait`

| Modif. | Écran | Changement | Pourquoi | Écart | Statut |
| --- | --- | --- | --- | --- | --- |
| M1 | [S20 Inscription](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=5-1089) | Ajouter une case « J'accepte les CGU », obligatoire | Obligation légale ([RG11](../bdd/mcd-doc.md#RG11)) | [D13](questions.md#D13) | à proposer |
| M2 | [S20 Inscription](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=5-1089) | Mot de passe : 8 caractères minimum au lieu de 6 | Recommandation ANSSI / NIST | [D14](questions.md#D14) | à proposer |
| M3 | [S20 Inscription](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=5-1089), [S17 Mon profil](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=5-1137) | Séparer « Nom » en prénom + nom | La BDD stocke deux champs | [D7](questions.md#D7) | à proposer |
| M4 | [S25 Détruire le compte](https://www.figma.com/design/oSH1BWg8ek3AtXc4DJ2LBx?node-id=5-1462) | Chef avec un second actif : demander de transférer le rôle de chef avant de détruire le compte, au lieu de détruire les données du collier | Les seconds gardent l'animal et ses données ; un seul chef par animal ([RG73](../bdd/mcd-doc.md#RG73), [RG74](../bdd/mcd-doc.md#RG74)) | [Q1](questions.md#Q1) | à proposer |
