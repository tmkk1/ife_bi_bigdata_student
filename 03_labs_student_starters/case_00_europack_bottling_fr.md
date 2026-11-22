# Étude de Cas 00 (Jeu de Données des TP Guidés) : EuroPack Beverage Bottling
## Performance des lignes d'embouteillage, fiabilité des machines et TRS (OEE)

**Cours :** Business Intelligence and Analyse des Mégadonnées (`01 31 0367 00`)  
**Rôle :** Jeu de données d'entraînement utilisé dans les **TP guidés (Labos 02–10)** *(distinct des projets notés Cas 1, 2 et 3)*  
**Langue :** Français (`FR`)

---

## 1. Contexte de l'entreprise et du secteur

### 1.1 L'embouteillage rapide et les livraisons aux magasins
Les usines d'embouteillage qui livrent les supermarchés européens, les hôtels et les restaurants doivent livrer **à l'heure et en quantité complète (OTIF)** tout en respectant des règles strictes d'hygiène et de fraîcheur. Les lignes automatiques tournent **24h/24 et 7j/7 en trois équipes** pour suivre les commandes des magasins et les pics de demande.

Comme le gain par bouteille est faible, chaque arrêt imprévu, problème de température du pasteurisateur ou bouteille cassée réduit vite les bénéfices. Les retards de livraison entraînent aussi des pénalités financières et la perte de contrats.

### 1.2 Profil de l'entreprise : EuroPack Beverage Bottling Sp. z o.o.
**EuroPack Beverage Bottling Sp. z o.o.** gère une usine automatique d'embouteillage et d'emballage à **Gdańsk, Pologne (Usine n° 1)**. Le site remplit, pasteurise, bouche, étiquette et met en palettes de l'eau plate, des boissons gazeuses et des bouteilles en verre consigné sur quatre lignes :
* **0.5L Eau Plate PET (`PET_05`) :** Bouteille en plastique recyclé léger (`rPET Light 18g`) produite à très grande vitesse.
* **1.5L Pétillant PET (`PET_15`) :** Bouteille pour boisson gazeuse (`PET Carbonated 34g`) qui demande une pression de remplissage bien contrôlée.
* **0.75L Verre Consigné (`GLASS_075`) :** Bouteille en verre brun (`Amber Glass 450g`) avec le coût de rebut par bouteille le plus élevé et très sensible aux chocs thermiques et mécaniques.

