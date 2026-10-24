<!-- Source : Notion « BDD ARCHITECTURE 2 » > Doc explicative du métier et des choix (page modifiée le 2026-09-22). Copie locale : si le diagramme drawio diffère, le diagramme fait foi. -->

# MCD App-DB — règles de gestion et justifications
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
### Règles de gestion
- RG1 : les codes d'espèce, de type et de race sont uniques et immuables.
- RG2 : un nom de race est unique au sein d'une espèce.
- RG3 : les races d'un animal appartiennent à son espèce.
- RG4 : un animal a au plus une race principale (*is_primary*).
- RG5 : un animal peut n'avoir aucune race (race inconnue).
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
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| appartenir | PET | 1,1 | SPECIES | 0,n | — |
### Justification
**PET** : table évidente, seuls deux points sont à signaler.
- 💡 is_sterilized : pour un animal adopté, le statut peut être inconnu. Un booléen force oui ou non ; prévoir trois états (oui / non / inconnu).
- ❓ birth_date est souvent approximative (adoption, refuge). Le Care Engine utilise l'âge : faut-il savoir qu'une date est estimée ?
### Règles de gestion
- RG6 : l'espèce d'un animal est immuable.
- RG7 : l'âge est calculé à partir de birth_date, il n'est pas stocké.
- RG8 : le poids est historisé dans HEALTH_ENTRY, pas porté par PET.
- RG9 : identification_number (puce / tatouage) est facultatif, mais unique lorsqu'il est renseigné.
---
## 3. USER_ACCOUNT / DEVICE / CONSENT / INVITATION
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
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| enregistrer | DEVICE | 1,1 | USER_ACCOUNT | 0,n | — |
| donner | CONSENT | (1,1) | USER_ACCOUNT | 1,n | — |
| posséder | PET | 1,n | USER_ACCOUNT | 0,n | owner_role |
| envoyer | INVITATION | 1,1 | USER_ACCOUNT | 0,n | — |
| viser | INVITATION | 1,1 | PET | 0,n | — |
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
- ❓ Parcours d'acceptation (création de compte, refus, expiration) non défini dans la maquette. À trancher en équipe.
**USER_ACCOUNT**
- ❓ Connexion OAuth (Google / Apple, prévue dans la présentation) : password devient facultatif et le fournisseur doit être stocké. À confirmer avant le MLD.
### Règles de gestion
- RG10 : l'email est unique.
- RG11 : l'acceptation des CGU est obligatoire à l'inscription.
- RG12 : un seul consentement actif par type et par utilisateur.
- RG13 : un consentement révoqué n'est pas supprimé, il est daté (traçabilité RGPD).
- RG14 : types de consentement MVP : CGU/confidentialité, traitement IA externe.
- RG15 : un propriétaire est soit chef, soit second. Le chef seul peut transférer son rôle ; les autres droits réservés au chef restent à définir.
- RG16 : quand un compte est supprimé, seul son lien *posséder* disparaît. Quand le dernier propriétaire est supprimé, l'animal et ses données sont supprimés. ❓ À revoir : la maquette (US-35) détruit les données du collier dès la suppression du chef ; sort des données santé et RGPD à trancher en équipe.
- RG17 : un push_token est unique.
- RG18 : un appareil dont le token est invalidé est supprimé.
- RG73 : un animal a exactement un propriétaire chef.
- RG74 : le chef peut transférer son rôle à un propriétaire second ; il devient alors second.
- RG75 : une invitation acceptée crée un lien *posséder* avec le rôle second.
- RG76 : une seule invitation en attente par animal et par e-mail.
- RG19 : la position du user n'est pas conservée. Elle est lue sur le téléphone à l'affichage et à la recherche de vétos.
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
- ❓ Qui crée un collier : Pawrise au provisioning (stock), ou l'utilisateur à l'appairage ? Le statut « en stock » suppose le premier cas.
### Règles de gestion
- RG20 : un animal a au plus un collier affecté à la fois.
- RG21 : un collier est affecté à au plus un animal à la fois.
- RG22 : une affectation n'est jamais supprimée, elle est clôturée par unassigned_at (historique des données par collier).
- RG23 : seul un collier au statut actif peut être affecté.
- RG24 : la batterie et la position du collier ne sont pas stockées dans l'App-DB (séries temporelles → TimescaleDB).
---
## 5. HEALTH_ENTRY
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
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| consigner | HEALTH_ENTRY | 1,1 | PET | 0,n | — |
### Justification
**HEALTH_ENTRY**
- ✅ Rôle : événement daté du carnet de santé (vaccin, pesée, consultation…).
- ✅ Forme : une table générique typée par entry_type, plutôt qu'une table par type : un seul historique, un seul écran, un seul export (RG30).
- ⚠️ Contrepartie : certains attributs n'ont de sens que pour certains types (RG26), d'où des champs vides. Choix assumé face à la spécialisation que proposerait Merise ; à expliciter.
- 💡 Pas d'auteur de l'entrée : une consultation saisie par le véto via le Portail n'a pas la même valeur qu'une saisie du propriétaire. DOCUMENT a document_source, HEALTH_ENTRY non ; ajouter entry_source par cohérence.
### Règles de gestion
- RG25 : types d'entrée : vaccin, antiparasitaire, traitement, consultation, examen, intervention, pesée, allergie, maladie chronique.
- RG26 : weight n'est renseigné que pour une pesée ; dosage et end_date que pour un traitement ou un antiparasitaire ; pour une allergie ou une maladie chronique, entry_date = diagnostic et end_date = guérison.
- RG27 : le poids actuel d'un animal est celui de sa dernière pesée.
- RG28 : une next_due_date génère un rappel à l'approche de l'échéance.
- RG29 : is_sterilized est porté par PET (état actuel, connu même sans date) ; l'intervention datée, si connue, est une entrée HEALTH_ENTRY.
- RG30 : pas d'entité carnet de santé : le carnet est une vue déduite de PET + HEALTH_ENTRY. Une donnée à valeur unique caractérisant l'animal va dans PET ; une donnée datée ou répétée va dans HEALTH_ENTRY.
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
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| définir | GEO_ZONE_SECURITY | 1,1 | USER_ACCOUNT | 0,n | — |
| surveiller | GEO_ZONE_SECURITY | 0,n | PET | 0,n | *is_active* |
### Justification
**GEO_ZONE_SECURITY / surveiller**
- ✅ Forme : la zone est séparée de son attribution aux animaux (voir doc MLD « PET_GEO_ZONE ») ; is_active est porté par surveiller pour désactiver un seul animal (RG34).
- ❓ RG33 contre RG15 : la zone appartient à son créateur, mais un co-propriétaire a les mêmes droits sur l'animal. Peut-il voir, modifier ou désactiver la zone de l'autre ?
### Règles de gestion
- RG31 : une zone est un cercle (centre + rayon).
- RG32 : une zone sécurisée alerte en sortie, une zone interdite alerte en entrée.
- RG33 : une zone ne surveille que les animaux dont son créateur est propriétaire.
- RG34 : la surveillance s'active et se désactive par animal et par zone (*is_active* sur *surveiller*).
- RG35 : une alerte de zone est envoyée à tous les propriétaires de l'animal.
- RG36 : la suppression d'un compte supprime les zones qu'il a définies.
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
- RG37 : le numéro ordinal est unique et sert de clé de correspondance avec la Vet-DB.
- RG38 : l'inscription d'un véto sur le Portail crée ou met à jour son occurrence dans l'annuaire et le passe partenaire.
- RG39 : seul un véto partenaire peut recevoir un accès (PET_VET_ACCESS). Avec un non-partenaire, l'échange se fait hors plateforme, via l'export PDF.
- RG40 : access_source vaut propriétaire ou escalade IA. Dans les deux cas, l'accès est validé par un propriétaire.
- RG41 : un seul accès actif à la fois par couple animal / véto. Un accès révoqué est daté, pas supprimé.
- RG42 : disponibilités et prise de rendez-vous sont lues via l'API du Portail, elles ne sont pas stockées dans l'App-DB.
- RG43 : un animal a au plus un vétérinaire traitant, partenaire ou non.
- RG44 : le vétérinaire traitant est choisi dans l'annuaire, sans création manuelle.
- RG45 : désigner un partenaire comme vétérinaire traitant ne lui ouvre pas d'accès aux données ; l'accès reste validé explicitement par un propriétaire (RG40).
---
## 8. ALERT
### Entités
**ALERT**
- <u>id_alert</u>
- alert_type
- severity
- explanation
- triggered_at
- acknowledged_at
### Associations
| Association | Entité A | Card. A | Entité B | Card. B | Attributs portés |
| --- | --- | --- | --- | --- | --- |
| déclencher | ALERT | 1,1 | PET | 0,n | — |
| provoquer | ALERT | 0,1 | GEO_ZONE_SECURITY | 0,n | — |
### Justification
**ALERT**
- ✅ Forme : entité et pas simple notification push : historique consultable dans l'app, lecture sur le Portail, traçabilité (RG49, WBS 8.2.3).
- ❓ Une alerte urgente peut mener à une escalade, mais ALERT et ESCALATION ne sont pas liées : le véto ne sait pas quelle alerte a motivé l'escalade. Utile ?
### Règles de gestion
- RG46 : types d'alerte : santé, sortie de zone, entrée de zone, batterie faible, collier déconnecté.
- RG47 : niveaux de gravité : information, vigilance, urgence.
- RG48 : une alerte de zone est reliée à la zone qui l'a provoquée ; les autres types ne le sont pas.
- RG49 : une alerte n'est jamais supprimée (traçabilité), sauf avec la suppression de l'animal.
- RG50 : une alerte est envoyée sur tous les appareils de tous les propriétaires de l'animal.
- RG51 : explanation est obligatoire : chaque alerte indique pourquoi elle a été déclenchée.
- RG52 : acknowledged_at est partagé par tous les propriétaires de l'animal.
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
- ⚠️ RG53 (visible par son seul initiateur) va à l'encontre de RG15 (mêmes droits pour tous les propriétaires). Justifier ce choix (confidentialité de l'échange) ou l'aligner.
### Règles de gestion
- RG53 : une conversation porte sur un seul animal et n'est visible que par le propriétaire qui l'a initiée.
- RG54 : une conversation donne lieu à au plus une escalade.
- RG55 : statuts d'escalade : en attente, prise en charge, clôturée.
- RG56 : une escalade est attribuée à un véto partenaire disponible ; sa prise en charge ouvre un accès (access_source = escalade IA), validé par le propriétaire (RG40).
- RG57 : un message véto n'est possible que dans une conversation escaladée vers ce véto.
- RG58 : conversations et messages ne sont jamais supprimés, sauf avec le compte ou l'animal.
- RG59 : sender_role vaut propriétaire, IA ou véto ; model_version, sources et confidence_score ne sont renseignés que pour les messages de l'IA.
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
- RG60 : un abonnement couvre un collier ; un collier a au plus un abonnement actif à la fois ; les anciens restent historisés. Plusieurs colliers = plusieurs abonnements.
- RG61 : statuts d'abonnement : actif, impayé, résilié.
- RG62 : le statut est mis à jour par les webhooks Stripe.
- RG63 : factures, moyens de paiement et paiements ne sont pas stockés dans l'App-DB, ils sont consultés chez Stripe.
- RG64 : payment_customer_ref (client Stripe) est unique par utilisateur.
- RG65 : l'abonnement est payé par l'utilisateur qui l'a souscrit, même si l'animal a plusieurs propriétaires.
- RG66 : à la fin de la période payée d'un abonnement non renouvelé, les données du collier restent collectées et stockées mais ne sont plus accessibles pendant une période de grâce (durée paramétrée, calculée à partir de current_period_end, non stockée). Un réabonnement pendant cette période rend l'accès, y compris aux données collectées entre-temps. À la fin de la période de grâce, la collecte s'arrête.
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
- RG67 : formats acceptés : PDF et images.
- RG68 : un véto ne peut joindre un document que s'il a un accès actif à l'animal (PET_VET_ACCESS).
- RG69 : un document est supprimé avec l'entrée à laquelle il est joint.
- RG70 : les documents sont inclus dans l'export véto (PDF).
- RG71 : le fichier est stocké hors base (stockage objet) ; la base conserve sa référence (storage_ref).
- RG72 : document_source vaut propriétaire ou véto.
