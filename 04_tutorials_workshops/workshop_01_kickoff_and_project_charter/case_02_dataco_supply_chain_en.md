# Case Study 02: DataCo Industrial Hydraulics Distribution
## Delivery Reliability (OTIF), Warehouse Bottlenecks & True Net Margin

**Course:** Business Intelligence and Big Data Analysis (`01 31 0367 00`)  
**Target Milestone:** Workshop #1 — Project Charter & Goal Setting  
**Language:** English (`EN`)

---

## 1. Company & Industry Context

### 1.1 The European Industrial Hydraulics Market
Factories, underground mines, and heavy press builders depend on high-pressure hydraulic pumps, control valves, cylinders, filters, and steel hoses. If a hydraulic hose bursts or a valve breaks, an entire factory machine stops within seconds.

Because downtime is so costly, industrial buyers sign strict delivery contracts (**Service Level Agreements / SLAs**): the European standard requires **>= 92.0% On-Time In-Full (OTIF)** delivery. Late or incomplete deliveries trigger automatic **cash penalties**.

### 1.2 Company Profile: DataCo Industrial Hydraulics Distribution
**DataCo Industrial Hydraulics Distribution Sp. z o.o.** runs a four-warehouse European network delivering **12 standardized hydraulic products (SKUs)** to **16 B2B business customers** grouped into four customer segments:
* **`VIP Heavy OEM`:** Large continuous assembly plants buying under high-discount volume contracts.
* **`Mining & Tunneling`:** Heavy mining companies that need tough cylinders, hoses, and fast emergency replacements.
* **`Press Builder OEM`:** Machine builders buying precision hydraulic pumps and control valves.
* **`Regional MRO`:** Local factory maintenance teams ordering replacement filters and spare parts.

---

## 2. Warehouse Network & Product Catalog

### 2.1 Four Warehouses (Hubs) & Transport Carriers (`Warehouses` & `Carrier_SLA_Policies`)

| Warehouse Hub | Region Served | Special Operations / Bottleneck Risk |
| :--- | :--- | :--- |
| **`HUB-Central-Frankfurt`** | Germany, Austria, Switzerland & Western Europe | Fast automated picking and export shipping for pumps and valves |
| **`HUB-Poland-Wroclaw`** | Lower Silesia Automotive Factories | Mixed pallet shipping and factory assembly spare parts |
| **`HUB-South-Katowice`** | Upper Silesia Heavy Industry | Includes the **high-pressure water test bench & hose assembly bays** needed before dispatch! |
| **`HUB-North-Gdansk`** | Baltic & Nordic Port Corridor | Regional staging for cylinders, valves, and MRO spare parts |

Each hub ships orders using four external transport companies (3PL carriers: **`DHL_EXPRESS`**, **`DB_SCHENKER`**, **`UPS_FREIGHT`**, **`RABEN_LOGISTICS`**) across four delivery speeds:
* **`Same Day` (`1d` SLA)** and **`First Class` (`2d` SLA)** — urgent breakdown shipping with high courier prices and strict late penalties.
* **`Second Class` (`4d` SLA)** and **`Standard Class` (`6d` SLA)** — planned regular restocking.

### 2.2 Product Catalog (`Products` Sheet, 5 Categories / 12 SKUs)
1. **Hydraulic Pumps** *(High price, high gross profit)*
2. **Control Valves** *(Precision flow control parts)*
3. **Actuators & Cylinders** *(Heavy motion equipment)*
4. **High-Pressure Hoses** *(Lower-price consumables that must pass mandatory high-pressure safety testing before leaving the warehouse)*
5. **Filtration & Conditioning** *(Regular replacement filter cartridges)*

---

## 3. Main Business Problems

