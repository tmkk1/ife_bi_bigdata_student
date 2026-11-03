# Course: Business Intelligence and Big Data Analysis (`01 31 0367 00`)

## Academic & Technical Synthesis — Lecture 02: Data Ingestion, Pipelines & Enterprise Architectures

**Language:** English (`EN`)  
**Semester:** Fall / Spring  
**Audience:** 4th Year B.Sc. Engineering (Management and Production Engineering)

---

## 1. The Engineering Mission & End-to-End Architecture

To construct an automated, resilient ingestion bridge capable of ingesting raw, dirty, unintegrated files (CSV, nested JSON, multi-sheet Excel), resolving severe temporal granularity mismatches, and building an idempotent, structured staging pipeline.

```text
                    THE END-TO-END INDUSTRIAL DATA JOURNEY
                    
 ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
 │ SOURCE SYSTEMS  │ ────► │  LANDING LAYER  │ ────► │ STORAGE & TABLES│
 │ (MES/ERP/SCADA) │       │ (Bronze/Raw Ingest)     │ (Parquet/Iceberg)│
 └─────────────────┘       └─────────────────┘       └─────────────────┘
                                                               │
                                                               ▼
 ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐
 │   BI SERVING    │ ◄──── │  MODELING (GOLD)│ ◄──── │ QUALITY (SILVER)│
 │ (PowerBI/Looker)│       │ (Kimball Schema)│       │ (Clean/Dedupe)  │
 └─────────────────┘       └─────────────────┘       └─────────────────┘
```

> **The Golden Engineering Axiom:** *Ingestion is the front door of your data architecture. If ingestion fails or admits corrupted records silently, every downstream dashboard, analytical model, and executive decision is compromised.*

---

## 2. Ingestion Channels & Extraction Mechanics

1. **Change Data Capture (CDC) & DB Replication:** Reading relational engine transaction logs (e.g., PostgreSQL/Oracle via Debezium) non-intrusively. Captures row-level `INSERT`, `UPDATE`, and `DELETE` operations without placing query overhead on operational CPUs.
2. **Batch File Drops & Object Storage:** Automated batch dumps (CSV, Excel, Parquet) transferred via secure SFTP or deposited into cloud object buckets (GCS / AWS S3).
3. **REST APIs & Webhooks:** Pulling semi-structured JSON payloads from external or SaaS providers (e.g., dynamic utility energy tariffs, courier tracking, supplier catalogs).
4. **Industrial IoT Streaming:** Low-overhead publish/subscribe protocols (MQTT, OPC-UA) streaming high-frequency sensor readings from edge PLCs to message brokers.

---

## 3. Ingestion Strategies: Full vs. Incremental

* **Full Load (Snapshot / Truncate & Reload):**
  * *Mechanism:* The entire source dataset is extracted, completely overwriting the destination table.
  * *Application:* Small, slowly changing reference tables (e.g., machine registries, operator rosters).
  * *Limitation:* Does not scale for high-volume telemetry; creates severe network I/O and database compute bottlenecks.
* **Incremental Load (Delta Append / Upsert):**
  * *Mechanism:* Ingests only records created or modified since the last execution window.
  * *Prerequisites:* Requires an immutable watermark timestamp (`updated_at > :last_run`) or transaction log CDC.
  * *Application:* High-volume telemetry, transactional order streams, maintenance event logs.
  * *Trade-off:* Requires robust deduplication logic to guard against timestamp drift or repeated records.

---

## 4. Operational Engineering: Historical Backfilling

Backfilling is the process of running a data pipeline retroactively across a historical window.

* **Primary Triggers in Industry:**
  1. *Initial Deployment:* Launching a new BI platform requiring 12 to 24 months of historical performance baselines.
  2. *Bug Fixes & Logic Re-definitions:* Adjusting a corrupted KPI formula (e.g., scrap calculation) and reprocessing past history.
  3. *Upstream Outages & Recovery:* Reprocessing data backlogs following network dropouts or shopfloor server downtime.
