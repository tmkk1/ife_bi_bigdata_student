-- =========================================================================
-- MISSION 0 (COMMENCEZ ICI — Votre toute première requête SQL ! Sans GROUP BY !)
-- Objectif métier : Avant de calculer des KPIs, lire le catalogue des lignes
--                   d'embouteillage et afficher 5 arrêts bruts sur LINE_B.
-- Astuce Console : Surlignez N'IMPORTE QUELLE requête ci-dessous et appuyez sur
--                  Cmd+Shift+Entrée (Mac) / Ctrl+Shift+Entrée (Windows/Linux) pour exécuter uniquement
--                  le bloc sélectionné !
-- =========================================================================

-- 0A. Lire des colonnes précises d'une table (SELECT ... FROM ...)
SELECT line_id, line_name, filler_type, hourly_operating_cost_eur
FROM stg_lines;

-- 0B. Filtrer les lignes (WHERE) et limiter à 5 résultats (LIMIT)
SELECT log_id, operational_shift_date, shift_code, line_code, root_cause, downtime_min
FROM stg_stoppages
WHERE line_code = 'LINE_B'
LIMIT 5;

-- =========================================================================
-- MISSION 1 (DÉMO — Votre première agrégation avec GROUP BY)
-- Objectif métier : Quel volume d'arrêt provient des pannes imprévues (Unplanned)
--                   par rapport à la maintenance préventive (Preventive) ?
-- =========================================================================
SELECT stoppage_type,
       COUNT(*)          AS incident_count,
       SUM(downtime_min) AS total_downtime_min
FROM stg_stoppages
GROUP BY stoppage_type
ORDER BY total_downtime_min DESC;

-- =========================================================================
-- MISSION 2 (WHERE + ORDER BY + LIMIT) : Les 5 plus longues pannes imprévues
-- Objectif métier : La maintenance veut analyser en priorité les 5 plus longs
--                   arrêts imprévus pour comprendre nos pires délais de réparation.
-- Consigne : Complétez les 3 trous (___) et exécutez !
-- =========================================================================
SELECT log_id, line_code, root_cause, downtime_min
FROM stg_stoppages
WHERE stoppage_type = '___'
ORDER BY ___ DESC, log_id
LIMIT ___;

-- =========================================================================
-- MISSION 3 (GROUP BY + SUM + AVG) : LINE_A est-elle vraiment la pire machine ?
-- Objectif métier : La direction soupçonne LINE_A. Classez chaque ligne par
--                   cumul d'arrêts imprévus (total_min) et temps moyen de
--                   réparation (mttr_min) pour vérifier son hypothèse !
-- =========================================================================
SELECT line_code,
       COUNT(*)                    AS stoppages,
       SUM(___)                    AS total_min,
       ROUND(AVG(downtime_min), 2) AS mttr_min
FROM stg_stoppages
WHERE stoppage_type = 'Unplanned'
GROUP BY ___
ORDER BY ___ DESC;

-- =========================================================================
-- MISSION 4A (GROUP BY + HAVING) : Isoler les pannes chroniques (> 20 arrêts)
-- Objectif métier : Avec un budget maintenance limité, isolez UNIQUEMENT les
--                   causes ayant provoqué PLUS DE 20 arrêts imprévus.
-- Rappel : WHERE filtre les lignes AVANT regroupement ; HAVING filtre les groupes APRÈS !
-- =========================================================================
SELECT root_cause,
       ___ AS incident_count,
       ___ AS total_min
FROM stg_stoppages
WHERE ___
GROUP BY ___
HAVING ___
ORDER BY total_min DESC;

-- =========================================================================
-- MISSION 4B (Part en %) : Quel % des arrêts provient de chaque cause ?
-- Objectif métier : La responsable maintenance veut le poids en % (Pareto) de
--                   chacune des 4 causes d'arrêts imprévus pour justifier un
--                   budget sur les 2 causes majeures.
-- Nouveau motif SQL : SUM(SUM(downtime_min)) OVER () calcule le total global
--                     sur tous les groupes afin de diviser proprement !
-- =========================================================================
SELECT root_cause,
       COUNT(*)          AS incident_count,
       SUM(downtime_min) AS total_min,
       ROUND(SUM(downtime_min) * 100.0 / SUM(SUM(___)) OVER (), 2) AS downtime_share_pct
FROM stg_stoppages
WHERE stoppage_type = '___'
GROUP BY root_cause
ORDER BY total_min DESC;

