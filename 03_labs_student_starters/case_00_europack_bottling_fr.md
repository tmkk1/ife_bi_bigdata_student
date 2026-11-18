# Cas d'Étude 00 (Jeu de Données des TP Guidés) : EuroPack Beverage Bottling
## Performance des Lignes d'Embouteillage, Fiabilité & OEE

**Cours :** Business Intelligence et Analyse des Mégadonnées (`01 31 0367 00`)  
**Rôle :** Jeu pédagogique neutre utilisé pour les **TP guidés (Labos 02–10)** *(distinct des projets notés Cas 1, 2 et 3)*  
**Langue :** Français (`FR`)

---

## 1. Contexte Industriel & Entreprise

### 1.1 L'Embouteillage Haute Cadence & Engagements Distribution
Les embouteilleurs industriels livrant les grandes enseignes européennes et le secteur CHR (Cafés, Hôtels, Restaurants) opèrent sous des engagements stricts de livraison **OTIF (On-Time In-Full)** et des normes sanitaires rigoureuses. Les lignes automatisées tournent **24h/24 et 7j/7 en 3×8** pour absorber les pics saisonniers et les promotions de la grande distribution.

Les marges unitaires par bouteille étant réduites, chaque arrêt ligne imprévu, dérive thermique du pasteurisateur ou casse verre dégrade rapidement la rentabilité — tout en exposant l'usine à des pénalités de retard.

### 1.2 Profil de l'Entreprise : EuroPack Beverage Bottling Sp. z o.o.
**EuroPack Beverage Bottling Sp. z o.o.** exploite une usine automatisée de soutirage et conditionnement de boissons à **Gdańsk, Pologne (Usine n° 1)**. Le site remplit, pasteurise, bouche, étiquette et palettise eaux plates, boissons pétillantes et formats verre consigné sur quatre lignes :
* **0.5L Eau Plate PET (`PET_05`) :** Bouteille PET recyclé léger (`rPET Light 18g`) produite à très haute cadence.
* **1.5L Pétillant PET (`PET_15`) :** Bouteille PET carbonatée (`PET Carbonated 34g`) exigeant une pression de soutirage maîtrisée.
* **0.75L Verre Consigné (`GLASS_075`) :** Bouteille verre ambré (`Amber Glass 450g`) au coût de rebut unitaire le plus élevé et sensible aux chocs mécaniques et thermiques.

