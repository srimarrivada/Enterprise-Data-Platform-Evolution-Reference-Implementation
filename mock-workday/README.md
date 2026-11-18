# Mock HCM Source

**Status:** ✅ Built

## What This Proves
A repeatable, synthetic HCM source that every phase is built and tested against. It behaves like a real enterprise source: authenticated APIs, paging, incremental and effective-dated pulls, rate limits, transient failures, messy identities, and back-dated and future-dated changes. **Synthetic data only.** This is not a replica of any vendor's real schema.

**Fully Reproducible:** The same seed and base time give identical data on every start, timestamps included. No value comes from the wall clock.

## Endpoints

| Endpoint | Purpose | Used from |
|---|---|---|
| `POST /ccx/service/{tenant}/Human_Resources` | SOAP `Get_Workers` (WS-Security username/password; `Updated_From/Through`, `Effective_From/Through`, `Page`, `Count`) | Phase 1 |
| `POST /oauth2/{tenant}/token` | OAuth 2.0 client-credentials token | Phase 2 |
| `GET /ccx/service/customreport2/{tenant}/{owner}/{report}?format=json` | RaaS: `Recruiting_Candidates`, `Requisitions` (optional `Updated_From`) | Phase 2 |
| `GET /learning/v1/learners`, `/learning/v1/enrollments` | Learning API, cursor pagination | Phase 2 |
| `POST /admin/export-survey` | Writes the survey CSV to the SFTP folder | Phase 2 |
| `POST /admin/simulate-changes?changes=20&hires=2` | Applies one round of changes and returns them as events | Phases 1 and 3 |
| `GET /admin/ground-truth` | Correct answers for tests and benchmarks | All |
| `GET /health` | Health, worker count and current round | All |

Interactive API docs: http://localhost:8080/docs

## Quickstart

Requires Docker Desktop (or Docker Engine) with the Compose plugin.

