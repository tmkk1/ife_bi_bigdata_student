# Business Intelligence et Analyse des Mégadonnées (`01 31 0367 00`)

## Synthèse Académique et Technique — Cours 01 : Introduction à la Gestion des Données Industrielles

**Langue :** Français (`FR`)  
**Semestre :** Automne / Printemps  
**Public :** Ingénieurs 4e année B.Sc. (Génie Industriel et Management de la Production)

---

## 1. Cadre Pédagogique, Organisation et Gouvernance du Cours

### 1.1 Charge de Travail et Rythme Hebdomadaire
* **Crédits ECTS :** 5 ECTS (Volume global : 15h de Cours Magistraux, 30h de Travaux Pratiques / Laboratoires, 30h de Travaux Dirigés / Ateliers d'architecture).
* **Rythme Opérationnel :**
  * **Cours Magistraux :** Fondements théoriques, principes de modélisation dimensionnelle, méthodologie de calcul des indicateurs de performance (KPI), règles de perception et de sémiologie graphique.
  * **Laboratoires (3h Pratiques) :** Implémentation technique via Python et Pandas, requêtage analytique haute performance avec DuckDB et SQL, intégration d'outils décisionnels modernes et exploration des jeux de données réels.
  * **Travaux Dirigés (3h en Équipes) :** Conception d'architecture de données, élaboration de schémas en étoile (*Star Schema*) de niveau production, formulation mathématique rigoureuse des métriques industrielles et maquettage (*wireframing*) de tableaux de bord exécutifs.

### 1.2 Modalités d'Évaluation et Règlements
* **Seuil d'Admission :** Obtention obligatoire d'un minimum de $51\%$ à chacune des deux composantes d'évaluation :
  * **Test de Connaissances Individuel (20%) :** Épreuve de 30 minutes portant sur les méthodes numériques, les paradigmes ELT, la modélisation dimensionnelle de Kimball, le calcul de métriques et les moteurs OLAP.
  * **Projet d'Équipe et Soutenance Orale (80%) :** Livraison et défense en semaine 10 d'une solution décisionnelle de bout en bout (*end-to-end*) réalisée par équipes de 5 étudiants.
* **Régime d'Assiduité :** Présence obligatoire aux Travaux Pratiques et Travaux Dirigés. Tolérance maximale d'une seule absence non justifiée par modalité. Un quorum d'au moins $50\%$ des membres de chaque équipe doit impérativement être réuni à chaque séance.
* **Charte relative à l'Intelligence Artificielle (Arrêté Rectoral n° 31/2025) :**
  * *Usages Autorisés :* Assistance à la syntaxe de programmation, débogage de code, optimisation algorithmique et séances de remue-méninges conceptuel.
  * *Usages Interdits :* Production non vérifiée de rapports écrits automatisés et soumission de modèles de données ou de tableaux de bord générés par IA sans validation analytique manuelle.

### 1.3 Rôles d'Ingénierie au sein des Équipes de Projet
Chaque équipe de 5 étudiants reproduit la structure fonctionnelle d'un pôle de données d'entreprise :
1. **Bronze Lead (Ingénieur d'Intégration de Données) :** Responsable de l'ingestion des sources hétérogènes (CSV, JSON, XLSX), de la normalisation des horodatages et de la création des tables de transit (*staging*) sous Pandas.
2. **Silver Lead (Analyste Numérique et Qualité des Données) :** Évalue la complétude des données, configure les filtres statistiques d'exclusion des valeurs aberrantes ($3\sigma$, IQR) et prend en charge l'imputation des données manquantes.
3. **Gold Lead (Architecte d'Entrepôt de Données) :** Conçoit le modèle dimensionnel (schéma en étoile), génère les clés de substitution (*surrogate keys*) et implémente les tables de faits et de dimensions sous DuckDB/SQL.
4. **Analytics Lead (Développeur KPI et Analytique de Production) :** Définit les formulations mathématiques formelles et implémente la logique d'agrégation des indicateurs synthétiques complexes (TRS/OEE, OTIF, CSE/SEC).
5. **UX & BI Lead (Développeur Décisionnel et Storyteller de Données) :** Conçoit les maquettes d'interface utilisateur (UI/UX) et produit le tableau de bord exécutif interactif en appliquant les principes de clarté visuelle.

---

## 2. Fondements de la Gestion des Données Industrielles

### 2.1 La Problématique Industrielle : Surabondance de Données et Déficit d'Insights
Les usines modernes génèrent quotidiennement plusieurs gigaoctets de télémétrie capteurs et de journaux transactionnels. Pourtant, les réunions de direction restent souvent paralysées par des conflits d'arbitrage fondés sur des feuilles de calcul Excel contradictoires (**"drowning in data, starving for insights"**).

L'ingénierie décisionnelle moderne répond à des questions opérationnelles critiques qui ne devraient pas exiger des semaines d'investigation :
* **Pertes de Disponibilité :** Pour quelle raison la ligne d'emboutissage B a-t-elle subi une chute de $14\%$ de sa disponibilité lors des postes de nuit du mois précédent ?
* **Rentabilité Réelle :** Quelles gammes de fabrication, bien que rentables sur le plan théorique, génèrent un résultat négatif en raison de pénalités de retard de livraison et de remises commerciales imprévues ?
* **Gaspillage Énergétique :** Quel volume de mégawattheures ($MWh$) est dissipé inutilement par les fours industriels lors des phases d'inactivité non planifiées ?

### 2.2 La Pyramide DIKW Appliquée à l'Environnement Manufacturier
Le cadre conceptuel DIKW (*Data, Information, Knowledge, Wisdom*) structure la transformation progressive des signaux bruts en valeur décisionnelle stratégique :

```text
                    ▲
                   / \
                  /   \     SAGESSE / DÉCISION
                 /  ★  \    Action de Direction : Révision de la maintenance préventive
                /───────\   Remplacement d'outil à 165 min d'usure -> Économie : 45 000 €/trim.
               /         \
              / CONNAISSANCE \ Corrélations & KPI agrégés : Les pannes de contrainte mécanique
             /─────────────\ bondissent de 300% au-delà de 180 min d'usure sur acier haute
            /  INFORMATION  \ résistance, faisant chuter le TRS (OEE) du Poste 2 à 62%.
           /─────────────────\ Nettoyé & Contextualisé : La Presse 04 a subi une panne
          /      DONNÉES      \ de contrainte lors du Poste 2 pendant le Lot Automobile #402.
         /─────────────────────\ Signaux Bruts : 2026-10-14 14:15:00 | Presse_04 |
        /                       \ Couple: 68.4 Nm | Temp: 312.1 K | Usure: 195 min.
```

### 2.3 Typologie des Formats de Données Industrielles
L'écosystème manufacturier repose sur quatre classes majeures de données :
* **Données Structurées :** Schémas stricts organisés en lignes et colonnes immuables (tables relationnelles SQL, exports ERP, fichiers CSV). Exemple : lignes de commandes clients, nomenclatures d'articles, volumes produits par poste.
* **Données Semi-Structurées :** Structures hiérarchiques et imbriquées clé-valeur sans schéma préalable rigide (fichiers JSON, XML). Exemple : journaux d'interventions de GMAO avec codes d'erreur variables, structures tarifaires dynamiques d'électricité.
* **Séries Temporelles (Time-Series) :** Mesures chronologiques continues associées à une horloge précise, générées par des automates programmables (API/PLC) ou des compteurs communicants. Elles exigent un rééchantillonnage temporel (*resampling*) pour convertir des données haute fréquence (ex. puissance toutes les 15 minutes) en métriques de poste de 8 heures.
* **Données Non Structurées :** Documents dépourvus de formalisme tabulaire exigeant des pipelines de traitement automatisé (NLP, OCR, vision par ordinateur) : rapports d'incidents manuscrits, factures PDF, imagerie thermique de maintenance.

---

## 3. L'Intégration Industrielle et le Modèle ISA-95

### 3.1 Décomposition des Couches Architecturales
La norme internationale ISA-95 régit l'intégration hiérarchique entre les systèmes de contrôle commande d'atelier et les progiciels de gestion d'entreprise :

```text
┌────────────────────────────────────────────────────────────────────────┐
│ NIVEAU 4 : IT d'Entreprise (ERP, SCM, CRM)                             │
│ Résolution temporelle : Quotidienne, Mensuelle, Transactionnelle       │
│ Données : Commandes de vente, catalogues articles, tarifs d'énergie    │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Cloisonnement : Décalage sémantique et temporel)
┌───────────────────────────────────▼────────────────────────────────────┐
│ NIVEAU 3 : Gestion des Opérations - MOM (MES, GMAO/CMMS, WMS)          │
│ Résolution temporelle : Poste de 8 heures, Horaire, Événementielle     │
│ Données : Ordres de fabrication, rebuts, tickets d'arrêts de ligne     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ (Cloisonnement : Rupture de protocole et fréquence)
┌───────────────────────────────────▼────────────────────────────────────┐
│ NIVEAUX 1-2 : Technologies Opérationnelles - OT (SCADA, PLC, Capteurs) │
│ Résolution temporelle : Milliseconde, Seconde, Période de 15 minutes   │
│ Données : Température (K), couple (Nm), vitesse (RPM), puissance (kWh) │
└────────────────────────────────────────────────────────────────────────┘
```

### 3.2 Le Problème des Silos et Décalages Temporels
Dans la plupart des organisations industrielles, ces couches constituent des **silos étanches** :
* **Décalage de Fréquence :** Le compteur communicant (Niveau 2) mesure la consommation électrique toutes les 15 minutes. Le système MES (Niveau 3) enregistre le tonnage d'acier façonné par plage de 8 heures. L'ERP (Niveau 4) applique une tarification d'achat de l'électricité variable selon les heures pleines et creuses. Aucun système ne peut isolément calculer le coût énergétique réel par tonne produite.
* **Hétérogénéité Sémantique :** Une même presse industrielle d'estampage est identifiée sous l'étiquette `P-01` dans la supervision SCADA, sous la chaîne `Press_1` dans la maintenance (GMAO), et sous l'identifiant comptable `Asset_1004` dans l'ERP. La mission de l'ingénieur décisionnel consiste à combler ces ruptures sémantiques et temporelles au sein d'un entrepôt de données unifié.

---

## 4. Architectures de Stockage : Systèmes Opérationnels (OLTP) vs Entrepôts Analytiques (OLAP)

| Critère d'Évaluation | Bases Opérationnelles (ERP, MES) — OLTP | Entrepôts de Données (DWH, Datamarts) — OLAP |
| :--- | :--- | :--- |
| **Objectif Principal** | Assurer le fonctionnement temps réel de l'usine | Permettre l'analyse décisionnelle et stratégique |
| **Profil des Requêtes** | Écritures rapides et ponctuelles (insertions/mises à jour de lignes) | Balayages (*scans*) massifs de millions de lignes historiques |
| **Gestion de l'Historique** | Écrase les valeurs modifiées (perte de la trajectoire passée) | Conserve l'intégralité de l'historique sans modification |
| **Structure des Données** | Normalisée (formes normales évitant toute redondance) | Dénormalisée (schémas en étoile facilitant les agrégations) |
| **Risque Majeur** | Une requête d'analyse lourde sature le processeur et bloque l'usine | Coûts d'ingestion et de stockage si la gouvernance fait défaut |

### Les Quatre Piliers d'un Entrepôt de Données (Adaptation du standard de Bill Inmon)
1. **Orienté Sujet (*Subject-Oriented*) :** Les structures de données sont modélisées autour des concepts métiers fondamentaux (Production, Fiabilité des Équipements, Logistique) et non selon la logique technique d'une application source.
2. **Variant dans le Temps (*Time-Variant*) :** Chaque enregistrement est rattaché explicitement à un point dans le temps, garantissant la traçabilité des états successifs sans écrasement des archives.
3. **Non-Volatile :** Une fois validées et chargées dans l'entrepôt analytique, les données deviennent immuables et accessibles en lecture seule, ce qui sécurise les audits et les analyses de tendances.
4. **Bouclier Analytique (*OLAP Workload Shield*) :** L'entrepôt isole hermétiquement le traitement analytique lourd, prévenant tout ralentissement ou blocage critique des bases de production temps réel.

---

## 5. Paradigmes de Traitement, Qualité et Modélisation

### 5.1 Évolution ETL vers ELT et Cadence de Latence
* **Paradigme ETL Traditionnel (*Extract $\rightarrow$ Transform $\rightarrow$ Load*) :**
  Les transformations sont exécutées sur des serveurs de traitement dédiés avant le chargement dans l'entrepôt afin de limiter l'empreinte sur des disques autrefois coûteux. Ce mode souffre d'une grande rigidité de schéma et empêche tout recalcul ultérieur à partir des données sources brutes.
* **Paradigme ELT Moderne (*Extract $\rightarrow$ Load $\rightarrow$ Transform*) :**
  Les données brutes sont chargées directement dans l'entrepôt ou le lac de données (couche Bronze). Les étapes de nettoyage et d'agrégation s'effectuent ensuite directement au moyen de moteurs SQL et de code Python optimisés. Ce mode préserve l'intégrité historique complète de l'archive brute.
* **Latence de Traitement :**
  * *Traitement par Lots (Batch) :* Traitement de jeux de données finis à intervalles programmés (horaires, par poste de travail ou quotidiens). Idéal pour les clôtures financières ou les calculs de TRS global.
  * *Traitement par Flux (Streaming) :* Traitement continu, message par message, à latence milliseconde via des courtiers comme Apache Kafka ou MQTT. Indispensable pour la détection prédictive d'anomalies critiques ou l'arrêt de sécurité d'équipements.

### 5.2 Qualité des Données d'Atelier
L'application de la règle décisionnelle **"Garbage In, Garbage Out"** impose la maîtrise de trois pathologies majeures de la donnée industrielle :
* **Valeurs Aberrantes Numériques :** Provoquées par des défaillances matérielles de capteurs (ex. pic de tension indiquant $99\,999\text{ kWh}$ ou couple moteur négatif de $-450\text{ Nm}$). Elles sont traitées par filtrage statistique :
  * *Règle des Trois Sigmas :* 

$$\mu \pm 3\sigma$$

  * *Intervalle Interquartile (IQR) :* 

$$[Q_1 - 1{,}5 \times \text{IQR},\; Q_3 + 1{,}5 \times \text{IQR}]$$

* **Incohérence des Données de Référence :** Dérive des identifiants machines selon les logiciels (`SCADA: M-01`, `GMAO: Mach_1`, `Excel: Presse #1`). Ces écarts empêchent toute réconciliation sans tables de transcodage.
* **Complétude et Unicité :** Lacunes temporelles (`NaN`) générées par des pannes de réseau industriel et doublons causés par les boucles d'interrogation logicielle.

### 5.3 Modélisation Dimensionnelle : Schéma en Étoile de Ralph Kimball
Le schéma en étoile structure l'analyse décisionnelle en séparant les faits mesurables de leur contexte d'interprétation :
* **Table de Faits (*Fact Table*) :** Regroupe les mesures numériques additives ou semi-additives quantifiant un événement opérationnel (`Unités_Produites`, `Minutes_Arrêt`, `Consommation_kWh`).
* **Tables de Dimensions (*Dimension Tables*) :** Entités descriptives contextualisant la mesure (`Dim_Temps`, `Dim_Machine`, `Dim_Produit`).
* **Source Unique de Vérité (*Single Source of Truth - SSOT*) :** En l'absence d'une gouvernance centralisée, chaque service applique sa propre interprétation des formules de calcul (par exemple, un service maintenance qui redéfinit le TRS pour masquer des micro-arrêts). Une plateforme décisionnelle centralisée garantit une formule mathématique unique et immuable.

### 5.4 Données de Référence (RDM) vs Données de Référence Métier (MDM)
* **Données de Référence (*Reference Data Management - RDM*) :** Ensembles discrets de codes permissibles et tables de recherche standardisées partagés à l'échelle de l'entreprise :
  * *Exemples :* Codes monétaires ISO (`EUR`, `USD`), unités de mesure d'ingénierie (`kWh`, `Nm`, `°C`), codes de défaillance standardisés (`TWF` : Usure d'outil, `HDF` : Défaillance hydraulique).
* **Données de Référence Métier (*Master Data Management - MDM*) :** Entités métiers fondamentales non transactionnelles fournissant le contexte opérationnel :
  * *Exemples :* Registre du parc machines (numéros de série, cadences nominales), catalogues d'articles et nomenclatures de fabrication (BOM - *Bill of Materials*), annuaires des clients et des dépôts logistiques.

### 5.5 Analytique Visuelle et Règle d'Or d'Edward Tufte
Le passage des données brutes aux récits visuels stratégiques s'articule autour de trois paliers :
1. *Niveau Opérationnel :* Tableaux statiques pour les audits et les passations de consignes en atelier.
2. *Niveau Tactique :* Tableaux de bord décisionnels interactifs avec filtres croisés pour l'analyse des causes profondes.
3. *Niveau Stratégique :* Tableaux de bord de direction générale traduisant directement la performance d'atelier en décisions financières.

#### Le Ratio Données/Encre (*Data-to-Ink Ratio*)
Selon la règle formulée par Edward Tufte, un graphique doit maximiser la part d'encre (ou de pixels) consacrée à la transmission de données informatives, en éliminant tout élément décoratif superflu (*chartjunk*) :

$$\text{Ratio Données/Encre} = \frac{\text{Encre utile consacrée aux données}}{\text{Encre totale utilisée pour imprimer le graphique}}$$

### 5.6 Cadre de Gouvernance DAMA-DMBOK
Le référentiel international DAMA-DMBOK place la **Gouvernance des Données** au centre stratégique des disciplines de l'entreprise :
* **Noyau Central :** Gouvernance des Données (politiques, autorité décisionnelle, stratégies de conformité).
* **Disciplines Périphériques :** Architecture des données, Intégration et interopérabilité, Qualité des données, Données de référence et MDM, Entreposage de données et Business Intelligence.

---

## 6. Synthèse des Études de Cas Industrielles du Cours

```text
┌────────────────────────────────────────────────────────────────────────┐
│ CAS D'ÉTUDE 1 : SmartPress Automotive                                  │
├────────────────────────────────────────────────────────────────────────┤
│ • Domaine : Télémétrie d'estampage haute fréquence, GMAO, plannings.   │
│ • Sources Brutes : sensor_telemetry.csv, maintenance_logs.json,        │
│   machines_and_shifts.xlsx                                             │
│ • Métriques Clés : TRS/OEE, MTBF, MTTR, Taux de Rebut.                 │
│ • Perspectives Exécutives : Directeur des Opérations (COO) vs          │
│   Responsable de la Maintenance.                                       │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ CAS D'ÉTUDE 2 : DataCo Industrial                                      │
├────────────────────────────────────────────────────────────────────────┤
│ • Domaine : Commandes de vente ERP, traçabilité WMS, catalogues.       │
│ • Sources Brutes : order_items_trans.csv, shipment_events.json,         │
│   master_catalog.xlsx                                                  │
│ • Métriques Clés : OTIF (Complet et dans les Délais), Variabilité des  │
│   Délais de Livraison, Érosion de la Marge Commerciale.                │
│ • Perspectives Exécutives : VP Chaîne Logistique vs Directeur          │
│   Commercial.                                                          │
└────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────────────┐
│ CAS D'ÉTUDE 3 : Nexis Precision Electronics                            │
├────────────────────────────────────────────────────────────────────────┤
│ • Domaine : Assemblage électronique de précision, People Analytics.    │
│ • Sources Brutes : shift_production_performance.csv,                   │
│   workforce_events.json, workforce_roster_and_skills.xlsx              │
│ • Métriques Clés : Réalisation du Planning, Taux de Rebuts, Coût Réel │
│   de Main-d'Œuvre par Bonne Unité, Taux d'Attribution Prime Qualité.   │
│ • Perspectives Exécutives : Directrice des Ressources Humaines (DRH)   │
│   vs Directeur des Opérations & de la Production.                      │
└────────────────────────────────────────────────────────────────────────┘
```

