# Écrans → données → endpoints

Rangé dans l'ordre du Figma : par US (US-01 à US-36), puis par écran et par overlay (`↳` = sheet, modale ou page posée sur l'écran). Pour chaque ligne : ce que l'écran **lit**, ce qu'il **écrit**, l'endpoint appelé et son domaine (= section de `openapi.yaml`).

Sources : `../pawrise-figma/docs/USER_STORIES_FIGMA.md` (US, écrans S01–S26) et le code `../pawrise-figma/src/`, passé écran par écran (relevé du 2026-10-18).

Les endpoints sont des brouillons : nommage et conventions fixés à l'étape C2. Les écarts renvoient à `questions.md`.

Domaines : **Compte** · **Animaux** · **Colliers** · **Santé** · **Localisation** · **Notifications** · **Chat** · **Partage** · **Vétos** (hors sprint sauf annuaire).

## Tableau

| US | Écran / overlay | Lit | Écrit | Endpoint (domaine) | Écart |
| --- | --- | --- | --- | --- | --- |
| 01 | S01 Santé | chien actif : nom, photo, race, âge ; score bien-être (0–100) et état ; message de synthèse ; 5 indicateurs : valeur affichée et état (bon, à surveiller, alerte) ; batterie ; collier connecté ou non (« dernières mesures reçues ») | — | `GET /pets/{id}/health` (Santé) | D10 |
| 02 | ↳ S02 Détail indicateur | état, valeur, message simple, détail, série de points par période (aujourd'hui, 7 j, 30 j), plage normale ; fibrillation : vue dédiée sans période | — | `GET /pets/{id}/health/{indicator}?period=` (Santé) | D10 |
| 03 | ↳ S02 → S04 « Demander à Pawrise » (si indicateur en alerte) | — | ouvre le chat avec un message de contexte (chien + alerte) | `POST /pets/{id}/conversation` avec contexte (Chat) | D12 |
| 04 | ↳ S05 Mes chiens | liste : photo, nom, race ; chien actif | chien actif (local à l'app) | `GET /pets` (Animaux) | |
| 14 | ↳ ↳ S05 Édition du chien | photo, nom, race (texte libre), naissance, sexe (dont « non renseigné »), poids, taille, infos santé | idem | `PATCH /pets/{id}` (Animaux) | D2 |
| 13 | ↳ S11 Collier (depuis la pastille batterie de S01) | batterie, réseau (signal fort / déconnecté), code du collier, modèle | — | `GET /pets/{id}/collar` (Colliers) | D9, D10 |
| 13 | ↳ ↳ Remplacer le collier | — | nouveau code `PW-XXXXXX` ; l'ancien est dissocié ; génère une notification | `PUT /pets/{id}/collar` (Colliers) | D9 |
| 25 | S01 bouton démo Tout va bien / Alerte | — | — | hors contrat (démo) | |
| 05 | S06 Localisation | photo, nom ; collier connecté ; position ; heure de la dernière position (« il y a 30 s ») ; position obsolète après 3 min ; batterie ; code collier | — | `GET /pets/{id}/location` (Localisation) | D10 |
| 06 | S06 contrôles carte | trajet récent (20 derniers points) | actualiser la position | `GET /pets/{id}/trail`, `GET /pets/{id}/location` (Localisation) | |
| 09 | ↳ S06 Bannière « a quitté la zone » | alerte de sortie de zone : nom de la zone | ignorer ; toucher → chat avec contexte zone | `GET /notifications` ou alerte active (Notifications), `POST /pets/{id}/conversation` (Chat) | D4, D12 |
| 07 | ↳ S07 Zones de sécurité | zones : emoji, nom, rayon (m), alertes de sortie actives ; chien dedans ou dehors | ajouter, renommer, régler le rayon, supprimer, activer les alertes | `GET/POST /pets/{id}/zones`, `PATCH/DELETE /zones/{id}` (Localisation) | D5 |
| 08 | S04 Chat | en-tête : photo, nom, collier connecté ; messages (rôle, texte) ; suggestions de réponse sous un message de Pawrise ; « en train d'écrire » | message libre ou suggestion choisie | `GET /pets/{id}/conversation`, `POST .../messages` (Chat) | D12 |
| 10 | S04 → S08 « Contacter un vétérinaire » | — | — | navigation seule | D11 |
| 11 | S09 Ajouter un chien (étapes) | photos d'exemple ; liste des races (recherche) | photo (fichier ≤ 1,5 Mo ou exemple), nom, naissance, sexe, race, poids, taille, infos santé | `POST /pets`, `POST /pets/{id}/photo`, `GET /breeds` (Animaux) | D2 |
| 12 | S10 Associer un collier | — | code `PW-XXXXXX` par QR ou saisie ; erreur si invalide ou déjà associé | `POST /pets/{id}/collar` (Colliers) | D9 |
| 15 | S12 Rappels | rappels du chien : type (vaccin, traitement, autre), nom, échéance, état (à venir, en retard, effectué) | créer, modifier, marquer effectué ou rouvrir, supprimer | `GET/POST /pets/{id}/reminders`, `PATCH/DELETE /reminders/{id}` (Santé) | D3, C-1 |
| 16 | S12 → S13 échéance < 24 h | — | crée une notification « Soin à prévoir » | côté serveur (Notifications) | D4 |
| 17 | S13 Notifications & alertes | chien, titre, type (santé, carte, rappel, véto), lue ou non, date ; filtre non lues | marquer lue (une ou toutes) ; ouvrir → écran concerné | `GET /notifications`, `PATCH /notifications/{id}`, `POST /notifications/read-all` (Notifications) | D4, C-1 |
| 18 | S08 Vétérinaires | mes rendez-vous ; cliniques : nom du véto, clinique, adresse, téléphone, distance, partenaire, urgence, prochain créneau ; filtres, tri | — | `GET /clinics` (Vétos, annuaire en App-DB) ; créneaux via Portail | hors sprint |
| 19 | S14 Créneaux → S15 Confirmation | jours, créneaux libres ou complets ; récapitulatif : véto, clinique, adresse, créneau, chien | motif ; « Transmettre le dossier » (collier, profil, infos médicales) ; confirmer | Portail + `pet_vet_access` | hors sprint |
| 20 | S15b Rendez-vous confirmé | rendez-vous | annuler | Portail | hors sprint |
| 21 | S16 Clinique hors réseau | adresse, téléphone | — | `GET /clinics/{id}` (Vétos) | |
| 22 | S17 Paramètres → ↳ Mon profil | initiales, nom, e-mail, téléphone | nom, e-mail, téléphone | `GET/PATCH /me` (Compte) | D7 |
| 31 | S18 Propriétaires & partage | par chien : nombre de propriétaires ; chacun : nom, e-mail, rôle (chef, second, en attente), « vous » | — | `GET /pets/{id}/owners` (Partage) | |
| 32 | ↳ S22 Rôle de chef | propriétaire cible, conséquences | donner le rôle de chef | `POST /pets/{id}/owners/{userId}/chief` (Partage) | |
| 23 | ↳ S18 Inviter un propriétaire | chiens ; propriétaires déjà associés (doublon) | chien, e-mail | `POST /pets/{id}/invitations` (Partage) | Q3 |
| 24 | S17 Confidentialité | partage de localisation, notifications santé, données anonymisées | les trois interrupteurs | `GET/PATCH /me/preferences` (Compte) | D6 |
| 33 | ↳ S23 Conditions, confidentialité | texte statique | — | hors API | |
| 34 | ↳ S24 Données vétérinaires | texte statique | — | hors API | |
| 26 | ↳ S17 Se déconnecter | — | fermeture de session sur l'appareil | `POST /auth/logout` (Compte) | |
| 35, 36 | ↳ S25 / S26 Détruire le compte | par chien : mon rôle, code collier, noms des seconds ou du chef ; rendez-vous confirmés | confirmer la destruction | `GET /pets` + `GET /pets/{id}/owners` ; `DELETE /me` (Compte) | Q1 |
| 27 | S19 Connexion | — | e-mail, mot de passe | `POST /auth/login` (Compte) | T1 |
| 28 | S20 Inscription | — | nom, e-mail, téléphone, mot de passe (≥ 6 caractères) ; e-mail déjà utilisé → erreur | `POST /auth/register` (Compte) | D7 |
| 29 | S21 Découverte (5 étapes) | texte statique | — | hors API | D8 |
| 30 | S21 → S09 → S10 | idem US-11 et US-12 | idem | idem | |
| — | Paramètres « Réinitialiser la démonstration » | — | — | hors contrat (démo) | |

## Constats sur la maquette

- **C-1** Les panneaux S12 Rappels et S13 Notifications existent mais **aucun bouton ne les ouvre** dans le code : seul un clic sur une notification de rappel ouvre S12. L'entrée est peut-être dans le Figma ; à vérifier.
- Plusieurs comportements du prototype sont calculés dans l'app et devront venir du serveur : sortie de zone, notification d'échéance < 24 h, notification après remplacement du collier, fraîcheur de la position.
- Le chat du prototype répond avec des textes écrits à l'avance : la forme réelle des réponses (sources, score de confiance, RG59) est à définir avec l'équipe IA.
