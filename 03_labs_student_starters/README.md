# Student Laboratory Starters (Labs 01–10 · 30 Hours)

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Semester:** Winter 2026/2027 (IFE, Lodz University of Technology)  
**Tracks:** 10 × 3-Hour Hands-On Engineering Labs supporting both **EN** and **FR** cohorts

Each lab directory provides **both English (`EN`) and French (`FR`) tracks** across all 10 labs (`Labs 01–10`):
- **Student Starter Notebooks (`.ipynb` EN & `_fr.ipynb` FR)** with `# TODO` engineering challenges.
- **Executed Solution Notebooks (`_solution.ipynb` EN & `_solution_fr.ipynb` FR)** (for instructor reference and post-lab review; excluded from early student release builds).
- **Tutor Instructions & 3-Hour Session Agendas (`tutor_instructions_and_agenda.md` EN & `tutor_instructions_and_agenda_fr.md` FR)** for all Labs 01–10.

All guided Labs 02–10 run on the neutral **Case 0 (`case0_europack_bottling` — EuroPack Beverage Bottling)** teaching dataset so every student learns the complete Lakehouse & BI pipeline fairly without leaking solutions for any of the 3 graded squad project cases (**Case 1 SmartPress**, **Case 2 DataCo**, **Case 3 Nexis**). Read the full Case 0 business brief before starting Lab 02:
- **English Case 0 Description:** [`case_00_europack_bottling_en.md`](case_00_europack_bottling_en.md)
- **Description du Cas 0 (Français) :** [`case_00_europack_bottling_fr.md`](case_00_europack_bottling_fr.md)

All lab code reads inputs dynamically from `lab_02_bronze_ingestion_and_profiling/data/` (student repo) or `05_case_studies_reference_solutions/` (instructor repo) and writes practice deliverables cleanly into `sandbox_outputs/case0_europack_bottling/` so reference datasets are never overwritten.

## 10-Lab Curriculum Schedule

| Lab | Dates (EN / FR) | Directory | Primary Engineering Milestone |
| :---: | :---: | :--- | :--- |
| **Lab 01** | `04.11 / 03.11` | [`lab_01_python_and_tooling_primer/`](lab_01_python_and_tooling_primer/tutor_instructions_and_agenda.md) | `.venv`, Git/VS Code, Jupyter Kernel, Python Syntax & *Restart Kernel and Run All* rule |
| **Lab 02** | `16.11 / 16.11` | [`lab_02_bronze_ingestion_and_profiling/`](lab_02_bronze_ingestion_and_profiling/tutor_instructions_and_agenda.md) | Multi-format Raw → Bronze ingestion (**CSV + JSON + XLSX** on Case 0 + Case 3 nested JSON drill), audit columns & Snappy Parquet |
| **Lab 03** | `23.11 (PM, after Tutorial #2) / 24.11` | [`lab_03_silver_cleaning_part1/`](lab_03_silver_cleaning_part1/tutor_instructions_and_agenda.md) | Apache Parquet internals (`PAR1`, footer stats, Pushdown), Bronze DQ Scorecard, string/alias hygiene, strict Silver typing, `keep='last'` dedup & `S3 (ts-6h)` night shift attribution |
| **Lab 04** | `26.11 / 27.11` | [`lab_04_silver_quality_and_integration/`](lab_04_silver_quality_and_integration/tutor_instructions_and_agenda.md) | Tukey IQR vs 3-Sigma, **DAMA Quarantine (`quarantine_errors.parquet`)**, `.interpolate(method='time')`, Privacy PII Gate, safe `many_to_one` joins & **`480.0 min` shift Fan-Out Trap** |
| **Lab 05** | `27.11 / 30.11` | [`lab_05_gold_duckdb_modeling/`](lab_05_gold_duckdb_modeling/tutor_instructions_and_agenda.md) | Kimball 4-Step Grain Matrix, `schema.dbml`, 60-day DuckDB Dimensions & Facts + FK integrity & Lab 04 reconciliation |
| **Lab 06** | `30.11 / 01.12` | [`lab_06_kpi_analytical_views/`](lab_06_kpi_analytical_views/tutor_instructions_and_agenda.md) | OLAP windows (`LAG`, 7d rolling, `ROLLUP`), anti-fan-trap CTEs, volume-weighted OEE/MTBF/MTTR SQL views (Insights 0A & 0B) |
| **Lab 07** | `08.12 / 08.12` | [`lab_07_visual_analytics_and_bi_serving/`](lab_07_visual_analytics_and_bi_serving/tutor_instructions_and_agenda.md) | IBCS/Tufte Plotly Express prototypes (7d OEE, Horizontal Pareto, Valve-Wear envelope) & BI Parquet serving export |
| **Lab 08** | `15.12 / 15.12` | [`lab_08_dual_track_cockpit_part1/`](lab_08_dual_track_cockpit_part1/tutor_instructions_and_agenda.md) | **Dual-Track Streamlit Cockpit Part 1 (pre-break):** `@st.cache_*`, COO vs Maintenance tabs, weighted KPI cards & core charts (`dashboard_app_v1.py`) |
| **Lab 09** | `12.01 / 12.01` | [`lab_09_dual_track_cockpit_part2/`](lab_09_dual_track_cockpit_part2/tutor_instructions_and_agenda.md) | **Dual-Track Streamlit Cockpit Part 2 (pre-Dry Run):** Live Date Range & Line filters, empty-slice guards, 60s Crisis Drill & Tab 3 Quarantine + 0-PII Monitor (`dashboard_app.py`) |
| **Lab 10** | `19.01 / 19.01` | [`lab_10_technical_signoff_and_code_freeze/`](lab_10_technical_signoff_and_code_freeze/tutor_instructions_and_agenda.md) | Golden KPI reconciliation, automated PII privacy scan & pre-defense Code Freeze (`signoff_report.json`) |

## Quick Regeneration (Instructors)
```bash
python 02_data_generator/generate_lab_notebooks.py
```
