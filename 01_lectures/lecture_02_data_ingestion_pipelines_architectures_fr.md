# Business Intelligence et Analyse des Mégadonnées (`01 31 0367 00`)

## Synthèse Académique et Technique — Cours 02 : Ingestion de Données, Pipelines et Architectures d'Entreprise

**Langue :** Français (`FR`)  
**Semestre :** Automne / Printemps  
**Public :** Ingénieurs 4e année B.Sc. (Génie Industriel et Management de la Production)

---

## 1. Contexte Opérationnel et Mission d'Ingénierie

### 1.1 Constats Techniques Issus des Travaux Pratiques
Lors des premières sessions de laboratoire et de travaux dirigés, l'analyse des données sources industrielles a mis en lumière trois contraintes structurelles majeures :
* **Formats Multiples et Non Intégrés :** Les données sont dispersées entre des fichiers plats CSV, des classeurs Excel multi-onglets et des structures hiérarchiques JSON imbriquées.
* **Divergence des Résolutions Temporelles :** Coexistence de relevés de capteurs haute fréquence (relevés toutes les 15 minutes), de récapitulatifs opérationnels par poste de travail (8 heures) et de transactions logistiques ou financières enregistrées au jour le jour.
* **Altération des Données de Référence :** Présence d'identifiants machines hétérogènes (ex. `"PRESS_01"` face à `"Press_01 "`), d'espaces résiduels de fin de chaîne, de valeurs manquantes dues à des ruptures de communication réseau et de pics d'aberration sur les capteurs.

### 1.2 La Mission d'Ingénierie des Données
La mission consiste à concevoir et déployer une passerelle d'ingestion automatisée, résiliente et sans intervention humaine, capable de collecter ces flux isolés, de corriger leurs incohérences et de les charger au sein d'une couche de préparation (*staging*) analytique standardisée.

---

## 2. Le Parcours de la Donnée de Bout en Bout (*The End-to-End Data Journey*)

Le cycle de vie complet de la donnée industrielle s'articule autour de six couches fonctionnelles successives :

```text
 ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
 │ SOURCES ISA-95  │ ────► │ ZONE DE DÉPÔT   │ ────► │ STOCKAGE TABLES │
 │ (ERP, MES, IoT) │       │ (Bronze / Brut) │       │(Parquet/Iceberg)│
 └─────────────────┘       └─────────────────┘       └─────────────────┘
                                                               │
                                                               ▼
 ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
 │ RESTITUTION BI  │ ◄──── │ MODÉLISATION    │ ◄──── │ TRANSFORMATION  │
 │(PowerBI/Looker) │       │ (Gold / Étoile) │       │ (Silver / Qual.)│
 └─────────────────┘       └─────────────────┘       └─────────────────┘
```

1. **Systèmes Sources (Pyramide ISA-95) :** Systèmes ERP, MES, WMS, supervisions SCADA, compteurs communicants IoT et API partenaires.
2. **Zone de Dépôt et d'Ingestion (*Landing Layer / Bronze*) :** Extraction physique, transport réseau sécurisé, conversion initiale des flux et atterrissage à l'état brut.
3. **Formats de Fichiers et Stockage :** Stockage objet distribué dans le cloud (AWS S3, Google Cloud Storage) et formats de tables colonnaires ouverts (Apache Parquet, Apache Iceberg).
4. **Nettoyage et Qualité des Données (*Silver*) :** Déduplication, détection statistique des valeurs aberrantes, imputation des valeurs nulles et harmonisation des libellés.
5. **Modélisation Analytique et Entreposage (*Gold*) :** Schéma dimensionnel en étoile de Ralph Kimball, gestion des clés de substitution (*surrogate keys*) et vues relationnelles OLAP.
6. **Restitution et Récit de Données (*Serving & Storytelling*) :** Tableaux de bord décisionnels interactifs (Power BI, Looker Studio) et synthèses visuelles destinées aux comités de direction.

