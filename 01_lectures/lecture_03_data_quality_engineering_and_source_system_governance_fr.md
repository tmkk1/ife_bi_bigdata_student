# Business Intelligence et Analyse des Mégadonnées (`01 31 0367 00`)

## Synthèse Académique et Technique — Cours 03 : Ingénierie de la Qualité des Données et Gouvernance des Systèmes Sources

**Langue :** Français (`FR`)  
**Enseignant :** Tomasz Kołodziejczyk (IFE, 2026)  
**Public :** Ingénieurs 4e année B.Sc. (Génie Industriel et Management de la Production)  
**Contexte du Pipeline de Données (Architecture Médaillon) :** `1. Données Sources` → `2. Couche Bronze` → **`3. Couche Silver`** → `4. Couche Gold` → `5. BI & Analytique`

---

## 1. Pourquoi la Qualité des Données est Critique : Défaillances Réelles de Systèmes

### 1.1 Étude de Cas : Perte de la Sonde NASA Mars Climate Orbiter (125 M\$)
* **Type de Défaillance :** Défaut d'intégration système
* **Anomalie d'Unités :** Le logiciel développé par Lockheed Martin produisait les impulsions des propulseurs en unités impériales ($\text{lbf}\cdot\text{s}$), tandis que le système de navigation de la NASA attendait des unités métriques ($\text{N}\cdot\text{s}$).
* **Erreur de Trajectoire :** Ce décalage de calcul a conduit la sonde à pénétrer l'atmosphère martienne $100\text{ km}$ plus bas que prévu (`57 km` réels contre `226 km` planifiés lors de `TCM-4`).
* **Conséquence Catastrophique :** La sonde a subi une friction atmosphérique extrême et s'est entièrement désintégrée, entraînant une perte en capital de **125 M\$**.

> **Leçon Fondamentale d'Ingénierie :** *« Des nombres dépourvus de métadonnées strictes et de contrats d'interface sont mortels dans les systèmes d'ingénierie. »*

### 1.2 Étude de Cas : Limite de Lignes Excel — Troncature Silencieuse (`65 536`)
* **Analyse de la Défaillance Système (2020) :** Un pipeline automatisé de santé publique ingérait des résultats de laboratoire CSV dans d'anciens modèles `.xls` utilisant le format historique Excel 97–2003. Ce format obsolète impose une limite technique stricte de **65 536 lignes** par feuille de calcul.
* **Impact sur la Santé Publique :** Par conséquent, **15 841 cas positifs de COVID-19** ont été silencieusement tronqués au seuil, paralysant le traçage des contacts pendant plusieurs jours.

> **Enseignement Principal d'Ingénierie Système :** *« Choisissez les formats de fichiers adaptés aux pipelines de données automatisés. »*

### 1.3 Étude de Cas : Crise des Stocks Fantômes (Défaillance MES)
* **Analyse de l'Écart Système (Registre Numérique vs Réalité Physique) :** Les opérateurs de l'équipe de nuit omettaient d'enregistrer les pièces rebutées dans le MES afin de protéger leurs primes d'équipe. Ce contournement opérationnel a créé une divergence critique entre les registres ERP et le stock physique de l'entrepôt :
  * **Système ERP (Numérique) :** `12 000 Pcs Prêtes` enregistrées comme disponibles en entrepôt (`COMP-4500`, `WH-B-42`).
  * **Entrepôt Physique :** `0 Support` — rayonnages physiques totalement vides.
* **Impact Processus :** Les rebuts non déclarés se sont accumulés silencieusement sur plusieurs postes. Lorsque la ligne d'assemblage du client a demandé l'expédition, aucune unité physique n'était disponible, déclenchant un arrêt immédiat.
* **Conséquence Financière :** Pénalité contractuelle de **150 000 €** et **4 heures** d'arrêt complet de la chaîne d'assemblage automobile.

---

## 2. L'État d'Esprit Industriel et la Règle du 1-10-100

### 2.1 L'Ingénierie des Données Reflète la Fabrication Physique

