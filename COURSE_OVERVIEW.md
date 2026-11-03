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

* **Zbiór bazowy 1 (Kaggle):** *AI4I 2020 Predictive Maintenance Dataset* (autor: Stephan Matzka / UCI) – zawiera 10 000 rekordów z czujników maszyn (temperatura procesu, prędkość obrotowa, moment obrotowy, zużycie narzędzia) oraz flagi konkretnych typów awarii (TWF, HDF, PWF, OSF).

* **Zbiór bazowy 2 (Kaggle):** *Manufacturing Production Line Performance / Factory Downtime Logs* (lub wygenerowana tabela zleceń produkcyjnych production\_batches.csv oraz słownik maszyn machines\_dict.xlsx).

* *Wskazówka techniczna:* Zbiór AI4I 2020 można w 3 minuty wzbogacić w Pythonie o znaczniki czasu (timestamp), przypisać do 4 różnych linii produkcyjnych i 3 zmian roboczych, a tabelę słownikową maszyn i operatorów wydzielić do osobnego pliku Excel/JSON, aby studenci mieli co integrować w Tygodniu 2\.

### **ONE-PAGER 1 (Gotowy materiał dla studentów)**

**CASE STUDY \#1: SmartPress Automotive – Shopfloor Performance & OEE Analytics**

**1\. Business Context** SmartPress Automotive is a Tier-1 supplier of stamped metal components for the European automotive industry. Over the past two quarters, the plant in Central Poland has experienced a noticeable drop in production efficiency and a spike in unplanned machine stops. The Management Board has raw data dumps from the shopfloor SCADA sensors, the Maintenance ticketing system, and the ERP shift schedule, but lacks a unified Business Intelligence system to diagnose the root causes.

**2\. Source Data Architecture (Your Data Pack)**

* **sensor\_telemetry.csv (SCADA System):** High-frequency logs containing machine ID, timestamp, air & process temperature, rotational speed (RPM), torque (Nm), tool wear (min), and defective units produced. *(Warning: Contains sensor glitches, extreme numerical outliers, and missing timestamps).*

* **maintenance\_logs.json (CMMS System):** Records of planned and unplanned downtimes, failure mode codes (Tool Wear Failure, Heat Dissipation Failure, Power Failure, Overstrain), and repair duration.

* **machines\_and\_shifts.xlsx (ERP Master Data):** Dictionary of production lines, machine models, nominal cycle times, hourly operating costs, and shift supervisor assignments.

**3\. Engineering & Analytical Challenges (Weeks 2–7)**

* **Integration (ELT \- Bronze):** Synchronize high-frequency telemetry with shift schedules and downtime events using time-window joins.

* **Data Quality & Numerical Methods (Silver):** Apply statistical outlier detection ($3\sigma$ or IQR method) to filter out corrupted torque/temperature sensor spikes. Impute missing ambient temperature readings using linear interpolation.

* **Dimensional Modeling (Gold):** Design a Star Schema centered around a Fact\_Production\_Runs table, linked to Dim\_Machine, Dim\_Time\_Shift, Dim\_Failure\_Type, and Dim\_Operator.

* **Synthetic Metrics (KPIs):** Calculate **OEE (Overall Equipment Effectiveness \= Availability × Performance × Quality)**, **MTBF** (Mean Time Between Failures), **MTTR** (Mean Time To Repair), and **Scrap Rate (%)**.

**4\. Dual Storytelling Perspectives (If two groups select this case):**

* **Group A Focus – Chief Operations Officer (COO) Perspective:** Focus on capacity utilization, shift-to-shift comparisons, OEE maximization, and meeting production targets across different product types (L/M/H quality variants).

* **Group B Focus – Head of Maintenance & Reliability Perspective:** Focus on equipment degradation, Pareto analysis of failure modes, tool wear thresholds, thermal stress anomalies, and minimizing MTTR.

## **CASE STUDY 2: Globalny Łańcuch Dostaw, Logistyka Produkcyjna i OTIF**

*(Supply Chain Resilience, Inventory & Order Fulfillment BI)*

### **Skąd wziąć dane (Realny zbiór Open Source):**

* **Zbiór bazowy (Kaggle):** **DataCo Smart Supply Chain for Big Data Analysis** (ok. 180 000 wierszy, ponad 50 kolumn\!).

* Jest to jeden z najlepszych publicznych zbiorów danych do nauki modelowania hurtowni danych. W oryginale jest to wielka, zdenormalizowana tabela płaska zawierająca wszystko: dane o zamówieniach, produktach, kategoriach, magazynach, czasach wysyłki (planowanych vs. rzeczywistych), rabatach, marżach i lokalizacjach geograficznych.

