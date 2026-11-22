# Course: Business Intelligence and Big Data Analysis (`01 31 0367 00`)

## Academic & Technical Synthesis — Lecture 03: Data Quality Engineering & Source-System Governance

**Language:** English (`EN`)  
**Instructor:** Tomasz Kołodziejczyk (IFE, 2026)  
**Audience:** 4th Year B.Sc. Engineering (Management and Production Engineering)  
**Data Pipeline Context (Medallion Architecture):** `1. Source Data` → `2. Bronze Layer` → **`3. Silver Layer`** → `4. Gold Layer` → `5. BI & Analytics`

---

## 1. Why Data Quality Matters: Real-World System Failures

### 1.1 Case Study: NASA Mars Climate Orbiter Loss (\$125M)
* **Failure Type:** System Integration Failure
* **Unit Defect:** Lockheed Martin software output thruster impulse in Imperial units ($\text{lbf}\cdot\text{s}$), while NASA navigation expected Metric units ($\text{N}\cdot\text{s}$).
* **Trajectory Error:** The calculation mismatch caused the spacecraft to enter the Martian atmosphere $100\text{ km}$ lower than planned (`57 km` actual vs. `226 km` planned at `TCM-4`).
* **Catastrophic Outcome:** The probe encountered extreme atmospheric friction and disintegrated completely, resulting in a **\$125M** capital loss.

> **Core Engineering Lesson:** *"Numbers without strict metadata and interface contracts are deadly in engineering systems."*

### 1.2 Case Study: Excel Row Limit — Silent Data Truncation (`65,536`)
* **System Failure Analysis (2020):** An automated public health pipeline ingested CSV lab results into outdated `.xls` templates using the legacy Excel 97–2003 format. This legacy file format has a strict, hard technical limit of **65,536 rows** per worksheet.
* **Public Health Impact:** Consequently, **15,841 positive COVID-19 cases** were silently dropped at the threshold, severely stalling contact tracing for days.

> **Primary System Engineering Takeaway:** *"Choose the appropriate file formats for automated data pipelines."*

### 1.3 Case Study: Ghost Inventory Crisis (MES Failure)
* **System Discrepancy Analysis (Digital Record vs. Physical Reality):** Night-shift operators skipped logging scrap parts in the Manufacturing Execution System (MES) to protect shift bonuses. This operational workaround created a critical discrepancy between ERP system records and physical warehouse stock:
  * **ERP System (Digital):** `12,000 Pcs Ready` logged as available in warehouse (`COMP-4500`, `WH-B-42`).
  * **Physical Warehouse:** `0 Brackets` — physical shelves completely empty.
* **Process Impact:** Unreported scrap accumulated silently over multiple shifts. When the customer's assembly line requested fulfillment, zero physical units were available, triggering an immediate shutdown.
* **Business Consequence:** **€150,000** contractual penalty and **4 hours** of car assembly line downtime.

---

## 2. The Industrial Mindset & The 1-10-100 Rule

### 2.1 Data Engineering Mirrors Physical Manufacturing

```text
PHYSICAL FACTORY FLOOR:
[ Raw Material ] ──► [ Stamping & Welding ] ──► [ Quality Control ] ──► [ Finished Car ]
       │                       │                        │                      │
       ▼                       ▼                        ▼                      ▼
[ Raw Signals  ] ──► [ Ingestion & Modeling ] ──► [ Quality Gates ] ──► [ Executive Decisions ]
ENTERPRISE DATA FACTORY
```

> **Core Pipeline Mindset — Zero Defect Tolerance:** *"A defect in data is just as destructive as a physical crack in a brake disc."*

### 2.2 The 1-10-100 Rule: Escalating Cost of Poor Data Quality
The **1-10-100 Rule** illustrates how the financial impact of bad data multiplies exponentially as it moves downstream. Preventing bad input at origin costs a fraction of cleaning it in data pipelines—and a sliver of the disastrous capital misallocations caused by corrupted executive reporting.

| Stage | Relative Cost | Architecture Layer | Mechanism & Consequence |
| :--- | :--- | :--- | :--- |
| **1. Prevention at Source** | **\$1** | `ERP / MES / PLC` | Block bad input at the source when the operator or sensor creates the record. |
| **2. Warehouse Patching** | **\$10** | `Silver Layer` | Data engineers write complex Python or SQL scripts to clean and guess missing values. |
| **3. Boardroom Failure** | **\$100** | `Gold or BI Layer` | Wrong capital investments, stockouts, or contractual fines caused by corrupted reports. |