```text
ATELIER DE FABRICATION PHYSIQUE :
[ Matière Première ] ──► [ Emboutissage & Soudage ] ──► [ Contrôle Qualité ] ──► [ Voiture Finie ]
         │                           │                            │                       │
         ▼                           ▼                            ▼                       ▼
[ Signaux Bruts    ] ──► [ Ingestion & Modélisation ] ──► [ Portes Qualité   ] ──► [ Décisions Exécutives ]
USINE DE DONNÉES D'ENTREPRISE
```

> **État d'Esprit Fondamental du Pipeline — Tolérance Zéro Défaut :** *« Un défaut dans les données est tout aussi destructeur qu'une fissure physique dans un disque de frein. »*

### 2.2 La Règle du 1-10-100 : Coût Exponentiel de la Non-Qualité
La **Règle du 1-10-100** illustre la multiplication exponentielle de l'impact financier d'une donnée erronée au fil de sa propagation en aval. Empêcher une saisie erronée à la source coûte une fraction du coût de son nettoyage dans les pipelines — et une infime partie des pertes liées aux mauvaises allocations de capital causées par des rapports exécutifs corrompus.

| Étape | Coût Relatif | Couche d'Architecture | Mécanisme et Conséquence |
| :--- | :--- | :--- | :--- |
| **1. Prévention à la Source** | **1 \$** | `ERP / MES / PLC` | Bloquer la saisie erronée à l'origine lorsque l'opérateur ou le capteur crée l'enregistrement. |
| **2. Rustine en Entrepôt** | **10 \$** | `Couche Silver` | Les ingénieurs données écrivent des scripts Python ou SQL complexes pour nettoyer et estimer les valeurs manquantes. |
| **3. Échec en Comité de Direction** | **100 \$** | `Couche Gold ou BI` | Investissements en capital erronés, ruptures de stock ou pénalités contractuelles causés par des rapports corrompus. |

---

## 3. Cadre DAMA-DMBOK : Les 6 Dimensions de la Qualité des Données

Le standard industriel **DAMA-DMBOK** divise la Qualité des Données en **6 dimensions mesurables** :

| # | Dimension | Question Diagnostique Clé |
| :--- | :--- | :--- |
| **01** | **Exactitude (*Accuracy*)** | Correspond-elle à la réalité physique ? |
| **02** | **Complétude (*Completeness*)** | Les valeurs sont-elles présentes ? |
| **03** | **Cohérence (*Consistency*)** | Les différents systèmes sont-ils d'accord ? |
| **04** | **Actualité / Ponctualité (*Timeliness*)** | Est-elle arrivée à temps ? |
| **05** | **Unicité (*Uniqueness*)** | Existe-t-il des doublons ? |
| **06** | **Validité (*Validity*)** | Respecte-t-elle les règles de format/code ? |

### 3.1 Complétude : Les Valeurs Requises Sont-Elles Présentes ?
* **Définition :** Mesure le pourcentage de valeurs non nulles dans les champs métier obligatoires.
* **Exemple :** Le champ `unit_price_eur` a renvoyé `NaN` dans **4 %** des lignes de commandes clients ERP, faussant les calculs en aval.
* **Règle Critique d'Ingénierie ($\text{NULL} \neq 0{,}0$ — Signal Inconnu vs Consommation Nulle) :**
  * `NULL` (Manquant) n'est **pas** égal à `0,0` (Zéro).
  * Une lecture de **`0,0 kWh`** indique qu'un four a été volontairement éteint, tandis qu'une valeur **`NULL`** signifie que le compteur intelligent a perdu sa connexion réseau.