* **Naive Backfills vs. Governed Backfills:**
  * *Naive:* Executing a single massive query covering months of historical data. Leads to database crashes, API rate-limiting blocks, and duplicate records.
  * *Governed:* Chunking workflows into isolated time windows (e.g., day-by-day), executing partition overwrites, and leveraging orchestrator backfill parameters (`catchup=True`).

---

## 5. File Format Architectures: Row-Based vs. Columnar

```text
                        ROW-BASED STORAGE (CSV, PostgreSQL)
 ┌─────────────────────────────────────────────────────────────────────────────┐
 │ Row 1: [ID: 1, Machine: P01, Status: RUN, Temp: 310.2]                      │
 │ Row 2: [ID: 2, Machine: P01, Status: RUN, Temp: 310.4]                      │
 │ Row 3: [ID: 3, Machine: P01, Status: WARN, Temp: 328.0]                     │
 └─────────────────────────────────────────────────────────────────────────────┘
  * Query: SELECT AVG(Temp) -> Storage controller MUST read every single byte 
    across all columns from disk. Discards up to 75-90% of retrieved I/O.

                      COLUMNAR STORAGE (Apache Parquet, DuckDB)
 ┌──────────────┬────────────────────────┬───────────────────┬─────────────────┐
 │ ID Chunk     │ Machine Chunk          │ Status Chunk      │ Temp Chunk      │
 │ [1, 2, 3]    │ ["P01", "P01", "P01"]  │ ["RUN","RUN","WRN"]│ [310.2,310.4,...│
 └──────────────┴────────────────────────┴───────────────────┴─────────────────┘
  * Query: SELECT AVG(Temp) -> Engine jumps straight to byte address of Temp Chunk.
    Zero bytes read for ID, Machine, or Status (Projection Pushdown).
```

### 5.1 Mechanical Sympathy & Compression Algorithms
Physical disk I/O represents the slowest operation in analytical computing. Columnar formats achieve massive read-speed gains and 70–90% compression ratios through homogeneous data packing:
* **Dictionary Encoding:** Replaces repeated string values with compact integer references:

$$\text{String Stream: } [\text{"RUN"}, \text{"RUN"}, \text{"WARN"}] \implies \text{Lookup: } \{0: \text{"RUN"}, 1: \text{"WARN"}\} \implies [0, 0, 1]$$

* **Run-Length Encoding (RLE):** Compresses consecutive repeated elements into count-value pairs:

$$\text{Sequence: } [\text{"P01"}, \text{"P01"}, \text{"P01"}, \text{"P02"}] \implies (\text{"P01"}, 3), (\text{"P02"}, 1)$$

* **The Trade-Off:** Columnar formats are inefficient for single-row transactional writes (OLTP), as appending a single row requires updating multiple distinct physical column chunks.

### 5.2 Comparative Matrix of File Formats

| Feature / Metric | CSV (Comma-Separated Values) | JSON / JSONL (Line-Delimited) | Apache Parquet |
| :--- | :--- | :--- | :--- |
| **Physical Layout** | Row-oriented plain text | Row-oriented text hierarchy | Columnar binary |
| **Schema Enforcement** | None (inferred at parse-time) | Semi-structured / dynamic | Strict embedded schema metadata |
| **Compression Ratio** | Poor (heterogeneous lines) | Poor (repetitive key strings) | Extreme ($70\% - 90\%$ via Snappy/Zstd) |
| **Analytical Query Speed** | Slow (full file scan required) | Slow (CPU-heavy text parsing) | Blazing fast (Projection/Predicate Pushdown) |
| **Best Used For** | Universal manual exports | Web APIs, streaming brokers | Big Data, OLAP Data Warehouses, Lakes |

### 5.3 Deep Dive: Anatomy of an Apache Parquet File
* **Magic Header (`PAR1`):** 4-byte verification string at the beginning and end of the binary file.
* **Row Groups:** Horizontal partitions of table data, typically sized between $128\text{ MB}$ and $512\text{ MB}$.
* **Column Chunks:** Vertical slices within a Row Group containing the data for an individual column.
* **Pages:** The fundamental unit of data storage within a Column Chunk (typically $1\text{ MB}$), where RLE, dictionary encoding, and compression algorithms (Snappy, Zstd) are applied.
* **File Footer (Read First):** Contains comprehensive metadata, including explicit schemas, byte offsets, null counts, and minimum/maximum values for every column within every Row Group:
  * **Projection Pushdown:** The engine parses the footer and reads only the specific column chunks needed for the query, skipping all irrelevant columns.
  * **Predicate Pushdown:** The engine compares query filters (e.g., `WHERE Temp > 350`) against the footer's min/max statistics, skipping entire Row Groups without decompressing them from disk.

