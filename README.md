# Enterprise Data Platform Evolution: Reference Implementation

Runnable reference implementation of the
[Enterprise Data Platform Evolution Reference Architecture](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture): an HR data platform modernized in four phases, **from an on-prem batch lake to a cloud-native governed lakehouse**.

> **This repo holds the code.** The design (architecture, ADRs, diagrams, NFRs, migration notes) lives in the
> [architecture repo](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture).
> Numbers in the diagrams are **design targets**. Numbers in the diagrams are **desgin targets**; numbers measured here are in [docs/benchmarks](docs/benchmarks/README.md).
> **Synthetic data only.** No proprietary names, data, code or configurations.

## What This Demonstrates

What each phase delivers once it's built. Check the [status table](#implementation-status) for what runs today.

- **Config-driven pipelines (Phase 1):** Extraction and dependencies are defined in YAML. The task graph is inferred from the configs, so the DAG can't drift from them.
- **Safe re-runs (Phase 1):** A failed run publishes nothing and keeps the watermark, so a rerun re-extracts the same window and produces identical results. Every run is recorded in a run log.
- **Warehouse-grade curation (Phases 1–2):** SCD Type 2 with content comparison, unknown members, blocking DQ gates and quarantined rejects.
- **Identity resolution (Phase 2):** A master person index with 4-pass matching (exact ID → email → fuzzy on name + hire date + job family → review queue), scored against known correct answers.
- **Lambda architecture (Phase 3):** An at-least-once stream consumer with idempotent sinks, reconciled against the batch layer as the source of truth.
- **Delta Lake operations (Phase 4):** Incremental MERGE, restore on failure and published snapshots.

## Implementation Status

| Phase | Status | Stack | Folder | Design |
|---|---|---|---|---|
| 0. Mock HCM source | 📋 Planned | FastAPI + Faker + SFTP | [mock-workday](mock-workday/) | N/A |
| Shared framework | 📋 Planned | Python + Jinja2 + Pydantic + PySpark | [framework](framework/) | [ADR-0001](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/adr/0001-yaml-driven-extraction.md) |
| 1. Batch Data Lake | 📋 Planned | PySpark + Hive/Parquet + Airflow | [phase1-batch-lake](phase1-batch-lake/) | [Phase 1](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase1-batch-lake.md) |
| 2. Multi-Source Analytics | 📋 Planned | + MongoDB + SFTP + MPI + DQ | [phase2-multi-source](phase2-multi-source/) | [Phase 2](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase2-multi-source.md) |
| 3. Real-Time Hybrid (Lambda) | 📋 Planned | + Kafka + Redis + Cassandra + MongoDB | [phase3-lambda-realtime](phase3-lambda-realtime/) | [Phase 3](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase3-lambda.md) |
| 4. Governed Lakehouse | 📋 Planned | Databricks + Delta + Unity Catalog + Event Hubs + Terraform | [phase4-azure-lakehouse](phase4-azure-lakehouse/) | [Phase 4](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs/architecture/phase4-lakehouse.md) |
| AWS variant (optional) | 📋 Planned | S3 + Glue + Athena + Lambda | [aws-variant](aws-variant/) | N/A |

📋 Planned · 🚧 In progress · ✅ Built (a phase is complete when its demo runs end to end and its results are in [docs/benchmarks](docs/benchmarks/README.md))

## Quickstart

> Available once the mock HCM source is added (see the status table).

| Part | Requirements |
|---|---|
| Tests, mock source and extraction | Python 3.12 (on Windows: Git Bash) |
| Spark jobs | Java 17 + PySpark (on Windows: WSL2 Ubuntu) |
| Local stacks | Docker Desktop (or Docker Engine) with Compose |
| Phase 4 | Azure subscription, Terraform, Databricks CLI |


**1. Run all tests (no Docker needed):**

```bash
python -m venv .venv
source .venv/Scripts/activate     # macOS/Linux: source .venv/bin/activate
pip install -r mock-workday/requirements.txt -e "framework[test]"
bash scripts/check.sh             # Spark tests are skipped unless Java 17 and PySpark are installed
```

**2. Start the mock source:**

```bash
cp .env.example .env
make mock-up                      # no make? bash scripts/dev.sh mock-up
curl -s http://localhost:8080/health
```

## Repository Layout

| Folder | Contents |
|---|---|
| `mock-workday/` | **Synthetic Workday-style source:** SOAP, OAuth + RaaS, learning API, SFTP, webhooks |
| `framework/` | **Shared Python package:** Extraction, Raw, DQ, MPI, SCD2 (used by every phase) |
| `phaseN-*/` | Configs, jobs, DAGs, Docker setup, demo script and tests for each phase |
| `scripts/` | `check.sh` (all tests) and `dev.sh` (dev commands for machines without `make`) |
| `docs/benchmarks/` | Measured results from this implementation |
| `.github/workflows/` | **CI:** Tests on every push |
| `data/` | Generated data and local volumes (gitignored) |

Run one phase's stack at a time to keep local memory use manageable.

## Confidentiality

Personal reference implementation built on synthetic data. It contains no proprietary documentation,
client or system names, real data, production code, configurations, schedules or volumes.

## License

[MIT](LICENSE)

## Author

**Sri Adilakshmi Marrivada**: Data Platform Architect<br>
[LinkedIn](https://www.linkedin.com/in/sri-adilakshmi-marrivada/) 