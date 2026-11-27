-- =========================================================================
-- MISSION 0 (START HERE — Your Very First SQL Query! No GROUP BY yet!)
-- Business Goal: Before computing any KPIs, inspect our bottling lines and
--                preview a few raw breakdown tickets on LINE_B.
-- Console Tip: Highlight ANY single query below and press Cmd+Shift+Enter (Mac)
--              or Ctrl+Shift+Enter (Windows/Linux) to run ONLY the highlighted part!
-- =========================================================================

-- 0A. Read specific columns from a table (SELECT ... FROM ...)
SELECT line_id, line_name, filler_type, hourly_operating_cost_eur
FROM stg_lines;

-- 0B. Filter rows (WHERE) and preview just 5 rows (LIMIT)
SELECT log_id, operational_shift_date, shift_code, line_code, root_cause, downtime_min
FROM stg_stoppages
WHERE line_code = 'LINE_B'
LIMIT 5;

-- =========================================================================
-- MISSION 1 (DEMO — Your First Aggregation with GROUP BY)
-- Business Goal: How much total downtime comes from Unplanned breakdowns
--                versus scheduled Preventive maintenance?
-- =========================================================================
SELECT stoppage_type,
       COUNT(*)          AS incident_count,
       SUM(downtime_min) AS total_downtime_min
FROM stg_stoppages
GROUP BY stoppage_type
ORDER BY total_downtime_min DESC;

-- =========================================================================
-- MISSION 2 (WHERE + ORDER BY + LIMIT): Top 5 Longest Unplanned Breakdowns
-- Business Goal: Maintenance wants to review the 5 single worst unplanned
--                breakdowns first to understand our maximum repair delays.
-- Task: Fill in the 3 blanks (___) and run!
-- =========================================================================
SELECT log_id, line_code, root_cause, downtime_min
FROM stg_stoppages
WHERE stoppage_type = '___'
ORDER BY ___ DESC, log_id
LIMIT ___;

-- =========================================================================
-- MISSION 3 (GROUP BY + SUM + AVG): Is LINE_A Really the Worst Machine?
-- Business Goal: Management blames LINE_A for most downtime. Rank every
--                bottling line by total unplanned downtime minutes (total_min)
--                and average repair duration (mttr_min) to test their claim!
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
-- MISSION 4A (GROUP BY + HAVING): Isolate Chronic Failure Root Causes
-- Business Goal: Maintenance has a tight engineering budget—find ONLY the
--                root causes that triggered MORE THAN 20 unplanned breakdowns.
-- Reminder: WHERE filters raw rows BEFORE grouping; HAVING filters groups AFTER!
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
-- MISSION 4B (Percentage Share %): What % of Downtime Comes from Each Cause?
-- Business Goal: The Head of Maintenance wants a Pareto percentage breakdown
--                across ALL 4 unplanned root causes so she can justify capital
--                investment on the top 2 problems.
-- New SQL Pattern: SUM(SUM(downtime_min)) OVER () computes the grand total
--                  across all grouped rows so you can divide by it cleanly!
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
-- JOIN TYPES PRIMER (Read & Run Demo before Missions 5–6!)
--   1. INNER JOIN      -> Keep ONLY rows that match in BOTH tables (A ∩ B).
--   2. LEFT JOIN       -> Keep ALL rows from the LEFT table; fill NULLs if
--                         no match exists on the right (use COALESCE(..., 0)!).
--   3. RIGHT JOIN      -> Mirror of LEFT JOIN (rarely used — put main table on LEFT!).
--   4. FULL OUTER JOIN -> Keep ALL rows from BOTH tables (useful for DQ audits).
--
-- Mini-Demo: Compare INNER vs LEFT JOIN when looking for 'Capper Sensor Drift'
--            across our 4 bottling lines! (Highlight either query + Cmd/Ctrl+Shift+Enter!)
-- =========================================================================

-- INNER JOIN: lines with 0 Capper Sensor Drift incidents DISAPPEAR!
SELECT l.line_id, COUNT(s.log_id) AS capper_stops
FROM stg_lines l
INNER JOIN stg_stoppages s
    ON l.line_id = s.line_code AND s.root_cause = 'Capper Sensor Drift'
GROUP BY l.line_id
ORDER BY l.line_id;

-- LEFT JOIN: ALL 4 bottling lines survive (showing 0 when no incident occurred!)
SELECT l.line_id, COUNT(s.log_id) AS capper_stops
FROM stg_lines l
LEFT JOIN stg_stoppages s
    ON l.line_id = s.line_code AND s.root_cause = 'Capper Sensor Drift'
GROUP BY l.line_id
ORDER BY l.line_id;

