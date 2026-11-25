# Note de cadrage : plateforme de données fraude et conformité

**Client :** Atlas Banque & Assurance (cas fictif)
**Auteur :** [Ton nom], ingénieur data
**Version :** 1.0, [date]
**Statut :** cadrage initial

> **Avertissement.** Atlas Banque & Assurance est un client fictif. Toutes les données utilisées sont simulées ou issues de jeux de données publics. Les chiffres du client (volumes, coûts, gains) sont des **hypothèses de travail**, signalées comme telles.

---

## 1. Contexte

Atlas est un groupe marocain de taille moyenne qui combine une banque de détail et une activité d'assurance (auto, habitation). Il compte environ 1,5 million de clients (hypothèse).

Son système d'information s'est construit par couches successives : un core banking, une application d'assurance et de nombreux fichiers Excel de reporting. Les données sont dispersées, les traitements tournent surtout la nuit, et la production des indicateurs repose sur des manipulations manuelles.

## 2. Problématique

| Constat | Conséquence pour le client |
|---|---|
| La détection de fraude repose sur des règles statiques et des traitements différés | La fraude est détectée plusieurs heures après les faits, ce qui limite les possibilités de blocage |
| Les données sont réparties entre plusieurs sources non réconciliées | Reporting lent, chiffres contradictoires entre directions |
| Il est difficile de retracer l'origine d'un indicateur | Risque en cas d'audit ou de contrôle |
| Les données personnelles circulent en clair dans plusieurs fichiers | Exposition au risque de fuite et de non-conformité |

**Question de pilotage :**
> Comment ramener le délai de détection de fraude de plusieurs heures à quelques secondes, tout en rendant le reporting traçable et conforme ?

## 3. Objectifs

1. **Unifier** les données bancaires et d'assurance dans une plateforme unique (architecture Lakehouse).
2. **Détecter** les transactions suspectes en quasi temps réel (règles métier + score de risque).
3. **Fiabiliser** le reporting avec des contrôles qualité automatisés et un lineage documenté.
4. **Protéger** les données personnelles par pseudonymisation et contrôle d'accès par rôle.
5. **Chiffrer** la valeur du projet (coûts, gains attendus) et proposer une feuille de route.

## 4. Périmètre

### Inclus dans le prototype

- Fraude sur transactions par carte bancaire, en batch et en streaming
- Un indicateur d'assurance : ratio sinistres/primes (S/P)
- Ingestion, nettoyage, modélisation et restitution (dashboard)
- Pseudonymisation des identifiants personnels
- Deux rôles d'accès : analyste fraude et auditeur
- Contrôles qualité automatisés et documentation du lineage

### Hors périmètre (évolutions possibles)

- Déploiement cloud (Azure) et Infrastructure as Code
- Orchestration par Kubernetes
- Catalogue de données d'entreprise complet
- Détection de fraude à l'assurance (sinistres) par modèle ML
- Intégration avec de vrais systèmes bancaires
- Audit de sécurité et certification

## 5. Données

| Donnée | Source | Nature |
|---|---|---|
| Transactions avec étiquette de fraude | Jeu de données public (PaySim ou équivalent, licence à vérifier) | Simulée |
| Clients, comptes, agences | Génération synthétique (Faker), contexte marocain | Simulée |
| Contrats et sinistres d'assurance | Génération synthétique | Simulée |
| Référentiels (marchands, produits, calendrier) | Fichiers générés | Simulée |

Du bruit réaliste est volontairement injecté (doublons, valeurs manquantes, formats de date incohérents, changements de schéma) afin de tester les contrôles qualité.

## 6. Solution cible (vue d'ensemble)

- **Ingestion :** Airflow (batch) et Kafka (streaming)
- **Traitement :** Spark et Spark Structured Streaming
- **Stockage :** Lakehouse en trois couches (Bronze brut, Silver nettoyé, Gold analytique) avec Delta Lake sur MinIO
- **Modélisation :** dbt, modèle en étoile, tests de données
- **Qualité :** Great Expectations et tests dbt, avec quarantaine des données invalides
- **Détection de fraude :** règles métier (montant, vitesse, changement de pays) et score par modèle de machine learning
- **Restitution :** dashboards Superset
- **Industrialisation légère :** Docker Compose, GitHub Actions