```
                     CHAÎNE DE VALEUR EMBOUTEILLAGE
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Fournisseurs Verre,  │ ───► │ EuroPack Beverage       │ ───► │ Grande Distribution &  │
 │ Préformes & Sirops   │      │ Bottling (Gdańsk n° 1)  │      │ Distributeurs CHR      │
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. Fonctionnement de l'Usine d'Embouteillage

### 2.1 Étapes de Production (Hall d'Embouteillage B-1)
Dans le Hall B-1, chaque ligne automatisée enchaîne quatre opérations continues :
1. **Rinçage & Convoyage :** Les bouteilles PET ou verre consigné entrent sur le convoyeur haute vitesse (`conveyor_speed_bpm`, bouteilles par minute).
2. **Soutirage Rotatif & Bouchage :** Des vannes rotatives sous pression (`filler_pressure_bar`, enveloppe physique normale `[0.0, 12.0]` bar) remplissent et bouchent les bouteilles tandis que l'automate (PLC) comptabilise l'usure cumulée des vannes (`valve_cycles_k`, en milliers de cycles).
3. **Pasteurisation Tunnel :** Les bouteilles passent dans un tunnel thermique instrumenté par des sondes de température ambiante (`ambient_temp_C`) et de pasteurisateur (`pasteurizer_temp_C`).
4. **Contrôle Optique & Éjection des Rejets :** Des caméras haute cadence contrôlent le niveau, le capsulage et l'intégrité du verre, journalisant les bouteilles produites (`bottled_units`) et les rejets (`rejected_units`).

### 2.2 Lignes d'Embouteillage (Onglet `Lines` de `plant_master_data.xlsx`)
L'usine exploite quatre lignes décrites dans `plant_master_data.xlsx` :

| ID Ligne | Modèle de Ligne | Technologie Soutireuse | Temps de Cycle Nominal | Coût Horaire d'Arrêt (€/h) |
| :--- | :--- | :--- | :---: | :---: |
| **`LINE_A`** | **Krones Servo Filler 4000** | Rotary Servo | **0.75 s/bouteille** | **240 € / heure** |
| **`LINE_B`** | **Legacy Mechanical Filler M2** | Legacy Mechanical | **0.90 s/bouteille** | **210 € / heure** |
| **`LINE_C`** | **Sidel Rotary Combi 4500** | Direct-Drive Combi | **0.72 s/bouteille** | **265 € / heure** |
| **`LINE_D`** | **Tetra High-Speed Aseptic 5000** | Aseptic High-Speed | **0.65 s/bouteille** | **195 € / heure** |

### 2.3 Formats de Bouteilles (Onglet `Bottle_Formats`) & Équipes (Onglet `Shifts`)

| Code Format | Libellé Format | Matériau Emballage | Cadence Horaire Cible | Coût de Rejet Unitaire (€/bouteille) |
| :--- | :--- | :--- | :---: | :---: |
| **`PET_05`** | 0.5L Still Water PET | rPET Light 18g | `4 600 / h` | **0,22 €** |
| **`PET_15`** | 1.5L Sparkling PET | PET Carbonated 34g | `4 000 / h` | **0,34 €** |
| **`GLASS_075`** | 0.75L Returnable Glass | Amber Glass 450g | `3 280 / h` | **0,68 €** |

* **Trois Équipes de 8 Heures (`480.0 min` planifiées par ligne et par poste) :**
  * **`S1` (Matin) :** `06:00 – 14:00` *(Équipes automatisme, qualité et maintenance au complet)*.
  * **`S2` (Après-midi) :** `14:00 – 22:00` *(Équipe de production standard)*.
  * **`S3` (Nuit) :** `22:00 – 06:00` *(Équipe réduite de nuit. Ce poste chevauchant minuit, utilisez `(timestamp - 6h)` pour rattacher les relevés entre `00:00` et `05:45` à la date opérationnelle de début de poste !)*.

---

## 3. Problématiques Métiers Principales

Malgré un carnet de commandes plein, l'Usine n° 1 subit des dérives de coûts et des sous-performances chroniques :
1. **OEE Usine Insuffisant :** L'objectif groupe pour l'**OEE (Overall Equipment Effectiveness / TRS)** est **>= 85,0 %**. Les tableaux Excel hebdomadaires affichent une moyenne globale autour de **70 %**, sans distinguer les pertes de **Disponibilité** (arrêts), de **Performance** (sous-cadence) ou de **Qualité** (rejets/casse). Les moyennes simples non pondérées et le découpage calendaire à minuit masquent des pertes critiques sur certaines combinaisons **Ligne × Équipe × Format**.
2. **Coûts Élevés de Rejets & d'Arrêts :** Sur la **période de 60 jours**, les rejets (notamment la casse verre `GLASS_075`) et les arrêts non planifiés coûtent plusieurs centaines de milliers d'euros, avec un temps moyen de réparation très supérieur à la cible de **60 minutes (`MTTR <= 60 min`)**.
3. **Maintenance Réactive au lieu de Préventive Conditionnelle :** Les techniciens n'interviennent sur les joints de vannes qu'*après* la panne. La direction maintenance manque d'indicateurs précis reliant le seuil cumulé **`valve_cycles_k`**, la dérive thermique (`delta_temp_C = pasteurizer_temp_C - ambient_temp_C`) et la pression de soutireuse au déclenchement des arrêts imprévus.

---

## 4. Deux Perspectives Décisionnelles (Cockpit Dual-Track)

### 🅰️ Perspective A : Directeur des Opérations (COO / Direction Usine)
* **Objectif Principal :** Hisser l'OEE pondéré vers **>= 85,0 %**, identifier les pertes cachées par **Équipe × Ligne × Format**, ramener le taux de rejet sous **2,0 %** et chiffrer en euros les pertes cumulées (rejets + arrêts non planifiés).
* **Décisions Supportées :** Affectation des lignes pour le verre `GLASS_075`, planification de l'équipe de nuit (`S3`) et priorisation des investissements.
* **Hors Périmètre :** Courbes PLC brutes toutes les 15 minutes ou détails des bons de travail techniciens.

### 🅱️ Perspective B : Responsable Maintenance & Fiabilité
* **Objectif Principal :** Réduire le temps moyen de réparation (**MTTR <= 60 min**), augmenter le **MTBF**, hiérarchiser les causes racines via un **Pareto des arrêts** et réviser les vannes *avant* la casse.
* **Décisions Supportées :** Fixer un seuil préventif clair sur **`valve_cycles_k`**, dimensionner les pièces de rechange et les équipes techniques, et définir les seuils d'alerte pression/température.
* **Hors Périmètre :** Tableaux de marge commerciale masquant les modes de défaillance physiques.

---

## 5. Données Disponibles sur 60 Jours (`lab_02_bronze_ingestion_and_profiling/data/case0_europack_bottling/`)

Le jeu de données couvre **60 jours opérationnels continus 24h/24** (`2026-10-01` – `2026-11-29` ; l'équipe de nuit `S3` du `2026-11-29` se termine le `2026-11-30 06:00`, dernier relevé 15 min à `05:45:00`) via trois sources hétérogènes :

1. **`line_telemetry.csv` (Télémesure PLC 15 min, 23 164 lignes) :** `timestamp`, `line_id`, `bottle_format`, `ambient_temp_C`, `pasteurizer_temp_C`, `conveyor_speed_bpm`, `filler_pressure_bar`, `valve_cycles_k`, `bottled_units`, `rejected_units`.
   * *Anomalies connues à profiler et traiter (Labos 03–04) :* Espaces/casse/alias (`"Line_A "`, `"LN-B"`, `"line_c"`), ligne fantôme orpheline (`LINE_Z`), dates futures (`2099-*`), doublons MQTT, valeurs manquantes `pasteurizer_temp_C` (`NaN` — **ne pas supprimer** via `.dropna()`, mais interpoler dans le temps !), pressions hors bornes physiques (`-99.0` et `85.0` bar hors `[0.0, 12.0]` bar) et quantités impossibles (`rejected_units > bottled_units` ou `bottled_units < 0`).
2. **`stoppage_logs.json` (Journaux d'Arrêts GMAO, 292 enregistrements) :** `log_id`, `event_date`, `line_code`, `stoppage_type` (`'Unplanned'` / `'unplanned'` / `'Preventive'`), `root_cause`, `downtime_min`, `technician_team`.
   * *Anomalies connues :* Alias/espaces (`"Line_A "`, `"LN-B"`), casse `'unplanned'`, doublons de `log_id` et journal fantôme `STOP-20269999` (`LINE_Z`, `2099-01-01`).
3. **`plant_master_data.xlsx` (Référentiels ERP, 3 onglets) :** `Lines`, `Shifts` (`S1/S2/S3`, `480 min`) et `Bottle_Formats`.

> [!IMPORTANT]
> **Éviter le piège du Fan-Out de Capacité (Labos 04–06) :** Plusieurs formats (`PET_05`, `PET_15`, `GLASS_075`) peuvent défiler sur une même ligne au cours d'un poste de 8h. Répartissez toujours **`planned_time_min`** au prorata (`time_share`) dans chaque ligne-poste pour que `SUM(planned_time_min)` vaille **exactement `480.0 min`**, et pré-agrégez les arrêts avant toute jointure avec la production !
