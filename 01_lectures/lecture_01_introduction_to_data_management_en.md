# Course: Business Intelligence and Big Data Analysis (`01 31 0367 00`)

## Academic & Technical Synthesis — Lecture 01: Introduction to Industrial Data Management

**Language:** English (`EN`)  
**Semester:** Fall / Spring  
**Audience:** 4th Year B.Sc. Engineering (Management and Production Engineering)

---

## 1. Executive Summary & Pedagogical Framework

Modern industrial enterprises generate vast volumes of telemetry and transactional logs, yet operational leadership frequently experiences the paradox of being **"drowning in data, starving for insights."** 

This course bridges the fundamental engineering divide between physical shopfloor processes (Operational Technology - OT) and enterprise data platforms (Information Technology - IT). It equips students with the end-to-end capabilities required to extract high-velocity, heterogeneous operational signals, ingest and transform them through governed analytical pipelines, and serve actionable executive intelligence.

```text
       [ Physical Reality ]                        [ Enterprise Value ]
 Shopfloor Sensors & Equipment  ───►  ELT Pipeline  ───►  Analytical Warehouse  ───►  Executive Dashboards
  (High-Frequency OT Telemetry)        (Bronze/Silver)         (Gold Star Schema)          (Actionable Insights)
```

---

## 2. Course Structure, Operations & Governance

### 2.1 Course Rhythm and Workload
* **Workload:** 5 ECTS Credits (15h Lectures, 30h Laboratories, 30h Tutorials).
* **Weekly Operating Rhythm:**
  * **Lectures:** Theoretical foundations, dimensional modeling paradigms, KPI formulations, and visual perception rules.
  * **Laboratories (3h Hands-on):** Technical execution using Python, Pandas, DuckDB, SQL, and modern BI tooling across real-world datasets.
  * **Tutorials (3h Team Workshops):** Architectural design, Data Architecture Diagrams, formal Kimball Star Schemas, metric mathematical definitions, and UX wireframing.

### 2.2 Grading Policy & Academic Integrity
* **Passing Threshold:** Minimum of $51\%$ required independently in both assessment components:
  * **Knowledge Test (20%):** 30-minute individual assessment covering numerical methods, ELT paradigms, Kimball Star Schema, KPI formulas, and OLAP query engines.
  * **Team Project & Defense (80%):** End-to-end implementation and live defense in 5-person engineering teams during Week 10.
* **Attendance Mandate:** Mandatory attendance for Laboratories and Tutorials (maximum 1 unexcused absence per category). Team quorum requires at least $50\%$ of team members present at every workshop.
* **AI Policy (Rector Regulation No. 31/2025):**
  * *Permitted:* Coding syntax troubleshooting, code refactoring, brainstorming, and architectural ideation.
  * *Strictly Prohibited:* Unverified automated reporting, generating synthetic data models, or submitting unverified end-to-end solutions.

### 2.3 Cross-Functional Team Roles
Each 5-person team mirrors a production-grade data organization:
1. **Bronze Lead (Data Integration Engineer):** Ingests raw CSV/JSON/XLSX sources, handles schema extraction, standardizes timestamps, and builds staging structures in Pandas.
2. **Silver Lead (Data Quality & Numerical Analyst):** Profiles data completeness, implements statistical cleaning ($3\sigma$, IQR), handles imputation, and deduplicates streams.
3. **Gold Lead (Data Warehouse Architect):** Designs the dimensional model (Star Schema), manages surrogate keys, and implements Fact/Dimension models in DuckDB/SQL.
4. **Analytics Lead (KPI & Production Analytics Developer):** Formulates mathematical definitions and code logic for complex synthetic KPIs (e.g., OEE, OTIF, SEC).
5. **UX & BI Lead (BI Developer & Data Storyteller):** Constructs dashboard wireframes, enforces UI/UX best practices (maximizing Tufte’s Data-to-Ink ratio), and drives executive data storytelling.

---

## 3. Foundations of Industrial Data Management

### 3.1 The DIKW Pyramid in Manufacturing
The Data-Information-Knowledge-Wisdom (DIKW) hierarchy illustrates how raw shopfloor signals are progressively refined into strategic business value:

```text
                  ▲
                 / \
                /   \     WISDOM / DECISION
               /  ★  \    Executive Policy: Replace tools at 165 min wear.
              /───────\   Saves 45,000 EUR/quarter in scrap and downtime.
             /         \
            / KNOWLEDGE \ Aggregated Patterns: Overstrain failures rise by 300%
           /─────────────\ when tool wear > 180 min on HSS steel (OEE drops to 62%).
          /  INFORMATION  \ Cleaned & Contextualized: Press 04 had Overstrain Failure
         /─────────────────\ during Shift 2 producing Batch #402.
        /       DATA        \ Raw Telemetry: 2026-10-14 14:15:00 | Press_04 | 
       /─────────────────────\ Torque: 68.4 Nm | Temp: 312.1 K | Wear: 195 min.
```