### 3.2 Unicité : Un Événement Réel = Un Enregistrement
* **Définition Clé :** Mesure le pourcentage de clés primaires dupliquées ou d'entités métier dupliquées dans un jeu de données.
* **Étude de Cas d'Impact Système (SmartPress) :** Un délai d'expiration réseau (*timeout*) a amené la passerelle SCADA à renvoyer **deux fois le lot de télémétrie de 14h15**, doublant artificiellement les indicateurs de production dans les rapports en aval.
* **Exemple de Distorsion du Chiffre d'Affaires (`SALES_TRANSACTIONS`) :**
  * `1004 | Widget A | User_5 | 150 $`
  * `1004 | Widget A | User_5 | 150 $` *(CLÉ DUPLIQUÉE)*
  * `1003 | Widget E | User_9 | 150 $`
  * *Impact :* Revenu de base `300 $` + `150 $` (Erreur) = **450 \$ de Total Déclaré**.

### 3.3 Validité : Les Données Respectent-Elles la Syntaxe et les Règles ?
* **Définition Clé :** Mesure le pourcentage d'enregistrements correspondant exactement au **type de données**, à la **plage acceptable** ou au **catalogue de données de référence** (*Reference Data*).
* **Étude de Cas 01 — Erreurs de Plage et de Format (DataCo) :**
  * Remise saisie à `15.0` au lieu de `0.15`, entraînant une remise impossible de **1500 %**.
  * Remise négative hors limites enregistrée : `-0.05`.
* **Étude de Cas 02 — Écart de Référentiel (EcoSteel) :**
  * Identifiant du four saisi en minuscules : `"eaf_line_1"`.
  * Rejeté pour non-conformité avec le code maître du catalogue : `"EAF_Line_1"`.
* **Flux de la Porte de Validation des Données (Moteur de Règles) :**
  * `0.15` (Flottant valide) → `AUTORISÉ ✓` (Syntaxe & Plage OK) → `Référentiel DONNÉES VALIDES`
  * `15.0 / -0.05` (Erreur de plage) → `REJETÉ ✗` (Hors limites) → `JOURNAL D'ERREURS`
  * `"eaf_line_1"` (Écart de code) → `REJETÉ ✗` (Violation du catalogue) → `JOURNAL D'ERREURS`

### 3.4 Exactitude : Les Données Reflètent-Elles la Réalité Physique ?
* **Validité vs Exactitude :** Une donnée peut être **100 % valide** (flottant IEEE 754 syntaxiquement valide, non nul et structure unique), tout en étant **0 % exacte** (valeurs physiquement impossibles). Les pipelines valident souvent les types sans vérifier la cohérence physique.
* **Études de Cas :**
  * **Cas SmartPress :** Le capteur de couple a enregistré `-999.0 Nm` et `4850.0 Nm` — des flottants parfaitement valides, mais physiquement impossibles sur la presse.
  * **Cas DataCo :** Délai d'expédition formaté correctement en flottant, mais enregistré à `145 jours` pour un colis domestique.

### 3.5 Cohérence : Les Systèmes S'Accordent-Ils sur la Vérité ?
* **Définition :** Mesure le pourcentage de faits concordants entre différents systèmes intégrés (ERP, WMS, MES, CMMS, SCADA).
* **Divergence des Données Opérationnelles (Fenêtre `14h00 – 16h00`) :**
  * **Journal de Maintenance CMMS :** `Panne Totale : 14h00 – 16h00` (`PRESS_01` déclarée en arrêt total).
  * **Télémétrie SCADA :** `450 Bonnes Pièces Produites : 14h00 – 16h00` (`PRESS_01` en production nominale).
* **Question Diagnostique Clé :** *« Le technicien a-t-il saisi la mauvaise machine, ou l'horloge du SCADA est-elle décalée ? »*

### 3.6 Actualité (Ponctualité) : La Donnée Est-Elle Disponible au Moment Requis ?
* **Définition :** Le décalage temporel entre les événements physiques de l'atelier et la disponibilité des données pour l'analyse opérationnelle.
* **Étude de Cas Réelle d'Usine (Latence Papier en Atelier) :** Une machine tombe en panne le **mardi matin (`09h15`)**. Le technicien note les détails de l'intervention sur un presse-papiers, mais ne les saisit dans le CMMS que le **vendredi après-midi (`16h30`)**. Les données sont exactes à 100 % le vendredi, mais **totalement inutiles pour la réunion quotidienne OEE du mercredi**.
* **Métrique de Latence :** **~79 Heures** d'écart.
* **Impact Opérationnel :** Visibilité nulle lors de la revue du mercredi, retardant de 3 jours complets les ajustements critiques de ligne.