* *Jak przygotować paczkę przed zajęciami:* Wystarczy podzielić ten zbiór w Pythonie na 3 logiczne pliki źródłowe: orders\_transactions.csv (transakcje), shipping\_logistics.csv (daty wysyłek, statusy dostaw, czasy transportu) oraz products\_customers\_catalog.xlsx (słowniki produktów, działów i klientów).

### **ONE-PAGER 2 (Gotowy materiał dla studentów)**

**CASE STUDY \#2: DataCo Industrial – Supply Chain & Order Fulfillment Intelligence**

**1\. Business Context** DataCo is a global manufacturer and distributor of industrial and consumer goods. Despite growing order volumes, the company suffers from severe delivery delays, unpredictable freight costs, and imbalanced inventory allocations across regional distribution centers. The Executive Committee requires an analytical data mart and interactive dashboards to monitor delivery reliability and product line profitability.

**2\. Source Data Architecture (Your Data Pack)**

* **order\_items\_trans.csv (ERP Sales Module):** Order IDs, item quantities, unit prices, applied discounts, gross sales, and net profit margins per transaction line. *(Warning: Contains duplicate transaction logs, negative profit anomalies, and inconsistent currency/discount formats).*

* **shipment\_tracking.csv (WMS / Logistics System):** Scheduled shipping days vs. actual shipping days, shipping mode (Standard, First Class, Second Class, Same Day), delivery status, and destination coordinates.

* **master\_catalog.xlsx (MDM System):** Product hierarchy (Department $\rightarrow$ Category $\rightarrow$Product), warehouse locations, and customer segment dictionaries.

**3\. Engineering & Analytical Challenges (Weeks 2–7)**

* **Integration (ELT \- Bronze):** Reconstruct the end-to-end order lifecycle by joining sales transactions with WMS logistics logs and master dictionaries.

* **Data Quality & Numerical Methods (Silver):** Standardize discount rates, remove duplicated ERP exports, and use numerical distribution analysis to detect extreme lead-time anomalies and pricing errors.

* **Dimensional Modeling (Gold):** Normalize the flat staging data into a clean Kimball Star Schema (Fact\_Order\_Fulfillment connected to Dim\_Product, Dim\_Customer, Dim\_Geography, Dim\_Shipping\_Mode, and Dim\_Calendar).

* **Synthetic Metrics (KPIs):** Implement **OTIF (On-Time In-Full %)**, **Schedule Variance (Lead Time Delta)**, **Late Delivery Risk Index**, and **Net Margin Erosion due to Discounts**.

**4\. Dual Storytelling Perspectives (If two groups select this case):**

* **Group A Focus – VP of Supply Chain & Logistics Perspective:** Focus on OTIF performance, shipping mode bottlenecks, lead-time variability across geographical regions, and warehouse dispatch efficiency.

* **Group B Focus – Commercial & Production Planning Director Perspective:** Focus on product portfolio profitability, impact of discount policies on margins, ABC/XYZ product segmentation, and demand patterns across customer segments.

## **CASE STUDY 3: Energochłonność Procesów Przemysłowych i Zrównoważona Produkcja**

*(Industrial Energy Management, Power Quality & Carbon Footprint)*

### **Skąd wziąć dane (Realny zbiór Open Source):**

* **Zbiór bazowy (UCI Machine Learning Repository / Kaggle):** **Steel Industry Energy Consumption Dataset**(dane z huty stali DAEWOO Steel Co. Ltd w Korei Południowej).

* Zawiera 35 040 rekordów zbieranych w interwałach **co 15 minut** przez cały rok: zużycie energii czynnej (kWh), energii biernej indukcyjnej i pojemnościowej (kVarh), współczynnik mocy (*Power Factor*), emisję $C{O}_{2}$($tC{O}_{2}$), status pracy linii (WeekStatus, Load\_Type: *Light\_Load, Medium\_Load, Maximum\_Load*).

* *Jak wzbogacić paczkę:* Zbiór ma idealną strukturę szeregów czasowych (co 15 minut). Aby wymusić integrację wieloźródłową (Tydzień 2), wystarczy dodać drugi plik z dobowym wolumenem wyprodukowanych ton stali (daily\_steel\_output.csv) oraz tabelę taryf energetycznych (energy\_tariffs.json – różne stawki za prąd w szczycie i poza szczytem).

### **ONE-PAGER 3 (Gotowy materiał dla studentów)**

**CASE STUDY \#3: Nexis Precision Electronics – Industrial Workforce Planning, People Analytics & Operations**

