# Case Study 00 (Guided Lab Dataset): EuroPack Beverage Bottling
## Bottling Line Performance, Equipment Reliability & OEE

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Role:** Neutral Teaching Dataset used across **Guided Labs 02–10** *(separate from graded squad project Cases 1, 2, and 3)*  
**Language:** English (`EN`)

---

## 1. Company & Industry Context

### 1.1 High-Speed Beverage Bottling & Retail Supply Commitments
Modern beverage bottlers supplying European retail chains and hospitality distributors operate under strict **On-Time In-Full (OTIF)** delivery windows and tight shelf-life and food-safety standards. High-speed bottling lines run **24/7 across three shifts** to meet seasonal promotional peaks and supermarket replenishment contracts.

Because margins per bottle are thin, unplanned line stoppages, pasteurizer drift, and bottle breakage quickly erase operating profit—while missed supermarket deliveries trigger contract penalties and lost shelf space.

### 1.2 Company Profile: EuroPack Beverage Bottling Sp. z o.o.
**EuroPack Beverage Bottling Sp. z o.o.** operates an automated beverage filling and packaging facility in **Gdańsk, Poland (Plant #1)**. The plant fills, pasteurizes, caps, labels, and palletizes still water, sparkling beverages, and returnable glass drinks across four automated bottling lines:
* **0.5L Still Water PET (`PET_05`):** Lightweight recycled PET (`rPET Light 18g`) produced at high throughput.
* **1.5L Sparkling PET (`PET_15`):** Pressurized carbonated PET (`PET Carbonated 34g`) requiring controlled rotary filler pressure.
* **0.75L Returnable Glass (`GLASS_075`):** Heavyweight amber glass (`Amber Glass 450g`) with the highest unit reject cost and strict thermal/mechanical handling limits.

```
                     BEVERAGE BOTTLING VALUE CHAIN
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Preform, Glass &     │ ───► │ EuroPack Beverage       │ ───► │ Retail Chains &        │
 │ Syrup Suppliers      │      │ Bottling (Gdańsk #1)    │      │ Hospitality Distributors│
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. How the Bottling Plant Works

### 2.1 Production Flow (Bottling Hall B-1)
Inside Bottling Hall B-1, each automated bottling line runs four continuous stages:
1. **Rinsing & Infeed:** Empty PET preforms/bottles or returnable glass bottles enter the high-speed conveyor (`conveyor_speed_bpm`, bottles per minute).
2. **Rotary Filling & Capping:** Pressurized rotary filling valves (`filler_pressure_bar`, normal operating envelope `[0.0, 12.0]` bar) fill and seal bottles while PLC counters track cumulative valve usage (`valve_cycles_k`, in thousands of cycles).
3. **Tunnel Pasteurization:** Filled bottles pass through a thermal tunnel monitored by ambient (`ambient_temp_C`) and pasteurizer (`pasteurizer_temp_C`) temperature sensors.
4. **Vision Inspection & Reject Ejection:** High-speed optical sensors inspect fill level, cap seal, and glass integrity, logging total filled bottles (`bottled_units`) and ejected defects (`rejected_units`).

### 2.2 Bottling Lines (`Lines` Sheet in `plant_master_data.xlsx`)
The plant runs four bottling lines defined in `plant_master_data.xlsx`:

| Line ID | Line Name | Filler Technology | Nominal Cycle Time | Hourly Operating Cost (€/h) |
| :--- | :--- | :--- | :---: | :---: |
| **`LINE_A`** | **Krones Servo Filler 4000** | Rotary Servo | **0.75 sec/bottle** | **€240 / hour** |
| **`LINE_B`** | **Legacy Mechanical Filler M2** | Legacy Mechanical | **0.90 sec/bottle** | **€210 / hour** |
| **`LINE_C`** | **Sidel Rotary Combi 4500** | Direct-Drive Combi | **0.72 sec/bottle** | **€265 / hour** |
| **`LINE_D`** | **Tetra High-Speed Aseptic 5000** | Aseptic High-Speed | **0.65 sec/bottle** | **€195 / hour** |

### 2.3 Bottle Formats (`Bottle_Formats` Sheet) & Work Shifts (`Shifts` Sheet)

| Format Code | Format Name | Packaging Material | Target Hourly Output | Unit Reject Cost (€/bottle) |
| :--- | :--- | :--- | :---: | :---: |
| **`PET_05`** | 0.5L Still Water PET | rPET Light 18g | `4,600 / h` | **€0.22** |
| **`PET_15`** | 1.5L Sparkling PET | PET Carbonated 34g | `4,000 / h` | **€0.34** |
| **`GLASS_075`** | 0.75L Returnable Glass | Amber Glass 450g | `3,280 / h` | **€0.68** |

* **Three 8-Hour Shifts (`480.0 min` planned per line per shift):**
  * **`S1` (Morning Shift):** `06:00 – 14:00` *(Full controls, QA, and mechanical maintenance support on site)*.
  * **`S2` (Afternoon Shift):** `14:00 – 22:00` *(Standard production crew)*.
  * **`S3` (Night Shift):** `22:00 – 06:00` *(Reduced night crew. Because this shift crosses midnight, use `(timestamp - 6h)` to assign readings between `00:00` and `05:45` to the shift's starting operational date!)*.

---

## 3. Main Business Problems

Despite strong retail demand, Plant #1 is struggling with unexplained cost overruns and missed efficiency targets:
1. **Sub-Target Plant OEE:** Management targets **>= 85.0% OEE (Overall Equipment Effectiveness)** across the bottling hall. Summary spreadsheets show plant-wide averages hovering near **70%**, masking whether losses come from **Availability** (stoppages), **Performance** (slow line speed), or **Quality** (rejected/broken bottles). Naive unweighted averages and midnight shift splits hide severe losses on specific **Line × Shift × Bottle Format** combinations.
2. **Rising Reject & Downtime Losses:** Over the **60-day window**, bottle rejections (especially expensive `GLASS_075` breakage) and unplanned stoppages cost hundreds of thousands of Euros, while average repair times significantly exceed the **60-minute target (`MTTR <= 60 min`)**.
3. **Reactive Instead of Condition-Based Maintenance:** Technicians currently overhaul filling valves only *after* a breakdown stops the line. Maintenance leadership lacks reliable evidence showing at what cumulative **`valve_cycles_k`** threshold—and accompanying thermal drift (`delta_temp_C = pasteurizer_temp_C - ambient_temp_C`) and filler pressure—unplanned stoppages spike sharply.

---

## 4. Two Executive Perspectives (Dual-Track Cockpit)

### 🅰️ Perspective A: Chief Operations Officer (COO / Plant Director)
* **Main Goal:** Lift weighted plant OEE toward **>= 85.0%**, pinpoint hidden **Shift × Line × Format** bottlenecks, keep reject rate below **2.0%**, and quantify combined reject + unplanned downtime losses in Euros.
* **Decisions Supported:** Which bottling lines should run returnable `GLASS_075`, how to schedule night shifts (`S3`), and where to prioritize capital/process upgrades.
* **Out of Scope:** Raw 15-minute PLC pressure traces or technician work-order tickets.

### 🅱️ Perspective B: Head of Maintenance & Reliability
* **Main Goal:** Reduce average repair duration (**MTTR <= 60 min**), increase Mean Time Between Failures (**MTBF**), rank root causes via a **Stoppage Pareto**, and replace worn valve seals *before* catastrophic leaks happen.
* **Decisions Supported:** Set a data-backed preventive overhaul limit on **`valve_cycles_k`**, align spare parts and technician teams, and establish early thermal/pressure warning thresholds.
* **Out of Scope:** High-level commercial margin spreadsheets that hide physical failure modes.

---

## 5. Available 60-Day Data (`lab_02_bronze_ingestion_and_profiling/data/case0_europack_bottling/`)

The dataset spans **60 continuous 24/7 operational days** (`2026-10-01` – `2026-11-29`; night shift `S3` of `2026-11-29` finishes on `2026-11-30 06:00`, with the last 15-minute reading at `05:45:00`) across three heterogeneous source files:

1. **`line_telemetry.csv` (15-min PLC Telemetry, 23,164 rows):** `timestamp`, `line_id`, `bottle_format`, `ambient_temp_C`, `pasteurizer_temp_C`, `conveyor_speed_bpm`, `filler_pressure_bar`, `valve_cycles_k`, `bottled_units`, `rejected_units`.
   * *Known Data Quality Issues to Profile & Clean (Labs 03–04):* Whitespace/casing/alias drift (`"Line_A "`, `"LN-B"`, `"line_c"`), orphan test-bench ID (`LINE_Z`), future timestamps (`2099-*`), MQTT duplicate rows, missing `pasteurizer_temp_C` readings (`NaN` — do **not** drop these rows; interpolate linearly over time!), out-of-envelope filler pressures (`-99.0` and `85.0` bar outside `[0.0, 12.0]` bar), and impossible counts (`rejected_units > bottled_units` / negative `bottled_units`).
2. **`stoppage_logs.json` (CMMS Line Stoppages, 292 records):** `log_id`, `event_date`, `line_code`, `stoppage_type` (`'Unplanned'` / `'unplanned'` / `'Preventive'`), `root_cause`, `downtime_min`, `technician_team`.
   * *Known Data Quality Issues:* Alias/whitespace keys (`"Line_A "`, `"LN-B"`), lowercase `'unplanned'`, duplicate `log_id` records, and phantom ghost log `STOP-20269999` (`LINE_Z`, `2099-01-01`).
3. **`plant_master_data.xlsx` (ERP Master Data, 3 Sheets):** `Lines`, `Shifts` (`S1/S2/S3`, `480 min`), and `Bottle_Formats`.

> [!IMPORTANT]
> **Avoid the Capacity Fan-Out Trap (Labs 04–06):** Multiple bottle formats (`PET_05`, `PET_15`, `GLASS_075`) can run on the same line during a single 8-hour shift. Always pro-rate **`planned_time_min`** proportionally by `time_share` inside each line-shift so `SUM(planned_time_min)` equals **exactly `480.0 min`**, and pre-aggregate stoppage events before joining production facts so rows are never multiplied!
