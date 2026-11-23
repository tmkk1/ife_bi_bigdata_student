# Team Project Charter Template

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Semester:** Winter 2026/2027 — Tutorial #1 Deliverable  
**Submission & Live Sign-Off:** Wednesday, 2 December 2026 at `16:00` *(In-Person — Tutorial #2)*  
**Purpose:** Formal contract between the project team and the Business Sponsor (*Data Owner*) — protects against **Scope Creep** and establishes clear **Acceptance Criteria** for the semester.

---

## Section 01 — Team Information

* **Team Name / Repository:** `[e.g., Team_1A_SmartPress]`
* **Selected Case Study:** `[SmartPress Automotive / DataCo Industrial (Supply Chain) / Nexis Workforce]`
* **Chosen Perspective:** `[Perspective A — Boardroom / Strategic  |  Perspective B — Shopfloor / Operational]`
* **Target Executive Sponsor Role:** `[e.g., COO / Head of Maintenance / VP Commercial / Logistics Director / HR Director / VP Operations]`
* **Paired Twin Team (Opposing Perspective):** `[Team name working on the same factory with the opposite perspective]`

### Team Roster & 5 Key Roles

| # | Full Name | Student ID | Assigned Project Role | Focus Area | GitHub Handle |
| :-: | :--- | :--- | :--- | :--- | :--- |
| 1 | `[Full Name]` | `[ID]` | **Project Leader & Business Translator** | Strategy | `@handle` |
| 2 | `[Full Name]` | `[ID]` | **Data Ingestion & Integration Lead** | Engineering | `@handle` |
| 3 | `[Full Name]` | `[ID]` | **Data Quality & Cleansing Lead** | Quality | `@handle` |
| 4 | `[Full Name]` | `[ID]` | **Data Warehouse Modeler** | Modeling | `@handle` |
| 5 | `[Full Name]` | `[ID]` | **BI Dashboard & UX Designer** | Visualization | `@handle` |

---

## Section 02 — Problem Statement

*Define the specific operational or financial pain afflicting your assigned factory that requires Business Intelligence intervention (3–5 sentences grounded in your Case Study dossier and initial Lab 02 Bronze observations).*

* **Core Operational Pain:**
  > `[Describe what is breaking or leaking money across the 60-day operating window, which departments/silos are affected, and why existing ERP exports or manual Excel reports fail to expose the root cause.]`
* **Where Value Is Lost in Porter's Value Chain:**
  > `[Name the specific Primary and/or Support Value Chain links — e.g., Operations & Technology Development (SmartPress), Outbound Logistics & Sales Margin (DataCo), or HRM & Operations (Nexis) — where margin is currently eroding.]`

---

## Section 03 — Business Objective

*Indicate clearly what leadership will be able to do **post-implementation** (using your **System of Insights**) that they physically cannot do today with traditional spreadsheets or raw transactional reports (**System of Record**).*

* **Executive Decision Unlocked by BI:**
  > `[Complete: "Thanks to our BI solution, the [Sponsor Role] will be able to make data-driven decisions to ... instead of relying on gut feel (HiPPO) or lagging global averages."]`
* **Expected Business Impact (Cost Leadership / Differentiation):**
  > `[Quantify the intended operational or financial improvement — e.g., closing the gap to >= 85% OEE, lifting OTIF to >= 92%, stopping negative-margin discounts, cutting unplanned downtime / 1.5x overtime burn, or raising L2+ certified shift coverage.]`

---

## Section 04 — Scope *(Protection Against Scope Creep)*

*Draw a hard boundary between what your team commits to deliver and what you are consciously excluding.*

### In-Scope *(What We WILL Deliver)*
* **Business Entities & Granularity:** `[e.g., 60-day operating window (2026-10-01 to 2026-11-29), specific presses / hubs / assembly lines, shifts S1/S2/S3]`
* **Analytical Views for Our Perspective (`A` or `B`):** `[List the 2–3 core management views or drill-downs your sponsor needs to answer their morning-coffee questions]`
* **Governance & Auditability:** `[e.g., Bronze-to-Silver cleansing rules, quarantine tracking for rejected records, reproducible DuckDB Star Schema powering a Streamlit dashboard]`

### Out-of-Scope *(What We Will Consciously EXCLUDE)*
* **Opposing Perspective Concerns:** `[Explicitly list metrics/views belonging to the paired A/B team that you will NOT build — e.g., raw 15-min sensor waveforms for COO, corporate margin tables for Maintenance, truck routing for VP Commercial, sales discount rules for Logistics]`
* **Excluded Data / Privacy Boundaries:** `[MANDATORY for Case 3 Nexis: physically drop all 5 PII/medical fields — first_name, last_name, corporate_email, national_id_masked, details_medical_note — keeping only anonymized employee_id. For Cases 1 & 2: exclude any personal operator/buyer names and out-of-window / phantom records.]`
* **Technical Non-Goals:** `[e.g., Real-time streaming ingestion, live ERP write-back, or unrequested predictive ML black boxes]`

---

## Section 05 — Target KPIs *(3–4 Primary Action Triggers)*

*Select **3 to 4 primary KPIs** to calculate in your warehouse and visualize on your dashboard. Remember the **Golden Rule**: if a KPI changes drastically and nobody takes action, it is informational noise—not a KPI.*

| # | KPI Name | Business Question Answered | Target / Alert Benchmark | Action Trigger *(What Decision Changes if It Turns Red?)* |
| :-: | :--- | :--- | :--- | :--- |
| 1 | `[e.g., Plant OEE % / Network OTIF % / Certified Staffing Coverage %]` | `[Specific managerial question]` | `[e.g., >= 85.0% / >= 92.0% / >= 95%]` | `[Concrete corrective action triggered by an alert]` |
| 2 | `[KPI 2]` | `[Specific managerial question]` | `[Target / threshold]` | `[Concrete corrective action]` |
| 3 | `[KPI 3]` | `[Specific managerial question]` | `[Target / threshold]` | `[Concrete corrective action]` |
| 4 | `[KPI 4 — optional]` | `[Specific managerial question]` | `[Target / threshold]` | `[Concrete corrective action]` |

---

## Section 06 — Key Risks *(Data Structure, Quality, Privacy & Team Collaboration)*

*Analyze concrete threats in your raw Bronze data structure/quality/privacy as well as internal team communication risks, and define how you will mitigate each one.*

| Risk Category | Specific Risk Identified | Impact *(H/M/L)* | Concrete Mitigation Plan & Role Owner |
| :--- | :--- | :-: | :--- |
| **Data Quality & Structure** | `[e.g., Dirty machine/carrier/contract text casing, duplicate rows, mixed ISO/EU dates, missing values, extreme outliers]` | `[High]` | `[e.g., Standardize keys, parse mixed dates safely, log rejected rows to quarantine — Owner: Data Quality & Cleansing Lead]` |
| **Grain / Modeling Trap** | `[e.g., Multi-variant shift fan-out (SmartPress), order-level freight/penalty double counting (DataCo), or S3 midnight shift splitting (SmartPress/Nexis)]` | `[High]` | `[e.g., Proportional planned-time / revenue pro-rata allocation and shift timestamp offset before joins — Owner: Data Warehouse Modeler]` |
| **Data Privacy & Governance** | `[e.g., PII & medical notes in Nexis Bronze files; undocumented business thresholds causing HiPPO disputes]` | `[High]` | `[e.g., Hard-drop all 5 PII columns before Silver/Gold (0-PII audit) & sign off clear DQR/KPI rules — Owner: Data Quality Lead & Project Leader]` |
| **Team Communication & Delivery** | `[e.g., Scope creep, uneven workload across the 5 roles, misalignment between Tutorial designs and Lab code]` | `[Med]` | `[e.g., Weekly sync before Labs/Tutorials, strict Git PR reviews, enforce Charter §4 boundaries — Owner: Project Leader]` |

---

## 🎤 Bonus Prep: 90-Second Boardroom Mini-Pitch Script *(For Tutorial #2 — Dec 2, 16:00)*

*Designated Speaker(s) (`1–2` team members):* `[Name(s)]`

1. **Identity & Perspective:** `"We are Team [X]. We are analyzing the [SmartPress / DataCo / Nexis Workforce] factory from the perspective of [Sponsor Role]."`
2. **Operational Problem:** `"Our main operational problem is [concise business pain]."`
3. **BI Decision & Solution:** `"Thanks to our BI solution, the board will be able to make the key decision to: [specific executive action]."`
4. **Success Metrics (KPIs):** `"We will measure success with specific indicators: [3–4 KPIs & targets]."`

---

## ✍️ Acceptance Criteria & Formal Sign-Off

By signing this Project Charter, all five team members commit to the agreed scope boundaries, transparent role ownership, strict data quality and privacy standards, and delivery of the BI solution aligned with the course milestones. Signing closes the scope negotiation phase.

**Team Signatures:**  
1. `__________________________` *(Project Leader & Business Translator)*  
2. `__________________________` *(Data Ingestion & Integration Lead)*  
3. `__________________________` *(Data Quality & Cleansing Lead)*  
4. `__________________________` *(Data Warehouse Modeler)*  
5. `__________________________` *(BI Dashboard & UX Designer)*  

**Business Sponsor / Instructor Sign-Off:** `__________________________` *(Karolina Stogidis — Date: `2026-12-02`)*
