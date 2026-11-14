#!/usr/bin/env bash
# scaffold.sh: creates placeholder files for the reference implementation repo.
# Never overwrites existing files; safe to re-run.
# Run from the repo root:  bash scripts/scaffold.sh
set -euo pipefail

if [[ ! -f README.md ]]; then
  echo "Run this from the repository root (README.md not found)." >&2
  exit 1
fi

# write <path>: content from stdin; skips the file if it already exists
write() {
  local path="$1"
  if [[ -e "$path" ]]; then
    echo "skip    $path"
    cat > /dev/null          # discard the heredoc
    return 0
  fi
  mkdir -p "$(dirname "$path")"
  cat > "$path"
  echo "create  $path"
}

FOOTER="*Built on synthetic data only. This does not describe any specific organization's implementation.*"
ARCH="https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture/blob/main/docs"

# ---------------------------------------------------------------------------
# Root files
# ---------------------------------------------------------------------------
write ".env.example" <<'EOF'
# Copy to .env and adjust. Never commit .env. Demo values only.

# --- Mock HCM source (mock-workday) ---------------------------------------
HCM_BASE_URL=http://localhost:8080
HCM_TENANT=demo_tenant
HCM_USERNAME=demo_user
HCM_PASSWORD=change_me
MOCK_SEED=42
MOCK_WORKER_COUNT=1000
# Left commented out on purpose: if you export .env in your shell before running
# pytest, these would override the test settings and cause random 429/503 failures.
# MOCK_RATE_LIMIT_RPS=20
# MOCK_FAILURE_RATE=0.0

# --- Lake and run state -----------------------------------------------------
LAKE_ROOT=./data/lake
EDP_STATE_DIR=./data/state
EOF

# ---------------------------------------------------------------------------
# Benchmarks (measured results only)
# ---------------------------------------------------------------------------
write "docs/benchmarks/README.md" <<EOF

# Benchmarks

Measured results from this implementation. Numbers in the
[architecture diagrams](https://github.com/srimarrivada/Enterprise-Data-Platform-Evolution-Reference-Architecture)
are **design targets**; the values here are **measured**, using synthetic data from the mock HCM source.

| Phase | Metric | Design target | Measured | Setup (seed · workers · machine) | Date |
|---|---|---|---|---|---|
| 1 | End-to-end batch runtime | — | pending | | |
| 2 | MPI automatic resolution rate | ≥ 99% | pending | | |
| 2 | 360° profile read time | < 2 s | pending | | |
| 3 | Webhook acknowledgment | < 3 s | pending | | |
| 3 | Webhook → profile update latency (p50 / p95) | — | pending | | |
| 4 | Demo run cost | — | pending | | |

Rows are filled in as each phase is built. Each measured value states the seed, worker count and machine it was measured on.

---

$FOOTER
EOF

# ---------------------------------------------------------------------------
# Placeholder READMEs for the component and phase folders (skipped if the folder already has a README)
# ---------------------------------------------------------------------------
make_stub() {  # folder, title, what it will contain, design link
  write "$1/README.md" <<EOF
# $2

**Status:** 📋 Planned

$3

**Design:** $4

---

$FOOTER
EOF
}

make_stub mock-workday "Mock HCM Source" \
  "Synthetic Workday-style source that every phase is built and tested against: SOAP, OAuth + RaaS, learning API, SFTP and webhooks." \
  "N/A (supports every phase)"
 
make_stub framework "Shared Framework" \
  "Config-driven Python package used by every phase: YAML extraction, Landing → Raw, curated (SCD2), DQ, MPI, pipeline runner and Delta merge." \
  "[ADR-0001: YAML-driven extraction]($ARCH/adr/0001-yaml-driven-extraction.md)"
make_stub phase1-batch-lake "Phase 1: Batch Data Lake" \
  "Four-zone lake (Landing → Raw → Curated → Consumption), SCD Type 2 star schema and Airflow DAGs generated from configs." \
  "[Phase 1 architecture]($ARCH/architecture/phase1-batch-lake.md)"
make_stub phase2-multi-source "Phase 2: Multi-Source Analytics" \
  "Learning, survey (SFTP) and recruiting sources, Master Person Index, DQ framework and 360° profile." \
  "[Phase 2 architecture]($ARCH/architecture/phase2-multi-source.md)"
make_stub phase3-lambda-realtime "Phase 3: Real-Time Hybrid (Lambda)" \
  "Webhook receiver with Redis dedup, Kafka, streaming consumer, speed-layer stores and batch/stream reconciliation." \
  "[Phase 3 architecture]($ARCH/architecture/phase3-lambda.md)"
make_stub phase4-azure-lakehouse "Phase 4: Cloud-Native Governed Lakehouse" \
  "Terraform, Databricks, Delta Lake, Unity Catalog and Event Hubs, with cost notes and teardown steps." \
  "[Phase 4 architecture]($ARCH/architecture/phase4-lakehouse.md)"
make_stub aws-variant "AWS Variant (Optional)" \
  "The batch path on AWS (S3, Glue, Athena, Lambda, SNS) to compare cloud trade-offs." \
  "[Phase 4 architecture]($ARCH/architecture/phase4-lakehouse.md)"

echo
echo "Done. Review with:  git status"