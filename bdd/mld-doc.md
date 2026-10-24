<!-- Source : Notion « BDD ARCHITECTURE 2 » > Doc explicative MLD (2026-09-22) + légende de diagrams/mld.drawio. -->

# MLD App-DB — passage MCD → MLD et choix des liaisons

> /!\ Modifié le 2026-10-18 (PET_OWNER.owner_role, table INVITATION) : schéma draw.io cloud pas à jour. Les `.drawio` locaux le sont.

## Règles de passage MCD → MLD appliquées

- Association binaire (0,n / 1,1) : la clé primaire côté n migre en clé étrangère côté 1,1.
- Association binaire (0,n / 0,1) : clé étrangère facultative côté 0,1 → `PET.#ordinal_number` (véto traitant, *suivre*), `ALERT.#id_geo_zone` (*provoquer*), `ESCALATION.#ordinal_number` (véto en charge, *prendre_en_charge*).
- Association (1,1 / 0,1) *aboutir* : `ESCALATION.#id_conversation`, clé étrangère unique.
- Association N-N : nouvelle table, PK = FK + attributs portés → `PET_BREED` (*avoir_race*), `PET_OWNER` (*posséder*, porte owner_role), `PET_GEO_ZONE` (*surveiller*), `VET_CLINIC` (*exercer*).
- Identification relative (1,1) : PK composée des FK + identifiant local → `COLLAR_ASSIGNMENT`, `PET_VET_ACCESS`, `CONSENT`.

## Contraintes non représentables en MLD (MPD ou applicatif)

- Les races d'un animal appartiennent à son espèce ; une seule race principale (`is_primary`) par animal.
- À un instant donné : une seule affectation par animal et par collier, un seul accès actif par couple animal / véto, un seul consentement actif par type, un seul abonnement actif par collier.
- Une géozone ne surveille que les animaux de son créateur.
- Seul un vétérinaire partenaire (`is_partner`) peut recevoir un accès (`PET_VET_ACCESS`) ou une escalade.
- Données mesurées en continu (GPS, capteurs, batterie) : TimescaleDB, hors App-DB.

## PET_GEO_ZONE : pourquoi une table de liaison
| Cas | `GEozone` + `GEozone_Pet` | `GEozone` avec FK `pet_id` , sans `GEozone_Pet` |
| --- | --- | --- |
| **1 géozone partagée par 3 pets** | 1 zone + 3 associations | 3 zones identiques |
| **Modifier le contour de « Maison »** | 1 mise à jour | 3 mises à jour à maintenir cohérentes |
| **Affichage sur la carte** | 1 seule forme | 3 formes superposées ou dédoublonnage nécessaire |
| **Réutiliser « Maison » pour un nouveau pet** | Ajouter une association à la zone existante | Recréer la zone |
| **Zone définie mais non attribuée** | Possible | Impossible |
| **Récupérer les zones de Rex** | Jointure `GEozone_Pet` | `WHERE pet_id = ...` |
**Exemple d’incohérence possible :**
Avec 3 pets partageant la même maison :
```plain text
Rex   → Maison → 200 m
Oslo  → Maison → 200 m
Mimi  → Maison → 180 m  ← divergence
```
La même information métier (« Maison ») est alors stockée plusieurs fois. Une modification doit donc être répercutée sur plusieurs lignes, avec un risque de divergence.
Avec `GEozone_Pet` :
```plain text
GEozone
Maison → 200 m

GEozone_Pet
Maison ↔ Rex
Maison ↔ Oslo
Maison ↔ Mimi
```
La définition de la zone est unique ; la table de liaison ne fait que gérer son attribution.
**Conclusion :** `GEozone` porte la **définition de la zone**, tandis que `GEozone_Pet` porte sa **relation avec les pets**. Cette séparation permet la réutilisation, évite la duplication et garantit qu'une modification de la zone s'applique à tous les pets concernés.
