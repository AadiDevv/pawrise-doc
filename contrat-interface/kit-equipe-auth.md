# Kit équipe : onboarding et auth

À envoyer à la personne qui code l'onboarding et l'authentification dans son propre repo.

**En deux étapes** : (1) cloner la doc (ci-dessous) ; (2) envoyer la partie 2 comme premier message à son agent. L'agent installe lui-même la partie 1.

**Installation** : cloner la doc **à côté** du repo de code, avec la maquette (sous-module `pawrise-figma`).

```bash
git clone --recurse-submodules https://github.com/AadiDevv/pawrise-doc.git
```

```
~/code/
├── pawrise-doc/          ← doc, lecture seule
│   └── pawrise-figma/    ← maquette (sous-module)
└── <repo-auth>/          ← code
```

Déjà cloné sans la maquette : `git -C pawrise-doc submodule update --init`.

---

## 1. Bloc à coller dans le `CLAUDE.md` du repo de code

```markdown
## Documentation Pawrise (source de vérité)

La doc du projet vit dans `../pawrise-doc/` (repo cloné à côté de celui-ci). Elle fait foi : ce repo l'implémente, il ne la modifie pas. Avant chaque session : `git -C ../pawrise-doc pull --recurse-submodules`.

Lire selon la tâche :

| Tâche | Fichier |
| --- | --- |
| Endpoint (chemin, corps, réponses, règles) | `../pawrise-doc/contrat-interface/openapi.yaml`, tag `Compte` (et `Animaux`, `Colliers` pour la fin de l'onboarding) |
| Erreurs, dates, ids, en-têtes, jeton, PATCH | `../pawrise-doc/contrat-interface/conventions.md` |
| Point marqué `x-status: provisoire` ou cité dans `x-depends-on` (T1, D13…) | `../pawrise-doc/contrat-interface/questions.md`, à l'ancre du code |
| Table, colonne, contrainte, migration | `../pawrise-doc/bdd/schema.md`, puis `../pawrise-doc/bdd/sql/pawrise_app_db.sql` |
| Règle de gestion citée (RG10, RG77…) | `../pawrise-doc/bdd/mcd-doc.md`, à l'ancre |
| Écran de l'app (S19 Connexion, S20 Inscription, S21 Découverte) | `../pawrise-doc/pawrise-figma/docs/FIGMA_DELIVERY.md` |
| Stack et architecture du back | `../pawrise-doc/context/decisions.md`, `../pawrise-doc/context/architecture.md` |

Règles :
- Le code suit le contrat à la lettre : noms de champs, codes d'erreur (`code` stable), statuts HTTP.
- Prisma en approche base d'abord : `../pawrise-doc/bdd/sql/` est la seule source du schéma. Le schéma Prisma est introspecté depuis cette base.
- Écart entre la doc et le besoin du code (champ manquant, règle ambiguë, contradiction) : le noter dans `ECARTS.md` à la racine de ce repo (fichier, ligne ou ancre de la doc, problème, proposition), coder sur l'hypothèse la plus simple et le signaler en fin de tâche. La correction se fait dans `pawrise-doc`, par Aaditya.
```

---

## 2. Prompt de mise en situation (premier message à son agent)

```markdown
Tu rejoins Pawrise Care, projet EPITECH T-ESP-800 : collier connecté pour chien (GPS, capteurs), app mobile propriétaire, API REST (API-CORE, NestJS), IA de conseil santé. MVP à visée de conseil, pas un dispositif médical.

Ta mission dans ce repo : implémenter l'**onboarding et l'authentification** côté back, selon le contrat d'interface déjà écrit. La doc fait foi et vit dans `../pawrise-doc/` (voir `CLAUDE.md`).

Périmètre (tag `Compte` de `../pawrise-doc/contrat-interface/openapi.yaml`) :
- `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`
- `GET /me`, `PATCH /me`, `GET /me/preferences`, `PATCH /me/preferences`
- `DELETE /me` en dernier (dépend de Q1, encore ouverte)

Décisions déjà prises, à respecter :
- Jeton d'accès court (≈ 15 min), JWT sans état, rôle `owner` / `vet` dans le payload (T1, encore à confirmer).
- Jeton de rafraîchissement stocké haché dans `refresh_token`, à usage unique, avec rotation ; un jeton déjà utilisé qui revient révoque toute sa famille (D15, RG77–RG79).
- CGU acceptées à l'inscription, dans la même transaction, table `consent` (RG11, D13). Mot de passe : 8 caractères minimum (D14).
- Erreurs au format Problem Details avec un `code` stable (convention 4).
- NestJS, Prisma en base d'abord (le SQL de `../pawrise-doc/bdd/sql/` est la source du schéma), architecture en vertical slice : un dossier par cas d'usage, règles métier dans `domain/` (`../pawrise-doc/context/decisions.md`).

Commence ainsi, sans écrire de code :
0. Copie le bloc de la partie 1 de `../pawrise-doc/contrat-interface/kit-equipe-auth.md` dans le `CLAUDE.md` de ce repo (crée-le s'il n'existe pas).
1. Lis `../pawrise-doc/contrat-interface/conventions.md`, les endpoints du tag `Compte` dans `openapi.yaml`, les entrées T1, D13, D14, D15 de `questions.md`, puis les tables `user_account`, `consent`, `refresh_token`, `device` de `../pawrise-doc/bdd/schema.md`. Terminé quand chaque endpoint du périmètre a son corps, ses réponses et ses règles identifiés.
2. Rends-moi un résumé court : ce que fait chaque endpoint, les tables qu'il touche, les règles (RG) qu'il applique. Puis la liste de tout ce qui est ambigu, manquant ou contradictoire, avec le fichier et l'ancre concernés. Terminé quand chaque point provisoire (`x-depends-on`) est soit expliqué, soit dans la liste.
3. Propose un plan de travail découpé en tranches livrables (une tranche = un endpoint testable de bout en bout), dans l'ordre, avec les tests prévus pour chacune.

Attends ma validation du plan avant de coder.
```
