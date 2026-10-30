# Registre des questions et divergences

Salle d'attente : une question n'y vit que tant qu'elle n'est pas tranchée. Une fois tranchée, la décision part dans sa source de vérité (RG dans `../bdd/`, US dans la maquette, `../context/decisions.md`) et la ligne garde seulement « tranché → voir … ».

Une question ne bloque pas le contrat : on avance sur l'**hypothèse de travail** et l'endpoint concerné est marqué `provisoire`.

Règle d'arbitrage BDD ↔ maquette : la maquette fait foi sur le fonctionnement, sauf contrainte BDD (RGPD, intégrité, règle métier) qu'elle ignore.

| ID | Sujet | Hypothèse de travail | Bloquant | Statut | Où |
| --- | --- | --- | --- | --- | --- |
| <a name="T1"></a>T1 | Type de jeton d'auth | Un seul jeton, rôle `owner` / `vet` dans le payload | Non | Proposé, à valider (Yassine) | ci-dessous |
| <a name="T2"></a>T2 | ORM de l'API-CORE | Prisma (fiche APP-DB du Figma d'architecture ; préférence d'Aaditya pour TypeScript / Node.js) | Non | À valider en équipe | — |
| <a name="D1"></a>D1 | Co-propriété chef / seconds | Rôle sur `pet_owner`, un seul chef, transfert, entité INVITATION | Non | Tranché (maquette fait foi) → BDD en cours de mise à jour | ci-dessous |
| <a name="D2"></a>D2 | Profil du chien : taille, infos médicales, sexe, race, espèce | API suit la maquette ; BDD à compléter (voir détail) | Non | À trancher | ci-dessous |
| <a name="D3"></a>D3 | Rappels : objet autonome (maquette) vs `next_due_date` d'une entrée de carnet (BDD) | `/reminders` = vue sur `health_entry.next_due_date` ; « effectué » crée l'entrée réalisée | Non | À trancher | ci-dessous |
| <a name="D4"></a>D4 | Notifications : alertes + rappels + véto, « lu » par personne (maquette) vs `alert` seul, acquittement partagé (BDD, RG52) | `/notifications` = vue agrégée ; « lu » = `acknowledged_at` partagé | Non | À trancher | ci-dessous |
| <a name="D5"></a>D5 | Zones : emoji, zone interdite, zone par chien | API suit la BDD (lat/long, `zone_type` = `safe` par défaut, zone de l'utilisateur affectée aux chiens) ; emoji ignoré | Non | À trancher | ci-dessous |
| <a name="D6"></a>D6 | Préférences : partage de localisation, notifications santé, données anonymisées | « Données anonymisées » = nouveau `consent_type` ; les deux autres = préférences du compte | Non | À trancher | ci-dessous |
| <a name="D7"></a>D7 | Nom : un champ (maquette) vs `first_name` + `last_name` (BDD) | API en deux champs ; maquette à adapter | Non | À trancher | — |
| <a name="D8"></a>D8 | Avancement de l'inscription (découverte, collier, terminé) | État local à l'app, hors API | Non | Hypothèse | — |
| <a name="D9"></a>D9 | Code collier `PW-XXXXXX` vs `serial_number` ; qui crée le collier (❓ BDD) | Le code PW est le `serial_number` ; colliers créés par Pawrise avant vente | Non | À trancher | — |
| <a name="D10"></a>D10 | Données hors App-DB : score, indicateurs, position, trajet, batterie, signal | Exposées par API-CORE (lecture TimescaleDB + Care Engine) | Non | Hypothèse | ci-dessous |
| <a name="D11"></a>D11 | Chat → véto : prise de rendez-vous (maquette) vs escalade vers un véto partenaire dans la conversation (BDD, archi) | Sprint 1 : chat sans escalade ; escalade à trancher | Non | À trancher | ci-dessous |
| <a name="D12"></a>D12 | Chat : un fil continu par chien, messages de contexte, suggestions de réponse (maquette) vs plusieurs `conversation` par chien et utilisateur, sans suggestions (BDD) | Une conversation active par chien et utilisateur ; le contexte est un message de Pawrise ; suggestions = champ du message IA, à stocker ou non | Non | À trancher | ci-dessous |
| <a name="D13"></a>D13 | CGU à l'inscription : RG11 les rend obligatoires (même transaction), la maquette S20 n'a pas de case à cocher | `POST /auth/register` exige `acceptedTermsVersion` ; maquette à adapter (contrainte légale) | Non | À trancher | — |
| <a name="D14"></a>D14 | Longueur du mot de passe : 6 caractères dans la maquette (S20) | 8 minimum (recommandation ANSSI / NIST pour un mot de passe seul) ; maquette à adapter | Non | À trancher | — |
| <a name="D15"></a>D15 | Sessions : rien en BDD pour stocker les jetons de rafraîchissement, donc impossible de révoquer une session (déconnexion, rotation, vol) | Nouvelle table `refresh_token` (hash du jeton, `id_user`, expiration, révocation) ; seuls les jetons de rafraîchissement sont stockés, le jeton d'accès reste un JWT sans état | Non | Tranché (2026-10-30) → BDD à mettre à jour | — |
| <a name="Q1"></a>Q1 | Données d'un animal à la suppression du compte (RGPD) | GPS + identité effacés ; métriques santé anonymisées gardées si consentement ; seconds conservent tout | Non | À trancher en équipe + avocate | Confluence (à publier) |
| <a name="Q2"></a>Q2 | Droits d'un propriétaire second | Mêmes droits que le chef, sauf transfert du rôle et suppression des données de l'animal | Non | À trancher en équipe | Confluence (à publier) |
| <a name="Q3"></a>Q3 | Acceptation d'une invitation | Invitation `pending` → acceptée par l'invité (crée un compte s'il n'en a pas) ; refus ou annulation possibles | Non | À trancher en équipe | Confluence (à publier) |

## T1 — Jeton d'auth

Un seul type de jeton, rôle `owner` / `vet` dans le payload. Les rôles propres à un animal (chef / second) restent en base, pas dans le jeton : ils dépendent de l'animal, pas de la personne.

## D1 — Co-propriété : chef et seconds

| Point | BDD (avant) | Maquette | Décision |
| --- | --- | --- | --- |
| Rôles | RG15 : mêmes droits pour tous. `pet_owner` = `id_user`, `id_pet` | US-31 : un **chef** et des **seconds** par chien (`OwnerRole`, `src/data/mock.ts`) | Rôle porté par *posséder* (`owner_role`), un seul chef par animal. RG15 réécrite |
| Transfert | — | US-32 : seul le chef transfère son rôle à un second actif, puis devient second | Nouvelle RG |
| Invitation | Point ouvert 💡 (`mcd-doc.md:114`) | US-23 : invitation par e-mail, l'invité devient second ; statut `pending` (`src/data/owners.ts`) | Entité INVITATION (l'invité peut ne pas avoir de compte). Acceptation → Q3 |
| Suppression du chef | RG16 : l'animal disparaît avec le **dernier** propriétaire | US-35 : données du collier détruites, collier réinitialisé, même s'il reste des seconds | → Q1. Position d'Aaditya : les données santé survivent (anonymisées, ou au choix du propriétaire) |
| Suppression d'un second | RG16 | US-36 : seul son compte est détruit | Cohérent |
| Droits d'un second | RG15 | Seul le transfert est réservé au chef | → Q2. Lié à RG33 (géozones) et RG53 (conversations) |

