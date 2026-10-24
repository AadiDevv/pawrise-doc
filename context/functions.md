# Pawrise Care – Fonctions principales

Ce que le système doit accomplir, par composante du WBS (`wbs.md`).

# 1. Pawrise Collar – Hardware Layer

## 1.1 Capteurs & Mesures
* Mesurer et enregistrer la position GPS de l'animal.
* Détecter l'activité, l'immobilité, les mouvements brusques.
* Mesurer la température et éventuellement le rythme cardiaque.
* Offrir des mesures précises et régulières pour l'analyse comportementale.

## 1.2 Système embarqué
* Collecter les données capteurs en temps réel.
* Optimiser la consommation énergétique du collier.
* Exécuter un firmware fiable pour lire et structurer les données.
* Assurer une disponibilité continue du système embarqué.

## 1.3 Communication du collier
* Transmettre les données vers l'application via BLE ou réseau cellulaire.
* Garantir une synchronisation fiable même en cas de perte temporaire de signal.
* Sécuriser l'envoi des données (authentification et intégrité).
* Standardiser le format des messages envoyés au backend.

## 1.4 Boîtier & Conception Physique
* Protéger le système interne contre l'eau, la poussière et les chocs.
* Offrir un confort optimal pour l'animal (poids, forme, matériau).
* Assurer l'intégration stable des capteurs dans le boîtier.
* Garantir la résistance à une utilisation prolongée en extérieur.

## 1.5 Batterie & Autonomie
* Assurer une autonomie maximale.
* Permettre une recharge simple et rapide.
* Adapter la consommation à l'usage et à l'environnement.
* Informer l'utilisateur du niveau de batterie restant.

# 2. Collector & Firmware Communication Layer

## 2.1 Acquisition de données
* Récupérer les données brutes des capteurs à intervalles réguliers.
* Détecter des événements significatifs (inactivité anormale, agitation, etc.).
* Conserver localement les données en cas de perte de connexion.

## 2.2 Transmission & Protocoles
* Assurer une synchronisation fluide avec l'app mobile.
* Utiliser un protocole robuste pour envoyer les données au backend.
* Garantir la transmission même en mode basse consommation.
* Réessayer automatiquement en cas d'échec d'envoi.

## 2.3 Sécurité
* Vérifier l'identité du collier avant transmission.
* Garantir que les données reçues n'ont pas été altérées.
* Assurer un horodatage exact.

# 3. Backend & API Platform

## 3.1 Ingestion des données
* Recevoir les données brutes envoyées par le collier.
* Normaliser, filtrer et nettoyer ces données pour stockage.
* Gérer les doublons, retards ou incohérences.
* Propager les données pertinentes vers les modules d'analyse.

## 3.2 Stockage & Modélisation
* Enregistrer les données capteurs en séries temporelles.
* Maintenir un historique long terme pour l'analyse vétérinaire.
* Générer des données agrégées.

## 3.3 API App & Vet
* Fournir aux utilisateurs les données nécessaires (GPS, activité, santé).
* Fournir aux vétérinaires une vue structurée de l'historique santé.
* Alimenter l'app mobile avec les alertes et recommandations.

## 3.4 Administration
* Gérer les comptes utilisateurs et les animaux associés.
* Permettre la configuration et mise à jour des règles d'analyse.
* Assurer un contrôle d'accès adapté entre propriétaire et vétérinaire.

# 4. Pawrise Care Engine – IA & Analyse

## 4.1 Prétraitement des données
* Nettoyer les données capteurs (bruit, valeurs aberrantes).
* Regrouper les données en fenêtres temporelles cohérentes.
* Détecter des signaux simples (inactivité prolongée, hausse température).

## 4.2 Analyse comportementale
* Établir un modèle de comportement normal propre à chaque animal.
* Détecter des anomalies d'activité ou de sommeil.
* Mesurer l'évolution de la vitalité au jour le jour.