---

## 6. Core Ingestion Engineering Principles

### 6.1 Idempotency
An operation is **idempotent** if running it multiple times with the exact same input produces the exact same final state, with zero side effects or duplicate rows:

$$f(f(x)) = f(x)$$

* *Failure Anti-Pattern (Blind Append):* A network timeout occurs during extraction. The orchestrator retries the task, blindly appending data and artificially doubling scrap counts and production numbers.
* *Solution A (Partition Overwrite):* Ingesting data into designated time-partitioned folders (e.g., `year=2026/month=10/day=14/`). Retries overwrite the partition cleanly.
* *Solution B (Upsert / Merge):* Using composite natural primary keys (e.g., `machine_id` + `timestamp`) to update existing rows and insert only new records.

### 6.2 Schema Drift
Schema drift occurs when upstream sources alter structures unexpectedly (e.g., field renaming, changes in data types, or new structural attributes):
* *Fail-Fast Approach (Strict Enforcement):* Rejects any batch that violates an explicit contract, triggering alerting mechanisms before dirty data enters staging.
* *Schema-on-Read / Evolution:* Ingests raw records into variant or JSON string fields, deferring parsing and transformations to downstream transformation layers.

### 6.3 Data Lineage
The architectural and visual mapping that traces data backwards from executive dashboards to its raw extraction origins. Lineage is essential for:
* *Root-Cause Auditing:* Tracing a sudden drop in an OEE metric back through transformations to a faulty sensor spike.
* *Impact Analysis:* Determining which specific executive dashboards will be impacted before changing an upstream schema.
* *Compliance:* Providing end-to-end traceability for emissions, safety, and financial audits.

---

## 7. The Evolution of Data Architecture

### 7.1 Platform Generations
1. **First Generation: Enterprise Data Warehouse - DWH (1990s–2000s):**
   * *Technologies:* Teradata, Oracle Exadata.
   * *Characteristics:* Highly structured relational schemas, fast SQL, tightly coupled compute and storage.
   * *Flaws:* Expensive, could not scale to semi-structured or high-frequency IoT streaming data.
2. **Second Generation: Data Lake (2010s):**
   * *Technologies:* Apache Hadoop (HDFS, MapReduce, YARN), AWS S3.
   * *Characteristics:* Inexpensive object storage, scale-out horizontal compute, schema-on-read for any format (unstructured, semi-structured).
   * *Flaws:* Lack of ACID transaction guarantees, poor query performance, and lack of governance, resulting in unmanageable "Data Swamps."
3. **Third Generation: Modern Cloud Data Lakehouse (Present):**
   * *Technologies:* BigQuery, Snowflake, Databricks, Apache Iceberg, Delta Lake.
   * *Characteristics:* Decoupled compute and storage, serverless execution, open columnar table formats with native ACID compliance.

### 7.2 Distributed Computing Concepts
* **Vertical Scaling (Scale-Up):** Adding CPU/RAM to a single machine. Faces severe physical hardware limits and exponential cost curves.
* **Horizontal Scaling (Scale-Out):** Distributing compute and storage across commodity server clusters.
* **Hadoop Triad:**
  * *HDFS:* Distributed, fault-tolerant file system splitting files into $128\text{ MB}$ blocks replicated across nodes.
  * *MapReduce:* Programming model that processes data locally on each node, avoiding massive network data movement.
  * *YARN:* Operating system managing cluster CPU and RAM resources.
* **Apache Spark:** Shifted distributed computing from disk-bound MapReduce to in-memory processing, speeding up transformation pipelines by $10\times\text{ to }100\times$.

---

## 8. Modern Enterprise ELT Stack vs. Course Toolkit