---

## 4. Gouvernance des Systèmes Sources et Architecture Préventive

### 4.1 L'Illusion : « Réparons ça dans l'Entrepôt de Données ! »
* **Tentation :** Nettoyer les données ERP/MES via Python dans la couche Silver.
* **Réalité :** Ne corrige que les graphiques exécutifs ; les données corrompues demeurent dans les systèmes opérationnels qui pilotent l'usine.

> *« Corriger en aval crée une illusion de qualité des données sans réalité opérationnelle. »*

#### 3 Raisons pour Lesquelles le Patching en Entrepôt Ne Suffit Pas
1. **Cécité Opérationnelle :** Corriger la BI ne corrige pas le WMS.
2. **Perte de la Vérité Terrain :** Les algorithmes ne peuvent pas deviner les modes de défaillance physique manquants.
3. **Zéro Responsabilisation :** Les correctifs informatiques silencieux empêchent l'amélioration des processus opérationnels.

> **Leçon Opérationnelle Clé :** *« Les correctifs IT silencieux créent une cécité opérationnelle et empêchent l'amélioration des processus à la racine. »*

### 4.2 Corriger à la Source : Poka-Yoke Numérique (Conception UI)
Sécuriser les interfaces dès le point de saisie en remplaçant les champs texte libres par des bornes de validation automatisées reliées aux données maîtres :
* **Supprimer les Champs Texte Libres :** Imposer des listes déroulantes obligatoires directement liées aux référentiels de Données Maîtres (*Master Data*) vérifiés.
* **Verrous de Plages Stricts :** Bloquer immédiatement la saisie si les valeurs dépassent les limites matérielles physiques ou les règles métier.
* **Systèmes IT Dédiés :** Construire de véritables applications informatiques pour la saisie plutôt que de s'appuyer sur des tableurs.

