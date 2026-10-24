# Décisions techniques

| Choix | Rôle / raison |
| --- | --- |
| Neon Cloud | PostgreSQL managé + TimescaleDB + pgvector (préféré à Supabase) |
| NestJS | Framework des services métier |
| FastAPI | Care Engine (écosystème IA Python) |
| Mosquitto | Broker MQTT des colliers |
| RabbitMQ | Tampon IoT Gateway → Data Ingestion uniquement : perte de message inacceptable et débit asymétrique |
| Redis | Cache d'authentification |
| Traefik | Routeur interne Docker : SSL, health checks, middlewares, évolutivité (justifié même avec un seul service exposé) |
| Cloudflare | Reverse proxy externe, protection DDoS |
| Prisma | ORM de l'API Core, en approche base d'abord : `bdd/sql/` reste la seule source des migrations (2026-10-24) |
| Vertical slice + domaine pur | Architecture de l'API Core : un dossier par cas d'usage (`features/<ressource>/<cas>/`), règles métier dans `domain/` qui ne dépend de rien, Prisma appelé directement dans le handler. Un repository seulement pour une ressource dont les requêtes deviennent lourdes et partagées (2026-10-24) |

## Principes

- YAGNI : RabbitMQ seulement où c'est justifié, un seul VPS tant que la charge ne l'impose pas.
- Responsabilité unique : enrichissement, persistance, escalade et contrôle d'accès vivent dans l'API Core, pas dans le service d'inférence.
- Node.js en cohabitation Docker : un conteneur ≈ un cœur, à prendre en compte dans les comparaisons mémoire.
- Documentation : ne pas répéter sur les fiches ce que le schéma montre déjà (dépendances, flux).
