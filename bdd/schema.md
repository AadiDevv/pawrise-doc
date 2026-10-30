# Schéma App-DB (MPD PostgreSQL)

Généré depuis `diagrams/mpd.drawio` (source de vérité). À régénérer après chaque modification du diagramme.

> /!\ Modifié le 2026-10-30 (contrat d'interface : refresh_token, reminder, notification, zone du chien, préférences, pet.height / medical_notes, message.quick_replies) : draw.io cloud pas à jour. Les `.drawio` locaux le sont.

Légende : PK clé primaire · FK clé étrangère · UQ unique · Null = colonne facultative (sinon NOT NULL).

Types : uuid via `gen_random_uuid()`, timestamptz pour les instants, date pour les dates calendaires, numeric pour poids, taille et coordonnées, jsonb pour les sources et suggestions IA, listes de valeurs en varchar + CHECK.

Hors diagramme (script SQL) : CHECK (listes de valeurs, RG26 / RG48 / RG59), index uniques partiels « un seul actif à la fois » (dont RG73, RG76), ON DELETE, triggers (RG16, RG23, RG39), index de performance.

## species

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| species_code | varchar(20) | PK |  |
| species_name | varchar(250) | UQ |  |

## breed_type

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| breed_type_code | varchar(20) | PK |  |
| breed_type_name | varchar(250) | UQ |  |

## breed

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| breed_code | varchar(20) | PK |  |
| breed_name | varchar(250) |  |  |
| species_code | varchar(20) | FK |  |
| breed_type_code | varchar(20) | FK |  |

## pet

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_pet | uuid | PK |  |
| pet_name | varchar(100) |  |  |
| birth_date | date |  | oui |
| sex | varchar(10) |  |  |
| is_sterilized | boolean |  | oui |
| identification_number | varchar(20) | UQ | oui |
| coat_color | varchar(50) |  | oui |
| photo | varchar(500) |  | oui |
| height | numeric(5,1) |  | oui |
| medical_notes | text |  | oui |
| species_code | varchar(20) | FK |  |
| ordinal_number | varchar(20) | FK | oui |

## pet_breed (liaison)

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_pet | uuid | PK, FK |  |
| breed_code | varchar(20) | PK, FK |  |
| is_primary | boolean |  |  |

## user_account

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_user | uuid | PK |  |
| email | varchar(255) | UQ |  |
| password_hash | varchar(255) |  |  |
| first_name | varchar(100) |  |  |
| last_name | varchar(100) |  |  |
| phone_number | varchar(20) |  | oui |
| email_verified_at | timestamptz |  | oui |
| registration_date | timestamptz |  |  |
| payment_customer_ref | varchar(255) | UQ | oui |
| location_sharing | boolean |  |  |
| health_notifications | boolean |  |  |

## pet_owner (liaison)

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_user | uuid | PK, FK |  |
| id_pet | uuid | PK, FK |  |
| owner_role | varchar(10) |  |  |

## invitation

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_invitation | uuid | PK |  |
| invited_email | varchar(255) |  |  |
| invitation_status | varchar(10) |  |  |
| invited_at | timestamptz |  |  |
| responded_at | timestamptz |  | oui |
| id_pet | uuid | FK |  |
| id_user | uuid | FK |  |

## device

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_device | uuid | PK |  |
| push_token | varchar(512) | UQ |  |
| platform | varchar(10) |  |  |
| last_active_at | timestamptz |  |  |
| id_user | uuid | FK |  |

## consent

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_user | uuid | PK, FK |  |
| consent_type | varchar(30) | PK |  |
| consent_granted_at | timestamptz | PK |  |
| consent_version | varchar(20) |  |  |
| consent_revoked_at | timestamptz |  | oui |

## refresh_token

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_refresh_token | uuid | PK |  |
| token_hash | varchar(255) | UQ |  |
| family_id | uuid |  |  |
| issued_at | timestamptz |  |  |
| expires_at | timestamptz |  |  |
| used_at | timestamptz |  | oui |
| revoked_at | timestamptz |  | oui |
| id_user | uuid | FK |  |

## collar

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| serial_number | varchar(50) | PK |  |
| hardware_version | varchar(20) |  |  |
| firmware_version | varchar(20) |  |  |
| collar_status | varchar(20) |  |  |
| activated_at | timestamptz |  | oui |

## collar_assignment

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_pet | uuid | PK, FK |  |
| serial_number | varchar(50) | PK, FK |  |
| assigned_at | timestamptz | PK |  |
| unassigned_at | timestamptz |  | oui |

## health_entry

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_health_entry | uuid | PK |  |
| entry_type | varchar(30) |  |  |
| entry_date | date |  |  |
| label | varchar(150) |  |  |
| weight | numeric(5,2) |  | oui |
| dosage | varchar(100) |  | oui |
| end_date | date |  | oui |
| next_due_date | date |  | oui |
| notes | text |  | oui |
| id_pet | uuid | FK |  |

## geo_zone_security

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_geo_zone | uuid | PK |  |
| geo_zone_name | varchar(100) |  |  |
| zone_type | varchar(10) |  |  |
| center_latitude | numeric(9,6) |  |  |
| center_longitude | numeric(9,6) |  |  |
| radius | integer |  |  |
| emoji | varchar(8) |  |  |
| alerts_enabled | boolean |  |  |
| id_pet | uuid | FK |  |

## reminder

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_reminder | uuid | PK |  |
| reminder_type | varchar(20) |  |  |
| label | varchar(100) |  |  |
| due_at | timestamptz |  |  |
| done_at | timestamptz |  | oui |
| id_pet | uuid | FK |  |

## veterinarian

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| ordinal_number | varchar(20) | PK |  |
| first_name | varchar(100) |  |  |
| last_name | varchar(100) |  |  |
| phone_number | varchar(20) |  | oui |
| email | varchar(255) |  | oui |
| is_partner | boolean |  |  |

## clinic

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_clinic | uuid | PK |  |
| clinic_name | varchar(150) |  |  |
| address | varchar(255) |  |  |
| postal_code | varchar(10) |  |  |
| city | varchar(100) |  |  |
| latitude | numeric(9,6) |  |  |
| longitude | numeric(9,6) |  |  |
| phone_number | varchar(20) |  | oui |
| has_emergency_service | boolean |  |  |

## vet_clinic (liaison)

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| ordinal_number | varchar(20) | PK, FK |  |
| id_clinic | uuid | PK, FK |  |

## pet_vet_access

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_pet | uuid | PK, FK |  |
| ordinal_number | varchar(20) | PK, FK |  |
| access_granted_at | timestamptz | PK |  |
| access_revoked_at | timestamptz |  | oui |
| access_source | varchar(20) |  |  |

## alert

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_alert | uuid | PK |  |
| alert_type | varchar(30) |  |  |
| severity | varchar(10) |  |  |
| explanation | text |  |  |
| triggered_at | timestamptz |  |  |
| acknowledged_at | timestamptz |  | oui |
| id_pet | uuid | FK |  |
| id_geo_zone | uuid | FK | oui |

## notification

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_notification | uuid | PK |  |
| notification_type | varchar(10) |  |  |
| title | varchar(200) |  |  |
| created_at | timestamptz |  |  |
| read_at | timestamptz |  | oui |
| id_user | uuid | FK |  |
| id_pet | uuid | FK |  |
| id_alert | uuid | FK | oui |
| id_reminder | uuid | FK | oui |

## conversation

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_conversation | uuid | PK |  |
| started_at | timestamptz |  |  |
| id_pet | uuid | FK |  |
| id_user | uuid | FK |  |

## message

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_message | uuid | PK |  |
| sender_role | varchar(10) |  |  |
| content | text |  |  |
| sent_at | timestamptz |  |  |
| model_version | varchar(50) |  | oui |
| sources | jsonb |  | oui |
| confidence_score | numeric(4,3) |  | oui |
| quick_replies | jsonb |  | oui |
| id_conversation | uuid | FK |  |

## escalation

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_escalation | uuid | PK |  |
| escalation_reason | text |  |  |
| escalated_at | timestamptz |  |  |
| escalation_status | varchar(20) |  |  |
| preliminary_report | text |  | oui |
| closed_at | timestamptz |  | oui |
| id_conversation | uuid | FK, UQ |  |
| ordinal_number | varchar(20) | FK | oui |

## subscription

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_subscription | uuid | PK |  |
| plan_code | varchar(50) |  |  |
| subscription_status | varchar(20) |  |  |
| started_at | timestamptz |  |  |
| current_period_end | timestamptz |  |  |
| canceled_at | timestamptz |  | oui |
| payment_provider_ref | varchar(255) | UQ |  |
| id_user | uuid | FK |  |
| serial_number | varchar(50) | FK |  |

## document

| Colonne | Type | Clés | Null |
| --- | --- | --- | --- |
| id_document | uuid | PK |  |
| file_name | varchar(255) |  |  |
| file_type | varchar(50) |  |  |
| storage_ref | varchar(500) | UQ |  |
| document_source | varchar(10) |  |  |
| uploaded_at | timestamptz |  |  |
| id_health_entry | uuid | FK |  |

## Relations

Notation pattes d'oie, à gauche la table qui porte la FK : `||` exactement un · `o|` / `|o` zéro ou un · `}o` zéro à plusieurs · `}|` un à plusieurs.

| Relation |
| --- |
| `breed }o──|| species` |
| `breed }o──|| breed_type` |
| `pet }o──|| species` |
| `pet }o──|o veterinarian` |
| `pet_breed }o──|| pet` |
| `pet_breed }o──|| breed` |
| `pet_owner }o──|| user_account` |
| `pet_owner }|──|| pet` |
| `invitation }o──|| pet` |
| `invitation }o──|| user_account` |
| `device }o──|| user_account` |
| `consent }|──|| user_account` |
| `refresh_token }o──|| user_account` |
| `collar_assignment }o──|| pet` |
| `collar_assignment }o──|| collar` |
| `health_entry }o──|| pet` |
| `document }o──|| health_entry` |
| `geo_zone_security }o──|| pet` |
| `reminder }o──|| pet` |
| `vet_clinic }|──|| veterinarian` |
| `vet_clinic }o──|| clinic` |
| `pet_vet_access }o──|| pet` |
| `pet_vet_access }o──|| veterinarian` |
| `alert }o──|| pet` |
| `alert }o──|o geo_zone_security` |
| `notification }o──|| user_account` |
| `notification }o──|| pet` |
| `notification }o──|o alert` |
| `notification }o──|o reminder` |
| `conversation }o──|| user_account` |
| `conversation }o──|| pet` |
| `message }|──|| conversation` |
| `escalation o|──|| conversation` |
| `escalation }o──|o veterinarian` |
| `subscription }o──|| user_account` |
| `subscription }o──|| collar` |

`1..n` (au moins un) n'est pas garanti par une FK : assuré par l'application (pet_owner, consent, message, vet_clinic).
