
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

*Built on synthetic data only. This does not describe any specific organization's implementation.*
