# Baseline — qwen3.6-35b-a3b (2026-09-04)

## Build / host
- llama-server `b210-50f068fff`, Strix Halo 395 (32 threads), 125 GiB unified
- Router: `MODELS_MAX=1`, port 9931, sleep-idle 900s. Model was `sleeping`, woke on first request.

## Config snapshot (models.ini [qwen3.6-35b-a3b])
- weights `Qwen3.6-35B-A3B-UD-Q8_K_XL.gguf` (37G) + `mmproj-BF16` (861M)
- `spec-type draft-mtp`, `spec-draft-n-max 2`
- template `qwen-fixed-chat_template.jinja` (froggeric-v22.1), `reasoning auto`, `deepseek`, `preserve`
- sampling: temp 1.0, top-p 0.95, top-k 20, min-p 0.0, presence 1.5, repeat 1.0 (= upstream Thinking/general)
- unset (defaults): ctx-size → 262144 from GGUF, batch 2048 / ubatch 512, cache-type K/V default, np auto → **4 slots × 262144**, unified KV on, cont-batching on

## Final lock-in (2026-09-04)

`llama/models.ini` `[*]` + `[qwen3.6-35b-a3b]`:
- `n-gpu-layers = all` (was 99; future-proof for deeper models, global `[*]`)
- `spec-draft-n-max = 3` (was 2; MTP sweep winner)
- `ubatch-size = 2048` (was default 512; −21% long-prompt ingest, peaked vs 4096 regression)
- unchanged: ctx 262144, 4 slots unified KV (F16), flash-attn, sampling Thinking/general, froggeric jinja, KV quant skipped

Verified: child args `--n-gpu-layers all --spec-draft-n-max 3 --ubatch-size 2048`; sanity 71.1 tok/s / 11-11 accepted.

## Tests (all via POST /v1/chat/completions, model=qwen3.6-35b-a3b, stream=false)

| # | Task | prompt_n | prompt tok/s | gen tok/s | wall | draft accepted/total | Notes |
|---|------|----------|--------------|-----------|------|----------------------|-------|
| T1 | "one sentence: speculative decoding", max 128 | 19 | 151 | 60.9 | 2.2s | — | thinking model; short replies mostly land in `reasoning_content` |
| T2 | math + `<\|think_medium\|>`, max 512 | 40 | 266 | 68.0 | 7.7s | — | ok |
| T3 | tool-use (get_weather/Paris), max 256 | 382 | 646 | 59.8 | 2.0s | — | correct `tool_calls` emitted |
| T4 | codebase dump ~38KB chars / 44 files, max 256 | 12431 | 835 | 64.7 | 16.3s | 57/64 (0.89 this req) | correct answer (top-level dirs + llama/ contents), `reasoning_content` empty (auto skipped thinking) |
| T5 | "Say hi in one sentence", max 64 | 16 | 147 | 62.1 | ~1.2s | 38/48 (0.79 this req) | **truncated inside `<think>`** — content empty, reasoning only. Expected: thinking models need generous `max_tokens`; 64 cuts the answer off. |

## Server counters (after T5, /metrics?model=qwen3.6-35b-a3b)
- prompt avg 471 tok/s, gen avg 65.1 tok/s
- spec totals: 2727 drafted / 1968 accepted = **0.72**; pos0 1088, pos1 880 (cond. pos1 ≈ 0.81)
- `n_tokens_max` observed 36163 (historical, pre-baseline)
- `requests_deferred` 0
- Prior journal (overnight task 477): prompt 276 tok/s, gen 46 tok/s, acceptance 0.55, mean len 2.10 — slower/longer-context than today's short tests

## Memory
- `MemoryCurrent` 42.5G, `MemoryPeak` 63.7G; system 49G used / 75G avail
- Headroom for full-262k KV (~21.5G at F16) looks fine on paper; not yet tested at the limit

## Observations / follow-ups
1. Sampling default matches upstream Thinking/general — keep; precise-coding + instruct presets belong as **per-request overrides** from pi, not in models.ini.
2. `max_tokens` guidance for pi: thinking responses need room (T5 shows 64 tokens = answer never leaves `<think>`). Suggest ≥1024 default for agentic calls.
3. Tool-use path works with custom jinja (T3). Deeper agentic loop (multi-turn + truncation warnings) not yet tested.
4. Long-context validated to 12k prompt tokens only. Full 262k soak + compaction-concurrency test still open (deferred, lower priority per user).
5. Next tuning candidates: ubatch/batch for big prompts, `spec-draft-n-max` 2→3→4 sweep, cache-type-k/v if 262k-soak pressures memory.
