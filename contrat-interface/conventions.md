# Conventions transverses de l'API (C2)

Règles communes à tous les endpoints de `openapi.yaml`. Un sujet à la fois ; statut : `à traiter`, `proposé`, `validé`.

| # | Sujet | Statut |
| --- | --- | --- |
| 1 | Dates et heures | validé |
| 2 | Identifiants | validé |
| 3 | Nommage des champs JSON | validé |
| 4 | Format des erreurs | validé |
| 5 | Pagination | validé |
| 6 | En-têtes (auth, langue) | validé |
| 7 | Versioning de l'API | validé |
| 8 | Unités et valeurs énumérées | validé |
| 9 | Champs vides, PATCH et forme des réponses | validé |

## 1. Dates et heures

**Règle : l'API transporte des valeurs brutes, le front les affiche.**

| Cas | Format | Exemple | BDD |
| --- | --- | --- | --- |
| Instant (envoi d'un message, alerte, position) | ISO 8601 en UTC, suffixe `Z` | `2026-10-18T09:30:00Z` | `timestamptz` |
| Date calendaire (naissance, échéance sans heure) | `YYYY-MM-DD` | `2023-04-12` | `date` |

- Le front convertit vers le fuseau du téléphone et formate en français (« 18 oct., 11 h 30 »).
- L'API ne renvoie jamais de texte calculé pour l'affichage : pas d'âge (« 3 ans »), pas de durée relative (« il y a 30 s »). Le front les calcule depuis la date brute (RG7 : l'âge n'est pas stocké).
- En entrée, le front envoie aussi de l'ISO 8601 ; un instant sans fuseau est refusé.

Pourquoi : un seul format à parser, aucune ambiguïté de fuseau, et l'affichage (langue, format) reste une affaire d'écran.

## 2. Identifiants

**Règle : l'API expose l'identifiant de la BDD, toujours sous forme de chaîne.**

| Ressource | Identifiant exposé | Exemple | BDD |
| --- | --- | --- | --- |
| Compte, animal, zone, alerte, conversation, message, invitation… | UUID | `"3f2b8c1e-…"` | `uuid` |
| Espèce, race | code | `"dog"`, `"golden_retriever"` | `species_code`, `breed_code` |
| Vétérinaire | numéro ordinal | `"12345"` | `ordinal_number` |
| Collier | numéro de série (= code `PW-XXXXXX`, hypothèse D9) | `"PW-8A4F2C"` | `serial_number` |

- Le front ne fabrique jamais d'identifiant : c'est le back qui le crée et le renvoie à la création.
- Les tables de liaison ont un identifiant composé de leurs clés étrangères (`pet_owner` : `(id_user, id_pet)`). Dans la route, on donne les deux : `/pets/{petId}/owners/{userId}`.
- Un identifiant est opaque : le front ne doit pas en déduire d'information (ordre, date).

## 3. Nommage des champs JSON

**Règle : champs en anglais, en `camelCase`. La BDD reste en `snake_case` ; la conversion se fait dans l'API-CORE.**

| BDD (`snake_case`) | API (`camelCase`) |
| --- | --- |
| `pet.id_pet` | `id` (dans l'objet chien lui-même) |
| `conversation.id_pet` | `petId` (référence à un autre objet) |
| `pet_name` | `name` |
| `birth_date` | `birthDate` |
| `is_sterilized` | `isSterilized` |

- L'identifiant d'un objet s'appelle `id` ; une référence à un autre objet s'appelle `<objet>Id` (`petId`, `userId`).
- Pas de préfixe redondant : `pet.pet_name` devient `name`.
- Booléens en `is` / `has` (`isPartner`, `hasEmergencyService`), comme en BDD.

Pourquoi : `camelCase` est la norme en JavaScript / TypeScript, côté app comme côté NestJS.

**Où se fait la conversion : une seule fois, dans `schema.prisma`** (si l'ORM retenu est Prisma, voir T2). Chaque champ Prisma porte le nom de l'API et pointe vers la colonne BDD avec `@map` (`@@map` pour la table) :

```prisma
model Pet {
  id        String   @id @map("id_pet") @db.Uuid
  name      String   @map("pet_name")
  birthDate DateTime? @map("birth_date") @db.Date
  @@map("pet")
}
```

Le client Prisma renvoie donc déjà `id`, `name`, `birthDate`. Entités, DTO et mappers propagent les propriétés par spread, sans réaffectation champ par champ ; seul ce qui change de type est réécrit (dates → ISO, convention 1). C'est l'approche du projet Horas : le repository construit l'entité par spread du résultat Prisma (`new Absence_Core({ ...e })`), puis le mapper construit le DTO par spread. Dans Horas, la BDD était déjà en `camelCase` ; ici, `@map` absorbe la différence avec le MPD en `snake_case`. Sans `@map`, Prisma renverrait `pet_name` et le spread vers l'entité serait impossible.

💡 Piste d'implémentation (hors contrat) : une fonction utilitaire qui convertit les `Date` en ISO dans les mappers, pour ne plus réécrire les champs date un par un.

## 4. Format des erreurs

**Règle : toute erreur a la même forme, avec un `code` stable que l'app traduit en message.**

Format : standard *Problem Details* (RFC 9457, `Content-Type: application/problem+json`), complété d'un `code` et, pour la validation, d'une liste `errors` par champ.

```json
{
  "status": 409,
  "code": "COLLAR_ALREADY_ASSIGNED",
  "title": "Collar already assigned",
  "detail": "Collar PW-8A4F2C is assigned to another pet."
}
```

```json
{
  "status": 400,
  "code": "VALIDATION_FAILED",
  "title": "Validation failed",
  "errors": [
    { "field": "birthDate", "code": "DATE_IN_FUTURE" },
    { "field": "name", "code": "REQUIRED" }
  ]
}
```

- `code` : en anglais, `MAJUSCULES_SNAKE`, stable dans le temps. **C'est lui que l'app lit.** Elle affiche son propre texte en français (« Code invalide ou déjà associé. »), comme pour les dates : l'affichage reste au front.
- `title` / `detail` : pour les développeurs (logs, Swagger), jamais affichés tels quels.
- `errors[].field` : nom du champ JSON (`camelCase`, convention 3), pour placer le message sous le bon champ du formulaire.

| Statut HTTP | Quand | Exemple Pawrise |
| --- | --- | --- |
| 400 | données invalides | date de naissance dans le futur |
| 401 | pas connecté, jeton absent ou expiré | session expirée |
| 403 | connecté mais pas le droit, sur une ressource qu'on a le droit de voir | un second tente de donner le rôle de chef |
| 404 | ressource inexistante **ou appartenant à quelqu'un d'autre** | `GET /pets/{id}` sur le chien d'un autre compte |
| 409 | conflit avec l'état actuel | e-mail déjà utilisé, collier déjà associé, invitation déjà en attente (RG76) |
| 413 | fichier trop lourd | photo du chien de plus de 1,5 Mo |
| 429 | trop de requêtes ; `Retry-After` donne le délai en secondes | trop d'essais de connexion ratés |
| 500 | erreur interne | — |
| 503 | service dépendant indisponible | IA-ENGINE en panne pendant un message du chat |

Pourquoi 404 et pas 403 pour la ressource d'un autre : ne pas révéler qu'elle existe. Même esprit que dans Horas : la requête est filtrée sur l'utilisateur, la ressource d'un tiers est simplement introuvable.

Les codes de chaque endpoint sont listés dans `openapi.yaml`.

**Côté implémentation (repris de Horas, adapté)** : le domaine lance des erreurs typées (`AppError` → `NotFoundError`, `ConflictError`…) qui portent statut et `code` précis (`new ConflictError("COLLAR_ALREADY_ASSIGNED")`, pas un `CONFLICT` générique) ; un *exception filter* global NestJS les convertit au format ci-dessus ; toute autre erreur devient un 500 neutre. Un repository ne transforme pas une panne BDD en 404 et ne recopie jamais l'erreur interne dans la réponse.

Spécificités NestJS à gérer dans ce filtre (enregistré en `APP_FILTER`, `@Catch()` sans argument) :

- **Exceptions Nest** (`UnauthorizedException` du guard JWT, `NotFoundException` de routes inconnues…) : converties au même format. Le domaine, lui, n'utilise que `AppError`, pour rester indépendant de Nest.
- **Validation des DTO** (`ValidationPipe` + `class-validator`) : son `exceptionFactory` est configuré une fois pour produire `VALIDATION_FAILED` avec `errors: [{ field, code }]`, au lieu des phrases anglaises par défaut.
- **Erreurs Prisma** (si T2 validé) : `P2002` (unicité violée) → 409, `P2025` (enregistrement introuvable) → 404. La BDD sert de dernier filet si le domaine a oublié un contrôle.

## 5. Pagination

**Règle : on ne pagine que les listes qui grandissent sans fin ; on les pagine par curseur.**

| Liste | Paginée ? | Pourquoi |
| --- | --- | --- |
| Notifications (`GET /notifications`) | oui | s'accumulent pendant toute la vie du compte |
| Messages du chat (`GET .../messages`) | oui | idem ; on charge les plus anciens en remontant le fil |
| Chiens, propriétaires, zones, rappels | non | quelques éléments par compte |
| Séries santé, trajet | non | bornées par la période demandée (`?period=`), pas par une page |
| Races, cliniques | non | filtrées (`?q=`, distance) et bornées par `limit` |

**Par curseur, pas par numéro de page** : `?limit=20&cursor=<valeur reçue>`.

```json
{
  "items": [ { "id": "…", "title": "…" } ],
  "nextCursor": "eyJ0IjoiMjAyNi0xMC0xOFQwOTozMDowMFoifQ"
}
```

- `nextCursor` vaut `null` quand il n'y a plus rien à charger.
- Le curseur est opaque : l'app le renvoie tel quel, sans le lire.
- `limit` : 20 par défaut, 100 au maximum.
- Ordre : du plus récent au plus ancien.

Pourquoi le curseur : sur une liste qui reçoit de nouveaux éléments en tête (notifications, messages), une pagination par numéro de page décale tout à chaque arrivée. La page 2 réaffiche alors un élément déjà vu ou en saute un. Le curseur dit « après cet élément-là » et reste juste.

**Forme des listes** : toutes les listes renvoient `{ "items": [...] }`, paginées ou non. Ajouter la pagination plus tard à une liste ne casse donc pas l'app (on ajoute `nextCursor`, on ne change pas la forme).

## 6. En-têtes

**Règle : le strict nécessaire.**

| En-tête | Sens | Valeur | Quand |
| --- | --- | --- | --- |
| `Authorization` | requête | `Bearer <jeton d'accès>` | toutes les routes sauf inscription, connexion, rafraîchissement |
| `Content-Type` | requête | `application/json` ; `multipart/form-data` pour la photo du chien | requêtes avec corps |
| `Content-Type` | réponse | `application/json` ; `application/problem+json` pour une erreur (convention 4) | toujours |
| `X-Request-Id` | réponse (et requête si l'app en fournit un) | identifiant unique de la requête | toujours |

**Jetons (dépend de T1)**
- Jeton d'accès court (≈ 15 min), envoyé dans `Authorization`. Il porte l'identifiant et le rôle (`owner` / `vet`).
- Jeton de rafraîchissement long, échangé contre un nouveau jeton d'accès par `POST /auth/refresh`, renouvelé à chaque usage. La déconnexion (`POST /auth/logout`) l'invalide.
- L'app les garde dans le stockage sécurisé du téléphone (Keychain / Keystore), pas de cookie : l'app mobile n'est pas un navigateur.

**`X-Request-Id`** : l'API-CORE le crée si l'app n'en envoie pas, le transmet au Care Engine et l'écrit dans ses logs. Une erreur signalée par un utilisateur se retrouve alors d'un service à l'autre.

**Pas d'en-tête de langue ni de fuseau** : l'app affiche elle-même textes, dates et messages d'erreur (conventions 1 et 4).

## 7. Versioning de l'API

**Règle : version dans l'URL (`/v1/...`), changée seulement en cas de rupture.**

Pourquoi c'est nécessaire : une app mobile ne se met pas à jour pour tout le monde en même temps. Des téléphones garderont l'ancienne version pendant des semaines et appelleront encore l'ancienne forme de l'API.

| Changement | Rupture ? | Action |
| --- | --- | --- |
| Ajouter un endpoint, un champ en réponse, un champ facultatif en entrée, un `code` d'erreur | non | rien, reste en `/v1` |
| Retirer ou renommer un champ, changer son type, rendre obligatoire un champ d'entrée, changer le sens d'une valeur | oui | nouvelle version (`/v2`) pour les routes touchées ; `/v1` maintenue le temps que les anciennes apps disparaissent |

Deux obligations qui rendent les ajouts sans risque :

- l'app **ignore les champs qu'elle ne connaît pas** (pas de validation stricte qui rejette un champ en trop) ;
- l'app **accepte une valeur d'énumération inconnue** et l'affiche de façon neutre (ex. un nouveau type de notification).

**Centralisé des deux côtés** : côté NestJS, `app.enableVersioning({ type: VersioningType.URI, defaultVersion: "1" })` dans `main.ts` ; les contrôleurs n'écrivent jamais `v1`, seule une route qui casse reçoit `@Version("2")`. Côté app, l'adresse de base (`…/v1`) est une constante unique.

## 8. Unités et valeurs énumérées

### Unités

**Règle : une seule unité par grandeur, écrite dans le nom du champ. L'API envoie des nombres, jamais du texte formaté.**

| Grandeur | Champ (exemple) | Unité | Type | BDD |
| --- | --- | --- | --- | --- |
| Poids | `weightKg` | kg | nombre décimal | `weight` (kg) |
| Taille | `heightCm` | cm | nombre | absent (D2) |
| Rayon d'une zone | `radiusM` | mètre | entier | `radius` (m, RG31) |
| Distance d'une clinique | `distanceM` | mètre | entier | calculée |
| Position | `latitude`, `longitude` | degrés WGS84 | nombre décimal | `numeric(9,6)` |
| Température | `temperatureC` | °C | nombre décimal | TimescaleDB |
| Rythme cardiaque | `heartRateBpm` | battements / min | entier | TimescaleDB |
| Activité | `activityMin` | minute | entier | TimescaleDB |
| Sommeil | `sleepMin` | minute | entier | TimescaleDB |
| Batterie | `batteryPct` | % (0–100) | entier | TimescaleDB |
| Score bien-être | `score` | sans unité (0–100) | entier | Care Engine |

- L'app convertit pour l'affichage : `sleepMin: 450` → « 7 h 30 » ; `distanceM: 1200` → « 1,2 km » (la maquette affiche le sommeil en heures et les distances en km).
- Coordonnées : la carte de la maquette utilise un repère abstrait (0–1000) ; l'API, elle, transporte de vraies coordonnées.

### Valeurs énumérées

**Règle : un code anglais stable en `snake_case`, identique à la valeur stockée en BDD. L'app le traduit en libellé.**

```json
{ "sex": "female", "zoneType": "safe", "alertType": "zone_exit", "severity": "warning" }
```

- Mêmes valeurs qu'en BDD (contraintes `CHECK`) : aucune table de conversion côté back, la valeur traverse les couches telle quelle.
- Les clés restent en `camelCase` (convention 3) ; seules les valeurs sont en `snake_case`.
- L'app affiche « Femelle », « Sortie de zone »… et tolère une valeur inconnue (convention 7).
- La liste des valeurs possibles de chaque champ est dans `openapi.yaml` (`enum`).

## 9. Champs vides, PATCH et forme des réponses

**En réponse : tous les champs sont toujours présents.** Un champ sans valeur vaut `null`, il n'est jamais omis. L'app a un type fixe.

**En `PATCH` : seuls les champs envoyés changent.**

| Dans le corps du `PATCH` | Effet |
| --- | --- |
| champ absent | inchangé |
| champ avec une valeur | remplacé |
| champ à `null` | effacé (seulement si le champ est facultatif ; sinon 400) |

**Pas d'enveloppe de succès** : la réponse est l'objet lui-même (`{ "id": …, "name": … }`), ou `{ "items": […] }` pour une liste (convention 5). Pas de `{ success, data }` : le statut HTTP dit déjà si c'est un succès.

| Opération | Statut | Corps |
| --- | --- | --- |
| Lecture (`GET`) | 200 | l'objet ou la liste |
| Création (`POST`) | 201 | l'objet créé, avec son `id` |
| Modification (`PATCH`, `PUT`) | 200 | l'objet à jour |
| Suppression (`DELETE`) | 204 | vide |
| Action (`POST /auth/logout`…) | 204, ou 200 si elle renvoie quelque chose | — |
