# Étude de Cas 01 : SmartPress Automotive Components
## Performance de l'usine, fiabilité des machines et optimisation du TRS (OEE)

**Cours :** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Atelier :** Atelier #1 — Charte de projet et cadrage des objectifs  
**Langue :** Français (`FR`)

---

## 1. Contexte de l'entreprise et du secteur

### 1.1 Le secteur automobile (livraison Just-In-Time)
Les grands constructeurs automobiles (Volkswagen, Stellantis, Toyota) travaillent en **Juste-à-Temps (JIT)** et **Juste-en-Séquence (JIS)**. Leurs usines gardent presque zéro stock de réserve : souvent moins de **2 à 4 heures** de pièces à côté de la ligne d'assemblage.

Pour cette raison, les fournisseurs directs (**Tier-1**) n'ont pas le droit de livrer en retard. Si un problème arrête une ligne d'assemblage automobile, le fournisseur paie une pénalité de **5 000 € à 15 000 € par minute** et risque de perdre ses futurs contrats.

### 1.2 Profil de l'entreprise : SmartPress Automotive Components
**SmartPress Automotive Components Sp. z o.o.** gère l'usine d'emboutissage n° 3 à **Poznań (Pologne)**. L'usine presse des feuilles d'acier à froid pour fabriquer des pièces de structure automobile (*Body-in-White*) :
* **Montants A et B :** Pièces de sécurité pour la cabine, fabriquées en acier très résistant (AHSS).
* **Traverses de châssis et supports de suspension :** Pièces robustes qui demandent des dimensions très précises.
* **Supports de batterie (EV) :** Pièces embouties en profondeur pour les voitures électriques.

