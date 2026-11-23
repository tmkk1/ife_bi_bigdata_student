# Case Study 01: SmartPress Automotive Components
## Factory Production Performance, Machine Reliability & OEE

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Target Milestone:** Workshop #1 — Project Charter & Goal Setting  
**Language:** English (`EN`)

---

## 1. Company & Industry Context

### 1.1 The Automotive Supply Chain (JIT & JIS)
Modern car manufacturers (such as Volkswagen, Stellantis, and Toyota) run their assembly lines using **Just-In-Time (JIT)** and **Just-In-Sequence (JIS)** delivery. Their plants keep almost no backup stock—often less than **2 to 4 hours** of parts next to the assembly line.

Because of this, **Tier-1 suppliers** (companies that deliver directly to car makers) cannot afford late or missing deliveries. Any mistake that stops a car assembly line leads to financial penalties of **€5,000 to €15,000 per minute** and damages the supplier's chance of winning future contracts.

### 1.2 Company Profile: SmartPress Automotive Components
**SmartPress Automotive Components Sp. z o.o.** runs a metal stamping factory in **Poznań, Poland (Plant #3)**. The factory presses flat steel coils into structural car body parts (*Body-in-White*):
* **A-Pillars & B-Pillars:** Safety-critical cabin support pillars pressed from Advanced High-Strength Steel (AHSS).
* **Chassis Crossmembers & Suspension Brackets:** Strong mounting parts that must match exact size limits.
* **Battery Frame Brackets (EV):** Deep-pressed structural brackets for electric vehicle battery frames.

```
                     AUTOMOTIVE SUPPLY CHAIN POSITION
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Tier-2 Steel Mills   │ ───► │  SmartPress Automotive  │ ───► │ Car Makers (OEMs)      │
 │ (Steel Coils L/M/H)  │      │  (Poznań Plant #3)      │      │ (JIT Assembly Lines)   │
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. How the Factory Works

### 2.1 Production Steps (Stamping Hall T-2)
Inside Stamping Hall T-2, automated press lines make parts in four steps:
1. **Uncoiling & Feeding:** Large steel rolls (coils) are unrolled, flattened, and fed into the press.
2. **Stamping & Forming (`600 T – 1,200 T`):** Heavy presses cut, bend, and shape the metal into 3D car parts.
3. **Camera Quality Check (AOI):** High-speed optical cameras inspect parts and count defective pieces (`scrap_units`).
4. **Scrap Recycling:** Leftover steel and rejected parts go into recycling bins.

### 2.2 Stamping Presses (`Machines` Sheet)
The factory operates four presses listed in `machines_and_shifts.xlsx`:

| Machine ID | Press Model & Drive Type | Force (Tonnage) | Standard Cycle Time | Downtime Cost (€/h) |
| :--- | :--- | :---: | :---: | :---: |
| **`PRESS_01`** | **Schuler Servo Direct Drive** *(Programmable speed control)* | `1,000 T` | **3.5 sec/part** | **€250 / hour** |
| **`PRESS_02`** | **Legacy Komatsu Mechanical Flywheel** *(Older mechanical clutch press)* | `800 T` | **4.0 sec/part** | **€220 / hour** |
| **`PRESS_03`** | **AIDA Heavy Transfer Press** *(Rigid multi-step press for thick parts)* | `1,200 T` | **3.2 sec/part** | **€280 / hour** |
| **`PRESS_04`** | **Schuler High-Speed Progressive** *(Fast press for small brackets)* | `600 T` | **2.8 sec/part** | **€190 / hour** |

### 2.3 Steel Variants (`Product_Variants` Sheet) & Work Shifts (`Shifts` Sheet)
* **Variant `L` (Mild Steel):** Soft and easy to press, needs low force, low material cost per scrapped part.
* **Variant `M` (Medium-Strength Steel / HSLA):** Medium forming force and medium tool wear.
* **Variant `H` (High-Strength Steel / AHSS):** Very strong steel (`600–1,000 MPa`). It needs maximum press force, costs a lot when a part is scrapped, and heats up the pressing tools faster through friction.
* **Three 8-Hour Shifts (`480 min` planned per press per shift):**
  * **`S1` (Morning):** `06:00 – 14:00` *(Full tooling and maintenance engineering team on site)*.
  * **`S2` (Afternoon):** `14:00 – 22:00` *(Standard production team)*.
  * **`S3` (Night):** `22:00 – 06:00` *(Small night crew. Because this shift crosses midnight, use `(timestamp - 6h)` to assign events after `00:00` to the right shift start date!)*.

---

## 3. Main Business Problems

Even though customer orders are full, Plant #3 is losing money and failing customer stability audits:
1. **Low OEE Performance:** The corporate target for **OEE (Overall Equipment Effectiveness)** is **>= 85.0%**. Weekly Excel reports show an average around **70%**, without showing if the problem comes from machine stops (**Availability**), slow cycle speed (**Performance**), or defective parts (**Quality**). Simple averages and midnight calendar splits also hide major losses on specific machines and shifts.
2. **High Downtime & Scrap Costs:** Over the **60-day period**, unplanned breakdowns and wasted high-strength `Variant H` steel cost hundreds of thousands of Euros. Night-shift repairs are also much slower than the **60-minute target (`MTTR <= 60 min`)**.
3. **Reactive Maintenance Instead of Preventive Maintenance:** Maintenance currently fixes presses only *after* they break. They do not yet have clear data showing at what exact cumulative **`tool_wear_min`**, temperature difference (`delta_temp_K`), and torque (`torque_Nm`) tools begin to overheat, seize, or create scrap.

---

## 4. Two Executive Perspectives (Track A vs. Track B)

### 🅰️ Perspective A: Chief Operations Officer (COO)
* **Main Goal:** Reach **>= 85.0% OEE**, protect customer deliveries, find hidden losses by **Press × Shift × Steel Variant**, and calculate downtime + scrap waste in Euros.
* **Decisions Supported:** Which press should run high-strength `Variant H` parts, how to plan night shifts (`S3`), and where to invest improvement budgets.
* **Out of Scope (Does NOT Want):** Raw 15-minute sensor curves or technician repair details.

### 🅱️ Perspective B: Head of Maintenance & Reliability
* **Main Goal:** Cut average repair time (**MTTR <= 60 min**), increase time between breakdowns (**MTBF**), rank top failure causes (Pareto chart), and replace/regrind tools *before* they break.
* **Decisions Supported:** Set a clear `tool_wear_min` limit for preventive tool changes, plan spare parts and night-shift maintenance staff, and set safe temperature/torque warning limits.
* **Out of Scope (Does NOT Want):** Corporate financial margin tables that hide physical machine failure causes.

---

## 5. Available 60-Day Data (`data/bronze/`)

The dataset covers **60 continuous 24/7 days** (`2026-10-01` – `2026-11-29`; night shift `S3` of `2026-11-29` ends on `2026-11-30 06:00`, with the last 15-minute log at `05:45:00`) across three files:

1. **`sensor_telemetry.csv` (SCADA Sensor Logs, ~23,164 rows):** 15-minute machine readings (`timestamp`, `machine_id`, `product_variant`, `air_temp_K`, `process_temp_K`, `rotational_speed_rpm`, `torque_Nm`, `tool_wear_min`, `produced_units`, `scrap_units`).
   * *Known Data Errors to Clean:* Messy machine names (`"Press_01 "`, `"P-02"`, `"press_03"`), fake machine ID (`PRESS_99`), wrong future dates (`2099-*`), duplicate message rows, missing `process_temp_K` values (`NaN` — do **not** drop these rows; interpolate them over time!), impossible torque values (`-999 Nm`, `4850 Nm`), and `scrap_units > produced_units`.
2. **`maintenance_logs.json` (CMMS Repair Tickets, 286 records):** Repair tickets (`ticket_id`, `event_date`, `machine_code`, `downtime_type` [`'Unplanned'` / `'unplanned'` / `'Preventive'`], `failure_mode`, `repair_duration_min`).
   * *Known Data Errors & Cleaning Rules:* Fake ticket `CMMS-20269999` (`PRESS_99`, `2099-01-01`, `'Phantom Ticket'`), messy machine names (`'Press_01 '`, `'P-02'`), lowercase `'unplanned'`, plus guard against `repair_duration_min <= 0` and map any missing `failure_mode` to `'Brak danych / Unspecified'` *(Polish for "No data / Unspecified")*.
3. **`machines_and_shifts.xlsx` (ERP Master Data, 3 Sheets):** `Machines` (press model & drive type, cycle time, operating/downtime cost €/h), `Shifts` (`S1/S2/S3`, 8h / `480 min`), and `Product_Variants` (`L/M/H` steel grade, target hourly output, and scrap material cost €/part).

> [!IMPORTANT]
> **Avoid Double-Counting (Fan-Out Trap):** Multiple steel variants (`L/M/H`) can run on the same press during one 8-hour shift. In Gold `Fact_Shift_Production`, split **`planned_time_min`** proportionally across variants inside each press-shift so `SUM(planned_time_min)` equals **exactly `480.0 min`**. Always aggregate breakdowns separately before joining so you do not multiply production rows!

---

## 6. What to Deliver in Workshop #1
Complete [`project_charter_template.md`](project_charter_template.md) with:
1. Your assigned Perspective (**A** or **B**);
2. Your data quality & audit plan (`Data Quality Gate 1` / `Proces DQ Gate 1` and quarantine log);
3. Your **Gartner ITScore** check (`As-Is` vs `To-Be`);
4. **3 measurable SMART-BI questions** targeting the hidden 60-day losses.
