# Student Laboratory Starters (Labs 01–10 · 30 Hours)

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Semester:** Winter 2026/2027 (IFE, Lodz University of Technology)  
**Tracks:** 10 × 3-Hour Hands-On Engineering Labs supporting both **EN** and **FR** cohorts

Each lab directory provides **both English (`EN`) and French (`FR`) tracks** across all 10 labs (`Labs 01–10`):
- **Student Starter Notebooks (`.ipynb` EN & `_fr.ipynb` FR)** with `# TODO` engineering challenges.
- **Executed Solution Notebooks (`_solution.ipynb` EN & `_solution_fr.ipynb` FR)** (for instructor reference and post-lab review; excluded from early student release builds).
- **Tutor Instructions & 3-Hour Session Agendas (`tutor_instructions_and_agenda.md` EN & `tutor_instructions_and_agenda_fr.md` FR)** for all Labs 01–10.

All lab code reads inputs dynamically from `lab_02_bronze_ingestion_and_profiling/data/` (student repo) or `05_case_studies_reference_solutions/` (instructor repo) and writes practice deliverables cleanly into `sandbox_outputs/<case_name>/` so reference datasets are never overwritten.

## 10-Lab Curriculum Schedule

| Lab | Dates (EN / FR) | Directory | Primary Engineering Milestone |
| :---: | :---: | :--- | :--- |
| **Lab 01** | `04.11 / 03.11` | [`lab_01_python_and_tooling_primer/`](lab_01_python_and_tooling_primer/tutor_instructions_and_agenda.md) | `.venv`, Git/VS Code, Jupyter Kernel, Python Syntax & *Restart Kernel and Run All* rule |
| **Lab 02** | `16.11 / 16.11` | [`lab_02_bronze_ingestion_and_profiling/`](lab_02_bronze_ingestion_and_profiling/tutor_instructions_and_agenda.md) | Multi-format Raw → Bronze ingestion (**CSV + JSON + XLSX**), audit columns, Snappy Parquet & initial DQ profiling |
| **Lab 03** | `23.11 (PM, after Tutorial #2) / 24.11` | [`lab_03_silver_cleaning_part1/`](lab_03_silver_cleaning_part1/tutor_instructions_and_agenda.md) | Architecture-as-Code (**Mermaid** lineage), `.str.strip().upper()`, alias mapping, UTC parsing, `S3 (ts-6h)` night shift attribution & dedup |
| **Lab 04** | `26.11 / 27.11` | [`lab_04_silver_cleaning_part2/`](lab_04_silver_cleaning_part2/tutor_instructions_and_agenda.md) | Tukey IQR vs 3-Sigma, **DAMA Quarantine (`quarantine_errors.parquet`)**, `.interpolate(method='time')` & RODO PII Gate |
| **Lab 05** | `27.11 / 30.11` | [`lab_05_silver_integration/`](lab_05_silver_integration/tutor_instructions_and_agenda.md) | 15m→1h resampling, `validate='many_to_one'` joins, resolving the **`480 min` shift-variant Fan-Out Trap** |
| **Lab 06** | `30.11 / 01.12` | [`lab_06_gold_duckdb_modeling/`](lab_06_gold_duckdb_modeling/tutor_instructions_and_agenda.md) | Kimball 4-Step Grain Matrix, `schema.dbml`, 60-day DuckDB Dimensions & Facts + FK integrity audit |
| **Lab 07** | `08.12 / 08.12` | [`lab_07_kpi_analytical_views/`](lab_07_kpi_analytical_views/tutor_instructions_and_agenda.md) | OLAP windows (`LAG`, 7d rolling), anti-fan-trap CTEs, volume-weighted OEE/MTBF/MTTR views |
| **Lab 08** | `15.12 / 15.12` | [`lab_08_visual_exploration_and_bi_connection/`](lab_08_visual_exploration_and_bi_connection/tutor_instructions_and_agenda.md) | IBCS/Tufte Plotly Express exploration & DuckDB/Parquet BI serving connectors |
| **Lab 09** | `12.01 / 12.01` | [`lab_09_dual_track_cockpit_workshop/`](lab_09_dual_track_cockpit_workshop/tutor_instructions_and_agenda.md) | Multi-page Dual-Track Streamlit Cockpit (`dashboard_app.py` for Perspective A vs B + Quarantine tab) |
| **Lab 10** | `19.01 / 19.01` | [`lab_10_technical_signoff_and_code_freeze/`](lab_10_technical_signoff_and_code_freeze/tutor_instructions_and_agenda.md) | Golden KPI reconciliation, automated RODO PII scan & pre-defense Code Freeze (`signoff_report.json`) |

## Quick Regeneration (Instructors)
```bash
python 02_data_generator/generate_lab_notebooks.py
```
