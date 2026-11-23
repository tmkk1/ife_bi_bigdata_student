# Case Study 03: Nexis Precision Automotive Components
## Workforce Planning, Fatigue Analysis & Factory Staffing Costs

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Target Milestone:** Workshop #1 — Project Charter & Goal Setting  
**Language:** English (`EN`)

---

## 1. Company & Industry Context

### 1.1 Precision Assembly & Why People Matter
Nexis builds high-precision electromechanical car parts (solenoid valves, ABS brake actuators, and electronic sensors). On these lines, speed and quality depend directly on **worker station certifications (`Level 2+` / `Level 3`)**, steady hands, and focus across 24/7 three-shift production. When uncertified or overtired workers run a line, defective parts (**scrap**), rework, and customer delays rise quickly.

### 1.2 Company Profile: Nexis Precision Automotive Components
Located in **Wrocław, Poland**, **Nexis** runs four continuous assembly lines (`LINE_01`..`LINE_04`) with **165 active workers**: **115 permanent** employees and **50 temporary agency** workers across three shifts (**`S1` Morning, `S2` Afternoon, `S3` Night**).

---

## 2. Main Business Problems

Over the **60-day period**, management relies on guesses instead of clear data, making costs, absences, and scrap worse:
1. **Wrong Overtime Cost Tracking:** Existing reports multiply all worked hours by the base hourly wage. They ignore the **`1.5x` overtime pay rate**, so leaders do not see the true payroll cost or how many full-time workers (**FTEs**) are actually missing.
2. **Temporary Agency Turnover & the €250 Quality Bonus:** Nexis pays a **€250 Monthly Quality Bonus** only to workers who keep their personal defect rate `<= 1.80%` and attend regularly. Are uncertified temporary agency workers really cheaper per good part once high turnover (churn) and defect scrap are included—and is bonus access fair?
3. **Overtime Fatigue & Sick Leave (Bradford Factor $B = S^2 \times D$):** Do heavy overtime hours increase sick leave and worker defect rates? To measure this accurately:
   * Group consecutive sick days into single sick episodes (**Bradford Factor $B = S^2 \times D$**, where $S$ = number of separate sick episodes and $D$ = total sick days; `>= 400` Critical, `>= 150` High).
   * Check overtime only in the 7 days **before** each shift (`[d-7, d-1]`, `prior_7d_ot_hours >= 8h`)—never look ahead into future days!
4. **Blaming Night Shift (`S3`) vs. Real Line Bottlenecks:** Plant staff commonly blame Night Shift (`S3`) for all scrap problems. Does the data actually point to `S3`, or is a specific **Morning Shift (`S1`) assembly line** short on certified (`L2+`) workers and producing heavy scrap?

---

## 3. Two Executive Perspectives (Track A vs. Track B)

### 🅰️ Perspective A: European HR Director (*Turnover, Fatigue & Bonus Fairness*)
* **Main Goal:** Compare Permanent vs. Temporary Agency turnover (churn), check €250 Quality Bonus (`<= 1.80%` scrap) qualification fairness, measure how heavy overtime (`prior_7d_ot >= 8h`) leads to sick leave, spot high **Bradford Factor ($B = S^2 \times D$)** cases, and keep worker data anonymous in analytical tables (using `employee_id` only).
* **Out of Scope (Does NOT Want):** Machine motor diagnostics or customer sales pricing tables.

### 🅱️ Perspective B: VP of Manufacturing Operations (*Line Coverage, Scrap & Staffing Costs*)
* **Main Goal:** Measure **`Line × Shift` L2+ Certified Staffing Coverage %**, connect under-certification and worker fatigue to scrap losses (€), audit true **`1.5x OT`** labor cost, and calculate **Dynamic Implied Missing Monthly FTEs** that update live when date filters change (never hardcode hiring numbers!).
* **Out of Scope (Does NOT Want):** Private worker names, emails, or personal medical notes.

---

## 4. Available 60-Day Data (`data/bronze/`)