> **Axiome Fondamental d'Ingénierie :** *L'ingestion constitue la porte d'entrée de toute l'architecture de données. Si l'ingestion échoue ou laisse entrer silencieusement des données erronées, l'ensemble des indicateurs, des modèles analytiques et des décisions stratégiques en aval sera irrémédiablement compromis.*

---

## 3. Canaux d'Ingestion et Stratégies de Chargement

### 3.1 Canaux d'Ingestion en Milieu Industriel
* **Réplication de Base de Données et CDC (*Change Data Capture*) :** Extraction en flux direct depuis les bases de données relationnelles transactionnelles (PostgreSQL, Oracle, SQL Server). Le CDC lit les journaux de transactions (ex. via Debezium) sans solliciter le processeur des systèmes opérationnels de l'usine.
* **Dépôts de Fichiers par Lots (*Batch Drops*) :** Exports programmés périodiques (fichiers CSV, classeurs Excel, JSON) transmis par serveurs SFTP sécurisés ou déposés dans des compartiments de stockage d'objets cloud.
* **APIs REST et Webhooks :** Récupération de données externes semi-structurées au format JSON (tarifications dynamiques de l'énergie horaire, suivi des transporteurs logistiques).
* **Flux IoT Industriels (*Publish / Subscribe*) :** Protocoles de communication légers à très faible latence (MQTT, OPC-UA) diffusant en temps réel les mesures issues des automates programmables (PLC) et des capteurs de puissance.

### 3.2 Chargement Complet (*Full Load*) vs Chargement Incrémentiel (*Incremental Load*)

```text
        STRATÉGIE A : CHARGEMENT COMPLET (Snapshot / Truncate & Reload)
  Source ──[100% de la Table]──► Destination (Entièrement purgée et réécrite)
  * Coût d'E/S et de bande passante réseau très élevé ; réservé aux petites tables.

        STRATÉGIE B : CHARGEMENT INCRÉMENTIEL (Delta Append / Upsert)
  Source ──[Filtre: updated_at > :dernier_run]──► Destination (Mise à jour ciblée)
  * Hautement scalable ; optimise le réseau mais requiert un filigrane temporel fiable.
```

* **Chargement Complet (*Snapshot / Truncate & Reload*) :**
  * *Mécanisme :* La totalité des données sources est extraite à chaque cycle, remplaçant intégralement le contenu de la table cible.
  * *Avantages et Limites :* Simplicité de mise en œuvre, mais totalement inadapté aux volumétries importantes en raison de la saturation du réseau et des entrées/sorties disque.
  * *Cas d'Usage :* Petites tables de référence à évolution très lente (registres de machines, listes d'équipes).
* **Chargement Incrémentiel (*Delta Append / Upsert*) :**
  * *Mécanisme :* Seules les lignes nouvellement créées ou modifiées depuis la dernière extraction sont collectées et insérées ou fusionnées.
  * *Prérequis :* Nécessite un champ de filigrane fiable (*High-Water Mark*, ex. `updated_at > :derniere_date_chargement`) ou une capture des modifications via CDC.
  * *Cas d'Usage :* Tables transactionnelles de commandes, journaux de pannes de GMAO et séries temporelles de capteurs IoT.

### 3.3 Opérations de Rattrapage Historique (*Backfilling*)
Le *backfilling* désigne l'exécution manuelle ou automatisée d'un pipeline de traitement sur une période chronologique antérieure.

* **Trois Déclencheurs Majeurs en Entreprise :**
  1. *Déploiement Initial d'une Solution :* Lancement d'un nouveau projet décisionnel nécessitant de recalculer 12 à 24 mois de métriques historiques d'efficacité énergétique ou de TRS.
  2. *Correction d'une Formule Métier :* Modification de l'algorithme d'imputation d'un arrêt machine imposant le retraitement de l'historique complet.
  3. *Reprise Après Panne Réseau Amont :* Restauration de la connectivité atelier après une coupure de 72 heures, nécessitant le traitement ordonné des journaux accumulés.
