-- =====================================================================
-- Pawrise Care — App-DB — MPD PostgreSQL
-- Dérivé du MLD Merise. Les références RGxx renvoient à la fiche MCD.
-- Prérequis : PostgreSQL 13+ (gen_random_uuid() natif).
-- =====================================================================

BEGIN;

-- =====================================================================
-- 1. Référentiels espèces / races
-- =====================================================================

CREATE TABLE species (
    species_code  varchar(20)  PRIMARY KEY,                -- RG1 : code unique et immuable
    species_name  varchar(250) NOT NULL UNIQUE
);

CREATE TABLE breed_type (
    breed_type_code  varchar(20)  PRIMARY KEY,             -- RG1
    breed_type_name  varchar(250) NOT NULL UNIQUE
);

CREATE TABLE breed (
    breed_code       varchar(20)  PRIMARY KEY,             -- RG1
    breed_name       varchar(250) NOT NULL,
    species_code     varchar(20)  NOT NULL REFERENCES species (species_code) ON DELETE RESTRICT,
    breed_type_code  varchar(20)  NOT NULL REFERENCES breed_type (breed_type_code) ON DELETE RESTRICT,
    CONSTRAINT uq_breed_name_per_species UNIQUE (species_code, breed_name)   -- RG2
);

-- =====================================================================
-- 2. Comptes utilisateurs, appareils, consentements
-- =====================================================================

CREATE TABLE user_account (
    id_user               uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    email                 varchar(255) NOT NULL,
    password_hash         varchar(255) NOT NULL,           -- hash (argon2 / bcrypt), jamais le mot de passe en clair
    first_name            varchar(100) NOT NULL,
    last_name             varchar(100) NOT NULL,
    phone_number          varchar(20),
    email_verified_at     timestamptz,
    registration_date     timestamptz  NOT NULL DEFAULT now(),
    payment_customer_ref  varchar(255) UNIQUE               -- RG64 : client Stripe
);
-- RG10 : email unique, insensible à la casse
CREATE UNIQUE INDEX uq_user_account_email ON user_account (lower(email));

CREATE TABLE device (
    id_device       uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    push_token      varchar(512) NOT NULL UNIQUE,          -- RG17
    platform        varchar(10)  NOT NULL,
    last_active_at  timestamptz  NOT NULL DEFAULT now(),
    id_user         uuid         NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,
    CONSTRAINT ck_device_platform CHECK (platform IN ('ios', 'android'))
);

CREATE TABLE consent (
    id_user             uuid        NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,
    consent_type        varchar(30) NOT NULL,
    consent_granted_at  timestamptz NOT NULL DEFAULT now(),
    consent_version     varchar(20) NOT NULL,
    consent_revoked_at  timestamptz,                        -- RG13 : révocation datée, jamais supprimée
    PRIMARY KEY (id_user, consent_type, consent_granted_at),
    CONSTRAINT ck_consent_type  CHECK (consent_type IN ('terms_privacy', 'external_ai_processing')),  -- RG14
    CONSTRAINT ck_consent_dates CHECK (consent_revoked_at IS NULL OR consent_revoked_at >= consent_granted_at)
);
-- RG12 : un seul consentement actif par type et par utilisateur
CREATE UNIQUE INDEX uq_consent_active ON consent (id_user, consent_type) WHERE consent_revoked_at IS NULL;

-- =====================================================================
-- 3. Annuaire vétérinaire
-- =====================================================================

CREATE TABLE veterinarian (
    ordinal_number  varchar(20)  PRIMARY KEY,               -- RG37 : clé de correspondance avec la Vet-DB
    first_name      varchar(100) NOT NULL,
    last_name       varchar(100) NOT NULL,
    phone_number    varchar(20),
    email           varchar(255),
    is_partner      boolean      NOT NULL DEFAULT false     -- RG38 : passe à true à l'inscription au Portail
);