| Approche | Exemple | Résultat |
| :--- | :--- | :--- |
| **Option A : Saisie Texte Libre** *(Rejetée — Risque d'Erreur Élevé)* | `ABC-123_err [x]` → Écart de schéma / SKU invalide | Taux élevé de fautes de frappe, casse le flux ETL, nécessite une correction manuelle. |
| **Option B : Sélection Validée** *(Approuvée — Poka-Yoke)* | `MD-102 (Pompe) ▼` → Vérifié contre la Base Maître | Liste restreinte pré-approuvée, zéro saisie erronée, flux automatisé. |

### 4.3 Corriger à la Source : Automatisation de l'Atelier
* **Éliminer la Saisie Manuelle :** Utiliser des lecteurs de codes-barres, la RFID et des compteurs directs sur automates (PLC).
* **Passerelles Edge Intelligentes :** Configurer les passerelles OT pour envoyer des drapeaux d'état explicites plutôt que des valeurs par défaut issues de saisies manuelles.

> **Impératif Système :** *« L'automatisation physique directe élimine la latence humaine, les erreurs de frappe manuelle et les valeurs par défaut à la source. »*

### 4.4 Standard Industriel : Contrats de Données (*Data Contracts* / SLA Formel)
Un **Contrat de Données (YAML / SLA)** formalise l'accord entre les **Propriétaires de Systèmes en amont (ERP / MES)** et **l'Ingénierie des Données**, en fixant des frontières strictes et vérifiables avant l'entrée dans l'Entrepôt :
1. **Schémas Exacts :** Noms de champs strictement définis, types de données précis (JSON/SQL) et règles de nullabilité imposées.
2. **Règles Métier :** Validation sémantique stricte et contrôles automatisés de logique métier avant livraison.
3. **Calendriers de Livraison :** Fréquences de rafraîchissement définies, fenêtres de disponibilité garanties et alertes automatiques de rupture de SLA.

---

## 5. Modèles Techniques de la Couche Silver : Quarantaine, Valeurs Aberrantes, Imputation et Observabilité

### 5.1 Portes Qualité Automatisées et Modèle de Quarantaine
Les plateformes modernes (**dbt**, **Great Expectations**, **Soda**) déploient des portes qualité automatisées pour stopper les enregistrements corrompus avant leur propagation.

> **Règle de Bonne Pratique :** Ne jamais supprimer silencieusement les données invalides. Préserver la traçabilité visuelle (*lineage*) et l'historique des anomalies est essentiel pour la fiabilité du pipeline.

```text
┌────────────────┐     ┌─────────────────┐     VALIDE (98 %)  ┌──────────────────────┐
│ BRONZE         │ ──► │ PORTE DQ        │ ─────────────────► │ SILVER               │
│ (Données Brutes)     │ (Contrôle DQ)   │                    │ (Couche Propre)      │
└────────────────┘     └────────┬────────┘                    └──────────────────────┘
                                │ ÉCHEC (2 %)
                                ▼
                       ┌─────────────────┐                    ┌──────────────────────┐
                       │ QUARANTAINE     │ ──(Alerte)───────► │ Alerte Équipe Métier │
                       │ (Table Isolée)  │                    │ (Corriger à la Source)│
                       └─────────────────┘                    └──────────────────────┘
```

### 5.2 Détection des Valeurs Aberrantes : Piège du 3-Sigma vs Boîte à Moustaches de Tukey (IQR)

#### La Règle du 3-Sigma (Seuillage par Z-Score) — Le Piège Industriel des Valeurs Aberrantes
* Suppose une distribution normale gaussienne et signale les données hors $\mu \pm 3\sigma$ (couverture théorique : `99,73 %` des données valides).
* **Vulnérabilité Industrielle :** Un seul pic extrême de télémétrie (ex. `25 000 kWh` ou `4 850 Nm`) fausse fortement les métriques quadratiques d'échantillon :
  1. La moyenne ($\mu$) dérive vers le pic aberrant ($\mu_{\text{réel}} \rightarrow \mu_{\text{corrompu}}$).
  2. L'écart-type ($\sigma$) gonfle de manière exponentielle ($\sigma_{\text{corrompu}}$).
  3. **Effet de Masquage :** La borne élargie $\pm 3\sigma$ devient si lâche que de réelles anomalies critiques passent la quarantaine sans être détectées.

#### Détection Robuste : Méthode de Tukey (IQR)
* Trie les données pour isoler les 50 % centraux, filtrant le bruit aux extrémités :

$$\text{IQR} = Q_3\,(75\,\%) - Q_1\,(25\,\%)$$

$$\text{Limites Physiques Valides} = \left[Q_1 - 1{,}5 \times \text{IQR},\;\; Q_3 + 1{,}5 \times \text{IQR}\right]$$

* **Exemple :** $Q_1 = 40\text{ s},\; Q_3 = 60\text{ s} \implies \text{IQR} = 20\text{ s}$. Limites valides : $[10\text{ s},\; 90\text{ s}]$.
* **Avantage Atelier vs 3-Sigma :**
  * *Résistance aux Pics Extrêmes :* Les quartiles et médianes ignorent par construction les glitchs extrêmes en queue de distribution.
  * *Adaptation à l'Asymétrie Industrielle :* Très fiable pour les métriques asymétriques comme les temps de réparation ou les retards de cycle.

### 5.3 Imputation des Données : Domaines Physiques vs Domaines Métier

> **Règle :** Les ingénieurs ne doivent jamais remplir aveuglément les valeurs manquantes par zéro (`0`) ou par des moyennes globales.

| Domaine | Méthode | Mécanisme et Exemple |
| :--- | :--- | :--- |
| **Signaux Physiques Continus** | **Interpolation Linéaire Temporelle** | Les systèmes physiques possèdent une inertie thermique ; les variables continues (ex. température du four) évoluent progressivement dans le temps. Exemple : `310 K` à `14h00` et `314 K` à `14h30` s'interpolent à `312 K` à `14h15`. |
| **Attributs Métier et Financiers** | **Jointure sur Données Maîtres (*Lookup Join*)** | Les attributs commerciaux discrets (ex. prix produit) n'ont aucune continuité physique et ne doivent jamais être moyennés. Exécuter une jointure déterministe sur `PROD_ID` avec le Catalogue Maître Produits (ex. `"SKU-882"` `PRICE: NULL` $\rightarrow$ `49,99 $`). |

### 5.4 Nettoyage des Données : Préserver l'Intégrité des Métriques (Nullification Mono-Cellule)
* **Scénario Télémétrie SmartPress :** À `14:15:00`, un glitch capteur a enregistré une anomalie de couple de `-999.0 Nm`, simultanément à **120 unités valides produites**.
* **Erreur Naïve (Suppression Complète de la Ligne) :** Supprimer toute la ligne élimine la mesure de couple aberrante, mais efface définitivement **120 pièces automobiles finies** des registres de production, provoquant une dérive majeure du rendement.
* **Action Correcte (Nullification Mono-Cellule) :** Isoler et remplacer uniquement la cellule erronée `-999.0 Nm` par `NULL`, puis interpoler le couple tout en conservant la production valide intacte :

| Horodatage | `UNITS_PRODUCED` | `TORQUE_NM` | Action |
| :--- | :--- | :--- | :--- |
| `14:00:00` | `118` | `45.2` | Valide |
| `14:15:00` | **`120`** *(Production Sauvegardée)* | ~~`-999.0`~~ → **`NULL` (`45.65`)** | Nullifié et interpolé linéairement : $(45{,}2 + 46{,}1) / 2$ |
| `14:30:00` | `122` | `46.1` | Valide |

* **Résultat :** `120 / 120 Unités Préservées`.

### 5.5 Observabilité Automatisée des Données (Suivi des Macro-Métriques)
Les règles standard au niveau de la ligne ne déclencheront aucune alerte si une ligne d'usine entière cesse silencieusement de transmettre ses fichiers. L'observabilité automatisée surveille la télémétrie globale du système :
* **SLA de Fraîcheur :** Respect des horaires (ex. échéance `06h00`).
* **Anomalies de Volume :** Chute brutale du nombre de lignes (ex. `10k → 150` lignes, alarme active `-98,5 %`).
* **Dérive de Distribution :** Alerte de décalage statistique (ex. `5 % → 35 %`).

---

## 6. Gouvernance Organisationnelle et Amélioration Continue

### 6.1 La Qualité des Données est un Sport d'Équipe : 3 Rôles Clés

| Rôle | Périmètre | Responsabilités |
| :--- | :--- | :--- |
| **Data Owner** *(ex. Directeur d'Usine / VP Logistique)* | **Mandat** | Responsable de la qualité des données du domaine sur les systèmes opérationnels ; approuve les définitions de KPI et les budgets de correction ERP/MES. |
| **Data Steward** *(ex. Planificateur Principal / Resp. Maintenance)* | **Règles Métier** | Définit les règles de validation métier et les standards d'exactitude ; gère les catalogues de Données Maîtres et coordonne la correction dans les systèmes sources. |
| **Data Engineer** *(Équipe IT / BI)* | **Automatisation & Reporting** | Implémente les contrôles automatisés de qualité dans l'entrepôt ; publie les Rapports d'Exceptions Qualité pour les Stewards. |

### 6.2 Amélioration Continue : Le Cycle PDCA de la Qualité des Données
Comment l'Entrepôt de Données aide les équipes métier à corriger les erreurs dans le système source :
1. **01. PLAN (Data Steward) :** Définir des règles métier claires de Qualité des Données (critères d'exactitude, seuils de validation, logique métier).
2. **02. DO (Data Engineer) :** Coder les règles dans l'Entrepôt en SQL, les exécuter quotidiennement et journaliser les enregistrements non conformes.
3. **03. CHECK (Tableau de Bord d'Exceptions BI) :** Publier un Tableau de Bord Qualité et une liste d'erreurs pour les équipes opérationnelles.
4. **04. ACT (Équipe Atelier / Bureau) :** Ouvrir l'ERP/MES/CMMS et corriger les enregistrements défectueux directement à la source.

### 6.3 Exemples de Règles DQ Métier Mesurées dans l'Entrepôt

| Domaine / Système | Nom de la Règle | Steward | Condition de Validation |
| :--- | :--- | :--- | :--- |
| **Finance / ERP** | **Règle #1 : Alignement Catalogue Maître** | Sales Steward | `order_items.product_id IN Master_Catalog` AND `Unit_Price >= Standard_Cost` |
| **Maintenance / CMMS** | **Règle #2 : Complétude des Tickets de Panne** | Maintenance Steward | `IF repair_duration > 60 min THEN failure_mode IS NOT NULL AND technician IS NOT NULL` |
| **Logistique / WMS** | **Règle #3 : Chronologie d'Expédition** | Logistics Steward | `actual_ship_date >= order_date` |

### 6.4 Le Rapport d'Exceptions DQ (« Liste À Corriger »)
Au lieu de masquer les erreurs, l'équipe BI construit un Tableau de Bord de Qualité des Données pour les Data Stewards (ex. Santé Globale du Domaine : `96,4 %` de validité des commandes ERP face à un objectif de `99,5 %`) accompagné d'une table d'actions :
* `ORDER #10492` (Commercial : J. Kowalski) — *Défaut :* Prix unitaire manquant — *Action :* **Corriger dans SAP**
* `TICKET #8831` (Équipe : S2, M. Nowak) — *Défaut :* Réparation > 2h sans code de défaillance — *Action :* **Mettre à jour le CMMS**

Dès le vendredi, les opérateurs corrigent leurs propres enregistrements dans l'ERP/CMMS, garantissant un chargement suivant **100 % propre à la source**.

### 6.5 Corrections Permanentes : La Méthode des « 5 Pourquoi » sur les Erreurs Répétées
* **Symptôme sur le Tableau de Bord DQ :** Les tickets de maintenance affichent des durées de réparation erronées (`MTTR = 18 heures`).
* **Pourquoi 1 :** Les techniciens clôturent les tickets 18 heures après la fin de l'intervention.
* **Pourquoi 2 :** Ils clôturent tous les tickets en masse le lendemain matin.
* **Pourquoi 3 :** Ils doivent marcher 400 mètres depuis la ligne de presses pour saisir les données.
* **Pourquoi 4 :** L'ordinateur CMMS se trouve dans un bureau, sans tablettes dans l'atelier.
* **Action Permanente (PDCA) :** Acheter 3 tablettes durcies pour la ligne de presses → **Le défaut chute à 0 % de façon permanente.**

---

## 7. Synthèse et Feuille de Route des Prochains Laboratoires

> **Message Clé à Retenir :** *« Utilisez l'Entrepôt de Données pour mesurer et exposer les défauts de données, donnez aux Data Stewards les moyens de les corriger à la source, et utilisez le nettoyage en couche Silver comme dernière ligne de défense. »*

### Feuille de Route des Prochains Travaux Pratiques
* **Lab #2 — Profilage des Données et Diagnostic :** Charger les fichiers des études de cas et exécuter le profilage pour diagnostiquer tous les défauts de Complétude, d'Unicité, de Validité et d'Exactitude.
* **Lab #3 — Couche Silver : Clés et Déduplication :** Construire votre couche Silver en Python. Nettoyer les clés et dédupliquer les enregistrements pour bâtir une base saine.
* **Lab #4 — Couche Silver : Valeurs Aberrantes et Imputation :** Construire votre couche Silver en Python. Appliquer les algorithmes de détection IQR et imputer les valeurs manquantes pour le raffinement final.