---

## 3. DAMA-DMBOK Framework: The 6 Dimensions of Data Quality

The industry-standard **DAMA-DMBOK** divides Data Quality into **6 measurable dimensions**:

| # | Dimension | Core Diagnostic Question |
| :--- | :--- | :--- |
| **01** | **Accuracy** | Does it match physical reality? |
| **02** | **Completeness** | Are values present? |
| **03** | **Consistency** | Do different systems agree? |
| **04** | **Timeliness** | Did it arrive on time? |
| **05** | **Uniqueness** | Are there duplicates? |
| **06** | **Validity** | Does it follow format/code rules? |

### 3.1 Completeness: Are Required Values Present?
* **Definition:** Measures the percentage of non-null values in mandatory business fields.
* **Example:** The `unit_price_eur` field returned as `NaN` in **4%** of ERP sales order lines, breaking downstream calculations.
* **Critical Engineering Rule ($\text{NULL} \neq 0.0$ — Unknown Signal vs. Zero Consumption):**
  * `NULL` (Missing) does **not** equal `0.0` (Zero).
  * A reading of **`0.0 kWh`** indicates a furnace was intentionally turned off, whereas a **`NULL`** value means the smart meter lost its network connection entirely.

### 3.2 Uniqueness: One Real Event = One Record
* **Core Metric Definition:** Measures the percentage of duplicate primary keys or duplicated business entities within a dataset.
* **System Impact Case Study (SmartPress):** A network timeout caused the SCADA gateway to send the **14:15 telemetry batch twice**, artificially doubling production output metrics in downstream reports.
* **Revenue Metric Distortion Example (`SALES_TRANSACTIONS`):**
  * `1004 | Widget A | User_5 | $150`
  * `1004 | Widget A | User_5 | $150` *(DUPLICATE KEY)*
  * `1003 | Widget E | User_9 | $150`
  * *Impact:* Base Revenue `\$300` + `\$150` (Error) = **\$450 Reported Total**.

### 3.3 Validity: Does Data Follow the Syntax & Rules?
* **Core Definition:** Measures the percentage of records correctly matching their assigned **data type**, **acceptable range**, or **Reference Data catalog**.
* **Case Study 01 — Range & Format Errors (DataCo):**
  * Discount entered as `15.0` instead of `0.15`, resulting in an impossible **1500% discount**.
  * Out-of-bounds negative discount logged: `-0.05`.
* **Case Study 02 — Reference Data Mismatch (EcoSteel):**
  * Furnace ID logged in lowercase as `"eaf_line_1"`.
  * Rejected due to mismatch with master catalog code: `"EAF_Line_1"`.
* **Data Validation Gate Workflow (Rules Engine):**
  * `0.15` (Valid Float) → `ALLOWED ✓` (Syntax & Range OK) → `VALID DATA Repository`
  * `15.0 / -0.05` (Range Error) → `REJECTED ✗` (Out of Bounds) → `ERROR LOG`
  * `"eaf_line_1"` (Code Mismatch) → `REJECTED ✗` (Catalog Violation) → `ERROR LOG`

### 3.4 Accuracy: Does Data Reflect Physical Reality?
* **Validity vs. Accuracy:** Data can be **100% valid** (syntactically valid IEEE 754 float, non-null, and unique structure), yet **0% accurate** (physically impossible values logged). Pipelines often validate types without verifying physical sanity.
* **Case Study Breakdowns:**
  * **SmartPress Case:** Torque sensor logged `-999.0 Nm` and `4850.0 Nm` — perfectly valid floats, but physically impossible on the press.
  * **DataCo Case:** Shipping lead time formatted perfectly as a float, but recorded as `145 days` for a domestic parcel.

### 3.5 Consistency: Do Systems Agree on the Truth?
* **Definition:** Measures the percentage of matching facts across different integrated systems (ERP, WMS, MES, CMMS, SCADA).
* **Operational Data Discrepancy (`14:00 – 16:00` Window):**
  * **CMMS Maintenance Log:** `Total Breakdown: 14:00 – 16:00` (`PRESS_01` in total breakdown state).
  * **SCADA Telemetry Log:** `450 Good Parts Produced: 14:00 – 16:00` (`PRESS_01` successfully producing parts).
* **Key Diagnostic Question:** *"Did the technician log the wrong machine, or is the SCADA clock shifted?"*