## D2 — Profil du chien

| Champ maquette (S09) | BDD | Hypothèse |
| --- | --- | --- |
| Taille (cm) | absent | nouvelle colonne `pet.height_cm` (validé 2026-10-30, BDD à mettre à jour) |
| Infos médicales (texte libre) | absent ; allergies et maladies chroniques sont des `health_entry` | nouvelle colonne `pet.medical_notes`, texte libre (validé 2026-10-30, BDD à mettre à jour) |
| Sexe : mâle / femelle, obligatoire | `male`, `female`, `unknown` | l'API accepte les trois ; la maquette n'envoie que deux |
| Race : un seul choix, dont « Croisé » et « Je ne sais pas » | `pet_breed` n,n ; aucune ligne = inconnue | l'API accepte une liste de races ; « Je ne sais pas » = liste vide ; « Croisé » à trancher |
| Poids | `health_entry` de type pesée (RG8) | l'API crée une pesée à l'ajout |
| (absent) espèce | `species_code` obligatoire | `dog` par défaut |

## D3 — Rappels

La maquette gère un rappel comme un objet : type (vaccin, traitement, autre), nom, échéance, effectué. La BDD n'a pas d'objet rappel : RG28 dit qu'une `next_due_date` sur une entrée de carnet génère un rappel. Rien ne porte « effectué », et « autre soin » n'a pas d'`entry_type`.