### 3.2 Industrial Data Formats
Industrial environments produce three primary classifications of data:
* **Structured Data:** Strict schemas, rigid columns and rows (e.g., ERP sales ledgers, production batches, shift rosters). Stored in relational tables, CSV, or Excel.
* **Semi-Structured Data:** Hierarchical, dynamic key-value formats lacking rigid tabular boundaries (e.g., CMMS maintenance failure logs, REST API tariff payloads). Stored in JSON, JSONL, XML.
* **Time-Series Telemetry:** Continuous, high-frequency, timestamped readings from PLCs and IoT meters (e.g., 15-minute power meter logs, millisecond vibration readings). Requires temporal resampling and windowing.
* **Unstructured Data:** Operational documents requiring extraction pipelines (e.g., maintenance PDF logs, operator notes, thermal camera imaging).

### 3.3 The ISA-95 Industrial Data Problem
The ISA-95 standard governs the integration of enterprise systems with shopfloor control systems. However, industrial organizations routinely suffer from **isolated data silos** with sharply conflicting temporal granularity and naming conventions:

```text
┌─────────────────────────────────────────────────────────────┐
│ LEVEL 4: Corporate IT (ERP, CRM, SCM)                       │
│ Granularity: Daily / Transactional                          │
│ Scope: Purchase orders, customer accounts, unit costs       │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Silo Boundary: Semantic & Temporal Gap)
┌──────────────────────────────▼──────────────────────────────┐
│ LEVEL 3: Manufacturing Operations Management - MOM (MES, CMMS, WMS) │
│ Granularity: Shift (8-Hour) / Hourly / Event                │
│ Scope: Work orders, scrap counts, failure tickets, batches  │
└──────────────────────────────┬──────────────────────────────┘
                               │ (Silo Boundary: Protocol & Frequency Gap)
┌──────────────────────────────▼──────────────────────────────┐
│ LEVELS 1-2: Operational Technology - OT (SCADA, PLC, Meters)│
│ Granularity: Milliseconds / Seconds / 15-Minute Intervals   │
│ Scope: Temperature, torque, RPM, active power (kW), status  │
└─────────────────────────────────────────────────────────────┘
```

#### The Mismatched Granularity Trap
* **SCADA/IoT:** Records active power every 15 minutes.
* **MES:** Records output tons per 8-hour shift.
* **ERP:** Records dynamic Time-of-Use electricity tariffs on variable contracts.
* **Result:** To evaluate true operational cost per ton of product, engineers cannot query a single system. They must resolve temporal mismatches and unify divergent naming conventions (e.g., SCADA identifies `P-01`, CMMS records `Mach_1`, ERP logs `Asset_1004`).

### 3.4 Operational Databases (OLTP) vs. Analytical Warehouses (OLAP)
* **OLTP (Online Transaction Processing - ERP/MES):**
  * *Purpose:* Keep daily plant operations running without latency (e.g., booking inventory, processing work tickets).
  * *Mechanism:* Row-based storage optimized for rapid, high-concurrency, single-record writes and updates.
  * *Operational Risk:* Executing analytical aggregations spanning months of data across millions of rows locks tables, exhausts server memory, and risks freezing physical shopfloor operations.
* **OLAP (Online Analytical Processing - DWH/Lakehouse):**
  * *Purpose:* Support strategic decision-making and cross-departmental trend discovery.
  * *Mechanism:* Columnar storage optimized for full-table scans, aggregations, and complex multi-table joins.
  * *Core Principle:* Read-only, historical, append-mostly storage that isolates analytical compute from live operational databases.

#### Bill Inmon's 4 Core Pillars of a Data Warehouse
1. **Subject-Oriented:** Structured around overarching operational domains (e.g., Production, Equipment Reliability, Logistics) rather than discrete application workflows.
2. **Time-Variant:** Captures explicit point-in-time snapshots and state changes; data is historical and preserves past states rather than overwriting records.
3. **Non-Volatile:** Analytical data is permanent and immutable; it is never updated or deleted in place, safeguarding historical audits.
4. **OLAP Workload Shield:** Provides architectural separation, ensuring complex executive reporting cannot degrade critical plant automation systems.