### 3.6 Timeliness: Is Data Available When Needed?
* **Definition:** The time lag between physical shopfloor events and data availability for operational analysis.
* **Real Factory Case Study (Shopfloor Paper Latency):** A machine breaks down on **Tuesday morning (`09:15 AM`)**. The technician writes repair details on a paper clipboard but does not type them into the CMMS until **Friday afternoon (`04:30 PM`)**. The data is 100% accurate on Friday, but was **completely useless for Wednesday's daily OEE operations meeting**.
* **Time Lag Metric:** **~79 Hours** latency gap.
* **Operational Impact:** Zero visibility at Wednesday's OEE review, delaying critical line adjustments by 3 full days.

---

## 4. Source-System Governance & Preventative Architecture

### 4.1 The Illusion: "Let's Just Fix It in the Data Warehouse!"
* **Temptation:** Clean ERP/MES data via Python in the Silver layer.
* **Reality:** Only fixes executive charts; corrupted data remains in operational systems running the factory.

> *"Fixing downstream creates an illusion of data quality without operational reality."*

#### 3 Reasons Warehouse Patching Is Not Enough
1. **Operational Blindness:** Fixing BI doesn't fix the WMS.
2. **Lost Ground Truth:** Algorithms cannot guess missing physical failure modes.
3. **Zero Accountability:** Silent IT patches prevent operational process improvements.

> **Key Operational Lesson:** *"Silent IT patches create operational blindness and prevent root-cause process improvements."*

### 4.2 Fixing at the Source: Digital Poka-Yoke (UI Design)
Error-proofing interfaces at point of entry by substituting manual free-text inputs with automated master data validation boundaries:
* **Kill Free-Text Fields:** Enforce mandatory drop-down selectors linked directly to verified Master Data repositories.
* **Hard Range Locks:** Block entry immediately if input values exceed physical hardware limits or operational rules.
* **Proper IT Systems:** Build proper IT applications for data entry instead of relying on spreadsheets.

| Approach | Example | Outcome |
| :--- | :--- | :--- |
| **Option A: Free-Text Input** *(Rejected — High Error Risk)* | `ABC-123_err [x]` → Schema mismatch / invalid SKU | High rate of typos, breaks ETL flow, requires manual fix. |
| **Option B: Validated Selection** *(Approved — Poka-Yoke)* | `MD-102 (Pump) ▼` → Verified against Master DB | Restricted picklist, zero bad entries, automated pipeline flow. |

### 4.3 Fixing at the Source: Shopfloor Automation
* **Eliminate Manual Typing:** Utilize barcode scanners, RFID, and direct PLC counters.
* **Smart Edge Gateways:** Configure OT gateways to send explicit status flags instead of placeholder values from manual inputs.

> **System Imperative:** *"Direct physical automation eliminates human data latency, manual typing errors, and placeholder defaults at the source."*

### 4.4 Industry Standard: Data Contracts (Formal SLA)
A **Data Contract (YAML / SLA)** serves as a formal agreement between upstream **System Owners (ERP / MES)** and **Data Engineering**, establishing strict, verifiable boundaries before data enters the Data Warehouse:
1. **Exact Schemas:** Strictly defined field names, precise data types (JSON/SQL), and enforced nullability rules.
2. **Business Rules:** Strict semantic validation and automated business logic checks enforced prior to data delivery.
3. **Delivery Schedules:** Defined refresh timelines, guaranteed availability windows, and automated SLA breach alerts.

---

## 5. Silver-Layer Technical Patterns: Quarantine, Outliers, Imputation & Observability

### 5.1 Automated Data Quality Gates & The Quarantine Pattern
Modern data platforms (**dbt**, **Great Expectations**, **Soda**) deploy automated quality gates to stop corrupted records before propagation.

> **Best Practice Rule:** Never silently delete invalid data. Preserving visual lineage and anomaly history is critical for pipeline reliability.

```text
┌────────────────┐     ┌─────────────────┐     PASS (98%)     ┌──────────────────────┐
│ BRONZE         │ ──► │ DQ GATE         │ ─────────────────► │ SILVER               │
│ (Raw Data)     │     │ (Quality Check) │                    │ (Clean Layer)        │
└────────────────┘     └────────┬────────┘                    └──────────────────────┘
                                │ FAIL (2%)
                                ▼
                       ┌─────────────────┐                    ┌──────────────────────┐
                       │ QUARANTINE      │ ──(Alert)────────► │ Business Team Alert  │
                       │ (Isolated Table)│                    │ (Fix at Source)      │
                       └─────────────────┘                    └──────────────────────┘
```