## D4 — Notifications

La maquette affiche dans une seule liste les alertes santé et carte, les rappels et les messages véto, chacun lu ou non lu par la personne. La BDD n'a que `alert` (santé, zone, batterie, déconnexion), avec un acquittement partagé entre tous les propriétaires (RG52).

La maquette crée aussi des notifications que la BDD ne connaît pas : « Soin à prévoir » (échéance < 24 h) et « Nouveau collier associé ».

## D5 — Zones

- Emoji de la zone : absent en BDD.
- Zone interdite (`forbidden`, RG32) : absente de la maquette.
- Maquette : zones listées par chien. BDD : zone de l'utilisateur, affectée à un ou plusieurs animaux (`pet_geo_zone`).

## D6 — Préférences de confidentialité

| Préférence (S17) | BDD | Hypothèse |
| --- | --- | --- |
| Données anonymisées | absent ; `consent_type` = CGU, traitement IA externe | nouveau `consent_type` (consentement RGPD, historisé) |
| Notifications santé | absent | préférence du compte (colonne ou table) |
| Partage de localisation | absent | position du téléphone de l'utilisateur (pas celle du chien) envoyée à Pawrise ; préférence du compte, activée par défaut (Aaditya, 2026-10-30) |

## D10 — Données hors App-DB

Score bien-être, indicateurs (rythme cardiaque, fibrillation atriale, activité, sommeil, température), position, trajet, batterie et signal ne sont pas dans l'App-DB : TimescaleDB et Care Engine.

⚠️ Le collier décrit dans `../context/overview.md` et le Figma d'architecture embarque GPS, accéléromètre et température. **Rythme cardiaque et fibrillation atriale** n'ont pas de capteur identifié. À confirmer avec Cyril (IoT).

## D11 — Chat vers vétérinaire

La maquette envoie du chat vers la prise de rendez-vous (US-10). La BDD et l'architecture prévoient une **escalade** : la conversation est confiée à un véto partenaire qui y répond (`escalation`, RG54–RG57). L'escalade est un pilier du produit mais n'a pas d'écran dans la maquette.

## D12 — Chat

- Maquette : un seul fil par chien, qui continue (`chats[dog.id]`). Une alerte de santé ou de zone ajoute un message de Pawrise dans ce fil. Les messages de Pawrise peuvent proposer des suggestions de réponse.
- BDD : `conversation` lié à un chien et à son initiateur (RG53), plusieurs possibles ; une escalade par conversation (RG54). `message` n'a pas de champ pour les suggestions.
- À trancher : nouvelle conversation à chaque alerte, ou fil unique ? Les suggestions sont-elles stockées ?

## Q1 — Données d'un animal à la suppression du compte

Pistes RGPD à faire valider par une avocate (pas un avis juridique) :

- Les données de santé d'un **animal** ne sont pas des « données de santé » au sens de l'art. 9 RGPD, qui vise les personnes.
- Elles deviennent des données personnelles dès qu'elles sont **liées au propriétaire**. Le GPS l'est presque toujours : domicile et trajets.
- Droit à l'effacement (art. 17) : à la suppression du compte, ce qui identifie le propriétaire doit disparaître.
- Des données **réellement anonymisées** sortent du RGPD (considérant 26). Les métriques santé s'anonymisent bien ; les traces GPS très mal.
- La maquette prévoit déjà un consentement « données anonymisées » (US-24).