```
                     CHAÎNE DE VALEUR EMBOUTEILLAGE
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Fournisseurs Verre,  │ ───► │ EuroPack Beverage       │ ───► │ Supermarchés &         │
 │ Plastique & Sirops   │      │ Bottling (Gdańsk n° 1)  │      │ Restaurants            │
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. Fonctionnement de l'usine

### 2.1 Étapes de production (Hall d'embouteillage B-1)
Dans le Hall B-1, chaque ligne automatique travaille en quatre étapes continues :
1. **Rinçage et alimentation :** Les bouteilles vides en plastique (`PET`) ou en verre consigné arrivent sur le tapis rapide (`conveyor_speed_bpm`, bouteilles par minute).
2. **Remplissage et bouchage :** Des vannes rotatives sous pression (`filler_pressure_bar`, plage normale `[0.0, 12.0]` bar) remplissent et bouchent les bouteilles pendant que l'automate (PLC) compte l'usure cumulée des vannes (`valve_cycles_k`, en milliers de cycles).
3. **Pasteurisation en tunnel :** Les bouteilles passent dans un tunnel chauffé surveillé par des capteurs de température ambiante (`ambient_temp_C`) et du pasteurisateur (`pasteurizer_temp_C`).
4. **Contrôle par caméra et éjection des défauts :** Des caméras rapides vérifient le niveau, le bouchon et l'état du verre, et comptent les bonnes bouteilles (`bottled_units`) et les rejets (`rejected_units`).

### 2.2 Lignes d'embouteillage (onglet `Lines` de `plant_master_data.xlsx`)
L'usine utilise quatre lignes décrites dans `plant_master_data.xlsx` :

| ID Ligne | Modèle de ligne | Technologie de remplissage | Temps de cycle normal | Coût d'arrêt (€/h) |
| :--- | :--- | :--- | :---: | :---: |
| **`LINE_A`** | **Krones Servo Filler 4000** | Rotary Servo | **0.75 s/bouteille** | **240 € / heure** |
| **`LINE_B`** | **Legacy Mechanical Filler M2** | Legacy Mechanical | **0.90 s/bouteille** | **210 € / heure** |
| **`LINE_C`** | **Sidel Rotary Combi 4500** | Direct-Drive Combi | **0.72 s/bouteille** | **265 € / heure** |
| **`LINE_D`** | **Tetra High-Speed Aseptic 5000** | Aseptic High-Speed | **0.65 s/bouteille** | **195 € / heure** |

### 2.3 Formats de bouteilles (onglet `Bottle_Formats`) et équipes (onglet `Shifts`)

| Code Format | Nom du format | Matériau | Cadence horaire cible | Coût d'une bouteille rejetée (€/bouteille) |
| :--- | :--- | :--- | :---: | :---: |
| **`PET_05`** | 0.5L Still Water PET | rPET Light 18g | `4 600 / h` | **0,22 €** |
| **`PET_15`** | 1.5L Sparkling PET | PET Carbonated 34g | `4 000 / h` | **0,34 €** |
| **`GLASS_075`** | 0.75L Returnable Glass | Amber Glass 450g | `3 280 / h` | **0,68 €** |

* **Trois équipes de 8 heures par jour (`480.0 min` prévues par ligne et par équipe) :**
  * **`S1` (Matin) :** `06:00 – 14:00` *(Toute l'équipe d'automatisme, qualité et maintenance est sur place)*.
  * **`S2` (Après-midi) :** `14:00 – 22:00` *(Équipe de production normale)*.
  * **`S3` (Nuit) :** `22:00 – 06:00` *(Petite équipe de nuit. Comme ce poste passe minuit, utilisez `(timestamp - 6h)` pour rattacher les données entre `00:00` et `05:45` à la date de début de l'équipe !)*.

---

## 3. Problèmes principaux de l'entreprise

Même avec beaucoup de commandes clients, l'Usine n° 1 dépense trop et n'atteint pas ses objectifs :
1. **TRS (OEE) trop bas :** L'objectif du groupe est **OEE >= 85,0 %**. Les tableaux Excel hebdomadaires affichent une moyenne autour de **70 %**, sans montrer si le problème vient des arrêts (**Disponibilité**), d'une vitesse trop lente (**Performance**) ou des bouteilles rejetées/cassées (**Qualité**). De plus, des moyennes simples non pondérées et le découpage à minuit cachent de grosses pertes sur certaines combinaisons **Ligne × Équipe × Format**.
2. **Coûts élevés des rejets et des arrêts :** Sur **60 jours**, les bouteilles rejetées (surtout la casse du verre `GLASS_075`) et les pannes imprévues coûtent plusieurs centaines de milliers d'euros. Le temps moyen de réparation dépasse aussi beaucoup l'objectif de **60 minutes (`MTTR <= 60 min`)**.
3. **Maintenance après la panne au lieu de maintenance préventive :** Les techniciens réparent les joints de vannes seulement *après* la panne. L'équipe maintenance manque de preuves chiffrées montrant à partir de quel niveau d'usure **`valve_cycles_k`**, d'écart de température (`delta_temp_C = pasteurizer_temp_C - ambient_temp_C`) et de pression les arrêts imprévus augmentent fortement.

---

## 4. Deux points de vue différents (Track A vs. Track B)

### 🅰️ Perspective A : Directeur des Opérations (COO / Direction Usine)
* **Objectif principal :** Faire monter l'OEE pondéré vers **>= 85,0 %**, trouver les blocages cachés par **Équipe × Ligne × Format**, garder le taux de rejet sous **2,0 %** et calculer en euros le coût total des rejets et arrêts non planifiés.
* **Décisions à prendre :** Choisir quelles lignes produisent le verre `GLASS_075`, mieux organiser l'équipe de nuit (`S3`) et décider où investir.
* **Hors périmètre (Ne veut PAS voir) :** Les courbes brutes de pression toutes les 15 minutes ou le détail des fiches d'intervention technique.

### 🅱️ Perspective B : Responsable Maintenance & Fiabilité
* **Objectif principal :** Réduire le temps moyen de réparation (**MTTR <= 60 min**), augmenter le temps entre deux pannes (**MTBF**), classer les causes de panne avec un **Pareto des arrêts** et changer les joints de vannes *avant* les grosses fuites.
* **Décisions à prendre :** Fixer une limite claire de remplacement préventif sur **`valve_cycles_k`**, planifier les pièces de rechange et les équipes techniques, et définir des seuils d'alerte de température et de pression.
* **Hors périmètre (Ne veut PAS voir) :** Les tableaux financiers de marge commerciale qui cachent les causes mécaniques des pannes.

---

## 5. Données disponibles sur 60 jours (`lab_02_bronze_ingestion_and_profiling/data/case0_europack_bottling/`)

Les données couvrent **60 jours en continu 24h/24** (`2026-10-01` – `2026-11-29` ; l'équipe de nuit `S3` du `2026-11-29` se termine le `2026-11-30 06:00`, dernier relevé à `05:45:00`) dans trois fichiers :

1. **`line_telemetry.csv` (Mesures capteurs toutes les 15 min, 23 164 lignes) :** `timestamp`, `line_id`, `bottle_format`, `ambient_temp_C`, `pasteurizer_temp_C`, `conveyor_speed_bpm`, `filler_pressure_bar`, `valve_cycles_k`, `bottled_units`, `rejected_units`.
   * *Erreurs à nettoyer (Labos 03–04) :* Noms de lignes mal écrits avec espaces, minuscules ou anciens codes (`"Line_A "`, `"LN-B"`, `"line_c"`), fausse ligne de test (`LINE_Z`), fausses dates futures (`2099-*`), lignes en double, valeurs `pasteurizer_temp_C` manquantes (`NaN` — **ne pas supprimer** ces lignes, utilisez l'interpolation temporelle !), pressions impossibles (`-99.0` et `85.0` bar hors `[0.0, 12.0]` bar) et quantités impossibles (`rejected_units > bottled_units` ou `bottled_units < 0`).
2. **`stoppage_logs.json` (Journaux d'arrêts GMAO, 292 enregistrements) :** `log_id`, `event_date`, `line_code`, `stoppage_type` (`'Unplanned'` / `'unplanned'` / `'Preventive'`), `root_cause`, `downtime_min`, `technician_team`.
   * *Erreurs à nettoyer :* Espaces ou anciens codes de ligne (`"Line_A "`, `"LN-B"`), `'unplanned'` en minuscules, doublons de `log_id` et faux journal fantôme `STOP-20269999` (`LINE_Z`, `2099-01-01`).
3. **`plant_master_data.xlsx` (Données de référence ERP, 3 onglets) :** `Lines`, `Shifts` (`S1/S2/S3`, `480 min`) et `Bottle_Formats`.

> [!IMPORTANT]
> **Attention au double comptage (Fan-Out Trap, Labos 04–06) :** Plusieurs formats (`PET_05`, `PET_15`, `GLASS_075`) peuvent passer sur une même ligne pendant une équipe de 8h. Partagez toujours **`planned_time_min`** proportionnellement par `time_share` dans chaque ligne-équipe pour que `SUM(planned_time_min)` soit **exactement égal à `480.0 min`**, et agrégez les arrêts séparément avant de joindre les données de production pour ne pas multiplier les lignes !
