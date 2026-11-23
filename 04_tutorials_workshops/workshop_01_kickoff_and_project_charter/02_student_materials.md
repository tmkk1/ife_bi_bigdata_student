# Workshop 01 Student Materials: From Factory Floor Pains to Business Intelligence Strategy

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Session:** Tutorial #1 — Kickoff, Industrial BI Strategy & Project Charter (`Wed, 25 Nov 2026`, `16:15 – 18:30`, Online)  
**Presentation Deck:** [`Business Intelligence and Big Data Analysis - Tutorials #1.pdf`](Business%20Intelligence%20and%20Big%20Data%20Analysis%20-%20Tutorials%20%231.pdf)  
**Template to Complete:** [`project_charter_template.md`](project_charter_template.md)  
**Submission & Live Pitch Deadline:** **Wednesday, 2 December 2026 at 16:00 (In-Person — Tutorial #2)**

---

## 1. Course Structure & Your Mission

This semester simulates a real enterprise BI project split into two parallel, complementary tracks:

* **IT & Data Labs (*Tomasz Kołodziejczyk*):** Technical implementation — Python, Pandas data cleaning, DuckDB local data warehouses, and SQL optimization.
* **Business & Architecture Tutorials (*Karolina Stogidis*):** Strategic design — factory director perspective, process & data modeling, data governance, managerial dashboard ergonomics, and business defense.
* **Golden Rule:** *No coding in tutorials — here we design strategic solutions to be implemented in code during labs.* Remember: **data itself does not make decisions; people make decisions based on what they can read from it.**

### Your Step-by-Step Kickoff Mission
1. **Form your 5-person project team** and lock in your assigned **Case Study** (`SmartPress`, `DataCo`, or `Nexis`) and **Perspective** (`A` or `B`).
2. **Read your official Case Study Dossier (`EN` or `FR`):**
   * **Case #1 (`SmartPress Automotive`):** [`case_01_smartpress_automotive_en.md`](case_01_smartpress_automotive_en.md) | [`case_01_smartpress_automotive_fr.md`](case_01_smartpress_automotive_fr.md)
   * **Case #2 (`DataCo Industrial / Supply Chain`):** [`case_02_dataco_supply_chain_en.md`](case_02_dataco_supply_chain_en.md) | [`case_02_dataco_supply_chain_fr.md`](case_02_dataco_supply_chain_fr.md)
   * **Case #3 (`Nexis Workforce`):** [`case_03_nexis_workforce_en.md`](case_03_nexis_workforce_en.md) | [`case_03_nexis_workforce_fr.md`](case_03_nexis_workforce_fr.md)
3. **Assign the 5 Key Project Roles** inside your team (Section 3 below).
4. **Complete all 6 sections of [`project_charter_template.md`](project_charter_template.md)** and rehearse your **90-second Boardroom Mini-Pitch** for **Wednesday, 2 December 2026 (16:00)**.

---

## 2. Core Strategic Frameworks from Tutorial #1

### 2.1 Why a €2M SAP System Isn't Enough: Three Classes of Systems
Physical automation and ERP billing do not replace managerial intelligence. Every modern enterprise relies on three distinct layers:

| Layer | Role in the Enterprise | Industrial Examples |
| :--- | :--- | :--- |
| **01. Systems of Engagement** | Front-line interfaces connecting people and customers to the enterprise. | Storefront, CRM (Salesforce), Front-Office Portals, HR Self-Service |
| **02. Systems of Record** | Transactional backbones that reliably record *what happened*. | **SAP ERP / Financials**, SCADA Telemetry, CMMS (Maintenance), WMS (Warehouse), RCP Time Clocks |
| **03. Systems of Insights *(BI Lives Here!)*** | Analytical layer integrating silos to diagnose bottlenecks and guide decisions. | **Business Intelligence (BI)**, Executive Dashboards, Decision Support Systems, Predictive Analytics |

### 2.2 Building a Data-Driven Enterprise: The 4 Pillars & Beware of the HiPPO
> *"Organizations do not need a data strategy. They need a business strategy that incorporates data."*

Watch out for the **HiPPO** (*Highest Paid Person's Opinion*) — making critical factory decisions by hierarchy, loud opinions, or habits instead of verified evidence. Value only appears at the intersection of all **4 Pillars**:
1. **Business Goal** *(Strategic target & ROI)* — without Tech/Team, it stays a **PowerPoint**.
2. **Data** *(Telemetry & accuracy)* — without a Business Goal, it produces **Zero Impact**.
3. **Team** *(Culture & skills)* — without Tech, it collapses into **Excel Chaos**.
4. **Technology** *(ERP, BI & infrastructure)* — without Goal/Data, it ends as a **Tech PoC**.

### 2.3 Porter's Value Chain, 6 Factory Functions & Three Truths of BI
Breaking a factory into **Primary Activities** (*Inbound Logistics, Operations, Outbound Logistics, Marketing & Sales, Service*) and **Support Activities** (*Firm Infrastructure, HRM, Technology Development, Procurement*) shows how every department feeds **MARGIN** (`Value Delivered − Total Cost`) via **Cost Leadership** or **Differentiation**:

* **Case 1 (`SmartPress Automotive`):** Targets *Operations*, *Technology Development (OT/IT SCADA)*, and *Firm Infrastructure*.
* **Case 2 (`DataCo Supply Chain`):** Targets *Outbound Logistics*, *Marketing & Sales*, *Procurement (3PL Freight)*, and *Firm Infrastructure*.
* **Case 3 (`Nexis Workforce`):** Targets *Human Resource Management (HRM)*, *Operations (Precision Assembly)*, and *Firm Infrastructure (0-PII Governance)*.

Across the **6 core functions** (*Production & Operations, Maintenance & Reliability, Logistics & Warehouse, Quality Control, Finance & Controlling, Workforce & HR*), remember the **Three Truths of BI**:
1. **Prioritization:** No factory can monitor 50 KPIs at once — focus ruthlessly on the primary bottleneck (3–4 KPIs).
2. **Information Silos:** The biggest financial losses occur at the intersections *between* departments blaming each other.
3. **Managerial Simulation:** Throughout this semester, you act as boardroom decision-makers solving real industrial trade-offs.

### 2.4 From Raw Data to Action-Trigger KPIs
A **Dry Report** (*"Yesterday 14 operators took sick leave, and 5 worked 12 hours"*) provides no context and forces no action — it is **informational noise**. A **Synthetic KPI** (*"Overtime Ratio = 18% & Absence Rate = 9.2%"*) delivers an immediate **Action Signal**.

> [!IMPORTANT]
> **The Golden Rule of Action Triggers:** If a metric changes drastically and nobody in the organization acts, it is **not a KPI** — it is just informational noise.

#### Factory Metrics Matrix (Reference Across 6 Functions)
| Function | Representative Industrial KPIs |
| :--- | :--- |
| **Production** | `OEE` (Overall Equipment Effectiveness), `PPC` (Realized Volume vs. Plan), Machine Changeover Time |
| **Maintenance** | `MTBF` (Mean Time Between Failures), `MTTR` (Mean Time To Repair), Cost of Unplanned Downtime (EUR) |
| **Logistics** | `OTIF %` (On-Time In-Full Deliveries), Lead Time Variance |
| **Quality** | `Scrap Rate %` (Production Defect Rate), `COPQ` (Cost of Poor Quality) |
| **Finance** | `Net Operating Margin %`, Margin Erosion (uncontrolled discounts) |
| **Workforce / HR** | `Absenteeism Rate %`, `Overtime Ratio %`, `Staffing Coverage %`, Total Overtime Cost (EUR) |

---

## 3. Team Roles & Dual-Track Scope Boundaries

### 3.1 Five Key Project Roles (1 Accountable Owner per Role)
Distribute these exact 5 roles inside your team and record them in **Section 1** of your Project Charter:

| Role | Focus Area | Core Responsibilities |
| :--- | :--- | :--- |
| **1. Project Leader & Business Translator** | *Strategy* | Guards the business goal; owns the Project Charter, stakeholder communication, and final presentation narrative. |
| **2. Data Ingestion & Integration Lead** | *Engineering* | Connects raw source files (`CSV`, `JSON`, `XLSX`), handles extraction, and builds the ingestion pipeline. |
| **3. Data Quality & Cleansing Lead** | *Quality* | Cleans data in the Silver layer, detects anomalies (e.g., `3σ` or `IQR`, dirty keys, outliers), and enforces privacy/0-PII rules. |
| **4. Data Warehouse Modeler** | *Modeling* | Designs the dimensional star schema, builds the physical model in DuckDB, and optimizes analytical SQL queries. |
| **5. BI Dashboard & UX Designer** | *Visualization* | Designs wireframes/mockups, interactive filters, visual hierarchy, and final ergonomics of the managerial dashboard. |

### 3.2 Dual-Track Principle: Same Data, Two Perspectives!
Each factory is assigned to **two twin teams** working on the exact same raw files from opposing decision-making lenses. Respect your lane and list the opposing track's concerns under **Out-of-Scope (§4)**:

| Case Study | Perspective A — Boardroom / Strategic *(Macro)* | Perspective B — Shopfloor / Operational *(Micro)* |
| :--- | :--- | :--- |
| **1. SmartPress Automotive** | **COO:** Plant `OEE %` vs. `85%` target, Availability / Performance / Quality breakdown, shift & steel-variant economics, total downtime + scrap cost (EUR). *(Excludes raw 15-min sensor waveforms & technician repair logs).* | **Head of Maintenance:** Unplanned breakdown count, `MTTR <= 60 min`, `MTBF`, failure-mode Pareto, and preventive `tool_wear_min` / temperature / torque limits. *(Excludes corporate financial margin tables).* |
| **2. DataCo Industrial** | **VP Commercial & Pricing Control:** True Net Operating Margin after COGS, pro-rated freight & SLA penalties; discount erosion; unprofitable `Segment × Category` combinations. *(Excludes test-bench queues & truck gate scans).* | **Director of Supply Chain & Logistics:** Network `OTIF >= 92%`, On-Time vs. In-Full split, `warehouse_dwell_hours` at hubs/test bays, 3PL carrier performance & SLA penalties. *(Excludes sales rep commissions & commercial discount grids).* |
| **3. Nexis Workforce** | **European HR Director:** Permanent vs. Temporary Agency turnover (churn), €250 Quality Bonus fairness (`<= 1.80%` scrap), post-OT sick lag (`prior_7d_ot >= 8h`), Bradford Factor (`B = S² × D`), **strict 0-PII** (`employee_id` only). *(Excludes machine diagnostics & sales pricing).* | **VP of Manufacturing Operations:** `Line × Shift` L2+ certified staffing coverage %, fatigue/under-certification scrap losses (EUR), true `1.5×` overtime payroll audit, dynamic missing FTE sizing. *(Excludes private names, emails & medical notes).* |

> [!WARNING]
> **Mandatory Privacy Guardrail (Case 3 — Nexis Workforce):** Raw Bronze HR & event files intentionally include `first_name`, `last_name`, `corporate_email`, `national_id_masked`, and `details_medical_note`. Flag all 5 fields as **Out-of-Scope (§4)** and a **Key Privacy Risk (§6)** in your Charter — they must be physically dropped before Silver/Gold so only anonymized `employee_id` remains.

---

## 4. Completing Your 6-Section Project Charter

Your **Project Charter** is your formal contract with the business sponsor (*Data Owner*). It serves three corporate functions:
1. **A Formal Contract with the Business** — aligns the implementation team and sponsor before work starts.
2. **Protection Against Scope Creep** — stops unplanned feature requests from derailing the semester.
3. **Acceptance Criteria & Closing Negotiations** — defines upfront what project success looks like.

Complete all **6 sections** in [`project_charter_template.md`](project_charter_template.md):
1. **Team Information:** Team name, Case Study, Perspective (`A` or `B`), and all 5 assigned roles.
2. **Problem Statement:** Precise operational/financial pain hurting your factory.
3. **Business Objective:** What leadership can decide post-implementation that Excel cannot support today.
4. **Scope:** Clear **In-Scope** vs. **Out-of-Scope** boundaries (including PII exclusions where applicable).
5. **Target KPIs:** **3–4 primary KPIs** with clear **Action Triggers** (not informational noise!).
6. **Key Risks:** Concrete threats in **data structure, quality & privacy** (e.g., duplicate records, mixed dates, midnight shift splits, fan-out double counting, PII) and **internal team communication**, each with a mitigation plan.

---

## 5. Preparing Your 90-Second Boardroom Mini-Pitch (Due Dec 2, 16:00)

At the start of **Tutorial #2 (Wed, 2 December 2026, In-Person)**, each team has **strictly 90 seconds** (timed!) with **1–2 speakers** to convince the instructor (acting as Business Sponsor) to sign off your Project Charter. Follow this exact 4-part structure:

1. **Identity & Perspective (`~15s`):** *"We are Team [X]. We are analyzing the [SmartPress / DataCo / Nexis Workforce] factory from the perspective of [e.g., COO / Head of Maintenance / HR Director]."*
2. **Operational Problem (`~25s`):** *"Our main operational problem is [defined business pain, e.g., uncontrolled 1.5× overtime costs driven by sudden absences and uncertified shift gaps]."*
3. **BI Decision & Solution (`~25s`):** *"Thanks to our BI solution, the board will be able to make the key decision to: [specific managerial intervention unlocked by BI]."*
4. **Success Metrics / KPIs (`~25s`):** *"We will measure success with specific indicators: [your 3–4 target KPIs and benchmarks]."*
