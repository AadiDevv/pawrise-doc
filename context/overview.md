# Vue d'ensemble

## Produit

- 4 piliers : GPS intelligent, santé connectée (activité, sommeil, constantes, score bien-être), IA vétérinaire (chat RAG), vétérinaire partenaire (escalade, dashboard, service rémunéré).
- Flux : propriétaire → IA contextuelle (~80 % des cas) → vétérinaire partenaire avec accès aux données (cas sérieux).
- Différenciation : chaîne complète données capteurs → IA contextuelle → escalade véto humain → export PDF structuré (Tractive, Whistle, Maven Pet n'en couvrent qu'une partie).
- Cadrage : outil de conseil avec disclaimers médicaux, l'IA n'émet jamais de diagnostic.

## Équipe (9)

| Membre | Rôle |
| --- | --- |
| Yassine El Gherrabi | Backend, architecture, LLM/RAG, coordination PO |
| Elarif Inzoudine | Full-stack, CI/CD, DevOps |
| Ibrahim Sylla | Full-stack |
| Cyril Porez | Full-stack + IoT (seul profil hardware) |
| Nino Litim | Data / IA |
| Hamid Bennacef | Full-stack (backend) |
| Aaditya Satyal | Full-stack (backend) |
| Adam Lamouri | Data / IA + design UX/UI |
| Oumar Abdallah Abakar | Cloud infrastructure |

Organisation : sprints de 2 semaines, alternance (disponibilité limitée en période entreprise). Git : `main` → `develop` → `feature/*`, PR + 1 review + CI.

## Architecture backend

Macroservices, 5 services :

| Service | Rôle |
| --- | --- |
| IoT Gateway | Réception MQTT, authentification, validation des paquets, envoi vers RabbitMQ |
| Data Ingestion | Ingestion time-series en aval de RabbitMQ |
| API Core | Logique métier, enrichissement de contexte, escalade, contrôle d'accès, transformation des réponses |
| Care Engine | IA Python/FastAPI, LLM + RAG (~1,5 Go RAM, service séparé, potentiellement machine séparée) |
| File & Export | Export isolé (PDF, etc.) |

- Bases : App-DB (relationnel), TimescaleDB (séries temporelles, base séparée → références logiques, pas de FK), VectorDB.
- Bases métier séparées : App-DB (app propriétaire) et Vet-DB (Portail Vet). Voir `../bdd/README.md`.
- Infra : un VPS par environnement, scaling horizontal par ajout d'un second VPS.

## Analyse de risques (AMDEC)

- Répartition finale : 3 CRITIQUE, 4 ÉLEVÉ, 7 MODÉRÉ.
- CRITIQUE : faux négatifs IA (I01), hallucinations LLM (I03), échec de déclenchement de l'escalade (E01).
- Mitigations intégrées : cache BLE local, moyennes glissantes, score de confiance RAG, circuit breakers.
