# Étude de Cas 03 : Nexis Precision Automotive Components
## Planification des équipes, fatigue au travail et coûts de main-d'œuvre

**Cours :** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Atelier :** Atelier #1 — Charte de projet et cadrage des objectifs  
**Langue :** Français (`FR`)

---

## 1. Contexte de l'entreprise et du secteur

### 1.1 L'assemblage de précision et le rôle des opérateurs
Nexis fabrique des pièces automobiles de haute précision (vannes électriques, pièces de freinage ABS et capteurs électroniques). Sur ces lignes, la rapidité et la qualité dépendent directement des **certifications des opérateurs (`Level 2+` / `Level 3`)**, de la précision des gestes et de l'attention pendant le travail en continu (24h/24, 3 équipes). Quand des opérateurs non formés ou trop fatigués travaillent sur un poste, le nombre de pièces ratées (**rebuts / scrap**) augmente très vite.

### 1.2 Profil de l'entreprise : Nexis Precision Automotive Components
Installée à **Wrocław (Pologne)**, l'usine **Nexis** exploite **4 lignes d'assemblage** (`LINE_01..LINE_04`) avec **165 opérateurs** : **115 salariés permanents** et **50 travailleurs intérimaires**, répartis sur trois équipes (**`S1` Matin, `S2` Après-midi, `S3` Nuit**).

---

## 2. Problèmes principaux de l'entreprise

Sur une période de **60 jours**, la direction prend des décisions à l'intuition au lieu d'utiliser des chiffres fiables :
1. **Erreur sur le coût des heures supplémentaires (`1,5×`) :** Les rapports actuels paient toutes les heures au tarif normal. Ils oublient que les heures supplémentaires coûtent **`1,5×`** le salaire horaire de base. La direction ne voit donc ni le vrai coût salarial, ni le nombre d'employés manquants (**ETP / FTE**).
2. **Départs des intérimaires et Prime Qualité de 250 € :** Nexis donne une **Prime Qualité de 250 €/mois** seulement aux opérateurs qui gardent un taux de défaut `<= 1,80 %` et sont présents régulièrement. Les intérimaires non certifiés coûtent-ils vraiment moins cher par bonne pièce si l'on compte leur fort taux de départ (turnover) et les coûts de défauts (`scrap`) ?
3. **Fatigue liée aux heures supplémentaires et arrêts maladie (Facteur de Bradford $B = S^2 \times D$) :** Faire beaucoup d'heures supplémentaires provoque-t-il des arrêts maladie et plus de défauts qualité ? Pour le vérifier proprement :
   * Regroupez les jours de maladie qui se suivent en un seul épisode (**Facteur de Bradford $B = S^2 \times D$**, où $S$ = nombre d'épisodes maladie séparés et $D$ = total de jours d'absence ; `>= 400` Critique, `>= 150` Élevé).
   * Regardez uniquement les heures supplémentaires des 7 jours **avant** chaque journée (`[j-7, j-1]`, `prior_7d_ot_hours >= 8h`) — n'utilisez jamais des données du futur !
4. **Le mythe de l'équipe de nuit (`S3`) vs. le vrai problème sur une ligne :** Dans l'usine, tout le monde accuse l'équipe de nuit (`S3`) pour les pièces ratées. Les données confirment-elles que `S3` est responsable, ou y a-t-il un manque critique d'opérateurs certifiés (`L2+`) sur une ligne précise de l'**équipe du matin (`S1`)** ?

---

## 3. Deux points de vue différents (Track A vs. Track B)

### 🅰️ Perspective A : Direction des Ressources Humaines (DRH)
* **Objectif principal :** Comparer les départs (turnover) entre Permanents et Intérimaires, vérifier l'équité de la Prime Qualité de 250 € (`<= 1,80 %` de défauts), mesurer les arrêts maladie après de grosses heures supplémentaires (`prior_7d_ot >= 8h`), repérer les scores élevés du **Facteur de Bradford ($B = S^2 \times D$)**, et garder les données des salariés anonymes dans les tableaux finaux (`employee_id` uniquement).
* **Hors périmètre (Ne veut PAS voir) :** Les pannes de moteurs des machines ou les prix de vente aux clients.

### 🅱️ Perspective B : VP Opérations Industrielles
* **Objectif principal :** Vérifier le **taux de présence certifiée L2+ (`Ligne × Équipe`)**, relier le manque de certification et la fatigue aux pertes financières de défauts (€), contrôler le vrai coût des salaires avec **`1,5×` heures sup'**, et calculer dynamiquement le nombre d'**ETP (FTE) manquants** quand on change le filtre de dates (zéro chiffre fixe écrit en dur !).
* **Hors périmètre (Ne veut PAS voir) :** Les noms, e-mails ou notes médicales privées des travailleurs.