| Layer in the Modern Data Stack | Course Implementation | Enterprise Cloud Equivalent |
| :--- | :--- | :--- |
| **Ingestion & Extraction (EL)** | Python (`pandas`, `openpyxl`, `json`) | Airbyte, Fivetran, Apache Kafka, Debezium |
| **Storage & Staging Layer** | Local filesystem (`.parquet`, `.csv`) | Cloud Storage (AWS S3, GCS) + Apache Iceberg |
| **Analytical Query Engine** | DuckDB (Vectorized Columnar SQL) | Google BigQuery, Snowflake, Databricks |
| **Data Transformation (T)** | Python scripts & DuckDB SQL Views | dbt (data build tool), Dataform |
| **Orchestration & Workflow** | Structured scripts & execution milestones | Apache Airflow, Dagster, Prefect |
| **BI, Serving & Storytelling** | Power BI, Looker Studio, Streamlit | Enterprise Power BI, Tableau, Looker |

---

## 9. Workflow Orchestration & Directed Acyclic Graphs (DAGs)

An orchestrator (such as Apache Airflow) coordinates complex dependencies across systems, executing data workflows modeled as **DAGs (Directed Acyclic Graphs)**:
* **Directed:** Processing flows along defined paths in a single direction from upstream sources to downstream targets.
* **Acyclic:** The pipeline contains no circular logic loops ($A \rightarrow B \rightarrow C \rightarrow A$), preventing infinite loops and execution deadlocks.

```text
                      AN INDUSTRIAL PIPELINE DAG WORKFLOW
                      
  ┌───────────────────────┐             ┌───────────────────────┐
  │ Task 1: Ingest SCADA  │             │  Task 2: Ingest ERP   │
  │ (15-min sensor Bronze)│             │ (Shift Roster Bronze) │
  └───────────┬───────────┘             └───────────┬───────────┘
              │                                     │
              └──────────────────┬──────────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Task 3: Dependency Gate │
                    │ (Validate Record Counts)│
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Task 4: Clean (Silver)  │
                    │ (Outliers, Deduplication│
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Task 5: Model (Gold)    │
                    │ (Star Schema, OEE/MTTR) │
                    └────────────┬────────────┘
                                 │
                                 ▼
                    ┌─────────────────────────┐
                    │ Task 6: BI Cache & Alert│
                    │ (Publish to Operations) │
                    └─────────────────────────┘
```

---

## 10. Temporal Alignment & Industrial Realities

Industrial pipelines must resolve three recurring temporal challenges:
1. **Timestamp Standardization (ISO-8601):** Raw strings must be parsed immediately into standardized timestamp formats during Bronze ingestion to prevent parsing ambiguities across disparate systems.
2. **The Timezone Trap (UTC vs. Local Factory Time):** IoT gateways and smart meters record in UTC, whereas shopfloor shift schedules and ERP systems operate in Local Plant Time (e.g., CET/CEST).
   * *Consequence:* Neglecting timezone conversion shifts operational windows by 1–2 hours, falsely attributing morning scrap parts to the night shift supervisor.
   * *Rule:* Ingest, store, and process all pipeline stages in UTC; convert to Local Factory Time only at the dashboard presentation layer.
3. **Daylight Saving Time (DST):** Local time strings produce duplicate timestamps during autumn clock rollbacks and missing hours during spring forward shifts, breaking continuous time-series models.

### 10.1 Resolving Temporal Granularity Mismatches
* **Downsampling (Temporal Aggregation):** Consolidating high-frequency time-series streams into coarser business reporting intervals:

$$\text{Energy usage } [\text{kWh}] = \sum \text{kWh}; \quad \text{Power factor } [\%] = \text{Average}$$

* **Event-to-Window Mapping:** Mapping discrete, irregular log entries to an enclosing shift or operational window.
  * *Example:* Correlating a breakdown ticket logged at `14:23:10` to Shift 2 (`14:00:00 - 22:00:00`).
* **The Multi-Row Fan-Out Trap:** Joining tables before aligning their temporal granularity triggers row duplication, inflating volumetric calculations and invalidating financial summaries.