CREATE TABLE clinic (
    id_clinic              uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    clinic_name            varchar(150) NOT NULL,
    address                varchar(255) NOT NULL,
    postal_code            varchar(10)  NOT NULL,
    city                   varchar(100) NOT NULL,
    latitude               numeric(9,6) NOT NULL,
    longitude              numeric(9,6) NOT NULL,
    phone_number           varchar(20),
    has_emergency_service  boolean      NOT NULL DEFAULT false,
    CONSTRAINT ck_clinic_latitude  CHECK (latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_clinic_longitude CHECK (longitude BETWEEN -180 AND 180)
);

CREATE TABLE vet_clinic (
    ordinal_number  varchar(20) NOT NULL REFERENCES veterinarian (ordinal_number) ON DELETE CASCADE,
    id_clinic       uuid        NOT NULL REFERENCES clinic (id_clinic) ON DELETE CASCADE,
    PRIMARY KEY (ordinal_number, id_clinic)
);

-- =====================================================================
-- 4. Animal, races, propriétaires
-- =====================================================================

CREATE TABLE pet (
    id_pet                 uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    pet_name               varchar(100) NOT NULL,
    birth_date             date,                                -- RG7 : l'âge est calculé, pas stocké
    sex                    varchar(10)  NOT NULL DEFAULT 'unknown',
    is_sterilized          boolean,                             -- RG29 : NULL = inconnu
    identification_number  varchar(20)  UNIQUE,                 -- RG9 : facultatif, unique si renseigné
    coat_color             varchar(50),
    photo                  varchar(500),                        -- référence en stockage objet
    species_code           varchar(20)  NOT NULL REFERENCES species (species_code) ON DELETE RESTRICT,
    ordinal_number         varchar(20)  REFERENCES veterinarian (ordinal_number) ON DELETE SET NULL,  -- RG43 : véto traitant
    CONSTRAINT ck_pet_sex CHECK (sex IN ('male', 'female', 'unknown'))
);

CREATE TABLE pet_breed (
    id_pet      uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    breed_code  varchar(20) NOT NULL REFERENCES breed (breed_code) ON DELETE RESTRICT,
    is_primary  boolean     NOT NULL DEFAULT false,
    PRIMARY KEY (id_pet, breed_code)
);
-- RG4 : au plus une race principale par animal
CREATE UNIQUE INDEX uq_pet_breed_primary ON pet_breed (id_pet) WHERE is_primary;

CREATE TABLE pet_owner (
    id_user     uuid        NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,  -- RG16 : seul le lien disparaît
    id_pet      uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    owner_role  varchar(10) NOT NULL DEFAULT 'secondary',
    PRIMARY KEY (id_user, id_pet),
    CONSTRAINT ck_pet_owner_role CHECK (owner_role IN ('chief', 'secondary'))  -- RG15
);
-- RG73 : au plus un chef par animal (« exactement un » est assuré par l'application)
CREATE UNIQUE INDEX uq_pet_owner_chief ON pet_owner (id_pet) WHERE owner_role = 'chief';

CREATE TABLE invitation (
    id_invitation      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    invited_email      varchar(255) NOT NULL,
    invitation_status  varchar(10)  NOT NULL DEFAULT 'pending',
    invited_at         timestamptz  NOT NULL DEFAULT now(),
    responded_at       timestamptz,
    id_pet             uuid         NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    id_user            uuid         NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,  -- émetteur
    CONSTRAINT ck_invitation_status CHECK (invitation_status IN ('pending', 'accepted', 'declined', 'cancelled')),
    CONSTRAINT ck_invitation_dates  CHECK (responded_at IS NULL OR responded_at >= invited_at)
);
-- RG76 : une seule invitation en attente par animal et par e-mail
CREATE UNIQUE INDEX uq_invitation_pending ON invitation (id_pet, lower(invited_email)) WHERE invitation_status = 'pending';

-- =====================================================================
-- 5. Colliers
-- =====================================================================

CREATE TABLE collar (
    serial_number     varchar(50) PRIMARY KEY,
    hardware_version  varchar(20) NOT NULL,
    firmware_version  varchar(20) NOT NULL,
    collar_status     varchar(20) NOT NULL DEFAULT 'inactive',
    activated_at      timestamptz,
    CONSTRAINT ck_collar_status CHECK (collar_status IN ('inactive', 'active', 'retired'))
);

CREATE TABLE collar_assignment (
    id_pet         uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    serial_number  varchar(50) NOT NULL REFERENCES collar (serial_number) ON DELETE RESTRICT,
    assigned_at    timestamptz NOT NULL DEFAULT now(),
    unassigned_at  timestamptz,                             -- RG22 : clôturée, jamais supprimée
    PRIMARY KEY (id_pet, serial_number, assigned_at),
    CONSTRAINT ck_collar_assignment_dates CHECK (unassigned_at IS NULL OR unassigned_at > assigned_at)
);
-- RG20 / RG21 : une seule affectation en cours par animal et par collier
CREATE UNIQUE INDEX uq_collar_assignment_active_pet    ON collar_assignment (id_pet)        WHERE unassigned_at IS NULL;
CREATE UNIQUE INDEX uq_collar_assignment_active_collar ON collar_assignment (serial_number) WHERE unassigned_at IS NULL;

-- =====================================================================
-- 6. Carnet de santé et documents
-- =====================================================================

CREATE TABLE health_entry (
    id_health_entry  uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_type       varchar(30)  NOT NULL,
    entry_date       date         NOT NULL,
    label            varchar(150) NOT NULL,
    weight           numeric(5,2),                          -- kg
    dosage           varchar(100),
    end_date         date,
    next_due_date    date,                                  -- RG28 : génère un rappel
    notes            text,
    id_pet           uuid         NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    -- RG25 : types d'entrée
    CONSTRAINT ck_health_entry_type CHECK (entry_type IN (
        'vaccine', 'antiparasitic', 'treatment', 'consultation', 'exam',
        'surgery', 'weighing', 'allergy', 'chronic_disease')),
    -- RG26 : champs remplis selon le type
    CONSTRAINT ck_health_entry_weight   CHECK ((entry_type = 'weighing') = (weight IS NOT NULL)),
    CONSTRAINT ck_health_entry_weight_positive CHECK (weight > 0),
    CONSTRAINT ck_health_entry_dosage   CHECK (dosage IS NULL OR entry_type IN ('treatment', 'antiparasitic')),
    CONSTRAINT ck_health_entry_end_date CHECK (end_date IS NULL OR entry_type IN ('treatment', 'antiparasitic', 'allergy', 'chronic_disease')),
    CONSTRAINT ck_health_entry_dates    CHECK (end_date IS NULL OR end_date >= entry_date)
);

CREATE TABLE document (
    id_document      uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    file_name        varchar(255) NOT NULL,
    file_type        varchar(50)  NOT NULL,
    storage_ref      varchar(500) NOT NULL UNIQUE,          -- RG71 : fichier en stockage objet
    document_source  varchar(10)  NOT NULL,
    uploaded_at      timestamptz  NOT NULL DEFAULT now(),
    id_health_entry  uuid         NOT NULL REFERENCES health_entry (id_health_entry) ON DELETE CASCADE,  -- RG69
    CONSTRAINT ck_document_file_type CHECK (file_type IN ('application/pdf', 'image/jpeg', 'image/png', 'image/webp', 'image/heic')),  -- RG67
    CONSTRAINT ck_document_source    CHECK (document_source IN ('owner', 'vet'))   -- RG72
);

-- =====================================================================
-- 7. Géozones
-- =====================================================================

CREATE TABLE geo_zone_security (
    id_geo_zone       uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    geo_zone_name     varchar(100) NOT NULL,
    zone_type         varchar(10)  NOT NULL,
    center_latitude   numeric(9,6) NOT NULL,
    center_longitude  numeric(9,6) NOT NULL,
    radius            integer      NOT NULL,                -- mètres (RG31)
    id_user           uuid         NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,  -- RG36
    CONSTRAINT ck_geo_zone_type      CHECK (zone_type IN ('safe', 'forbidden')),  -- RG32
    CONSTRAINT ck_geo_zone_radius    CHECK (radius > 0),
    CONSTRAINT ck_geo_zone_latitude  CHECK (center_latitude  BETWEEN -90  AND 90),
    CONSTRAINT ck_geo_zone_longitude CHECK (center_longitude BETWEEN -180 AND 180)
);

CREATE TABLE pet_geo_zone (
    id_geo_zone  uuid    NOT NULL REFERENCES geo_zone_security (id_geo_zone) ON DELETE CASCADE,
    id_pet       uuid    NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    is_active    boolean NOT NULL DEFAULT true,             -- RG34
    PRIMARY KEY (id_geo_zone, id_pet)
);

-- =====================================================================
-- 8. Accès vétérinaire aux données
-- =====================================================================

CREATE TABLE pet_vet_access (
    id_pet             uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,
    ordinal_number     varchar(20) NOT NULL REFERENCES veterinarian (ordinal_number) ON DELETE RESTRICT,
    access_granted_at  timestamptz NOT NULL DEFAULT now(),
    access_revoked_at  timestamptz,
    access_source      varchar(20) NOT NULL,
    PRIMARY KEY (id_pet, ordinal_number, access_granted_at),
    CONSTRAINT ck_pet_vet_access_source CHECK (access_source IN ('owner', 'ai_escalation')),  -- RG40
    CONSTRAINT ck_pet_vet_access_dates  CHECK (access_revoked_at IS NULL OR access_revoked_at > access_granted_at)
);
-- RG41 : un seul accès actif par couple animal / véto
CREATE UNIQUE INDEX uq_pet_vet_access_active ON pet_vet_access (id_pet, ordinal_number) WHERE access_revoked_at IS NULL;

-- =====================================================================
-- 9. Alertes
-- =====================================================================

CREATE TABLE alert (
    id_alert         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    alert_type       varchar(30) NOT NULL,
    severity         varchar(10) NOT NULL,
    explanation      text        NOT NULL,                  -- RG51
    triggered_at     timestamptz NOT NULL DEFAULT now(),
    acknowledged_at  timestamptz,                           -- RG52 : partagé entre propriétaires
    id_pet           uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,  -- RG49
    id_geo_zone      uuid        REFERENCES geo_zone_security (id_geo_zone) ON DELETE SET NULL,
    CONSTRAINT ck_alert_type     CHECK (alert_type IN ('health', 'zone_exit', 'zone_entry', 'low_battery', 'collar_disconnected')),  -- RG46
    CONSTRAINT ck_alert_severity CHECK (severity IN ('info', 'warning', 'emergency')),   -- RG47
    -- RG48 : seules les alertes de zone sont reliées à une zone
    -- (id_geo_zone peut devenir NULL si la zone est supprimée, l'alerte est conservée)
    CONSTRAINT ck_alert_zone     CHECK (id_geo_zone IS NULL OR alert_type IN ('zone_exit', 'zone_entry'))
);

-- =====================================================================
-- 10. Chat IA et escalade
-- =====================================================================

CREATE TABLE conversation (
    id_conversation  uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    started_at       timestamptz NOT NULL DEFAULT now(),
    id_pet           uuid        NOT NULL REFERENCES pet (id_pet) ON DELETE CASCADE,            -- RG58
    id_user          uuid        NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE   -- RG53, RG58
);

CREATE TABLE message (
    id_message        uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    sender_role       varchar(10) NOT NULL,
    content           text        NOT NULL,
    sent_at           timestamptz NOT NULL DEFAULT now(),
    model_version     varchar(50),
    sources           jsonb,
    confidence_score  numeric(4,3),
    id_conversation   uuid        NOT NULL REFERENCES conversation (id_conversation) ON DELETE CASCADE,
    CONSTRAINT ck_message_sender_role CHECK (sender_role IN ('owner', 'ai', 'vet')),
    -- RG59 : champs IA renseignés pour les messages de l'IA uniquement
    CONSTRAINT ck_message_ai_fields   CHECK (sender_role = 'ai' OR (model_version IS NULL AND sources IS NULL AND confidence_score IS NULL)),
    CONSTRAINT ck_message_confidence  CHECK (confidence_score BETWEEN 0 AND 1)
);

CREATE TABLE escalation (
    id_escalation       uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    escalation_reason   text        NOT NULL,
    escalated_at        timestamptz NOT NULL DEFAULT now(),
    escalation_status   varchar(20) NOT NULL DEFAULT 'pending',
    preliminary_report  text,
    closed_at           timestamptz,
    id_conversation     uuid        NOT NULL UNIQUE REFERENCES conversation (id_conversation) ON DELETE CASCADE,  -- RG54
    ordinal_number      varchar(20) REFERENCES veterinarian (ordinal_number) ON DELETE RESTRICT,  -- véto en charge
    CONSTRAINT ck_escalation_status CHECK (escalation_status IN ('pending', 'in_progress', 'closed')),  -- RG55
    CONSTRAINT ck_escalation_vet    CHECK (escalation_status <> 'in_progress' OR ordinal_number IS NOT NULL),
    CONSTRAINT ck_escalation_closed CHECK ((escalation_status = 'closed') = (closed_at IS NOT NULL))
);

-- =====================================================================
-- 11. Abonnements
-- =====================================================================

CREATE TABLE subscription (
    id_subscription       uuid         PRIMARY KEY DEFAULT gen_random_uuid(),
    plan_code             varchar(50)  NOT NULL,
    subscription_status   varchar(20)  NOT NULL,
    started_at            timestamptz  NOT NULL,
    current_period_end    timestamptz  NOT NULL,            -- RG66 : base du calcul de la période de grâce
    canceled_at           timestamptz,
    payment_provider_ref  varchar(255) NOT NULL UNIQUE,     -- abonnement Stripe
    id_user               uuid         NOT NULL REFERENCES user_account (id_user) ON DELETE CASCADE,  -- RG65 : payeur
    serial_number         varchar(50)  NOT NULL REFERENCES collar (serial_number) ON DELETE RESTRICT,
    CONSTRAINT ck_subscription_status CHECK (subscription_status IN ('active', 'unpaid', 'canceled')),  -- RG61
    CONSTRAINT ck_subscription_period CHECK (current_period_end > started_at)
);
-- RG60 : au plus un abonnement en cours par collier (les résiliés restent historisés)
CREATE UNIQUE INDEX uq_subscription_current_collar ON subscription (serial_number)
    WHERE subscription_status IN ('active', 'unpaid');

-- =====================================================================
-- 12. Index de performance (PostgreSQL n'indexe pas les FK automatiquement)
-- =====================================================================

CREATE INDEX ix_breed_species                ON breed (species_code);
CREATE INDEX ix_breed_breed_type             ON breed (breed_type_code);
CREATE INDEX ix_pet_species                  ON pet (species_code);
CREATE INDEX ix_pet_vet                      ON pet (ordinal_number) WHERE ordinal_number IS NOT NULL;
CREATE INDEX ix_pet_breed_breed              ON pet_breed (breed_code);
CREATE INDEX ix_pet_owner_pet                ON pet_owner (id_pet);
CREATE INDEX ix_invitation_user               ON invitation (id_user);
CREATE INDEX ix_device_user                  ON device (id_user);
CREATE INDEX ix_vet_clinic_clinic            ON vet_clinic (id_clinic);
CREATE INDEX ix_collar_assignment_collar     ON collar_assignment (serial_number);
CREATE INDEX ix_health_entry_pet_date        ON health_entry (id_pet, entry_date DESC);
CREATE INDEX ix_health_entry_due             ON health_entry (next_due_date) WHERE next_due_date IS NOT NULL;  -- rappels
CREATE INDEX ix_document_health_entry        ON document (id_health_entry);
CREATE INDEX ix_geo_zone_user                ON geo_zone_security (id_user);
CREATE INDEX ix_pet_geo_zone_pet             ON pet_geo_zone (id_pet);
CREATE INDEX ix_pet_vet_access_vet           ON pet_vet_access (ordinal_number);
CREATE INDEX ix_alert_pet_time               ON alert (id_pet, triggered_at DESC);
CREATE INDEX ix_alert_zone                   ON alert (id_geo_zone) WHERE id_geo_zone IS NOT NULL;
CREATE INDEX ix_conversation_pet             ON conversation (id_pet);
CREATE INDEX ix_conversation_user            ON conversation (id_user);
CREATE INDEX ix_message_conversation_time    ON message (id_conversation, sent_at);
CREATE INDEX ix_escalation_vet               ON escalation (ordinal_number) WHERE ordinal_number IS NOT NULL;
CREATE INDEX ix_subscription_user            ON subscription (id_user);
CREATE INDEX ix_subscription_collar          ON subscription (serial_number);

-- =====================================================================
-- 13. Triggers (règles inter-tables non exprimables par une contrainte)
-- =====================================================================

-- RG16 : suppression du dernier propriétaire → suppression de l'animal et de ses données
CREATE FUNCTION fn_delete_orphan_pet() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    DELETE FROM pet p
    WHERE p.id_pet = OLD.id_pet
      AND NOT EXISTS (SELECT 1 FROM pet_owner po WHERE po.id_pet = OLD.id_pet);
    RETURN NULL;
END;
$$;

CREATE TRIGGER trg_pet_owner_delete_orphan_pet
AFTER DELETE ON pet_owner
FOR EACH ROW EXECUTE FUNCTION fn_delete_orphan_pet();

-- RG23 : seul un collier actif peut être affecté
CREATE FUNCTION fn_check_collar_active() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM collar c
        WHERE c.serial_number = NEW.serial_number AND c.collar_status = 'active'
    ) THEN
        RAISE EXCEPTION 'RG23 : le collier % n''est pas actif', NEW.serial_number;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_collar_assignment_check_active
BEFORE INSERT ON collar_assignment
FOR EACH ROW EXECUTE FUNCTION fn_check_collar_active();

-- RG33 : une zone ne surveille que les animaux de son créateur
CREATE FUNCTION fn_check_zone_owner() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM geo_zone_security z
        JOIN pet_owner po ON po.id_user = z.id_user
        WHERE z.id_geo_zone = NEW.id_geo_zone AND po.id_pet = NEW.id_pet
    ) THEN
        RAISE EXCEPTION 'RG33 : l''animal % n''appartient pas au créateur de la zone %', NEW.id_pet, NEW.id_geo_zone;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pet_geo_zone_check_owner
BEFORE INSERT OR UPDATE OF id_geo_zone, id_pet ON pet_geo_zone
FOR EACH ROW EXECUTE FUNCTION fn_check_zone_owner();

-- RG39 / RG56 : seul un véto partenaire reçoit un accès ou prend en charge une escalade
CREATE FUNCTION fn_check_vet_partner() RETURNS trigger
LANGUAGE plpgsql AS $$
BEGIN
    IF NEW.ordinal_number IS NOT NULL AND NOT EXISTS (
        SELECT 1 FROM veterinarian v
        WHERE v.ordinal_number = NEW.ordinal_number AND v.is_partner
    ) THEN
        RAISE EXCEPTION 'RG39 : le vétérinaire % n''est pas partenaire', NEW.ordinal_number;
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_pet_vet_access_check_partner
BEFORE INSERT OR UPDATE OF ordinal_number ON pet_vet_access
FOR EACH ROW EXECUTE FUNCTION fn_check_vet_partner();

CREATE TRIGGER trg_escalation_check_partner
BEFORE INSERT OR UPDATE OF ordinal_number ON escalation
FOR EACH ROW EXECUTE FUNCTION fn_check_vet_partner();

-- =====================================================================
-- 14. Règles laissées à l'application (décision d'équipe ou coût/bénéfice)
-- =====================================================================
-- RG3  : races d'un animal ∈ son espèce (décision : contrôle applicatif, pas de FK composite)
-- RG6  : espèce d'un animal immuable
-- RG11 : acceptation des CGU à l'inscription (même transaction que la création du compte)
-- Création d'un animal avec son premier lien pet_owner dans la même transaction
-- Cardinalités « au moins un » (pet_owner, consent, message, vet_clinic)
-- RG40 : validation de l'accès par un propriétaire avant insertion
-- RG57 : message véto seulement dans une conversation escaladée vers ce véto
-- RG66 : période de grâce calculée à partir de current_period_end
-- RG68 : ajout de document par un véto conditionné à un accès actif
-- Séries temporelles (GPS, capteurs, batterie) : TimescaleDB, base séparée (RG24)

COMMIT;
