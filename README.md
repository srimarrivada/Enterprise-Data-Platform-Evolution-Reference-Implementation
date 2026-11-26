# Enterprise Data Platform Evolution: Reference Implementation

Runnable reference implementation of the
[Enterprise Data Platform Evolution Reference Architecture](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture):
An HR data platform modernized in four phases, **from an on-prem batch lake to a cloud-native governed lakehouse**,
then rebuilt on AWS.

> **This repo holds the code.** The design (architecture, ADRs, diagrams, NFRs, migration notes) lives in the
> [architecture repo](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture).
> Numbers in the diagrams are **design targets**; numbers measured here go in `docs/benchmarks/`.
>
> **Synthetic data only.** No proprietary names, data, code or configurations.

## What This Demonstrates

What each phase delivers once it's built. The status table shows what runs today.

- **Config-driven pipelines (Phase 1):** Sources and dependencies are YAML; the DAG is generated from them, so it can't drift.
- **Two engines, one set of rules:** Every transformation runs in pure Python *and* PySpark, with parity tests proving they agree.
- **Safe re-runs (Phase 1):** A failed run publishes nothing and keeps its watermark; a re-run gives identical results.
- **Warehouse-grade curation (Phases 1–2):** SCD Type 2, unknown members, blocking DQ gates, quarantined rejects.
- **Identity resolution (Phase 2):** A 4-pass master person index scored against known answers.
- **Lambda architecture (Phase 3):** Two-phase webhook dedup, an order-independent stream consumer, batch/stream reconciliation.
- **Governed Lakehouse (Phase 4):** Incremental Delta MERGE, restore on failure, published snapshots, Unity Catalog data products.
- **Same design on AWS:** Glue, Lake Formation, Athena, MSK Serverless and DocumentDB, with the trade-offs written down.

## Implementation Status

| Phase | Status | Stack | Folder | Design |
|---|---|---|---|---|
| 0. Mock HCM Source | 🔲 Planned | FastAPI, Faker, SFTP, webhook sender | `mock-workday/` | N/A |
| Shared Framework | 🔲 Planned | Python, PySpark, Pydantic, Jinja2, Zeep | `framework/` | [ADR-0001](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/adr/0001-yaml-driven-extraction.md) |
| 1. Batch Data Lake | 🔲 Planned | HDFS, Hive, PySpark, Airflow, Tableau | `phase1-batch-lake/` | [Phase 1](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase1-batch-lake.md) |
| 2. Multi-Source Analytics | 🔲 Planned | + MPI, DQ framework, MongoDB, SFTP, ServiceNow | `phase2-multi-source/` | [Phase 2](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase2-multi-source.md) |
| 3. Real-Time Hybrid (Lambda) | 🔲 Planned | + Flask, Redis, Kafka, Spark Streaming, Cassandra | `phase3-lambda-realtime/` | [Phase 3](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase3-lambda.md) |
| 4. Cloud-Native Lakehouse | 🔲 Planned | Terraform, Azure Databricks, Delta, Unity Catalog, Event Hubs, Cosmos DB | `phase4-azure-lakehouse/` | [Phase 4](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase4-lakehouse.md) |
| AWS Variant | 🔲 Planned | S3, Glue, Lake Formation, Athena, MSK, DocumentDB | `aws-variant/` | N/A |

🔲 Planned · ⏳ In Progress · ✅ Built. A phase is **Built** when its demo runs end to end,
its architecture exit criteria pass, and its measured results are in `docs/benchmarks/`.

## Run Modes

| Mode | What Runs | Needs |
|---|---|---|
| A. Laptop | Python engine, local files, in-process stand-ins | Python 3.11 |
| B. Native Windows | Hadoop, Hive, Spark, Kafka, Cassandra, MongoDB, Redis; Airflow in WSL | [BigData-Installation-on-Windows](https://github.com/srimarrivada/BigData-Installation-on-Windows) and related guides |
| C. Docker | Pinned images per phase | Docker Desktop, 8–16 GB RAM |
| D. Cloud | Terraform + Databricks bundle (Azure), Terraform + Glue (AWS) | Azure / AWS accounts |

## Quickstart

> Available from step P0-08 (mock source). Until then, see the status table.

## Documentation

The **Technical Implementation Document** (Word) is built from `docs/implementation/`. Every chapter includes the
complete code of the commit it was built from. A copy is attached to each phase release.

## Related

- [Enterprise Data Platform Evolution: Reference Architecture](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture): The design this repo implements
- [Hybrid HR Data Platform: Reference Architecture](https://github.com/srimarrivada/Hybrid-HR-Data-Platform-Reference-Architecture): Shared decisions (Kimball modeling, idempotent loads, change detection, defense in depth)
- [BigData-Installation-on-Windows](https://github.com/srimarrivada/BigData-Installation-on-Windows) and [Apache-Airflow-Zero-To-Cluster-On-Windows](https://github.com/srimarrivada/Apache-Airflow-Zero-To-Cluster-On-Windows): Native tool setup used in Mode B

## Confidentiality

A personal reference implementation built on synthetic data. It contains no client or system names, real data,
production code, configurations, schedules or volumes.

## License

[MIT](LICENSE)

## Author

**Sri Adilakshmi Marrivada**: Data Platform Architect<br>
[LinkedIn](https://www.linkedin.com/in/sri-adilakshmi-marrivada/)