### 3.5 Processing Paradigms: ETL vs. ELT & Cadence
* **Legacy ETL (Extract $\rightarrow$ Transform $\rightarrow$ Load):**
  * Data is extracted from source systems, transformed on external staging servers to conform to rigid relational schemas, and loaded into expensive warehouse storage.
  * *Bottlenecks:* Highly rigid, loss of raw data, expensive to modify when business logic changes.
* **Modern ELT (Extract $\rightarrow$ Load $\rightarrow$ Transform):**
  * Raw operational data is extracted and loaded directly into a scalable storage engine (Bronze Layer). Transformations occur in-engine (Silver and Gold Layers) using scalable SQL and Python engines.
  * *Benefits:* Preserves original data immutability, provides infinite flexibility to re-derive metrics retrospectively.
* **Latency Cadence:**
  * **Batch Processing:** Bounded data executed in scheduled intervals (e.g., hourly, shift-end, daily financial ledger runs).
  * **Event Streaming:** Unbounded message streams processed continuously with millisecond latency via MQTT brokers or Apache Kafka (vital for real-time safety shut-downs and predictive anomaly detection).

### 3.6 Industrial Data Quality & Cleaning Rules
Data quality directly impacts executive trust (**"Garbage In, Garbage Out"**):
* **Numerical Outliers:** Sensor transmission faults or physical anomalies (e.g., voltage spikes yielding $99{,}999\text{ kWh}$ or anomalous negative torque values of $-450\text{ Nm}$). Resolved via statistical bounds:

$$\text{Three-Sigma Rule: } \mu \pm 3\sigma$$

$$\text{Interquartile Range (IQR): } [Q_1 - 1.5 \times \text{IQR},\; Q_3 + 1.5 \times \text{IQR}]$$

* **Inconsistent Master Identifiers:** Entity naming discrepancies across functional silos (`PRESS_01`, `Press_01 `, `P01`) preventing programmatic table joins. Resolved via string normalization, regex stripping, and master lookup tables.
* **Completeness & Uniqueness:** Telemetry gaps caused by network drops (yielding `NaN` values) and duplicate records caused by retry loops or ERP batch exports. Requires automated boundary validation and deduplication logic at ingest.

### 3.7 Dimensional Modeling: The Kimball Star Schema
Centralizes business event metrics within **Fact Tables**, surrounded by contextual **Dimension Tables**:
* **Fact Table:** Numeric, additive/semi-additive measurements representing business events (e.g., `Produced_Units`, `Downtime_Minutes`, `Energy_kWh`).
* **Dimension Tables:** Contextual attributes providing slicing and dicing angles (e.g., `Dim_Time`, `Dim_Machine`, `Dim_Product`).
* **Ungoverned vs. Governed Metrics:** Without centralized Star Schemas, individual departments define operational metrics arbitrarily (e.g., Maintenance and Production computing OEE differently to obscure departmental inefficiencies). A governed BI platform enforces an immutable **Single Source of Truth (SSOT)**.

### 3.8 Master Data Management (MDM) vs. Reference Data Management (RDM)
* **Reference Data (RDM):** Permissible values, standard domain lookups, and classification codes used across systems:
  * *Examples:* ISO Currency Codes (`EUR`, `USD`), Engineering Units (`kWh`, `Nm`, `°C`), CMMS Failure Codes (`TWF` - Tool Wear Failure, `HDF` - Hydraulic Failure).
* **Master Data (MDM):** Core, non-transactional business entities that give context to operational transactions:
  * *Examples:* Equipment Asset Registry (machine serial numbers, nominal operating speeds), Product Catalog & BOM (SKUs, bill of materials), Supplier and Customer hierarchies.

### 3.9 Visual Analytics & Edward Tufte’s Principles
* **Reporting Tiers:**
  * **Tier 1 (Operational):** Granular, tabular static views for daily compliance and shift handovers.
  * **Tier 2 (Tactical):** Interactive management cockpits with drill-downs and cross-filtering for root-cause analysis.
  * **Tier 3 (Strategic):** Executive visual narratives linking operational KPIs directly to financial performance and capital strategy.
* **Data-to-Ink Ratio:** Maximizing the visual weight of essential information while ruthlessly eliminating "chartjunk," redundant visual decoration, heavy borders, and non-informative colors:

$$\text{Data-Ink Ratio} = \frac{\text{Data-Ink}}{\text{Total Ink Used to Print the Graphic}}$$

### 3.10 DAMA-DMBOK Governance Framework
DAMA-DMBOK structures enterprise data management into specialized knowledge areas anchored by centralized **Data Governance**:
* **Core:** Data Governance (policies, data ownership, authority, compliance).
* **Surrounding Pillars:** Data Architecture, Data Integration & Interoperability, Data Quality, Reference & Master Data, Data Warehousing & BI.

