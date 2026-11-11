Poniżej znajdują się propozycje trzech kompleksowych studiów przypadków (*Case Studies*) w formie gotowych do wręczenia studentom „One-Pagerów” (przygotowanych po angielsku, gdyż przedmiot prowadzony jest w języku angielskim, wraz z polskim komentarzem metodycznym i wskazaniem konkretnych, publicznych zbiorów danych).

Praca w **5-osobowych zespołach** wymaga odpowiednio szerokiego zakresu zadań, a przydzielenie tego samego *Case Study* dwóm różnym grupom to świetny zabieg dydaktyczny. Aby wymusić na bliźniaczych grupach zupełnie inne podejście do *Data Storytellingu* i budowy dashboardów, w każdym One-Pagerze wprowadzono **dwie odmienne perspektywy zarządcze (Perspektywa A vs. Perspektywa B)**.

### **Podział ról w 5-osobowym zespole (rekomendacja na 1\. ćwiczenia)**

Aby uniknąć sytuacji, w której dwie osoby piszą kod, a trzy się przyglądają, warto zasugerować grupom podział na role projektowe (każdy odpowiada za swoją część podczas obrony):

1. **Data Integration Engineer (Warstwa Bronze / E\&L):** Odpowiada za pobranie źródeł, ujednolicenie formatów dat/czasu i złączenie tabel w Pandas.

2. **Data Quality & Numerical Analyst (Warstwa Silver / Transform):** Odpowiada za profilowanie jakości, imputację braków oraz numeryczną detekcję wartości odstających (IQR, 3 sigmy) i normalizację.

3. **Data Warehouse Architect (Warstwa Gold / Modeling):** Odpowiada za projekt Schematu Gwiazdy (dbdiagram.io) oraz budowę tabel Faktów i Wymiarów w DuckDB/SQL.

4. **KPI & Business Logic Developer:** Odpowiada za matematyczną definicję i implementację mierników syntetycznych (np. OEE, OTIF, SEC) oraz przekrojów OLAP.

5. **BI & Data Storytelling Lead:** Odpowiada za makiety UX/UI, budowę interaktywnego dashboardu oraz spójność narracji biznesowej.

## **CASE STUDY 1: Wydajność Parku Maszynowego, Utrzymanie Ruchu i OEE**

*(Manufacturing Operations, Downtime & OEE Analytics)*

### **Skąd wziąć dane (Realne zbiory Open Source do połączenia):**

* **Zbiór bazowy 1 (Kaggle):** *AI4I 2020 Predictive Maintenance Dataset* (autor: Stephan Matzka / UCI) – baza fizyczna dla symulacji parametrów pracy pras hydraulicznych na horyzoncie **60 dni** (`2026-10-01` – `2026-11-30`) z podziałem na **3 natywne formaty** (`sensor_telemetry.csv`, `maintenance_logs.json`, `machines_and_shifts.xlsx`).

### **ONE-PAGER 1 (Gotowy materiał dla studentów — 60-Day Simulation)**

**CASE STUDY \#1: SmartPress Automotive – Shopfloor Performance & OEE Analytics**

**1\. Business Context** SmartPress Automotive is a Tier-1 supplier of stamped metal components for the European automotive industry. Over the 60-day diagnostic window (`2026-10-01` – `2026-11-30`), the plant in Central Poland has experienced a noticeable drop in production efficiency (`70.38%` OEE) and high unplanned stops. Management has raw exports from SCADA sensors, the CMMS ticketing system, and ERP master schedules, and needs a unified BI system that eliminates join fan-out traps (`480.0 min` exact shift capacity).

**2\. Source Data Architecture (Your Data Pack — 3 Native Formats)**

* **`sensor_telemetry.csv` (SCADA System):** 23,164 high-frequency logs (`machine_id`, `timestamp`, air & process temperature, rotational speed RPM, torque Nm, tool wear min, and output/defects). *(Injected DQ anomalies quarantined at Gate 1: out-of-window dates, negative RPM, impossible wear).*
* **`maintenance_logs.json` (CMMS System):** 286 planned/unplanned tickets, failure mode codes (`TWF`, `HDF`, `PWF`, `OSF`), repair duration (`MTTR`), and direct maintenance costs.
* **`machines_and_shifts.xlsx` (ERP Master Data):** 3 tabs (`Machines`, `Shifts` with `480.0 min` nominal capacity, and `Product_Variants` `L`/`M`/`H`).

**3\. Engineering & Analytical Challenges (`Proces DQ Gate 1` + Gold)**