-- =========================================================================
-- RAPPEL DES TYPES DE JOIN (Lisez & exécutez avant les Missions 5–6 !)
--   1. INNER JOIN      -> Garde UNIQUEMENT les correspondances des 2 côtés (A ∩ B).
--   2. LEFT JOIN       -> Garde TOUTES les lignes de GAUCHE ; met NULL à droite
--                         s'il n'y a pas de match (utilisez COALESCE(..., 0) !).
--   3. RIGHT JOIN      -> Symétrique du LEFT JOIN (rare : mettez la table principale à gauche !).
--   4. FULL OUTER JOIN -> Garde TOUTES les lignes des 2 tables (utile en audit DQ).
--
-- Mini-Démo : Comparez INNER vs LEFT JOIN pour 'Capper Sensor Drift' sur nos 4 lignes !
--             (Surlignez l'une ou l'autre requête + Cmd/Ctrl+Shift+Entrée !)
-- =========================================================================

-- INNER JOIN : les lignes sans incident 'Capper Sensor Drift' DISPARAISSENT !
SELECT l.line_id, COUNT(s.log_id) AS capper_stops
FROM stg_lines l
INNER JOIN stg_stoppages s
    ON l.line_id = s.line_code AND s.root_cause = 'Capper Sensor Drift'
GROUP BY l.line_id
ORDER BY l.line_id;

-- LEFT JOIN : Les 4 lignes survivent toutes (0 affiché s'il n'y a eu aucun incident !)
SELECT l.line_id, COUNT(s.log_id) AS capper_stops
FROM stg_lines l
LEFT JOIN stg_stoppages s
    ON l.line_id = s.line_code AND s.root_cause = 'Capper Sensor Drift'
GROUP BY l.line_id
ORDER BY l.line_id;

-- =========================================================================
-- MISSION 5 (INNER JOIN) : Convertir les minutes d'arrêt en Euros (€)
-- Objectif métier : Le directeur d'usine arbitre en Euros, pas en minutes !
--                   Enrichissez stg_stoppages (s) avec le nom, la technologie et
--                   hourly_operating_cost_eur depuis stg_lines (l).
-- =========================================================================
SELECT s.line_code,
       l.line_name,
       l.filler_type,
       COUNT(*)                                       AS stoppages,
       SUM(s.downtime_min)                            AS total_min,
       ROUND(SUM((s.downtime_min / 60.0) * l.___), 2) AS downtime_cost_eur
FROM stg_stoppages s
INNER JOIN ___ l
    ON s.line_code = l.___
WHERE s.stoppage_type = 'Unplanned'
GROUP BY s.line_code, l.line_name, l.filler_type
ORDER BY downtime_cost_eur DESC;

-- =========================================================================
-- MISSION 6A (Briques de base & Intro aux CTE — Surlignez & exécutez chaque bloc !)
-- Objectif métier : Le directeur d'usine demande :
--   « Sur 60 jours, quel % de nos postes planifiés ont tourné SANS AUCUNE PANNE ? »
--
-- Pour répondre proprement, nous préparons DEUX briques avant de les joindre :
--   Bloc 1 : Tous les (date, poste, ligne) planifiés -> 720 lignes-postes.
--   Bloc 2 : Cumul d'arrêt imprévu par (date, poste, ligne) -> 210 postes seulement !
--
-- Astuce : Surlignez le Bloc 1 + Cmd/Ctrl+Shift+Entrée, puis le Bloc 2 + Cmd/Ctrl+Shift+Entrée !
--          En Mission 6B, nous réunissons ces 2 blocs dans une CTE (WITH nom AS (...)),
--          comme deux feuilles temporaires nommées pour cette requête !
-- =========================================================================

-- Bloc 1 (all_line_shifts) : Combien de lignes-postes uniques sur 60 jours ? (720 lignes !)
SELECT DISTINCT operational_shift_date, shift_code, line_id
FROM stg_telemetry
ORDER BY 1, 2, 3;

-- Bloc 2 (shift_stops) : Quelles lignes-postes ont subi une panne imprévue ? (210 lignes !)
SELECT operational_shift_date, shift_code, line_code,
       SUM(downtime_min) AS unplanned_min
FROM stg_stoppages
WHERE stoppage_type = 'Unplanned'
GROUP BY operational_shift_date, shift_code, line_code
ORDER BY 1, 2, 3;