DataCo's management faces three major problems across the **60-day operating window**:
1. **OTIF Crisis vs. 92.0% Contract Target:** Network OTIF is far below **92.0%**, costing DataCo around **€100,000** in late-delivery penalties every two months. Monthly hub averages hide *where* the delay actually starts: is it slow truck transit on the road, or waiting time inside the warehouse (**`warehouse_dwell_hours`**) at test bays and loading gates?
2. **High Sales Hiding Real Money Losses:** Sales managers celebrate high gross revenue from large VIP accounts. However, standard ERP sales reports look at profit **before** subtracting actual urgent shipping costs and late penalties. Combining big discounts (**15–23%**) with expensive urgent delivery on lower-priced products can turn orders into **negative net profit**!
3. **Double-Counting Trap (Fan-Out):** On average, each order contains **~1.8 product lines** (`~8,450+` clean lines across `~4,770+` orders). Freight cost (`freight_cost_eur`) and late penalties (`sla_penalty_eur`) exist once per order, not per item line. If you join order-level costs directly onto product lines without splitting them proportionally by each line's share of order net revenue (**revenue pro-rata allocation**), you count logistics costs nearly twice!

---

## 4. Two Executive Perspectives (Track A vs. Track B)

### 🅰️ Perspective A: VP Commercial & Pricing Control
* **Main Goal:** Protect real operating profit (`Net Revenue - COGS - Allocated Freight - Allocated SLA Penalty`), stop harmful discounts, and find unprofitable **`Segment × Category`** combinations.
* **Out of Scope (Does NOT Want):** Warehouse test-bench queue logs or truck gate scan timestamps.

### 🅱️ Perspective B: Director of Supply Chain & Logistics
* **Main Goal:** Raise network **OTIF >= 92.0%**, separate *On-Time* failures from *In-Full* failures, measure `warehouse_dwell_hours` (`DISPATCHED_FROM_HUB - ORDER_CONFIRMED`), compare underperforming hubs and 3PL carriers, and cut SLA penalties.
* **Out of Scope (Does NOT Want):** Sales rep commission details or commercial discount rules.

---

## 5. Available 60-Day Data (`data/bronze/`)

The simulation covers **60 business days** (`2026-10-01` – `2026-11-29`) across three files:

1. **`order_items_trans.csv` (ERP Sales Order Lines, 8,623 rows):** Line-level records (`order_id`, `order_date`, `customer_id`, `product_id`, `ordered_qty`, `delivered_qty`, `unit_price_eur`, `discount_rate`). *(Note: shipping columns come from `shipment_events.json` at the order level; splitting order freight and penalties across lines can create tiny ~€0.05 rounding differences compared to header totals).*
   * *Known Data Errors to Clean:* `~85` duplicate order-product lines, mixed ISO (`YYYY-MM-DD`) and European (`%d/%m/%Y %H:%M`) dates (be careful not to swap day and month!), negative discounts (`-0.05`), percentage typos (`15.0` instead of `0.15`), unknown product IDs (`SKU-GHOST-99`), impossible deliveries (`delivered_qty > ordered_qty`), and missing `unit_price_eur` (`NaN` — fill from master catalog `standard_cost_eur * list_markup`, do not drop rows!).
2. **`shipment_events.json` (Warehouse & Carrier Scans, 22,746 events):** Tracking steps (`event_id`, `timestamp`, `event_type` [`ORDER_CONFIRMED`, `PICKING_COMPLETED`, `DISPATCHED_FROM_HUB`, `IN_TRANSIT_HUB_SCAN`, `DELIVERED_AT_GATE`, `DELIVERY_EXCEPTION`], `order_id`, `warehouse_hub`, `shipping_mode`, `carrier_code`, `scheduled_shipping_days`, `freight_cost_eur`, `sla_penalty_eur`).
   * *Known Data Errors to Clean:* Trailing spaces (`"Standard Class  "`) splitting shipping categories, and corrupted `145-day` `DELIVERY_EXCEPTION` delays distorting averages.
3. **`master_catalog.xlsx` (Master Data Workbook, 4 Sheets):** `Products`, `Customers`, `Warehouses`, and `Carrier_SLA_Policies`.

---

## 6. What to Deliver in Workshop #1
Complete [`project_charter_template.md`](project_charter_template.md) with:
1. Your assigned Perspective (**A** or **B**);
2. Your data quality & audit plan (`Data Quality Gate 1` / `Proces DQ Gate 1`: deduplication, mixed-date parsing, discount scaling, quarantine log, and pro-rata cost allocation);
3. Your **Gartner ITScore** check (`As-Is` vs `To-Be`);
4. **3 measurable SMART-BI questions**.