* **Integration (ELT - Lab 02 Bronze):** Ingest `CSV + JSON + XLSX`, quarantine bad telemetry/tickets into `quarantine_errors.parquet`, and avoid double-counting capacity across high-frequency sensor rows.
* **Dimensional Modeling (Gold):** Build a Kimball Star Schema centered on `Fact_Shift_Production` (exact `480.0 min` grain) and `Fact_Maintenance_Events`, linked to `Dim_Machine`, `Dim_Shift`, `Dim_Product_Variant`, `Dim_Failure_Mode`, and `Dim_Date`.
* **Synthetic Metrics (KPIs):** **OEE = Availability × Performance × Quality**, **MTBF**, **MTTR**, **Scrap Cost (EUR)**, and breakdown correlation with `tool_wear > 180 min`.

**4\. Dual Storytelling Perspectives (Track A vs Track B):**

* **Group A Focus – Chief Operations Officer (COO):** Shift-by-shift OEE bottlenecks (e.g., `S3 PRESS_02` Variant `H`), capacity utilization, and scrap EUR impact.
* **Group B Focus – Head of Maintenance & Reliability:** Tool-wear threshold degradation (`> 180 min` driving breakdowns), failure Pareto (`TWF`/`HDF`), and MTTR reduction ROI.

## **CASE STUDY 2: Przemysłowa Dystrybucja Hydrauliki, OTIF i Marża Net (DataCo)**

*(Industrial Hydraulics Supply Chain, WMS Logistics & Net Margin Analytics)*

### **Skąd wziąć dane:**

* *Architektura pakietu 60-dniowego:* Pełna symulacja **60 dni** (`2026-10-01` – `2026-11-30`) w **3 heterogenicznych formatach** (`order_items_trans.csv`, `shipment_events.json`, `master_catalog.xlsx`), eliminująca ryzyko mnożenia sum zamówienia przez wielokrotne zdarzenia WMS.

### **ONE-PAGER 2 (Gotowy materiał dla studentów — 60-Day Simulation)**

**CASE STUDY \#2: DataCo Industrial Hydraulics – Supply Chain & Net Margin Intelligence**

**1\. Business Context** DataCo distributes heavy industrial hydraulics (`Hoses`, `Pumps`, `Valves`, `Filters`) across European regional hubs (`HUB-South-Katowice`, `HUB-Central-Lodz`, etc.). Despite €29.95M net sales over 60 days, overall OTIF has fallen to `74.07%` and SLA penalties + freight surcharges erode profitability—particularly on `VIP Heavy OEM` accounts.

**2\. Source Data Architecture (Your Data Pack — 3 Native Formats)**

* **`order_items_trans.csv` (ERP Sales Module):** 8,623 transaction lines across 4,774 orders (`ordered_qty`, `delivered_qty`, unit price, discount %, tax, COGS).
* **`shipment_events.json` (WMS / Carrier Telemetry):** 22,746 multi-milestone events (`PICKED`, `PACKED`, `DISPATCHED`, `DELIVERED`), warehouse dwell times, carrier codes, and SLA penalty triggers.
* **`master_catalog.xlsx` (MDM System):** 4 tabs (`Products`, `Customers`, `Warehouses`, `Carrier_SLA_Policies`).

**3\. Engineering & Analytical Challenges (`Proces DQ Gate 1` + Gold)**

* **Anti-Fan-Out Integration (Silver):** Collapse 22,746 WMS milestone events to 1 row per `order_id` *before* prorating freight & SLA penalties across order lines so net revenue (`€29.95M`) and net profit (`€8.50M`) never double-count.
* **Dimensional Modeling (Gold):** Build `Fact_Order_Lines` + `Fact_Shipments` linked to `Dim_Product`, `Dim_Customer`, `Dim_Warehouse`, `Dim_Carrier`, and `Dim_Date`.
* **Synthetic Metrics (KPIs):** True **OTIF (%)** (`On-Time AND In-Full`), Warehouse Dwell Time (h), Prorated Net Profit (`€` / `%`), and SLA Penalty Leakage.

**4\. Dual Storytelling Perspectives (Track A vs Track B):**

* **Group A Focus – VP of Supply Chain & Logistics:** Warehouse dwell bottlenecks (e.g., `HUB-South-Katowice` Urgent mode & `RABEN_LOGISTICS`), carrier SLA adherence, and late-delivery recovery.
* **Group B Focus – Commercial & FP&A Director:** Margin erosion waterfall (`Discount + Freight + SLA Penalties`), proving why `VIP Heavy OEM` (`VIP Hoses`) generates negative net margin despite high gross revenue.

## **CASE STUDY 3: People Analytics Conforme RODO, Burnout i Koszty Zmian (Nexis Workforce)**