-- =========================================================================
-- MISSION 6B (CTE + LEFT JOIN + COALESCE + % de Postes Sans Panne !)
-- Objectif métier : Relier le Bloc 1 (720 postes) et le Bloc 2 (210 postes en
--                   panne) via WITH (CTE) + LEFT JOIN sans effacer les 510 postes
--                   sains, et calculer pct_clean_shifts !
-- Astuce : Vous pouvez toujours surligner un SELECT interne dans WITH + Cmd/Ctrl+Shift+Entrée !
-- =========================================================================
WITH all_line_shifts AS (
    SELECT DISTINCT operational_shift_date, shift_code, line_id
    FROM stg_telemetry
),
shift_stops AS (
    SELECT operational_shift_date, shift_code, line_code,
           SUM(downtime_min) AS unplanned_min
    FROM stg_stoppages
    WHERE stoppage_type = 'Unplanned'
    GROUP BY operational_shift_date, shift_code, line_code
)
SELECT COUNT(*)                                                          AS total_line_shifts,
       COUNT(st.unplanned_min)                                           AS shifts_with_stoppage,
       COUNT(*) - COUNT(st.unplanned_min)                                AS clean_shifts,
       ROUND((COUNT(*) - COUNT(st.unplanned_min)) * 100.0 / COUNT(*), 2) AS pct_clean_shifts,
       SUM(___(st.unplanned_min, 0))                                     AS total_unplanned_min
FROM all_line_shifts ls
___ JOIN shift_stops st
    ON ls.operational_shift_date = st.operational_shift_date
   AND ls.shift_code = st.shift_code
   AND ls.line_id = st.line_code;