### 5.2 Outlier Detection: 3-Sigma Trap vs. Tukey's Boxplot (IQR)

#### The 3-Sigma Rule (Z-Score Thresholding) — The Industrial Outlier Trap
* Assumes a standard normal Gaussian distribution, flagging data outside $\mu \pm 3\sigma$ (expected coverage: `99.73%` of valid data).
* **The Industrial Vulnerability:** A single extreme telemetry spike (e.g., `25,000 kWh` or `4,850 Nm`) heavily skews quadratic sample metrics:
  1. Mean ($\mu$) shifts toward the outlier glitch ($\mu_{\text{true}} \rightarrow \mu_{\text{corrupted}}$).
  2. Standard Deviation ($\sigma$) inflates exponentially ($\sigma_{\text{corrupted}}$).
  3. **Masking Effect:** The inflated $\pm 3\sigma$ boundary becomes so loose that critical real anomalies pass quarantine undetected.

#### Robust Outlier Detection: Tukey's Boxplot Method (IQR)
* Sorts data to isolate the middle 50%, filtering boundary noise:

$$\text{IQR} = Q_3\,(75\%) - Q_1\,(25\%)$$

$$\text{Valid Physical Range Limits} = \left[Q_1 - 1.5 \times \text{IQR},\;\; Q_3 + 1.5 \times \text{IQR}\right]$$

* **Example:** $Q_1 = 40\text{s},\; Q_3 = 60\text{s} \implies \text{IQR} = 20\text{s}$. Valid limits: $[10\text{s},\; 90\text{s}]$.
* **Shopfloor Advantage vs. 3-Sigma:**
  * *Resistant to Tail Spikes:* Quartiles and medians inherently ignore extreme sensor glitches at distribution tails.
  * *Industrial Skew Alignment:* Highly reliable for asymmetric metrics like machine repair times or cycle delays.

### 5.3 Data Imputation: Physical vs. Business Domains

> **Rule:** Engineers must never blindly fill missing values with zero (`0`) or global averages.

| Domain | Method | Mechanism & Example |
| :--- | :--- | :--- |
| **Continuous Physical Signals** | **Time-Series Linear Interpolation** | Physical systems possess thermal inertia; continuous variables (e.g., furnace temperature) transition smoothly over time. Example: `310 K` at `14:00` and `314 K` at `14:30` interpolates to `312 K` at `14:15`. |
| **Business & Financial Attributes** | **Master Data Lookup Join** | Discrete commercial attributes (e.g., product price) lack continuous physical relationships and must never be averaged. Execute a deterministic join on `PROD_ID` against the Master Product Catalog (e.g., `"SKU-882"` `PRICE: NULL` $\rightarrow$ `$49.99`). |

### 5.4 Data Cleaning: Preserving Metric Integrity (Single-Cell Nullification)
* **SmartPress Telemetry Scenario:** At `14:15:00`, a sensor glitch recorded a torque anomaly of `-999.0 Nm`, occurring simultaneously with **120 valid produced units**.
* **Naive Mistake (Total Row Deletion):** Deleting the entire row purges the anomalous torque reading, but permanently erases **120 finished automotive parts** from factory output records, creating severe yield reporting drift.
* **Correct Action (Single-Cell Nullification):** Isolate and replace only the erroneous `-999.0 Nm` cell with `NULL`, then interpolate torque while keeping production output locked and valid:

| Timestamp | `UNITS_PRODUCED` | `TORQUE_NM` | Action |
| :--- | :--- | :--- | :--- |
| `14:00:00` | `118` | `45.2` | Valid |
| `14:15:00` | **`120`** *(Output Saved)* | ~~`-999.0`~~ → **`NULL` (`45.65`)** | Nullified & linearly interpolated: $(45.2 + 46.1) / 2$ |
| `14:30:00` | `122` | `46.1` | Valid |

* **Result:** `120 / 120 Units Preserved`.

### 5.5 Automated Data Observability (Macro-Metric Monitoring)
Standard row-level rules will not trigger an alert if an entire factory line silently stops transmitting files. Automated observability tracks system-wide telemetry:
* **Freshness SLAs:** Schedule compliance (e.g., `06:00 AM` cutoff).
* **Volume Anomalies:** Severe row drop-off (e.g., `10k → 150` rows, `-98.5%` active alarm).
* **Distribution Drift:** Statistical shift alerts (e.g., `5% → 35%`).