## 4.3 Analyse santé contextuelle
* Appliquer des règles vétérinaires validées (expert system).
* Contextualiser l'état de l'animal selon race, âge, historique.
* Identifier les écarts nécessitant vigilance ou action.

## 4.4 Chat IA & Expertise
* Résumer les données en explications compréhensibles.
* Répondre aux questions à partir des données de l'animal et d'une base de connaissances vétérinaires (LLM avec RAG).
* Escalader automatiquement vers un vétérinaire partenaire en cas de doute.
* Préparer un rapport synthétique pour consultation.

## 4.5 Export vétérinaire
* Générer un rapport PDF clair et structuré.
* Offrir un export numérique standardisé.
* Organiser les données dans une chronologie médicale lisible.

# 5. Mobile App – Propriétaire animal

## 5.1 Écran Bien-être
* Afficher un score global de bien-être.
* Présenter l'activité, le sommeil et les constantes.
* Offrir une vue simple de l'état actuel de l'animal.

## 5.2 Localisation
* Montrer la position GPS en temps réel.
* Définir des zones sécurisées et alerter si l'animal en sort.
* Afficher l'historique des déplacements.

## 5.3 Notifications & Alertes
* Prévenir en cas de signaux faibles (fatigue, stress, inactivité).
* Alerter si un comportement anormal apparaît.
* Rappeler les soins réguliers (vaccins, traitements).

## 5.4 Chat & Accompagnement
* Donner accès au chat IA.
* Permettre une interaction fluide entre utilisateur et expert.
* Faciliter la mise en relation avec un vétérinaire partenaire.

# 6. Vet Portal – Interface Vétérinaire

## 6.1 Vue patient
* Regrouper les informations médicales essentielles de l'animal.
* Fournir un historique détaillé des données capteurs.
* Mettre en avant les tendances importantes.

## 6.2 Analyse professionnelle
* Consulter les alertes générées.
* Lire un rapport automatique et le compléter.
* Ajouter des notes professionnelles au dossier.

## 6.3 Collaboration
* Faciliter le dialogue propriétaire / vétérinaire.
* Proposer des recommandations ciblées.
* Suivre l'évolution de l'animal dans le temps.

# 7. Infrastructure & Ops

## 7.1 Hébergement
* Exécuter les services backend de manière fiable et scalable.
* Gérer les environnements de développement, test et production.
* Garantir la disponibilité du système.

## 7.2 Monitoring
* Surveiller les performances et l'usage des APIs.
* Détecter rapidement les anomalies système.
* Tracer les erreurs.

## 7.3 CI/CD
* Automatiser tests et déploiements.
* Gérer les versions des applications.
* Faciliter la livraison continue.

# 8. Data, Privacy & Compliance

## 8.1 Protection des données
* Sécuriser les données personnelles.
* Chiffrer les données en transit et au repos.
* Respecter le RGPD.

## 8.2 Transparence & Éthique
* Garantir que l'IA n'émet jamais de diagnostic médical.
* Fournir des explications lisibles des recommandations.
* Assurer la traçabilité des alertes et analyses.

# 9. Business & User Lifecycle

## 9.1 Onboarding & Appairage
* Création de compte simple et sécurisée.
* Guider la connexion du collier à l'application.
* Faciliter la saisie des informations de l'animal.

## 9.2 Abonnement & Facturation
* Gérer abonnements et paiements de manière transparente.
* Permettre la consultation des factures et du statut.
* Sécuriser les transactions.

## 9.3 Support Client
* Fournir un moyen simple de contacter le support.
* Offrir des réponses rapides aux questions fréquentes.

## 9.4 Provisioning
* Activer un nouveau collier de manière sécurisée.
* Gérer le remplacement ou la désactivation d'un collier.

## 9.5 Partenaires vétérinaires
* Permettre l'onboarding d'un vétérinaire partenaire.
* Attribuer les demandes selon disponibilité.
* Recueillir le retour d'expérience utilisateur / vétérinaire.