**1\. Business Context** High-tech contract electronics and medical sensor manufacturing relies critically on human motor dexterity, station certifications, and operator alertness. Nexis Precision Electronics operates 4 assembly lines across 3 daily shifts. Management faced surging scrap costs (+34%) and falling schedule adherence (79%), relying on intuitive fixes (cheap agency temps and heavy overtime). BI analysis reveals counter-intuitive traps: agency staffing >20% causes scrap to quadruple, while overtime >8h/week destroys employee eligibility for the €250 Quality Bonus, crashing morale and driving turnover.

**2\. Source Data Architecture (Your Data Pack)**

* **shift_production_performance.csv (MES System):** Shift-level records (168 batches across 4 lines over 14 days) capturing planned target units, actual produced units, scrap defect units, rework units, material scrap loss (€), and line stoppage minutes.

* **workforce_events.json (Badge Telemetry & QA Audits):** Continuous event stream (6,300+ events) tracking clock-ins, station check-ins, optical QA audit defect counts, overtime approvals, and unplanned sick leave call-ins. *(Warning: Contains duplicate badge punches, 145-hour unclosed shift outliers, and Sunday/Monday burnout spikes).*

* **workforce_roster_and_skills.xlsx (HR Master Registry):** Multi-sheet workbook (`Employees`, `Skill_Matrix`, `Incentive_Policies`, `Shift_Staffing_Plan`) defining contracts, hourly rates, agency partners, skill levels, and the formal €250 Monthly Quality Bonus threshold (scrap $\le 1.80\%$).

**3\. Engineering & Analytical Challenges (Weeks 2–7)**

* **Integration (ELT \- Bronze):** Solve the multi-source challenge – aggregate individual badge telemetry and station defect counts to calculate the shift-level Agency Staffing Ratio (%) and link it directly to shift scrap and throughput.

* **Data Quality & Numerical Methods (Silver):** Deduplicate badge swipes, winsorize unclosed shift duration outliers (145h -> 8h), standardize messy contract casing (`temp_agency` vs `Temporary_Agency`), and compute individual monthly scrap rates.

* **Dimensional Modeling (Gold):** Build a Star Schema (`Fact_Shift_Production` & `Fact_Daily_Staffing_Attendance`) linked to conformed dimensions: `Dim_Date`, `Dim_Shift`, `Dim_Assembly_Line`, `Dim_Employee`.

* **Synthetic Metrics (KPIs):** Calculate **Schedule Attainment (%)**, **Shift Scrap Defect Rate (%)**, **True Quality-Adjusted Unit Labor Cost (€/good unit)**, **Quality Bonus Qualification Rate (%)**, and **Workforce Sizing Net ROI (€/year)**.

**4\. Dual Storytelling Perspectives (If two groups select this case):**

* **Group A Focus – Chief People Officer (CPO) / VP of Human Resources Perspective:** Focus on the Incentive Sabotage Paradox (overtime fatigue collapsing €250 Quality Bonus eligibility from 81.5% down to 14.8%), Monday burnout absenteeism, and building the Strategic Headcount Sizing Model proving that recruiting +18 permanent technicians saves €220k net annually.

* **Group B Focus – Director of Plant Operations & Production Planning Perspective:** Focus on the Cheap Agency Staffing Trap (agency staffing >20% quadruples scrap and inflates unit cost from €19.80 to €29.40), enforcing agency quota caps (max 15-20%), and balancing station certifications to eliminate line stoppages.

### **Podsumowanie dydaktyczne – dlaczego te 3 zestawy sprawdzą się idealnie?**

1. **Różnorodność problemów inżynierskich:** Masz tu 3 filary nowoczesnego przemysłu: **Utrzymanie Ruchu / OEE** (Case 1), **Łańcuch Dostaw / OTIF** (Case 2\) oraz **Zarządzanie Kapitałem Ludzkim i Operacjami / People Analytics** (Case 3).

2. **Wymuszenie pełnego cyklu ELT:** Żaden z tych problemów nie da się rozwiązać na jednej płaskiej tabeli – w każdym studenci muszą połączyć heterogeniczne źródła (CSV, JSON, XLSX) o różnej ziarnistości (zdarzenia telemetryczne, dane zmianowe, rejestry stałe).

3. **Wyraźna rola metod numerycznych (PEK W01.3):** W każdym zbiorze są dane ciągłe (temperatury, momenty obrotowe, czasy dostaw, pobór mocy w kWh), na których trzeba policzyć rozkłady, odsiać outliery metodami statystycznymi i policzyć złożone wskaźniki syntetyczne.
