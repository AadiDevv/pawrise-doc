<!-- Source : Notion « BDD ARCHITECTURE 2 » > Doc explicative du métier et des choix (page modifiée le 2026-09-22). Copie locale : si le diagramme drawio diffère, le diagramme fait foi. -->

# MCD App-DB — règles de gestion et justifications

> /!\ Modifié le 2026-10-30 (contrat d'interface, `../contrat-interface/questions.md` D2–D6, D9, D12, D15, Q3) : REFRESH_TOKEN, REMINDER, NOTIFICATION, zone du chien, préférences, PET.height / medical_notes, MESSAGE.quick_replies ; RG14, RG16, RG28, RG33, RG34, RG36, RG59 réécrites ; RG77–RG85 ajoutées. draw.io cloud et Notion pas à jour. Les `.drawio` locaux le sont.
> Niveau MCD (Merise) : entités, associations, attributs, identifiants (soulignés), cardinalités, règles de gestion.  
Types et tailles → dictionnaire de données (à part).

**Règle de documentation des tables**
Chaque table non évidente répond à 4 questions :
1. **Rôle** : que représente-t-elle dans le modèle ?
2. **Besoin** : quel besoin métier réel couvre-t-elle ?
3. **Forme** : pourquoi une table, et pas un attribut ou une simple association ?
4. **Règles** : quelles RG la justifient ou la contraignent ?
Marqueurs : ✅ justifié · ⚠️ à expliciter · ❓ question ouverte · 💡 piste d'amélioration. On ne justifie pas l'évident ; une justification importante absente est marquée ⚠️.
**Exemple — DEVICE** : ✅ Rôle : téléphone qui reçoit les notifications push. ✅ Besoin : alertes, rappels, messages véto. ✅ Forme : un user peut avoir plusieurs téléphones, donc une entité et pas un attribut. ✅ Règles : RG17, RG18, RG50.

---
## 1. Référentiels espèces / races
### Entités
**SPECIES**
- <u>species_code</u>
- species_name
**BREED_TYPE**
- <u>breed_type_code</u>
- breed_type_name
**BREED**
- <u>breed_code</u>
- breed_name
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| regrouper | BREED | 1,1 | SPECIES | 0,n | — |
| classer | BREED | 1,1 | BREED_TYPE | 0,n | — |
| avoir_race | PET | 0,n | BREED | 0,n | *is_primary* |
### Justification
**BREED_TYPE**
- ✅ Rôle : type morphologique d'une race (molosse, berger, cobby…), chien comme chat.
- ⚠️ Besoin : aucun usage n'est documenté. Qui le consomme : filtre dans l'app, seuils du Care Engine ?
- 💡 Si rien ne l'utilise au MVP, la retirer (YAGNI). Sinon, noter ici son consommateur.
**avoir_race** (PET ↔ BREED, n,n)
- ✅ Forme : n,n pour les croisés (Oslo = berger allemand + labrador) ; aucune ligne = race inconnue (RG3 à RG5).
**Référentiels**
- ❓ Qui alimente les listes d'espèces, de races et de types (liste FCI / LOF, saisie manuelle) ? La réponse fixe le format de breed_code.
- ❓ « Croisé » (RG85) est une race du référentiel, or BREED est classée dans un BREED_TYPE (1,1) : quel type lui donner (type « non défini ») ?
### Règles de gestion
- <a name="RG1"></a>RG1 : les codes d'espèce, de type et de race sont uniques et immuables.
- <a name="RG2"></a>RG2 : un nom de race est unique au sein d'une espèce.
- <a name="RG3"></a>RG3 : les races d'un animal appartiennent à son espèce.
- <a name="RG4"></a>RG4 : un animal a au plus une race principale (*is_primary*).
- <a name="RG5"></a>RG5 : un animal peut n'avoir aucune race (race inconnue).
- <a name="RG85"></a>RG85 : le référentiel contient une race « Croisé » (code mixed), choisie quand l'animal est croisé sans races connues. « Je ne sais pas » = aucune race (RG5).
---
## 2. PET
### Entités
**PET**
- <u>id_pet</u>
- pet_name
- birth_date
- sex
- is_sterilized
- identification_number
- coat_color
- photo
- height
- medical_notes
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| appartenir | PET | 1,1 | SPECIES | 0,n | — |
### Justification
**PET** : table évidente, seuls deux points sont à signaler.
- 💡 is_sterilized : pour un animal adopté, le statut peut être inconnu. Un booléen force oui ou non ; prévoir trois états (oui / non / inconnu).
- ❓ birth_date est souvent approximative (adoption, refuge). Le Care Engine utilise l'âge : faut-il savoir qu'une date est estimée ?
- ✅ height et medical_notes (2026-10-30, D2) : la maquette les saisit à l'ajout du chien. Valeur unique caractérisant l'animal, donc dans PET (RG30) ; medical_notes est un texte libre, non découpé en HEALTH_ENTRY.
### Règles de gestion
- <a name="RG6"></a>RG6 : l'espèce d'un animal est immuable.
- <a name="RG7"></a>RG7 : l'âge est calculé à partir de birth_date, il n'est pas stocké.
- <a name="RG8"></a>RG8 : le poids est historisé dans HEALTH_ENTRY, pas porté par PET.
- <a name="RG9"></a>RG9 : identification_number (puce / tatouage) est facultatif, mais unique lorsqu'il est renseigné.
- <a name="RG80"></a>RG80 : photo contient soit la référence d'une photo en stockage objet, soit la clé d'une photo d'exemple embarquée dans l'app (sample_1…).
---
## 3. USER_ACCOUNT / DEVICE / CONSENT / INVITATION / REFRESH_TOKEN
> /!\ Modifié le 2026-10-18 (co-propriété chef / second, INVITATION, RG15 et RG73–RG76) : schéma draw.io cloud pas à jour. Les `.drawio` locaux le sont.
### Entités
**USER_ACCOUNT**
- <u>id_user</u>
- email
- password
- first_name
- last_name
- phone_number
- email_verified_at
- registration_date
- payment_customer_ref
- location_sharing
- health_notifications
**DEVICE**
- <u>id_device</u>
- push_token
- platform
- last_active_at
**CONSENT** *(identifié relativement à USER_ACCOUNT)*
- <u>consent_type</u>
- <u>consent_granted_at</u>
- consent_version
- consent_revoked_at
**INVITATION**
- <u>id_invitation</u>
- invited_email
- invitation_status
- invited_at
- responded_at
**REFRESH_TOKEN**
- <u>id_refresh_token</u>
- token_hash
- family_id
- issued_at
- expires_at
- used_at
- revoked_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| enregistrer | DEVICE | 1,1 | USER_ACCOUNT | 0,n | — |
| donner | CONSENT | (1,1) | USER_ACCOUNT | 1,n | — |
| posséder | PET | 1,n | USER_ACCOUNT | 0,n | owner_role |
| envoyer | INVITATION | 1,1 | USER_ACCOUNT | 0,n | — |
| viser | INVITATION | 1,1 | PET | 0,n | — |
| ouvrir_session | REFRESH_TOKEN | 1,1 | USER_ACCOUNT | 0,n | — |
### Justification
**DEVICE**
- ✅ Rôle : téléphone ou tablette qui reçoit les notifications push, identifié par son token (Apple / Google).
- ✅ Besoin : alertes santé et de zone, rappels (vaccins, traitements), messages du véto après escalade.
- ✅ Forme : un user peut avoir plusieurs appareils (enregistrer : DEVICE 1,1 — USER_ACCOUNT 0,n), donc une entité et pas un attribut.
- ✅ Règles : RG17, RG18, RG50.
**CONSENT**
- ✅ Forme : entité historisée et non un booléen sur USER_ACCOUNT. Le RGPD impose de prouver quelle version a été acceptée, quand, et quand elle a été retirée (RG12, RG13).
- ⚠️ Accepter les CGU (contrat) et consentir à un traitement (RGPD) sont juridiquement distincts, mais tous deux sont dans consent_type (RG14). Acceptable, à expliciter.
**posséder** (PET ↔ USER_ACCOUNT, n,n)
- ✅ Besoin : plusieurs propriétaires pour un animal (couple, famille), dont un seul chef (RG15, RG16, RG73, RG74). Source : maquette US-31, US-32.
- ✅ Forme : owner_role est porté par l'association, car le rôle dépend du couple personne / animal (chef de l'un, second d'un autre).
- ❓ Ce que seul le chef peut faire, au-delà du transfert, n'est pas défini (maquette muette). À trancher en équipe (lié à RG33, RG53).
**INVITATION**
- ✅ Rôle : invitation d'une personne, par e-mail, à devenir propriétaire second d'un animal (maquette US-23).
- ✅ Forme : entité et pas une ligne de *posséder* en attente, car l'invité peut ne pas avoir de compte (pas d'id_user).
- ✅ Règles : RG75, RG76.
- ✅ Parcours d'acceptation (2026-10-30, Q3, hypothèse validée par Aaditya, à confirmer en équipe) : acceptation explicite par l'invité, après inscription s'il n'a pas de compte ; refus possible ; pas d'expiration ni d'annulation au MVP.
**REFRESH_TOKEN**
- ✅ Rôle : jeton de rafraîchissement d'une session (2026-10-30, D15). Le jeton d'accès reste un JWT sans état, non stocké.
- ✅ Besoin : révoquer une session (déconnexion, vol) et détecter la réutilisation d'un jeton volé.
- ✅ Forme : entité et pas attribut, car un utilisateur a une session par appareil et chaque rotation crée un jeton ; family_id regroupe les jetons d'une même session (RG77 à RG79).
**Préférences** (location_sharing, health_notifications)
- ✅ Attributs de USER_ACCOUNT, sans historique (2026-10-30, D6) : simples réglages, contrairement aux consentements RGPD. location_sharing = position du téléphone de l'utilisateur envoyée à Pawrise.
**USER_ACCOUNT**
- ❓ Connexion OAuth (Google / Apple, prévue dans la présentation) : password devient facultatif et le fournisseur doit être stocké. À confirmer avant le MLD.
### Règles de gestion
- <a name="RG10"></a>RG10 : l'email est unique.
- <a name="RG11"></a>RG11 : l'acceptation des CGU est obligatoire à l'inscription.
- <a name="RG12"></a>RG12 : un seul consentement actif par type et par utilisateur.
- <a name="RG13"></a>RG13 : un consentement révoqué n'est pas supprimé, il est daté (traçabilité RGPD).
- <a name="RG14"></a>RG14 : types de consentement MVP : CGU/confidentialité, traitement IA externe, données anonymisées pour la recherche (D6).
- <a name="RG15"></a>RG15 : un propriétaire est soit chef, soit second. Le chef seul peut transférer son rôle ; les autres droits réservés au chef restent à définir.
- <a name="RG16"></a>RG16 : quand un compte est supprimé, seul son lien *posséder* disparaît. Quand le dernier propriétaire est supprimé, l'animal et ses données sont supprimés. ❓ Sort des données santé et RGPD à trancher en équipe (Q1). Voir RG82 pour le chef.
- <a name="RG17"></a>RG17 : un push_token est unique.
- <a name="RG18"></a>RG18 : un appareil dont le token est invalidé est supprimé.
- <a name="RG73"></a>RG73 : un animal a exactement un propriétaire chef.
- <a name="RG74"></a>RG74 : le chef peut transférer son rôle à un propriétaire second ; il devient alors second.
- <a name="RG75"></a>RG75 : une invitation acceptée crée un lien *posséder* avec le rôle second.
- <a name="RG76"></a>RG76 : une seule invitation en attente par animal et par e-mail.
- <a name="RG77"></a>RG77 : un jeton de rafraîchissement est stocké haché et ne sert qu'une fois ; chaque usage en crée un nouveau dans la même famille.
- <a name="RG78"></a>RG78 : un jeton déjà utilisé présenté à nouveau révoque toute sa famille (vol présumé).
- <a name="RG79"></a>RG79 : la déconnexion révoque le jeton de l'appareil ; la suppression du compte supprime tous ses jetons.
- <a name="RG82"></a>RG82 : un chef qui a au moins un second actif sur l'un de ses animaux doit lui transférer son rôle (RG74) avant de supprimer son compte.
- <a name="RG84"></a>RG84 : health_notifications désactivé : pas de push pour les alertes santé ; la notification reste consultable.
- <a name="RG19"></a>RG19 : la position du user n'est pas conservée. Elle est lue sur le téléphone à l'affichage et à la recherche de vétos.
---
## 4. COLLAR / COLLAR_ASSIGNMENT
### Entités
**COLLAR**
- <u>serial_number</u>
- hardware_version
- firmware_version
- collar_status
- activated_at
**COLLAR_ASSIGNMENT** *(identifié relativement à PET et COLLAR)*
- <u>assigned_at</u>
- unassigned_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| concerner | COLLAR_ASSIGNMENT | (1,1) | PET | 0,n | — |
| affecter | COLLAR_ASSIGNMENT | (1,1) | COLLAR | 0,n | — |
### Justification
**COLLAR_ASSIGNMENT**
- ✅ Rôle : période pendant laquelle un collier est porté par un animal.
- ✅ Besoin : un collier peut changer d'animal (remplacement, revente). Les mesures de TimescaleDB doivent être rattachées au bon animal selon leur date.
- ✅ Forme : entité historisée plutôt qu'un lien direct COLLAR → PET, qui ne garderait que l'animal actuel (RG20 à RG22).
- ⚠️ Ce lien avec TimescaleDB, raison principale de l'historique, n'était écrit nulle part.
- ❓ TimescaleDB stocke-t-elle les mesures par serial_number ou par id_pet ? Par serial_number, COLLAR_ASSIGNMENT est indispensable pour lire l'historique d'un animal ; par id_pet, elle sert surtout à l'audit.
**COLLAR**
- ✅ Création (2026-10-30, D9) : Pawrise enregistre chaque collier avant la vente (statut inactif) ; l'utilisateur ne fait que l'associer par son code (serial_number). Pour le MVP, un script de données de départ ; back-office plus tard.
### Règles de gestion
- <a name="RG20"></a>RG20 : un animal a au plus un collier affecté à la fois.
- <a name="RG21"></a>RG21 : un collier est affecté à au plus un animal à la fois.
- <a name="RG22"></a>RG22 : une affectation n'est jamais supprimée, elle est clôturée par unassigned_at (historique des données par collier).
- <a name="RG23"></a>RG23 : seul un collier au statut actif peut être affecté.
- <a name="RG81"></a>RG81 : un collier est créé par Pawrise avant la vente, inactif ; il passe actif à sa première association. Un collier remplacé repasse inactif et peut être réassocié.
- <a name="RG24"></a>RG24 : la batterie et la position du collier ne sont pas stockées dans l'App-DB (séries temporelles → TimescaleDB).
---
## 5. HEALTH_ENTRY / REMINDER
### Entités
**HEALTH_ENTRY**
- <u>id_health_entry</u>
- entry_type
- entry_date
- label
- weight
- dosage
- end_date
- next_due_date
- notes
**REMINDER**
- <u>id_reminder</u>
- reminder_type
- label
- due_at
- done_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| consigner | HEALTH_ENTRY | 1,1 | PET | 0,n | — |
| planifier | REMINDER | 1,1 | PET | 0,n | — |
### Justification
**HEALTH_ENTRY**
- ✅ Rôle : événement daté du carnet de santé (vaccin, pesée, consultation…).
- ✅ Forme : une table générique typée par entry_type, plutôt qu'une table par type : un seul historique, un seul écran, un seul export (RG30).
- ⚠️ Contrepartie : certains attributs n'ont de sens que pour certains types (RG26), d'où des champs vides. Choix assumé face à la spécialisation que proposerait Merise ; à expliciter.
**REMINDER**
- ✅ Rôle : soin à faire à une échéance (vaccin, traitement, autre), marqué effectué ou non (2026-10-30, D3).
- ✅ Besoin : la maquette crée, modifie, coche et supprime des rappels, y compris sans soin passé dans le carnet.
- ✅ Forme : entité et pas next_due_date d'une HEALTH_ENTRY, qui ne permettait ni rappel sans entrée, ni « effectué », ni type « autre ».
- 💡 next_due_date de HEALTH_ENTRY ne génère plus de rappel et fait doublon : à supprimer si aucun usage n'apparaît.
- 💡 Pas d'auteur de l'entrée : une consultation saisie par le véto via le Portail n'a pas la même valeur qu'une saisie du propriétaire. DOCUMENT a document_source, HEALTH_ENTRY non ; ajouter entry_source par cohérence.
### Règles de gestion
- <a name="RG25"></a>RG25 : types d'entrée : vaccin, antiparasitaire, traitement, consultation, examen, intervention, pesée, allergie, maladie chronique.
- <a name="RG26"></a>RG26 : weight n'est renseigné que pour une pesée ; dosage et end_date que pour un traitement ou un antiparasitaire ; pour une allergie ou une maladie chronique, entry_date = diagnostic et end_date = guérison.
- <a name="RG27"></a>RG27 : le poids actuel d'un animal est celui de sa dernière pesée.
- <a name="RG28"></a>RG28 : un rappel est un REMINDER (types : vaccin, traitement, autre) ; done_at vide = à faire. Marquer effectué ne crée pas d'entrée dans le carnet. Une échéance à moins de 24 h génère une notification (RG83).
- <a name="RG29"></a>RG29 : is_sterilized est porté par PET (état actuel, connu même sans date) ; l'intervention datée, si connue, est une entrée HEALTH_ENTRY.
- <a name="RG30"></a>RG30 : pas d'entité carnet de santé : le carnet est une vue déduite de PET + HEALTH_ENTRY. Une donnée à valeur unique caractérisant l'animal va dans PET ; une donnée datée ou répétée va dans HEALTH_ENTRY.
---
## 6. GEO_ZONE_SECURITY
### Entités
**GEO_ZONE_SECURITY**
- <u>id_geo_zone</u>
- geo_zone_name
- zone_type
- center_latitude
- center_longitude
- radius
- emoji
- alerts_enabled
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| protéger | GEO_ZONE_SECURITY | 1,1 | PET | 0,n | — |
### Justification
**GEO_ZONE_SECURITY**
- ✅ Forme (révisée le 2026-10-30, D5) : la zone appartient à **un animal** (*protéger*), et non plus à son créateur avec une attribution n,n (*définir* + *surveiller*). Raisons : la maquette liste et gère les zones par chien ; tous les propriétaires du chien voient et gèrent les mêmes zones, ce qui ferme la question RG33 / RG15.
- ⚠️ Contrepartie assumée : deux chiens d'un même foyer ont chacun leur zone « Maison » (voir doc MLD, section PET_GEO_ZONE révisée).
- ✅ emoji (affiché par la maquette) et alerts_enabled (interrupteur « Alertes de sortie ») sont portés par la zone.
### Règles de gestion
- <a name="RG31"></a>RG31 : une zone est un cercle (centre + rayon).
- <a name="RG32"></a>RG32 : une zone sécurisée alerte en sortie, une zone interdite alerte en entrée.
- <a name="RG33"></a>RG33 : une zone protège un seul animal ; tous ses propriétaires la voient et la gèrent.
- <a name="RG34"></a>RG34 : les alertes s'activent et se désactivent par zone (alerts_enabled).
- <a name="RG35"></a>RG35 : une alerte de zone est envoyée à tous les propriétaires de l'animal.
- <a name="RG36"></a>RG36 : les zones d'un animal sont supprimées avec lui ; la suppression d'un compte ne les touche pas.
---
## 7. VETERINARIAN / CLINIC / PET_VET_ACCESS
### Entités
**VETERINARIAN** *(annuaire App-DB : partenaires et non-partenaires)*
- <u>ordinal_number</u>
- first_name
- last_name
- phone_number
- email
- is_partner
**CLINIC**
- <u>id_clinic</u>
- clinic_name
- address
- postal_code
- city
- latitude
- longitude
- phone_number
- has_emergency_service
**PET_VET_ACCESS** *(identifié relativement à PET et VETERINARIAN)*
- <u>access_granted_at</u>
- access_revoked_at
- access_source
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| exercer | VETERINARIAN | 1,n | CLINIC | 0,n | — |
| ouvrir | PET_VET_ACCESS | (1,1) | PET | 0,n | — |
| accorder | PET_VET_ACCESS | (1,1) | VETERINARIAN | 0,n | — |
| suivre | PET | 0,1 | VETERINARIAN | 0,n | — |
### Explications
**Pourquoi un numéro ordinal comme identifiant ?**  
Chaque vétérinaire en exercice en France est inscrit à l'Ordre avec un numéro unique et immuable. Il sert d'identifiant dans l'annuaire et de clé de correspondance avec la Vet-DB (relation applicative, pas de FK entre les deux bases). Un même numéro = une seule occurrence : pas de doublon entre un véto importé et un véto inscrit au Portail.
**Pourquoi CLINIC est une entité à part ?**  
En urgence, l'utilisateur cherche un lieu. Et si l'adresse était portée par VETERINARIAN, elle serait répétée pour chaque véto du même cabinet, ce que Merise interdit.
**Pourquoi PET_VET_ACCESS est une entité et pas une association ?**  
En Merise, une association n'a qu'une seule occurrence par couple d'entités. Or un accès peut être accordé, révoqué puis ré-accordé au même véto pour le même animal : cela fait plusieurs occurrences pour un même couple. Pour conserver cet historique (traçabilité RGPD), l'accès devient une entité identifiée relativement à PET et VETERINARIAN, complétée par access_granted_at. C'est la même logique que COLLAR_ASSIGNMENT. Sans besoin d'historique, une simple association *accéder* (PET 0,n — VETERINARIAN 0,n) aurait suffi.
**Quelle différence entre PET_VET_ACCESS et *suivre* ?**  
Ce sont deux liens distincts entre PET et VETERINARIAN :
| Lien | Représentation | Qui | Historisé |
| --- | --- | --- | --- |
| Accès aux données | entité PET_VET_ACCESS | partenaires seulement | oui |
| Vétérinaire traitant | association *suivre* | tout véto de l'annuaire | non, une seule valeur actuelle |
Ils ne peuvent pas être fusionnés : le vétérinaire traitant peut être un non-partenaire, qui n'a pas d'accès aux données.
**Points ouverts**
- ❓ Source de l'annuaire (import de l'Ordre, saisie manuelle ?) non décidée. Elle conditionne RG44 : « tous les vétos figurent dans l'annuaire ».
- 💡 CLINIC n'a pas d'identifiant naturel, d'où un risque de doublons à l'import. Le SIRET de l'établissement pourrait jouer le rôle du numéro ordinal.
### Règles de gestion
- <a name="RG37"></a>RG37 : le numéro ordinal est unique et sert de clé de correspondance avec la Vet-DB.
- <a name="RG38"></a>RG38 : l'inscription d'un véto sur le Portail crée ou met à jour son occurrence dans l'annuaire et le passe partenaire.
- <a name="RG39"></a>RG39 : seul un véto partenaire peut recevoir un accès (PET_VET_ACCESS). Avec un non-partenaire, l'échange se fait hors plateforme, via l'export PDF.
- <a name="RG40"></a>RG40 : access_source vaut propriétaire ou escalade IA. Dans les deux cas, l'accès est validé par un propriétaire.
- <a name="RG41"></a>RG41 : un seul accès actif à la fois par couple animal / véto. Un accès révoqué est daté, pas supprimé.
- <a name="RG42"></a>RG42 : disponibilités et prise de rendez-vous sont lues via l'API du Portail, elles ne sont pas stockées dans l'App-DB.
- <a name="RG43"></a>RG43 : un animal a au plus un vétérinaire traitant, partenaire ou non.
- <a name="RG44"></a>RG44 : le vétérinaire traitant est choisi dans l'annuaire, sans création manuelle.
- <a name="RG45"></a>RG45 : désigner un partenaire comme vétérinaire traitant ne lui ouvre pas d'accès aux données ; l'accès reste validé explicitement par un propriétaire (RG40).
---
## 8. ALERT / NOTIFICATION
### Entités
**ALERT**
- <u>id_alert</u>
- alert_type
- severity
- explanation
- triggered_at
- acknowledged_at
**NOTIFICATION**
- <u>id_notification</u>
- notification_type
- title
- created_at
- read_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| déclencher | ALERT | 1,1 | PET | 0,n | — |
| provoquer | ALERT | 0,1 | GEO_ZONE_SECURITY | 0,n | — |
| recevoir | NOTIFICATION | 1,1 | USER_ACCOUNT | 0,n | — |
| signaler | NOTIFICATION | 1,1 | PET | 0,n | — |
| notifier | NOTIFICATION | 0,1 | ALERT | 0,n | — |
| échoir | NOTIFICATION | 0,1 | REMINDER | 0,n | — |
### Justification
**ALERT**
- ✅ Forme : entité et pas simple notification push : historique consultable dans l'app, lecture sur le Portail, traçabilité (RG49, WBS 8.2.3).
**NOTIFICATION**
- ✅ Rôle : élément du fil de notifications d'**une** personne (alerte, échéance de rappel, nouveau collier, message véto) (2026-10-30, D4).
- ✅ Besoin : la maquette marque chaque notification lue ou non lue par personne, et affiche des notifications qui ne sont pas des alertes.
- ✅ Forme : entité distincte d'ALERT. ALERT est l'événement (cause, acquittement partagé RG52) ; NOTIFICATION est sa remise à chaque propriétaire, avec son propre read_at (RG83).
- ❓ Une alerte urgente peut mener à une escalade, mais ALERT et ESCALATION ne sont pas liées : le véto ne sait pas quelle alerte a motivé l'escalade. Utile ?
### Règles de gestion
- <a name="RG46"></a>RG46 : types d'alerte : santé, sortie de zone, entrée de zone, batterie faible, collier déconnecté.
- <a name="RG47"></a>RG47 : niveaux de gravité : information, vigilance, urgence.
- <a name="RG48"></a>RG48 : une alerte de zone est reliée à la zone qui l'a provoquée ; les autres types ne le sont pas.
- <a name="RG49"></a>RG49 : une alerte n'est jamais supprimée (traçabilité), sauf avec la suppression de l'animal.
- <a name="RG50"></a>RG50 : une alerte est envoyée sur tous les appareils de tous les propriétaires de l'animal.
- <a name="RG51"></a>RG51 : explanation est obligatoire : chaque alerte indique pourquoi elle a été déclenchée.
- <a name="RG52"></a>RG52 : acknowledged_at est partagé par tous les propriétaires de l'animal.
- <a name="RG83"></a>RG83 : une notification est créée pour chaque propriétaire destinataire ; read_at ne vaut que pour lui. Types : santé, carte, rappel, véto.
---
## 9. CONVERSATION / MESSAGE / ESCALATION
### Entités
**CONVERSATION**
- <u>id_conversation</u>
- started_at
**MESSAGE**
- <u>id_message</u>
- sender_role
- content
- sent_at
- model_version
- sources
- confidence_score
- quick_replies
**ESCALATION**
- <u>id_escalation</u>
- escalation_reason
- escalated_at
- escalation_status
- preliminary_report
- closed_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| porter_sur | CONVERSATION | 1,1 | PET | 0,n | — |
| initier | CONVERSATION | 1,1 | USER_ACCOUNT | 0,n | — |
| contenir | MESSAGE | 1,1 | CONVERSATION | 1,n | — |
| aboutir | ESCALATION | 1,1 | CONVERSATION | 0,1 | — |
| prendre_en_charge | ESCALATION | 0,1 | VETERINARIAN | 0,n | — |
### Justification
**ESCALATION**
- ✅ Forme : entité distincte de CONVERSATION car elle a son propre cycle de vie (statut, véto, rapport, clôture). En attributs de CONVERSATION, ces champs seraient vides pour la plupart des conversations (RG54 à RG56).
**CONVERSATION**
- ✅ RG53 confirmée (2026-10-30, D12) : un fil par animal **et par propriétaire**, pour la confidentialité des questions posées à l'IA. L'app utilise la conversation la plus récente ; une alerte ajoute un message de contexte dans le fil du propriétaire qui ouvre le chat dessus.
### Règles de gestion
- <a name="RG53"></a>RG53 : une conversation porte sur un seul animal et n'est visible que par le propriétaire qui l'a initiée.
- <a name="RG54"></a>RG54 : une conversation donne lieu à au plus une escalade.
- <a name="RG55"></a>RG55 : statuts d'escalade : en attente, prise en charge, clôturée.
- <a name="RG56"></a>RG56 : une escalade est attribuée à un véto partenaire disponible ; sa prise en charge ouvre un accès (access_source = escalade IA), validé par le propriétaire (RG40).
- <a name="RG57"></a>RG57 : un message véto n'est possible que dans une conversation escaladée vers ce véto.
- <a name="RG58"></a>RG58 : conversations et messages ne sont jamais supprimés, sauf avec le compte ou l'animal.
- <a name="RG59"></a>RG59 : sender_role vaut propriétaire, IA ou véto ; model_version, sources, confidence_score et quick_replies (suggestions de réponse) ne sont renseignés que pour les messages de l'IA.
---
## 10. SUBSCRIPTION
### Entités
**SUBSCRIPTION**
- <u>id_subscription</u>
- plan_code
- subscription_status
- started_at
- current_period_end
- canceled_at
- payment_provider_ref
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| souscrire | SUBSCRIPTION | 1,1 | USER_ACCOUNT | 0,n | — |
| couvrir | SUBSCRIPTION | 1,1 | COLLAR | 0,n | — |
### Justification
**SUBSCRIPTION**
- ✅ Rôle : état local de l'abonnement d'un collier.
- ✅ Forme : stocké localement bien que Stripe soit la source de vérité, pour autoriser l'accès sans appeler Stripe à chaque requête ; mis à jour par webhooks (RG62, RG63).
- ✅ Lien au collier : le coût réel (données cellulaires) est porté par le collier, donc l'abonnement le suit (RG60).
- ❓ Collier transféré à un autre utilisateur (revente, don) : l'abonnement en cours reste-t-il payé par l'ancien souscripteur (RG65) ?
### Règles de gestion
- <a name="RG60"></a>RG60 : un abonnement couvre un collier ; un collier a au plus un abonnement actif à la fois ; les anciens restent historisés. Plusieurs colliers = plusieurs abonnements.
- <a name="RG61"></a>RG61 : statuts d'abonnement : actif, impayé, résilié.
- <a name="RG62"></a>RG62 : le statut est mis à jour par les webhooks Stripe.
- <a name="RG63"></a>RG63 : factures, moyens de paiement et paiements ne sont pas stockés dans l'App-DB, ils sont consultés chez Stripe.
- <a name="RG64"></a>RG64 : payment_customer_ref (client Stripe) est unique par utilisateur.
- <a name="RG65"></a>RG65 : l'abonnement est payé par l'utilisateur qui l'a souscrit, même si l'animal a plusieurs propriétaires.
- <a name="RG66"></a>RG66 : à la fin de la période payée d'un abonnement non renouvelé, les données du collier restent collectées et stockées mais ne sont plus accessibles pendant une période de grâce (durée paramétrée, calculée à partir de current_period_end, non stockée). Un réabonnement pendant cette période rend l'accès, y compris aux données collectées entre-temps. À la fin de la période de grâce, la collecte s'arrête.
---
## 11. DOCUMENT
### Entités
**DOCUMENT**
- <u>id_document</u>
- file_name
- file_type
- storage_ref
- document_source
- uploaded_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| joindre | DOCUMENT | 1,1 | HEALTH_ENTRY | 0,n | — |
### Justification
**DOCUMENT**
- ✅ Forme : entité et pas attribut de HEALTH_ENTRY, car une entrée peut avoir plusieurs fichiers (joindre : 0,n côté HEALTH_ENTRY).
### Règles de gestion
- <a name="RG67"></a>RG67 : formats acceptés : PDF et images.
- <a name="RG68"></a>RG68 : un véto ne peut joindre un document que s'il a un accès actif à l'animal (PET_VET_ACCESS).
- <a name="RG69"></a>RG69 : un document est supprimé avec l'entrée à laquelle il est joint.
- <a name="RG70"></a>RG70 : les documents sont inclus dans l'export véto (PDF).
- <a name="RG71"></a>RG71 : le fichier est stocké hors base (stockage objet) ; la base conserve sa référence (storage_ref).
- <a name="RG72"></a>RG72 : document_source vaut propriétaire ou véto.
