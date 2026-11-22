# Case Study 00 (Guided Lab Dataset): EuroPack Beverage Bottling
## Bottling Line Performance, Machine Reliability & OEE

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Role:** Practice Dataset used across **Guided Labs 02–10** *(separate from graded team project Cases 1, 2, and 3)*  
**Language:** English (`EN`)

---

## 1. Company & Industry Context

### 1.1 Fast Beverage Bottling & Store Deliveries
Beverage bottling plants that supply European supermarkets, hotels, and restaurants must deliver orders **on time and in full (OTIF)** while meeting strict food-safety and freshness rules. High-speed bottling lines run **24/7 across three shifts** to keep up with supermarket stock orders and summer demand spikes.

Because profit per bottle is small, unexpected machine stops, heating problems in the pasteurizer, or broken bottles quickly wipe out profits. Late deliveries also lead to fines and lost shelf space in stores.

### 1.2 Company Profile: EuroPack Beverage Bottling Sp. z o.o.
**EuroPack Beverage Bottling Sp. z o.o.** runs an automated drink bottling plant in **Gdańsk, Poland (Plant #1)**. The plant fills, pasteurizes, caps, labels, and packs still water, sparkling drinks, and returnable glass bottles across four automated lines:
* **0.5L Still Water PET (`PET_05`):** Lightweight recycled plastic bottle (`rPET Light 18g`) made at very high speed.
* **1.5L Sparkling PET (`PET_15`):** Fizzy drink bottle (`PET Carbonated 34g`) that needs steady pressure during filling.
* **0.75L Returnable Glass (`GLASS_075`):** Heavy brown glass bottle (`Amber Glass 450g`) with the highest cost per rejected bottle and strict limits on heat and handling shocks.

```
                     BEVERAGE BOTTLING VALUE CHAIN
 ┌──────────────────────┐      ┌─────────────────────────┐      ┌────────────────────────┐
 │ Bottle, Glass &      │ ───► │ EuroPack Beverage       │ ───► │ Supermarkets &         │
 │ Syrup Suppliers      │      │ Bottling (Gdańsk #1)    │      │ Restaurants            │
 └──────────────────────┘      └─────────────────────────┘      └────────────────────────┘
```

---

## 2. How the Bottling Plant Works

### 2.1 Production Steps (Bottling Hall B-1)
Inside Bottling Hall B-1, each automated bottling line makes drinks in four continuous steps:
1. **Rinsing & Feeding:** Empty plastic (`PET`) or returnable glass bottles enter the high-speed conveyor (`conveyor_speed_bpm`, bottles per minute).
2. **Filling & Capping:** Pressurized rotating valves (`filler_pressure_bar`, normal range `[0.0, 12.0]` bar) fill and cap the bottles while machine counters track total valve use (`valve_cycles_k`, in thousands of cycles).
3. **Tunnel Pasteurization:** Filled bottles move through a heated tunnel checked by room temperature (`ambient_temp_C`) and pasteurizer temperature (`pasteurizer_temp_C`) sensors.
4. **Camera Quality Check & Rejects:** High-speed cameras check fill level, cap seal, and glass condition, counting good filled bottles (`bottled_units`) and rejected bottles (`rejected_units`).

### 2.2 Bottling Lines (`Lines` Sheet in `plant_master_data.xlsx`)
The plant runs four bottling lines listed in `plant_master_data.xlsx`:

| Line ID | Line Name | Filler Technology | Standard Cycle Time | Downtime Cost (€/h) |
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
  * **`S1` (Morning Shift):** `06:00 – 14:00` *(Full engineering, quality, and repair teams on site)*.
  * **`S2` (Afternoon Shift):** `14:00 – 22:00` *(Standard production crew)*.
  * **`S3` (Night Shift):** `22:00 – 06:00` *(Smaller night crew. Because this shift crosses midnight, use `(timestamp - 6h)` to assign readings between `00:00` and `05:45` to the date when the shift started!)*.

---

## 3. Main Business Problems

Even with strong customer demand, Plant #1 is overspending and missing its efficiency targets:
1. **Low Plant OEE:** Management aims for **OEE >= 85.0%** (Overall Equipment Effectiveness) across the bottling hall. Weekly spreadsheets show a plant-wide average near **70%**, without showing whether losses come from machine stops (**Availability**), slow line speed (**Performance**), or rejected/broken bottles (**Quality**). Simple unweighted averages and splitting the night shift at midnight also hide major losses on specific **Line × Shift × Bottle Format** combinations.
2. **High Reject & Stoppage Costs:** Over the **60-day period**, rejected bottles (especially expensive `GLASS_075` glass breakage) and unexpected stoppages cost hundreds of thousands of Euros. Average repair times are also much longer than the **60-minute target (`MTTR <= 60 min`)**.
3. **Fixing After Breakdowns Instead of Early Maintenance:** Technicians currently overhaul filling valves only *after* a line breaks down. Maintenance leaders do not yet have clear data showing at what **`valve_cycles_k`** count—along with temperature gap (`delta_temp_C = pasteurizer_temp_C - ambient_temp_C`) and filler pressure—unexpected stoppages jump sharply.

---

## 4. Two Executive Perspectives (Track A vs. Track B)

### 🅰️ Perspective A: Chief Operations Officer (COO / Plant Director)
* **Main Goal:** Raise weighted plant OEE toward **>= 85.0%**, find hidden **Shift × Line × Format** bottlenecks, keep the reject rate below **2.0%**, and calculate total reject + unplanned downtime losses in Euros.
* **Decisions Supported:** Which bottling lines should run returnable `GLASS_075`, how to plan night shifts (`S3`), and where to invest upgrade budgets.
* **Out of Scope (Does NOT Want):** Raw 15-minute sensor pressure traces or individual repair ticket notes.

### 🅱️ Perspective B: Head of Maintenance & Reliability
* **Main Goal:** Cut average repair time (**MTTR <= 60 min**), increase time between failures (**MTBF**), rank top failure causes with a **Stoppage Pareto**, and replace worn valve seals *before* big leaks happen.
* **Decisions Supported:** Set a clear preventive replacement limit on **`valve_cycles_k`**, plan spare parts and technician teams, and set early temperature/pressure warning thresholds.
* **Out of Scope (Does NOT Want):** High-level financial margin tables that hide physical machine failure causes.

---

## 5. Available 60-Day Data (`lab_02_bronze_ingestion_and_profiling/data/case0_europack_bottling/`)

The dataset covers **60 continuous 24/7 days** (`2026-10-01` – `2026-11-29`; night shift `S3` of `2026-11-29` finishes on `2026-11-30 06:00`, with the last 15-minute reading at `05:45:00`) across three files:

1. **`line_telemetry.csv` (15-min Machine Sensor Data, 23,164 rows):** `timestamp`, `line_id`, `bottle_format`, `ambient_temp_C`, `pasteurizer_temp_C`, `conveyor_speed_bpm`, `filler_pressure_bar`, `valve_cycles_k`, `bottled_units`, `rejected_units`.
   * *Known Data Errors to Clean (Labs 03–04):* Messy line names with extra spaces, lowercase, or old codes (`"Line_A "`, `"LN-B"`, `"line_c"`), fake test line ID (`LINE_Z`), impossible future dates (`2099-*`), duplicate message rows, missing `pasteurizer_temp_C` values (`NaN` — do **not** drop these rows; fill them with time interpolation!), out-of-range filler pressures (`-99.0` and `85.0` bar outside `[0.0, 12.0]` bar), and impossible counts (`rejected_units > bottled_units` or negative `bottled_units`).
2. **`stoppage_logs.json` (Maintenance Stoppage Logs, 292 records):** `log_id`, `event_date`, `line_code`, `stoppage_type` (`'Unplanned'` / `'unplanned'` / `'Preventive'`), `root_cause`, `downtime_min`, `technician_team`.
   * *Known Data Errors:* Extra spaces or old line codes (`"Line_A "`, `"LN-B"`), lowercase `'unplanned'`, duplicate `log_id` entries, and fake ghost log `STOP-20269999` (`LINE_Z`, `2099-01-01`).
3. **`plant_master_data.xlsx` (ERP Reference Data, 3 Sheets):** `Lines`, `Shifts` (`S1/S2/S3`, `480 min`), and `Bottle_Formats`.

> [!IMPORTANT]
> **Avoid Double-Counting (Fan-Out Trap, Labs 04–06):** Several bottle formats (`PET_05`, `PET_15`, `GLASS_075`) can run on the same line during one 8-hour shift. Always split **`planned_time_min`** proportionally by `time_share` inside each line-shift so `SUM(planned_time_min)` equals **exactly `480.0 min`**, and aggregate stoppage logs separately before joining production data so rows are never multiplied!