* **L'Erreur Naïve vs la Démarche Gouvernée :**
  * *L'Erreur Naïve :* Lancer une requête SQL unique portant sur une année complète de données historiques. Cette pratique sature la mémoire du serveur, déclenche des blocages par les quotas d'API (*rate limits*) et engendre des doublons massifs.
  * *La Démarche Gouvernée :* Fractionner le traitement en fenêtres étanches (*chunking*, jour par jour), procéder à un écrasement ciblé des dossiers de partitions (`year=2026/month=09/`) et utiliser les fonctions natives des orchestrateurs (paramètre `catchup=True` sous Apache Airflow).

---

## 4. Architecture des Formats de Fichiers : En Ligne vs En Colonne

### 4.1 Analyse Comparative des Formats de Données

| Critère d'Ingénierie | Format CSV (Lignes Texte) | Format JSON / JSONL (Arbre Texte) | Apache Parquet (Binaire Colonne) |
| :--- | :--- | :--- | :--- |
| **Structure Physique** | Ligne par ligne en texte brut | Hiérarchies d'objets imbriqués | Binaire structuré par colonnes |
| **Contrat de Schéma** | Aucun (typé arbitrairement) | Dynamique et semi-structuré | Strict et embarqué en métadonnées |
| **Taux de Compression** | Faible (données hétérogènes) | Très faible (répétition des clés) | Extrême ($70\%$ à $90\%$ d'économie) |
| **Performance en Lecture**| Lente (parcours de tout le fichier) | Lente (consommation CPU élevée) | Maximale (accès direct aux blocs) |
| **Domaine de Prédilection**| Échange générique de données | Échanges Web et messages IoT | Entrepôts, Lacs et moteurs OLAP |

### 4.2 Sympathie Mécanique et Goulots d'Étranglement Matériels
La lecture physique des octets sur le disque dur représente le composant le plus lent de l'infrastructure informatique. La notion de **sympathie mécanique** (*mechanical sympathy*) consiste à concevoir l'agencement des données de manière à respecter le fonctionnement physique des contrôleurs de stockage :

```text
             DISPOSITION EN LIGNE (CSV / SGBD Relationnel)
 Ligne 1: [ID: 1, Machine: PRESS_01, État: RUN, Temp: 310.2]
 Ligne 2: [ID: 2, Machine: PRESS_01, État: RUN, Temp: 310.4]
 Requête : SELECT AVG(Temp) -> Le matériel doit lire TOUS les octets de toutes
 les colonnes sur le disque pour n'en conserver que 25% (gaspillage de bande passante).

            DISPOSITION EN COLONNE (Apache Parquet / DuckDB)
 Bloc ID      : [1, 2, 3, 4]
 Bloc Machine : ["PRESS_01", "PRESS_01", "PRESS_01", "PRESS_02"]
 Bloc Temp    : [310.2, 310.4, 328.0, 309.8]
 Requête : SELECT AVG(Temp) -> L'analyseur se positionne directement sur le bloc
 mémoire "Temp". Zéro octet lu pour l'ID, la Machine ou l'État (Projection Pushdown).
```

### 4.3 Algorithmes d'Encodage et de Compression Haute Densité
Puisque les colonnes regroupent des valeurs strictement homogènes, elles permettent l'application d'algorithmes de compression particulièrement puissants :
* **Encodage par Dictionnaire (*Dictionary Encoding*) :**
  Remplace les chaînes de caractères répétitives par de petits index entiers :

$$\text{Flux texte : } [\text{"RUN"},\, \text{"RUN"},\, \text{"WARN"}] \implies \text{Dictionnaire : } \{0: \text{"RUN"},\, 1: \text{"WARN"}\} \implies [0,\, 0,\, 1]$$

  *Gain :* Une chaîne de texte pesant environ 8 octets est remplacée par un entier de 1 octet.
* **Encodage par Longueur de Plage (*Run-Length Encoding - RLE*) :**
  Compresse les séquences ininterrompues de valeurs identiques sous forme de tuples (Valeur, Fréquence) :

$$\text{Séquence : } [\text{"P01"},\, \text{"P01"},\, \text{"P01"},\, \text{"P02"}] \implies (\text{"P01"},\, 3),\, (\text{"P02"},\, 1)$$

  *Gain :* Des milliers de lignes consécutives émises par une même machine sont condensées en un seul bloc d'octets.

### 4.4 Anatomie Interne d'un Fichier Apache Parquet

```text
 ┌────────────────────────────────────────────────────────────────────────┐
 │ EN-TÊTE : Code magique binaire "PAR1" (4 octets)                       │
 ├────────────────────────────────────────────────────────────────────────┤
 │ ROW GROUP 1 (Partition Horizontale : généralement 128 Mo à 512 Mo)     │
 │  ├── Chunk Colonne A (Pages de données compressées Snappy/RLE)         │
 │  ├── Chunk Colonne B (Pages de données compressées Dict/Zstd)          │
 │  └── Chunk Colonne C (Pages de données continues)                      │
 ├────────────────────────────────────────────────────────────────────────┤
 │ ROW GROUP 2 (Partitions Horizontales additionnelles...)                │
 ├────────────────────────────────────────────────────────────────────────┤
 │ PIED DE PAGE / FOOTER (Métadonnées & Statistiques - Lu en Premier !)   │
 │  ├── Schéma complet et types stricts des données                       │
 │  ├── Statistiques de blocs : Valeurs Min / Max, Nombre de Valeurs Null │
 │  └── Décalages d'octets de chaque Chunk (Byte Offsets)                 │
 └────────────────────────────────────────────────────────────────────────┘
```

#### Pourquoi le Pied de Page (*Footer*) est-il Lu en Premier ?
Lors de l'écriture d'un fichier Parquet, les métadonnées globales, les adresses de décalage mémoire et les bornes statistiques ne sont connues qu'une fois le dernier enregistrement traité. Placer le bloc de métadonnées à la fin évite d'avoir à repositionner la tête d'écriture au début du fichier.

À la lecture, le moteur analytique charge prioritairement ce pied de page pour déployer deux mécanismes d'accélération :
1. **Projection Pushdown :** L'analyseur cible uniquement les adresses mémoire des colonnes requises par la clause `SELECT`, ignorant l'ensemble des autres colonnes stockées sur le disque.
2. **Predicate Pushdown :** Lorsqu'une requête applique un filtre (ex. `WHERE Temp > 350`), le moteur examine les bornes `[Min, Max]` consignées dans le pied de page du *Row Group*. Si la température maximale du bloc ne dépasse pas $328$, le groupe de lignes entier ($128\text{ Mo}$) est ignoré sans nécessiter de lecture détaillée ni de décompression.

---

## 5. Principes Fondamentaux de Conception des Pipelines

### 5.1 Idempotence
Une opération est qualifiée d'**idempotente** si le fait de la réexécuter plusieurs fois consécutives avec les mêmes données en entrée aboutit au même état final, sans générer d'effets de bord ni multiplier les lignes enregistrées :

$$f(f(x)) = f(x)$$

* **L'Anti-Patron du Chargement Aveugle (*Blind Append*) :**
  En cas de coupure réseau temporaire, l'orchestrateur relance automatiquement la tâche d'extraction. Si le pipeline insère les lignes sans contrôle, la production journalière et les rebuts sont artificiellement doublés, faussant l'ensemble des indicateurs de performance.
* **Techniques d'Implémentation de l'Idempotence :**
  1. *Écrasement de Partition (*Partition Overwrite*) :* Répartir les données dans des partitions temporelles dédiées (`date=2026-10-30/shift=S1/`). Toute réexécution écrase et remplace le contenu du dossier cible sans duplication.
  2. *Opérations de Fusion / Mise à Jour (*Upsert / Merge*) :* Recourir à une clé primaire composite (ex. `machine_id` + `timestamp`) pour mettre à jour les enregistrements existants et n'insérer que les nouveaux éléments.

### 5.2 Gestion de la Dérive de Schéma (*Schema Drift*)
La dérive de schéma correspond à l'altération imprévue de la structure des données transmises par les systèmes amont (renommage de colonnes, modification des types de variables, apparition de champs non documentés).
* **Validation Stricte (*Fail-Fast / Strict Enforcement*) :** Le pipeline compare les données entrantes à un schéma contractuel rigide. En cas d'écart, l'exécution s'interrompt immédiatement et émet une alerte, empêchant toute corruption de la zone de préparation.
* **Évolution de Schéma (*Schema Evolution / Schema-on-Read*) :** Les attributs non conformes sont stockés au sein de colonnes semi-structurées dynamiques (champs de type JSON variant), reportant leur typage et leur traitement aux étapes de modélisation en aval.

### 5.3 Lignage des Données (*Data Lineage*)
Le lignage correspond à la cartographie complète retraçant l'origine, les étapes d'agrégation et les flux de distribution de chaque donnée dans le système décisionnel :
* **Audit des Causes Racines :** Permet de remonter depuis une anomalie de TRS constatée sur un tableau de bord jusqu'à l'enregistrement défectueux initial dans `sensor_telemetry.csv`.
* **Analyse d'Impact :** Permet de déterminer avec précision quels tableaux de bord seront affectés par la modification de structure d'une table d'atelier.
* **Conformité Réglementaire :** Assure la traçabilité complète des données d'émissions polluantes et des certifications de qualité industrielle.

---

## 6. Évolution des Architectures de Données Distribuées

```text
 ┌──────────────────────┐      ┌──────────────────────┐      ┌──────────────────────┐
 │ GÉNÉRATION 1         │      │ GÉNÉRATION 2         │      │ GÉNÉRATION 3         │
 │ Entrepôt Traditionnel│ ───► │ Lac de Données       │ ───► │ Lakehouse Moderne    │
 │ (DWH : 1990 - 2000)  │      │ (Data Lake : 2010)   │      │ (Lakehouse : Présent)│
 └──────────────────────┘      └──────────────────────┘      └──────────────────────┘
   • SQL relationnel rapide      • Stockage objet économique   • Découplage calcul/stockage
   • Stockage et calcul liés     • Schéma à la lecture         • Conformité ACID complète
   • Inadapté aux flux IoT       • Risque de "Data Swamp"      • Moteurs OLAP serverless
```

### 6.1 Calcul Distribué : Montée en Charge Verticale vs Horizontale
* **Montée en Charge Verticale (*Scale-Up*) :** Ajout de mémoire et de processeurs à un serveur central unique. Cette méthode se heurte à des limites physiques infranchissables et génère des coûts financiers disproportionnés.
* **Montée en Charge Horizontale (*Scale-Out*) :** Interconnexion de machines standard au sein d'un cluster unifié.
* **Le Triptyque Hadoop (2006) :**
  1. *HDFS :* Système de fichiers distribué découpant les données en blocs de $128\text{ Mo}$ répliqués sur plusieurs nœuds physiques.
  2. *MapReduce :* Modèle de programmation déplaçant les algorithmes de calcul directement sur les machines hébergeant les données.
  3. *YARN :* Gestionnaire de ressources allouant les capacités CPU et mémoire aux différents travaux distribués.
* **L'Apport d'Apache Spark (2014) :** Remplacement des écritures disque intermédiaires de MapReduce par des traitements distribués directement en mémoire vive, offrant des gains de vitesse de calcul de l'ordre de $10\times\text{ à }100\times$.

### 6.2 Comparatif des Outils : Environnement Pédagogique vs Solutions Industrielles

| Couche Architecturale | Outils Utilisés dans le Cours | Équivalents Cloud d'Entreprise |
| :--- | :--- | :--- |
| **Ingestion et Connecteurs (EL)** | Python (`pandas`, `openpyxl`, `json`) | Fivetran, Airbyte, Apache Kafka, Debezium |
| **Stockage & Tables de Transit** | Fichiers locaux (`.parquet`, `.csv`) | Amazon S3, Google Cloud Storage, Apache Iceberg |
| **Moteur Analytique (OLAP)** | DuckDB (Moteur SQL vectorisé local) | Snowflake, Google BigQuery, Databricks |
| **Framework de Transformation (T)** | Scripts Python et Vues SQL DuckDB | dbt (*data build tool*), Dataform |
| **Orchestrateur de Traitements** | Enchaînement de scripts et jalons TP | Apache Airflow, Dagster, Prefect |
| **Restitution Visuelle (BI)** | Power BI, Looker Studio, Streamlit | Microsoft Power BI Service, Tableau Cloud |

---

## 7. Orchestration des Flux de Travail et Graphes Orientés Acycliques (DAGs)

Un orchestrateur (ex. Apache Airflow) coordonne l'exécution et les dépendances entre les différentes tâches au moyen de **DAGs (*Directed Acyclic Graphs*)** :
* **Orienté (*Directed*) :** Les flux d'exécution suivent un sens unique, depuis les extractions amont jusqu'aux tables finales.
* **Acyclique (*Acyclic*) :** Le graphe ne tolère aucune boucle fermée. Une tâche ne peut pas dépendre, directement ou indirectement, de sa propre sortie ($A \rightarrow B \rightarrow C \rightarrow A$), prévenant tout risque de blocage infini.

```text
                  EXEMPLE D'UN DAG INDUSTRIEL D'INGESTION
                  
  ┌─────────────────────────┐             ┌─────────────────────────┐
  │ Tâche 1 : Ingestion     │             │ Tâche 2 : Ingestion     │
  │ Télémétrie SCADA Bronze │             │ Planning d'Équipes ERP  │
  └────────────┬────────────┘             └────────────┬────────────┘
               │                                       │
               └───────────────────┬───────────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │ Tâche 3 : Barrière Valid. │
                     │ Contrôle des Volumétries  │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │ Tâche 4 : Nettoyage Silver│
                     │ Filtrage Aberrant & Dédub │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │ Tâche 5 : Modèle Gold     │
                     │ Étoile Kimball & Calc TRS │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │ Tâche 6 : Restitution     │
                     │ Actualisation Cache BI    │
                     └───────────────────────────┘
```

---

## 8. Hygiène Temporelle et Granularité des Données Industrielles

### 8.1 Gestion des Horodatages et des Fuseaux Horaires
L'alignement temporel des flux industriels exige le respect de trois principes stricts :
1. **Normalisation selon la Norme ISO-8601 :** Les chaînes de caractères brutes doivent être converties en types de données horodatés stricts dès l'entrée dans la couche Bronze (`AAAA-MM-JJTHH:MM:SSZ`).
2. **Le Risque des Décalages de Fuseaux (UTC vs Heure Locale d'Usine) :** Les passerelles IoT et les capteurs d'atelier enregistrent leurs mesures en temps universel coordonné (UTC), tandis que les plannings de production du système ERP sont renseignés en heure locale (ex. CET/CEST).
   * *Conséquence d'une omission :* L'absence de conversion produit un décalage d'une à deux heures, attribuant à tort les rebuts d'une prise de poste du matin au responsable de l'équipe de nuit précédente.
   * *Règle d'Ingénierie :* Collecter, stocker et transformer l'ensemble des données en UTC. La conversion vers le fuseau horaire local ne doit intervenir que lors de l'affichage sur le tableau de bord final.
3. **Gestion des Changements d'Heure (*Daylight Saving Time - DST*) :** En automne, le recul d'une heure génère des horodatages locaux dupliqués. Au printemps, la perte d'une heure crée une discontinuité artificielle dans les séries temporelles.

### 8.2 Traitement des Mésappariements de Granularité Temporelle
* **Sous-échantillonnage (*Downsampling* / Agrégation Temporelle) :**
  Opération consistant à agréger une série temporelle haute fréquence pour la faire correspondre à l'échelle de reporting attendue :

$$\text{Consommation d'Énergie du Poste } [\text{kWh}] = \sum_{i=1}^{32} \text{Mesure}_{15\min}(i)$$

$$\text{Facteur de Puissance Moyen } [\%] = \frac{1}{32} \sum_{i=1}^{32} \text{Facteur}_{15\min}(i)$$

* **Alignement Événement-Fenêtre (*Event-to-Window Mapping*) :**
  Consiste à associer un événement ponctuel à sa plage de fonctionnement ou à sa tranche tarifaire de rattachement (ex. arrêt machine consigné à `14:23:10` rattaché au Poste 2 débutant à `14:00:00`).

```text
                    LE PIÈGE DU DÉCUPLEMENT DE LIGNES
                  (The Multi-Row Fan-Out Trap Warning)
                  
 Si l'on réalise une jointure SQL entre une table de relevés quart-horaires
 (32 enregistrements par poste) et une table de production consolidée par poste
 (1 ligne) SANS avoir préalablement agrégé la première, la jointure va démultiplier
 les volumes de production par 32, faussant totalement le calcul des coûts et du TRS.
```

---

## 9. Profils Techniques d'Ingestion des Études de Cas

### Cas d'Étude 1 : SmartPress Automotive
* **Sources de Données :** `sensor_telemetry.csv`, `maintenance_logs.json`, `machines_and_shifts.xlsx`.
* **Défis Techniques d'Ingestion :**
  * Suppression des espaces parasites dans les identifiants machines (`"Press_01 "` $\rightarrow$ `"PRESS_01"`).
  * Harmonisation des chaînes de dates selon le standard ISO-8601.
  * Synchronisation des plages d'arrêts consignées en GMAO avec les mesures de couple et de température quart-horaires.

### Cas d'Étude 2 : DataCo Industrial
* **Sources de Données :** `order_items_trans.csv`, `shipment_events.json`, `master_catalog.xlsx`.
* **Défis Techniques d'Ingestion :**
  * Ingestion de flux d'événements semi-structurés JSON et normalisation des notations de remises ($15{,}0$ vs $0{,}15$).
  * Nettoyage des libellés relatifs aux modes de transport logistique et suppression des espaces superflus.
  * Dérivation dynamique des délais d'acheminement par calcul d'écart entre horodatages de jalons (`DISPATCHED_FROM_HUB` et `DELIVERED_AT_GATE`).
  * Rapprochement par jointure des lignes de commandes clients avec les statuts d'expédition sans démultiplication de lignes (*Fan Trap*).

### Cas d'Étude 3 : Nexis Precision Electronics
* **Sources de Données :** `shift_production_performance.csv`, `workforce_events.json`, `workforce_roster_and_skills.xlsx`.
* **Défis Techniques d'Ingestion :**
  * Extraction et traitement du flux semi-structuré d'événements de badges et d'audits de postes (JSON) pour calculer les heures d'opérateurs par quart.
  * Harmonisation de la casse des contrats de travail (`temp_agency` vs `Temporary_Agency`) et détection des pointages anormaux (durées de 145 h non closes).
  * Rapprochement multi-sources entre la présence effective des intérimaires, les rebuts observés en atelier et l'évaluation de la Prime Qualité.