---

## 4. Données disponibles sur 60 jours (`data/bronze/`)

Les données couvrent **60 jours en continu 24h/24** (`2026-10-01` – `2026-11-29` ; `4` lignes × `3` équipes = **`720` quarts de ligne**, `165` travailleurs avec badge) dans trois fichiers :

1. **`shift_production_performance.csv` (Production MES, `720` lignes) :** `shift_date`, `shift_code`, `assembly_line_id`, `line_name`, `product_category`, `planned_headcount`, `planned_certified_l2_plus`, `present_certified_l2_plus`, `headcount_coverage_pct`, `certified_staffing_coverage_pct`, `target_output_units`, `actual_produced_units`, `good_units`, `scrap_defect_units`, `rework_units`, `scrap_cost_eur`, `line_stoppage_min`, `operator_headcount_present`, `agency_worker_count`, `agency_staffing_ratio_pct`.
   * *Note importante (`spot_fill`) :* Sur `268/720` quarts, `operator_headcount_present` inclut aussi des intérimaires temporaires anonymes (`spot_fill`) sans badge personnel. Le fichier `workforce_events.json` suit uniquement les `165` travailleurs avec badge (`EMP-101..EMP-265`, plus les erreurs `EMP-GHOST-*`).
2. **`workforce_events.json` (Badges, contrôles qualité, heures sup' et maladie, 25 585 événements) :** Clés principales (`event_id`, `timestamp`, `employee_id`, `event_type` [`SHIFT_CLOCK_IN`, `SHIFT_CLOCK_OUT`, `STATION_CHECK_IN`, `INDIVIDUAL_QA_AUDIT`, `OVERTIME_AUTHORIZED`, `ABSENCE_UNPLANNED_SICK`], `assembly_line_id`, `shift_code`, `badge_reader_id`) et un sous-objet **`details`** (`approved_overtime_hours`, `total_shift_hours`, `units_inspected`, `defect_count`, `medical_note`, etc.). Utilisez `pd.json_normalize(raw, sep="_")` pour obtenir les colonnes `details_*`, y compris **`details_medical_note`**.
   * *Règles de confidentialité et de nettoyage :*
     * **Supprimer les notes médicales privées :** Supprimez **`details_medical_note`** avant de sauvegarder les tables Silver ou Gold.
     * **Mettre en quarantaine les erreurs :** Bloquez les faux badges (`EMP-GHOST-*`), les fausses dates (`2099-*`), les durées impossibles (`145.0h`, `-3.5h`, `22.0h` d'heures sup' sur un poste), et les doubles passages de badge (`< 60s`).
     * **Corriger le passage de minuit (`S3`) :** Alignez les pointages de nuit (`20:00–08:00`) avec les décalages horaires (`S1: -2h, S2: -3h, S3: -9h`).
3. **`workforce_roster_and_skills.xlsx` (Fichier RH, 4 onglets) :**
   * `Employees` : Identifiant anonyme **`employee_id`** (`EMP-101..EMP-265`), `hourly_base_wage_eur`, `overtime_rate_multiplier` (`1.5`), `churn_status`.
     * **Supprimer les données personnelles avant Silver/Gold :** Supprimez **`first_name`**, **`last_name`**, **`corporate_email`** et **`national_id_masked`** pour ne garder que `employee_id` !
     * **Nettoyer les textes :** Uniformisez `contract_type` (`'temp_agency'`, `'Temporary_Agency '`) et remplacez les cellules vides de `agency_partner` par `'Brak danych / Direct'` *(en polonais : « Aucune donnée / Direct »)*.
   * `Skill_Matrix`, `Incentive_Policies` (`max_station_scrap_pct = 1.80`, `monthly_bonus_eur = 250.0`), `Shift_Staffing_Plan`.

---

## 5. Travail demandé pour l'Atelier #1
Complétez [`project_charter_template.md`](project_charter_template.md) avec :
1. Votre rôle (**Perspective A** ou **B**) ;
2. Votre plan de qualité et de confidentialité des données (supprimer les 5 colonnes personnelles/médicales `first_name`, `last_name`, `corporate_email`, `national_id_masked`, `details_medical_note`, et mettre les mauvais relevés en quarantaine via `Data Quality Gate 1` / `Proces DQ Gate 1`) ;
3. Votre évaluation **Gartner ITScore** (`As-Is` vs `To-Be`) ;
4. **3 questions SMART-BI mesurables**.