---

## 6. Organizational Governance & Continuous Improvement

### 6.1 Data Quality Is a Team Sport: 3 Key Roles

| Role | Focus | Responsibilities |
| :--- | :--- | :--- |
| **Data Owner** *(e.g., Plant Manager / VP of Logistics)* | **Mandate** | Accountable for domain data quality across operational systems; approves KPI definitions and budgets for ERP/MES fixes. |
| **Data Steward** *(e.g., Lead Planner / Maintenance Mgr)* | **Business Rules** | Defines business validation rules and data accuracy standards; manages Master Data catalogs and coordinates source-system error correction. |
| **Data Engineer** *(IT / BI Team)* | **Automation & Reporting** | Implements automated data quality checks in the warehouse; publishes Data Quality Exception Reports for Stewards. |

### 6.2 Continuous Improvement: The Data Quality PDCA Cycle
How the Data Warehouse helps the business fix errors in the source system:
1. **01. PLAN (Data Steward):** Define clear business Data Quality rules (accuracy criteria, validation thresholds, business logic).
2. **02. DO (Data Engineer):** Code the rules in the Data Warehouse using SQL and run them daily; log non-compliant records.
3. **03. CHECK (BI Exception Dashboard):** Publish a Data Quality Scorecard & Error List for operational teams.
4. **04. ACT (Shopfloor / Office Team):** Open ERP/MES/CMMS and fix the broken records directly at the source.

### 6.3 Examples of Business DQ Rules Measured in the Warehouse

| Domain / System | Rule Name | Steward | Validation Condition |
| :--- | :--- | :--- | :--- |
| **Finance / ERP** | **Rule #1: Master Catalog Alignment** | Sales Steward | `order_items.product_id IN Master_Catalog` AND `Unit_Price >= Standard_Cost` |
| **Maintenance / CMMS** | **Rule #2: Breakdown Ticket Completeness** | Maintenance Steward | `IF repair_duration > 60 min THEN failure_mode IS NOT NULL AND technician IS NOT NULL` |
| **Logistics / WMS** | **Rule #3: Chronological Order Dispatch** | Logistics Steward | `actual_ship_date >= order_date` |

### 6.4 The DQ Exception Report ("To-Fix List")
Instead of hiding errors, the BI team builds a Data Quality Dashboard for Data Stewards (e.g., Overall Domain Data Health: `96.4%` ERP Orders Validity vs. `99.5%` Target) with an actionable error table:
* `ORDER #10492` (Sales Rep: J. Kowalski) — *Defect:* Missing Unit Price — *Action:* **Fix in SAP**
* `TICKET #8831` (Shift: S2, M. Nowak) — *Defect:* Repair > 2h without Failure Code — *Action:* **Update CMMS**

By Friday, operators fix their own records in ERP/CMMS, ensuring the next warehouse load is **100% clean at the source**.

### 6.5 Permanent Fixes: Running "5 Whys" on Repeated Errors
* **Symptom on DQ Dashboard:** Maintenance tickets have wrong repair durations (`MTTR = 18 hours`).
* **Why 1:** Technicians close tickets 18 hours after the repair is finished.
* **Why 2:** They close all tickets in bulk the next morning.
* **Why 3:** They need to walk 400 meters away from the press line to input the data.
* **Why 4:** The CMMS computer is in an office, with no tablets on the shop floor.
* **Permanent Act (PDCA):** Buy 3 rugged tablets for the press line → **Defect drops to 0% permanently.**

---

## 7. Summary & Upcoming Lab Roadmap

> **Golden Takeaway:** *"Use the Data Warehouse to measure and expose data defects, empower Data Stewards to fix them at the source, and use Silver-layer cleaning as your last line of defense."*

### Upcoming Practical Labs Roadmap
* **Lab #2 — Data Profiling & Diagnosis:** Load Case Study data files and run Data Profiling to diagnose all Completeness, Uniqueness, Validity, and Accuracy defects.
* **Lab #3 — Silver Layer: Keys & Deduplication:** Build your Silver Layer in Python. Clean keys and deduplicate records to construct a clean foundational layer.
* **Lab #4 — Silver Layer: Outliers & Imputation:** Build your Silver Layer in Python. Apply IQR outlier detection algorithms and impute missing values for final refinement.