-- =========================================================================
-- MISSION 5 (INNER JOIN): Translate Breakdown Minutes into Euros (€)
-- Business Goal: The COO makes investment decisions in Euros, not minutes!
--                Enrich stg_stoppages (s) with each line's name, filler type,
--                and hourly_operating_cost_eur from stg_lines (l).
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
-- MISSION 6A (CTE Building Blocks — Demo, Highlight & Run Each Block!)
-- Business Goal: The Plant Director asks:
--   "Over 60 days, what % of our scheduled shifts ran COMPLETELY breakdown-free?"
--
-- To answer this cleanly, we need TWO building blocks before joining:
--   Block 1: Every scheduled (date, shift, line) that ran -> 720 total line-shifts.
--   Block 2: Total unplanned downtime per (date, shift, line) -> only 210 shifts!
--
-- Tip: Highlight Block 1 and press Cmd/Ctrl+Shift+Enter, then highlight Block 2 and
--      press Cmd/Ctrl+Shift+Enter! In Mission 6B, we wrap both blocks inside a CTE
--      (WITH name AS (...)) — think of a CTE as a temporary named worksheet!
-- =========================================================================

-- Block 1 (all_line_shifts): How many unique line-shifts ran in 60 days? (720 rows!)
SELECT DISTINCT operational_shift_date, shift_code, line_id
FROM stg_telemetry
ORDER BY 1, 2, 3;

-- Block 2 (shift_stops): Which line-shifts had an unplanned breakdown? (210 rows!)
SELECT operational_shift_date, shift_code, line_code,
       SUM(downtime_min) AS unplanned_min
FROM stg_stoppages
WHERE stoppage_type = 'Unplanned'
GROUP BY operational_shift_date, shift_code, line_code
ORDER BY 1, 2, 3;

-- =========================================================================
-- MISSION 6B (CTE + LEFT JOIN + COALESCE + % Clean Shifts!)
-- Business Goal: Combine Block 1 (720 scheduled shifts) and Block 2 (210 shifts
--                with stoppages) using a WITH (CTE) + LEFT JOIN so clean shifts
--                are NOT erased, and compute pct_clean_shifts!
-- Tip: You can still highlight either inner SELECT inside WITH and press Cmd/Ctrl+Shift+Enter!
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
-- LIVE CLASSROOM POLL (DEMO — STOP & VOTE BEFORE RUNNING!):
-- Business Danger: What happens if someone skips Dimensional Modeling and
--                  naively JOINs 15-min stg_telemetry (23,000 rows) directly
--                  to stg_stoppages? (Remember: true unplanned downtime = 22,260 min!)
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
-- GOLD BUILD 1 (DEMO — Run me!): Create Your First Dimension (Dim_Line)
-- Business Goal: Turn your repaired schema.dbml into physical Gold Dimension
--                tables with clean integer Surrogate Keys (1, 2, 3, 4).
-- After running, click Refresh on the left Database Explorer -> see Dim_Line!
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
-- GOLD BUILD 2 (Fill in the blanks ___): Create Dim_Shift & Dim_Format
-- Business Goal: Materialize the Shift (480 min) and Bottle Format Dimensions
--                matching your schema.dbml blueprint.
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
-- GOLD BUILD 3 (Fill in the 2 blanks ___): Create 60-Day Dim_Date
-- Business Goal: Build one conformed Calendar Dimension shared across BOTH
--                production and breakdowns, with ready-made is_weekend/quarter flags!
-- Why integer YYYYMMDD (20261001)? Human-readable, naturally sortable, fast 4-byte
-- joins, zero timezone/locale drift, and supports Unknown/TBD sentinel keys without NULL!
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
-- SPEED SPRINT #1: Which Packaging Material Suffers the Worst Reject Rate?
-- Business Goal: Starting from our 3 Bottle Formats (Dim_Format), compute
--                total bottled units, rejected units, and reject_rate_pct!
--
-- Notice TWO modeling lessons here:
--  1. We put FROM Dim_Format FIRST — matching our business question ("Start with
--     our formats, then pull their production stats via LEFT JOIN!").
--  2. Why join on f.format_code instead of f.format_key today? Because stg_telemetry
--     is still a SILVER table (it only knows the ERP code 'GLASS_075'). Next week
--     in Lab 06, we run this lookup ONCE to store integer format_key inside
--     Fact_Shift_Production — after that, every Gold query joins purely on integers!
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
-- SPEED SPRINT #2 & #3: Weekend Output (Starting from Dim_Date!) & Tech Load
-- Business Goal (#2): Does bottling volume drop on weekends? Start FROM Dim_Date
--                     to compare average daily bottles on Weekends vs Weekdays!
-- Business Goal (#3): Which technician_team carries the heaviest unplanned load?
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

-- Sprint #3 (Highlight & press Cmd/Ctrl+Shift+Enter to run!):
SELECT technician_team,
       COUNT(*)          AS stoppages,
       SUM(downtime_min) AS total_min
FROM stg_stoppages
WHERE stoppage_type = '___'
GROUP BY ___
ORDER BY total_min DESC;