```
                     PLACE DANS LA CHAÎNE AUTOMOBILE
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Fournisseurs d'acier │ ───► │  SmartPress Automotive  │ ───► │ Constructeurs (OEM)    │
 │ (Bobines L / M / H)  │      │  (Usine n° 3, Poznań)   │      │ (Lignes JIT)           │
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. Fonctionnement de l'usine

### 2.1 Étapes de fabrication (Hall T-2)
Dans le hall T-2, les presses automatiques travaillent en quatre étapes :
1. **Déroulage et alimentation :** Les gros rouleaux d'acier (bobines) sont déroulés, aplatis et envoyés dans la presse.
2. **Frappe et mise en forme (`600 T – 1 200 T`) :** Des presses lourdes coupent, plient et forment le métal en pièces 3D.
3. **Contrôle par caméra (AOI) :** Des caméras rapides vérifient les pièces finies et comptent les pièces ratées (`scrap_units`).
4. **Recyclage des chutes :** Les restes d'acier et les pièces défectueuses partent au recyclage.

### 2.2 Les presses de l'usine (onglet `Machines`)
L'usine utilise quatre presses décrites dans `machines_and_shifts.xlsx` :

| ID Machine | Modèle et type de presse | Force (Tonnage) | Temps de cycle normal | Coût d'arrêt (€/h) |
| :--- | :--- | :---: | :---: | :---: |
| **`PRESS_01`** | **Schuler Servo Direct Drive** *(Vitesse réglable)* | `1 000 T` | **3,5 sec / pièce** | **250 € / heure** |
| **`PRESS_02`** | **Komatsu Mécanique (Flywheel)** *(Ancienne presse mécanique)* | `800 T` | **4,0 sec / pièce** | **220 € / heure** |
| **`PRESS_03`** | **AIDA Transfert Lourde** *(Presse rigide pour acier épais)* | `1 200 T` | **3,2 sec / pièce** | **280 € / heure** |
| **`PRESS_04`** | **Schuler Progressive Rapide** *(Presse rapide pour petites pièces)* | `600 T` | **2,8 sec / pièce** | **190 € / heure** |

### 2.3 Types d'acier (`Product_Variants`) et équipes de travail (`Shifts`)
* **Variante `L` (Acier doux) :** Facile à former, demande peu de force, faible coût si une pièce est ratée (`scrap`).
* **Variante `M` (Acier moyen / HSLA) :** Force moyenne et usure normale des outils.
* **Variante `H` (Acier très haute résistance / AHSS) :** Acier très dur (`600–1 000 MPa`). Il demande la force maximale, coûte très cher en cas de défaut, et chauffe vite les outils par frottement.
* **Trois équipes de `8h` par jour (`480 min` prévues par presse et par équipe) :**
  * **`S1` (Matin) :** `06:00 – 14:00` *(Toute l'équipe d'ingénieurs et de maintenance est sur place)*.
  * **`S2` (Après-midi) :** `14:00 – 22:00` *(Équipe de production normale)*.
  * **`S3` (Nuit) :** `22:00 – 06:00` *(Petite équipe de nuit. Comme ce poste passe minuit, utilisez `(timestamp - 6h)` pour rattacher les données après `00:00` à la bonne journée de travail !)*.

---

## 3. Problèmes principaux de l'entreprise

Même avec beaucoup de commandes clients, l'usine n° 3 perd de l'argent et échoue aux contrôles qualité :
1. **TRS (OEE) trop bas :** L'objectif du groupe est **OEE >= 85,0 %**. Les rapports Excel actuels montrent une moyenne autour de **70 %**, sans expliquer si le problème vient des pannes (**Disponibilité**), de la vitesse (**Performance**) ou des pièces ratées (**Qualité**). De plus, couper le poste de nuit à minuit cache les pires machines.
2. **Coûts élevés des pannes et des défauts :** Sur **60 jours**, les pannes imprévues et les défauts sur l'acier cher (`Variante H`) font perdre plusieurs centaines de milliers d'euros. La nuit, les réparations sont aussi beaucoup plus lentes que l'objectif de **60 minutes (`MTTR <= 60 min`)**.
3. **Maintenance réactive au lieu de préventive :** L'équipe répare les presses seulement *après* la panne. Elle ne sait pas encore à quel niveau exact d'usure (`tool_wear_min`), de température (`delta_temp_K`) et de force (`torque_Nm`) l'outil commence à casser ou à produire des défauts.

---

## 4. Deux points de vue différents (Track A vs. Track B)

### 🅰️ Perspective A : Directeur des Opérations (COO)
* **Objectif principal :** Atteindre **>= 85,0 % de TRS (OEE)**, livrer les constructeurs à l'heure, trouver les pertes cachées par **Presse × Équipe × Type d'acier**, et calculer le coût des arrêts et des défauts en euros.
* **Décisions à prendre :** Choisir quelles presses fabriquent l'acier `Variante H`, revoir l'organisation de l'équipe de nuit (`S3`), décider des investissements.
* **Hors périmètre (Ne veut PAS voir) :** Les courbes électriques détaillées toutes les 15 minutes ou les notes techniques des réparateurs.

### 🅱️ Perspective B : Responsable Maintenance & Fiabilité
* **Objectif principal :** Réduire le temps moyen de réparation (**MTTR <= 60 min**), augmenter le temps entre deux pannes (**MTBF**), classer les causes de pannes (Pareto), et changer les outils *avant* la casse.
* **Décisions à prendre :** Fixer une limite claire de `tool_wear_min` pour changer ou entretenir les outils, gérer les pièces de rechange et l'équipe de nuit, définir des alarmes de température et de couple (`torque_Nm`).
* **Hors périmètre (Ne veut PAS voir) :** Les tableaux de marge financière qui cachent les causes mécaniques des pannes.

---

## 5. Données disponibles sur 60 jours (`data/bronze/`)

Les données couvrent **60 jours en continu 24h/24** (`2026-10-01` – `2026-11-29` ; l'équipe de nuit `S3` du `2026-11-29` finit le `2026-11-30 à 06:00`, dernier relevé à `05:45:00`) dans trois fichiers :

1. **`sensor_telemetry.csv` (Capteurs SCADA, ~23 164 lignes) :** Mesures toutes les 15 minutes (`timestamp`, `machine_id`, `product_variant`, `air_temp_K`, `process_temp_K`, `rotational_speed_rpm`, `torque_Nm`, `tool_wear_min`, `produced_units`, `scrap_units`).
   * *Erreurs à nettoyer :* Noms mal écrits (`"Press_01 "`, `"P-02"`, `"press_03"`), fausse machine (`PRESS_99`), dates futures fausses (`2099-*`), lignes en double, valeurs `process_temp_K` manquantes (`NaN` — ne supprimez **pas** ces lignes, utilisez l'interpolation temporelle !), valeurs de couple impossibles (`-999 Nm`, `4850 Nm`), et `scrap_units > produced_units`.
2. **`maintenance_logs.json` (Tickets de réparation GMAO / CMMS, 286 tickets) :** `ticket_id`, `event_date`, `machine_code`, `downtime_type` (`'Unplanned'` / `'unplanned'` / `'Preventive'`), `failure_mode`, `repair_duration_min`.
   * *Erreurs à nettoyer :* Faux ticket `CMMS-20269999` (`PRESS_99`, `2099-01-01`, `'Phantom Ticket'`), noms de machines incohérents (`'Press_01 '`, `'P-02'`), `'unplanned'` en minuscules. Vérifiez aussi qu'aucun ticket valide n'a `repair_duration_min <= 0` et remplacez tout `failure_mode` vide par `'Brak danych / Unspecified'` *(en polonais : « Aucune donnée / Non spécifié »)*.
3. **`machines_and_shifts.xlsx` (Données de référence ERP, 3 onglets) :** `Machines` (modèle et type d'entraînement, temps de cycle, coût d'exploitation/arrêt €/h), `Shifts` (`S1/S2/S3`, 8h / `480 min`), et `Product_Variants` (`L/M/H`, nuance d'acier, cadence cible horaire et coût de défaut par pièce €/pièce).

> [!IMPORTANT]
> **Attention au double comptage (Fan-Out Trap) :** Plusieurs types d'acier (`L/M/H`) peuvent passer sur une presse pendant la même équipe de 8h. Dans la table Gold `Fact_Shift_Production`, partagez **`planned_time_min`** proportionnellement entre les variantes pour que **`SUM(planned_time_min)` soit exactement égal à `480.0 min`** par presse et par équipe. Calculez aussi les pannes séparément avant la jointure pour ne pas multiplier les lignes de production !

---

## 6. Travail demandé pour l'Atelier #1
Complétez [`project_charter_template.md`](project_charter_template.md) avec :
1. Votre rôle (**Perspective A** ou **B**) ;
2. Votre plan de qualité des données (`Data Quality Gate 1` / `Proces DQ Gate 1` et journal de quarantaine) ;
3. Votre évaluation **Gartner ITScore** (`As-Is` vs `To-Be`) ;
4. **3 questions SMART-BI mesurables** pour trouver les pertes cachées sur 60 jours.