The simulation covers **60 continuous 24/7 days** (`2026-10-01` – `2026-11-29`; `4` lines × `3` shifts = **`720` line-shifts**, `165` badged workers):

1. **`shift_production_performance.csv` (MES Production Output, `720` rows):** `shift_date`, `shift_code`, `assembly_line_id`, `line_name`, `product_category`, `planned_headcount`, `planned_certified_l2_plus`, `present_certified_l2_plus`, `headcount_coverage_pct`, `certified_staffing_coverage_pct`, `target_output_units`, `actual_produced_units`, `good_units`, `scrap_defect_units`, `rework_units`, `scrap_cost_eur`, `line_stoppage_min`, `operator_headcount_present`, `agency_worker_count`, `agency_staffing_ratio_pct`.
   * *Important Note (`spot_fill` Workers):* On `268/720` line-shifts, `operator_headcount_present` includes extra temporary `spot_fill` workers who do not have personal badges. Meanwhile, `workforce_events.json` only tracks badged events for the `165` rostered workers (`EMP-101..EMP-265`, plus test error `EMP-GHOST-*`).
2. **`workforce_events.json` (Badge, QA, Overtime & Sick Events, 25,585 events):** Top-level keys (`event_id`, `timestamp`, `employee_id`, `event_type` [`SHIFT_CLOCK_IN`, `SHIFT_CLOCK_OUT`, `STATION_CHECK_IN`, `INDIVIDUAL_QA_AUDIT`, `OVERTIME_AUTHORIZED`, `ABSENCE_UNPLANNED_SICK`], `assembly_line_id`, `shift_code`, `badge_reader_id`) plus a nested **`details`** JSON object (`approved_overtime_hours`, `total_shift_hours`, `units_inspected`, `defect_count`, `medical_note`, etc.). Flattening with `pd.json_normalize(raw, sep="_")` creates `details_*` columns—including **`details_medical_note`**.
   * *Privacy & Data Cleaning Rules:*
     * **Drop private medical text:** Remove **`details_medical_note`** before saving Silver or Gold tables.
     * **Quarantine bad events:** Catch fake badges (`EMP-GHOST-*`), wrong future dates (`2099-*`), impossible shift/OT hours (`145.0h`, `-3.5h`, `22.0h` single-shift OT), and double turnstile scans (`< 60s`).
     * **Fix midnight shifts:** Align `S3` cross-midnight scans (`20:00–08:00`) using shift offsets (`S1: -2h, S2: -3h, S3: -9h`).
3. **`workforce_roster_and_skills.xlsx` (HR Master Workbook, 4 Sheets):**
   * `Employees`: Pseudonym **`employee_id`** (`EMP-101..EMP-265`), `hourly_base_wage_eur`, `overtime_rate_multiplier` (`1.5`), `churn_status`.
     * **Drop personal columns before Silver/Gold:** Physically remove **`first_name`**, **`last_name`**, **`corporate_email`**, and **`national_id_masked`** so only `employee_id` remains!
     * **Standardize text:** Clean messy `contract_type` values (`'temp_agency'`, `'Temporary_Agency '`) and fill blank `agency_partner` cells with `'Brak danych / Direct'` *(Polish for "No data / Direct")*.
   * `Skill_Matrix`, `Incentive_Policies` (`max_station_scrap_pct = 1.80`, `monthly_bonus_eur = 250.0`), `Shift_Staffing_Plan`.

---

## 5. What to Deliver in Workshop #1
Complete [`project_charter_template.md`](project_charter_template.md) with:
1. Your assigned Perspective (**A** or **B**);
2. Your data quality & privacy cleaning plan (dropping the 5 personal/medical fields `first_name`, `last_name`, `corporate_email`, `national_id_masked`, `details_medical_note` and quarantining bad badge logs in `Data Quality Gate 1` / `Proces DQ Gate 1`);
3. Your **Gartner ITScore** check (`As-Is` vs `To-Be`);
4. **3 measurable SMART-BI questions**.