**New to Docker on Windows?** See
[Install Docker on Windows](https://github.com/srimarrivada/Docker-Installation-on-Windows/blob/main/Install%20Docker%20on%20Windows%2010%20and%20Configure%20Swarm%20Cluster.md#1-install-docker-on-windows)
(Sections 1.1–1.3), or the [official guide](https://docs.docker.com/get-started/get-docker/) for macOS and Linux.

**No Docker?** The mock also runs [without Docker](#without-docker).

```bash
# from the repo root
[ -f .env ] || cp .env.example .env      # keeps an existing .env
docker compose -f mock-workday/docker-compose.yml --env-file .env up -d --build
# shortcut: make mock-up   (no make? bash scripts/dev.sh mock-up)

curl -s http://localhost:8080/health
curl -s -X POST -H "Content-Type: text/xml" \
  --data-binary @mock-workday/examples/get_workers_request.xml \
  http://localhost:8080/ccx/service/demo_tenant/Human_Resources | head -c 1500

curl -s -X POST http://localhost:8080/admin/export-survey
sftp -P 2222 survey@localhost        # password change_me unless SFTP_PASSWORD is set; file is in upload/
```

On Windows PowerShell, use `curl.exe` instead of `curl` (`curl` is an alias for `Invoke-WebRequest`). Git Bash works as shown.

**Docker error on Windows** (`500 Internal Server Error` or "cannot connect to the Docker daemon"): Docker Desktop isn't running.
Start it and wait for **Engine running**. If it stays stuck, quit Docker Desktop, run `wsl --shutdown` and start it again.

### Without Docker

```bash
python -m venv .venv
source .venv/Scripts/activate        # macOS/Linux: source .venv/bin/activate
pip install -r mock-workday/requirements.txt
cd mock-workday && uvicorn mock_hcm.app:app --port 8080
```

Without Docker, the survey CSV is written to `mock-workday/data/sftp/upload/` (gitignored) and there is no SFTP server.

### Business Process Events

With the mock running, in a second terminal from `mock-workday/`:

```bash
python -m mock_hcm.events --rounds 2          # no receiver yet: prints JSON lines
# Phase 3, once the webhook receiver exists:
python -m mock_hcm.events --webhook-url http://localhost:8090/webhooks/hcm --duplicate-rate 0.05
```

## Simulated Time

The tenant is generated as of `MOCK_BASE_TIME` (default `2026-01-01T00:00:00+00:00`). Each change round is one simulated business day:

| Round | Timestamp of changed workers and events |
|---|---|
| 0 (startup) | On or before the base time |
| 1 | Base time + 1 day |
| N | Base time + N days |

Only the workers changed in a round get the new `updated_at`; everyone else keeps their value. Every round is later than everything before it, so watermark-based incremental pulls work.

Event `occurred_at` is simulated time. Measure latency (for example webhook → profile update) from when an event is received, not from `occurred_at`.

## Built-In Scenarios

| Scenario | Where | Share (default seed) | Tests |
|---|---|---|---|
| Terminated workers | Workers | ~8% | Status handling, SCD2 |
| Back-dated changes | Workers, simulated changes | ~3% / ~10% | Effective-dated handling |
| Future-dated changes | Workers, simulated changes | ~2% / ~5% | Future-dated handling |
| Learner with employee ID | Learning | ~95% | MPI pass 1 |
| Learner matched only by email (incl. case) | Learning | ~3% | MPI pass 2 |
| Nickname + personal email | Learning | ~1.5% | MPI pass 3 (fuzzy) |
| Not enough data to match | Learning | ~0.5% | MPI pass 4 (manual review) |
| Same person registered twice | Learning, recruiting | ~1% / ~3% | Duplicate handling |
| Hired candidate not linked to worker | Recruiting | ~20% of hires | Cross-source identity |
| External candidates never hired | Recruiting | 1 per 5 workers | False-positive matching |
| Survey email with case/whitespace noise | Survey CSV | ~2% | Standardization |
| Rate limit / transient 503 | All APIs except token | configurable | Retries with backoff |
| Duplicate webhook delivery | Events | `--duplicate-rate` | Dedup (Phase 3) |

**Batch and events stay consistent:** Every simulated change is returned by the next incremental SOAP pull and delivered as an event. Phase 3 reconciliation can be checked against `/admin/ground-truth`.

Rates are probabilities in `mock_hcm/generator.py` while actual counts vary slightly with the seed. Exact IDs per scenario are in `/admin/ground-truth`.

## Configuration

| Variable | Default | Meaning |
|---|---|---|
| `MOCK_SEED` | 42 | Same seed → same data |
| `MOCK_WORKER_COUNT` | 1000 | Tenant size |
| `MOCK_BASE_TIME` | `2026-01-01T00:00:00+00:00` | Time the tenant is generated as of; round N = this + N days. Keep it in the past. |
| `MOCK_RATE_LIMIT_RPS` | 20 | Requests per second (0 = off) |
| `MOCK_FAILURE_RATE` | 0.0 | Share of requests returning 503 |
| `MOCK_TOKEN_TTL_SECONDS` | 3600 | OAuth token lifetime (local runs only; not passed by Compose) |
| `HCM_BASE_URL` | `http://localhost:8080` | Where extractors find the mock |
| `HCM_TENANT`, `HCM_USERNAME`, `HCM_PASSWORD` | demo values | Tenant and SOAP credentials, set in `.env` |
| `HCM_CLIENT_ID`, `HCM_CLIENT_SECRET`, `SFTP_PASSWORD` | demo values | Optional until Phase 2; the demo defaults are used if unset |

## Tests

```bash
cd mock-workday && python -m pytest -q        expect: 11 passed (1 library deprecation warning)
```

Tests use a 200-worker tenant with no rate limit and no injected failures (see `tests/conftest.py`). They include reproducibility checks *(two tenants built from the same settings must be identical, and a change round must move only the changed workers forward)*.

Values already exported in your shell take priority. If tests fail at random with 503 or 429, run `MOCK_FAILURE_RATE=0 MOCK_RATE_LIMIT_RPS=0 python -m pytest -q`.

### Check Reproducibility in Docker

```bash
URL=http://localhost:8080/ccx/service/demo_tenant/Human_Resources
REQ=@mock-workday/examples/get_workers_request.xml
curl -s -X POST -H "Content-Type: text/xml" --data-binary "$REQ" "$URL" > before.xml
docker compose -f mock-workday/docker-compose.yml restart mock-hcm && sleep 3
curl -s -X POST -H "Content-Type: text/xml" --data-binary "$REQ" "$URL" > after.xml
diff before.xml after.xml && echo "identical"
rm before.xml after.xml
```

## Limitations (by design, for now)
- One SOAP operation (`Get_Workers`) and no WSDL. The extraction framework calls it with templated SOAP requests. More operations and a WSDL can be added when needed.
- OAuth uses client credentials; real HCM APIs often use a refresh-token flow.
- Data lives in memory. A restart regenerates the same starting data and resets the round to 0, so simulated changes are lost. Run a single server process.
- Admin endpoints are unauthenticated and for local demos only.
- Manager assignments are random and can form reporting cycles.
- Job profile and grade are chosen independently (salary follows grade), so a manager title can appear at a low grade. Manager assignments use grades G6–G8, not job titles.

---

*Built on synthetic data only. It does not describe any specific organization's systems.*
