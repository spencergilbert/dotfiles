# Spec-draft sweep — qwen3.6-35b-a3b (2026-09-04)

Same-day A/B, same build (b210), same battery (3× short-chat, 3× reason, 3× tool, 1× ~14.4k-token codebase Q&A), `draft-mtp` fixed, only `spec-draft-n-max` varied. Acceptance/mean-len from fresh `/metrics` counters (child restarted per variant → totals = battery-only).

| n-max | acceptance | mean draft len | chat gps | reason gps | tool gps | code gps |
|-------|-----------|----------------|----------|------------|----------|----------|
| 2     | 0.836     | 2.00           | 61       | 67         | 61       | 65.2     |
| **3** | 0.760     | **3.00**       | 62       | **72**     | 61       | **71.7** |
| 4     | 0.674     | 3.98           | 56       | 74.5       | 62       | 59.9     |

## Decision: keep `spec-draft-n-max = 3`

- n-max 3 posts full 3-token draft chains (mean len 3.00) with best agentic (code) and reasoning throughput.
- n-max 4 over-drafts: acceptance falls to 0.67, code gen drops ~12 tok/s vs n-max 3 despite full 4-token chains — MTP useful depth exceeded for this model.
- n-max 2 under-drafts (mean 2.00): less per-step throughput.

## Locks / verification
- `models.ini` `[qwen3.6-35b-a3b]`: `spec-type=draft-mtp`, `spec-draft-n-max=3` (qwen3.8-27b stanza untouched at 4).
- Router restarted; child args verified via `/v1/models`: `--spec-draft-n-max 3 --spec-type draft-mtp`.
- Post-restart sanity: gen 70.7 tok/s, 11/11 accepted.

## Notes
- Counters reset on child restart; Prometheus scrape deltas across restarts are invalid — always read `/metrics?model=...` fresh per test window.
- Prior overnight run (36k ctx, n-max 2): acceptance 0.55 / mean 2.10 — long-context acceptance is lower than short-ctx; keep that in mind for the 262k soak.