-- =========================================================================
-- SONDAGE EN SALLE (DÉMO — STOP & VOTEZ AVANT D'EXÉCUTER !) :
-- Danger métier : Que se passe-t-il si l'on saute la modélisation Kimball et
--                 qu'on fait un JOIN naïf entre la télémétrie 15 min (23 000 lignes)
--                 et stg_stoppages ? (Rappel : vrai total imprévu = 22 260 min !)
-- =========================================================================
SELECT COUNT(*)                                 AS joined_rows,
       SUM(st.downtime_min)                     AS FAKE_inflated_downtime_min,
       ROUND(SUM(st.downtime_min) / 22260.0, 1) AS inflation_multiplier
FROM stg_telemetry t
JOIN stg_stoppages st
  ON t.operational_shift_date = st.operational_shift_date
 AND t.shift_code = st.shift_code
 AND t.line_id = st.line_code
WHERE st.stoppage_type = 'Unplanned';

-- =========================================================================
-- CONSTRUCTION GOLD 1 (DÉMO — Exécutez !) : Créer votre 1re Dimension (Dim_Line)
-- Objectif métier : Traduire votre plan schema.dbml en tables Gold physiques
--                   dotées de clés entières de substitution (1, 2, 3, 4).
-- Après exécution, cliquez Rafraîchir dans l'explorateur à gauche -> Dim_Line !
-- =========================================================================
CREATE OR REPLACE TABLE Dim_Line AS
SELECT ROW_NUMBER() OVER (ORDER BY line_id) AS line_key,
       line_id                              AS line_code,
       line_name,
       filler_type,
       nominal_cycle_time_sec,
       hourly_operating_cost_eur
FROM stg_lines;

SELECT * FROM Dim_Line ORDER BY line_key;

-- =========================================================================
-- CONSTRUCTION GOLD 2 (Complétez les trous ___) : Créer Dim_Shift & Dim_Format
-- Objectif métier : Matérialiser les Dimensions Poste (480 min) et Format
--                   conformément à votre schéma schema.dbml.
-- =========================================================================
CREATE OR REPLACE TABLE Dim_Shift AS
SELECT ROW_NUMBER() OVER (ORDER BY shift_id) AS shift_key,
       shift_id                              AS shift_code,
       shift_name,
       start_time,
       end_time,
       (___ * 60)::INTEGER                   AS planned_duration_min
FROM stg_shifts;

CREATE OR REPLACE TABLE Dim_Format AS
SELECT ROW_NUMBER() OVER (ORDER BY ___) AS format_key,
       format_code,
       format_name,
       packaging_material,
       target_hourly_output,
       unit_reject_cost_eur
FROM ___;

SELECT * FROM Dim_Shift ORDER BY shift_key;

-- =========================================================================
-- CONSTRUCTION GOLD 3 (2 trous ___) : Créer Dim_Date sur 60 jours
-- Objectif métier : Construire un calendrier conforme partagé entre Production
--                   et Arrêts, avec attributs is_weekend/quarter prêts à filtrer !
-- Pourquoi un entier AAAAMMJJ (20261001) ? Lisible, triable naturellement, rapide
-- (4 octets), zéro bug de fuseau horaire/format, et gère les dates inconnues sans NULL !
-- =========================================================================
CREATE OR REPLACE TABLE Dim_Date AS
WITH bounds AS (
    SELECT MIN(operational_shift_date)::DATE AS min_d,
           MAX(operational_shift_date)::DATE AS max_d
    FROM stg_telemetry
),
dates AS (
    SELECT unnest(generate_series(min_d, max_d, INTERVAL '1 DAY'))::DATE AS cal_date
    FROM bounds
)
SELECT strftime(cal_date, '___')::INTEGER AS date_key,
       cal_date                           AS calendar_date,
       dayname(cal_date)                  AS day_of_week,
       dayofmonth(cal_date)               AS day_of_month,
       monthname(cal_date)                AS month_name,
       quarter(cal_date)                  AS quarter,
       year(cal_date)                     AS year,
       CASE WHEN dayofweek(cal_date) IN (0, 6) THEN ___ ELSE FALSE END AS is_weekend
FROM dates;

SELECT * FROM Dim_Date ORDER BY date_key LIMIT 7;

-- =========================================================================
-- SPRINT DÉTECTIVE #1 : Quel matériau d'emballage a le pire taux de rejet ?
-- Objectif métier : En partant de nos 3 formats (Dim_Format), calculer le
--                   volume embouteillé, les rejets et le taux reject_rate_pct !
--
-- Deux réflexes clés de modélisation :
--  1. On place FROM Dim_Format EN PREMIER — cela suit la pensée métier (« Je pars
--     de mes formats, puis je rattache leurs statistiques via LEFT JOIN ! »).
--  2. Pourquoi joindre sur f.format_code au lieu de f.format_key aujourd'hui ?
--     Parce que stg_telemetry est encore une table SILVER (elle ne connaît que
--     le code ERP 'GLASS_075'). Au Lab 06, on fait cette correspondance UNE FOIS
--     pour stocker l'entier format_key dans Fact_Shift_Production — ensuite, toutes
--     les requêtes Gold ne joignent plus que sur des entiers !
-- =========================================================================
SELECT f.format_code,
       f.packaging_material,
       SUM(t.bottled_units)                                           AS total_bottled,
       SUM(t.rejected_units)                                          AS total_rejected,
       ROUND(SUM(t.rejected_units) * 100.0 / SUM(t.bottled_units), 2) AS reject_rate_pct
FROM ___ f
LEFT JOIN stg_telemetry t
    ON f.___ = t.bottle_format
GROUP BY f.format_code, f.packaging_material
ORDER BY reject_rate_pct DESC;

-- =========================================================================
-- SPRINT DÉTECTIVE #2 & #3 : Production Week-end (depuis Dim_Date !) & Équipes
-- Objectif métier (#2) : La cadence chute-t-elle le week-end ? Partez FROM Dim_Date
--                        pour comparer la moyenne journalière Week-end vs Semaine !
-- Objectif métier (#3) : Quelle équipe technique absorbe le plus d'arrêts imprévus ?
-- =========================================================================
WITH daily_output AS (
    SELECT d.calendar_date,
           d.is_weekend,
           SUM(t.bottled_units) AS daily_bottles
    FROM ___ d
    LEFT JOIN stg_telemetry t
        ON d.___ = t.operational_shift_date
    GROUP BY d.calendar_date, d.is_weekend
)
SELECT is_weekend,
       COUNT(*)                     AS day_count,
       ROUND(AVG(daily_bottles), 0) AS avg_daily_bottles
FROM daily_output
GROUP BY is_weekend
ORDER BY is_weekend;

-- Sprint #3 (Surlignez & appuyez sur Cmd/Ctrl+Shift+Entrée pour exécuter !) :
SELECT technician_team,
       COUNT(*)          AS stoppages,
       SUM(downtime_min) AS total_min
FROM stg_stoppages
WHERE stoppage_type = '___'
GROUP BY ___
ORDER BY total_min DESC;