Le schéma d'architecture détaillé est disponible dans `docs/architecture.png`.

## 7. Indicateurs de succès

Les cibles ci-dessous sont des **hypothèses à valider** pendant le projet.

| Indicateur | Situation de départ (hypothèse) | Cible du prototype |
|---|---|---|
| Délai de détection d'une transaction suspecte | Plusieurs heures | Quelques secondes |
| Taux de lignes rejetées par les contrôles qualité | Non mesuré | Mesuré et publié à chaque exécution |
| Traçabilité d'un indicateur jusqu'à sa source | Impossible | 100 % des tables Gold documentées |
| Données personnelles en clair dans les couches Silver et Gold | Présentes | Aucune |
| Qualité du modèle de fraude | Sans objet | PR-AUC et couple précision/rappel documentés |

## 8. Hypothèses

- Les jeux de données publics sont suffisamment représentatifs pour démontrer l'approche.
- Un taux de fraude inférieur à 1 % des transactions, ce qui impose un traitement du déséquilibre de classes.
- Le volume simulé est réduit par rapport à un vrai établissement ; la scalabilité est discutée, pas testée.
- L'environnement du prototype tourne en local sur un poste de travail.

## 9. Risques

| Risque | Probabilité | Impact | Mesure |
|---|---|---|---|
| Périmètre trop large pour un mois | Élevée | Élevé | Périmètre figé, ordre de sacrifice défini (voir §11) |
| Ressources machine insuffisantes (Spark, Kafka, Airflow en local) | Moyenne | Moyen | Configuration allégée, services lancés par profils |
| Modèle de fraude peu performant | Moyenne | Faible | Priorité à l'évaluation honnête plutôt qu'à la performance |
| Données simulées jugées peu crédibles | Moyenne | Moyen | Bruit réaliste injecté et limites documentées |
| Licence des jeux de données incompatible | Faible | Moyen | Vérification et citation des sources dans le README |

## 10. Contraintes de conformité et de sécurité

Le projet applique le principe de protection dès la conception :

- pseudonymisation des identifiants personnels dès la couche Silver ;
- accès séparés par rôle sur la couche Gold ;
- aucun secret dans le dépôt Git (fichier `.env` exclu) ;
- journalisation des exécutions de pipelines.

Les exigences réglementaires marocaines applicables (protection des données personnelles, exigences des régulateurs bancaire et assurantiel) seront **cartographiées et vérifiées auprès des textes officiels** avant d'être citées dans le dossier final.

## 11. Planning et priorités

| Semaine | Contenu | Livrable |
|---|---|---|
| 1 | Cadrage, environnement, données, premier pipeline bout en bout | Note de cadrage, pipeline source vers dashboard |
| 2 | Couche Gold, qualité, pseudonymisation | Données fiables et documentées |
| 3 | Streaming, règles de fraude, modèle ML | Détection quasi temps réel |
| 4 | Business case, roadmap, documentation, démo | Dossier final présentable |

**Ordre de sacrifice en cas de retard :** d'abord l'intégration du score ML au flux streaming (conservé en batch), puis le fait sinistres, puis la CI. Les contrôles qualité, la pseudonymisation et la documentation ne sont jamais sacrifiés.

## 12. Livrables

1. Note de cadrage (ce document)
2. Schéma d'architecture as-is / to-be
3. Plateforme de données fonctionnelle (code, `docker compose up`)
4. Rapport de qualité des données et documentation du lineage
5. Évaluation du modèle de fraude
6. Business case et feuille de route
7. Présentation exécutive et vidéo de démonstration

## 13. Validation

| Rôle | Nom | Date |
|---|---|---|
| Auteur | [Ton nom] | [date] |
| Sponsor (fictif) | Direction des risques, Atlas | n/a |