*(Industrial Workforce Planning, Bradford Burnout & Compliance Analytics)*

### **ONE-PAGER 3 (Gotowy materiał dla studentów — 60-Day Simulation)**

**CASE STUDY \#3: Nexis Precision Automotive Components Sp. z o.o. — Workforce Analytics & Operations**

**1\. Business Context** Located in Wrocław, Nexis runs four electromechanical actuator assembly lines (`LINE_01..LINE_04`) across three continuous shifts (`S1/S2/S3`) staffed by 165 operators (115 Permanent + 50 Temporary Agency). Over 60 days, labor cost (€961k with 1.5x overtime premiums) and scrap losses (€934k) threaten margins, while management relies on flawed averages blaming night shifts (`S3`) without noticing RODO privacy exposure in raw HR spreadsheets.

**2\. Source Data Architecture (Your Data Pack)**

* **`shift_production_performance.csv` (MES System):** 720 line-shift rows across 60 days (`LINE_01..LINE_04 × S1..S3`) capturing output targets, produced/good/scrap units, rework, and scrap EUR waste.
* **`workforce_events.json` (Badge Telemetry, QA Audits & Absences):** ~25,585 events recording shift clock-ins/outs, optical QA defects, overtime approvals, and sick leaves (plus sensitive `details_medical_note` that MUST be purged!). Injects duplicate gate scans (`<60s`), `145h`/`-3.5h` glitches, ghost IDs, and `S3` cross-midnight scans.
* **`workforce_roster_and_skills.xlsx` (HR Master Registry):** 4 tabs (`Employees` containing RODO PII fields to purge pre-Silver, `Skill_Matrix`, `Incentive_Policies` €250/mo bonus `<=1.80%` scrap, and `Shift_Staffing_Plan`).

**3\. Engineering & Analytical Challenges (`Proces DQ Gate 1` + Gold)**

* **Mandatory RODO Purge (`DQ-C3-RODO`):** Physically drop `first_name`, `last_name`, `corporate_email`, `national_id_masked`, and `details_medical_note` prior to Silver/Gold export (`0` PII columns verified!).
* **Time & Causal Math:** Align midnight `S3` events deterministically (`S1:-2h, S2:-3h, S3:-9h`), enforce causal `[d-7, d-1]` prior overtime windows (`prior_7d_ot_hours`), cluster contiguous sick spells for the **Bradford Factor ($B = S^2 \times D$)**, and apply true **`1.5x` OT** wage multipliers.
* **Dimensional Modeling (Gold):** Build clean Star Schema (`Fact_Shift_Production`, `Fact_Daily_Staffing_Attendance`, `Fact_Absence_Events`) linked to `Dim_Date`, `Dim_Shift`, `Dim_Assembly_Line`, and pseudonymized `Dim_Employee`.

**4\. Dual Storytelling Perspectives:**

* **Group A Focus – HR Director:** Audit Permanent vs Agency churn & bonus exclusion fairness, prove how `prior_7d_ot >= 8h` drives sick absences (`Bradford B >= 400` critical tier), and enforce RODO / EU AI Act Annex III safeguards.
* **Group B Focus – VP of Manufacturing Operations:** Uncover the true bottleneck across `Line × Shift` L2+ Certified Coverage (e.g., morning `LINE_03 S1` collapse vs `S3`), quantify `1.5x` OT payroll + fatigued scrap losses, and model **Dynamic Implied Missing Monthly FTEs** reacting live to date slicers.

### **Podsumowanie dydaktyczne – dlaczego te 3 zestawy sprawdzą się idealnie?**

1. **Różnorodność problemów inżynierskich:** Masz tu 3 filary nowoczesnego przemysłu: **Utrzymanie Ruchu / OEE** (Case 1), **Łańcuch Dostaw / OTIF i Marże Net** (Case 2) oraz **Kapitał Ludzki, Burnout i RODO / People Analytics** (Case 3).
2. **Pełna parzystość 3 formatów (`CSV + JSON + XLSX`):** W każdym studium przypadku studenci integrują 3 heterogeniczne źródła na horyzoncie 60 dni z jawnymi regułami `Proces DQ Gate 1` oraz bramką kwarantanny.
3. **Rygor matematyczny i anty-fan-out (PEK):** Wyeliminowanie złączeń iloczynowych (`480.0 min` w SmartPress, alokacja prorata frachtu w DataCo, przyczynowe okno `prior_7d_ot` i czynnik Bradforda w Nexis) gwarantuje rzetelną spójność od Bronze aż po kafelki dashboardu.
