# Envelope soak — 92k-token prompt on qwen3.6-35b-a3b (2026-09-04)

Single 92,095-token prompt (llama.cpp `src/**` source dump, 47 files, 361 KB) sent to the live router instance (n-max 3, 4 slots, unified KV, ubatch 512, KV F16 default).

## Results
- Prompt processing: 92,095 tokens in 200.2 s → **460 tok/s** (vs 813 tok/s at 14.4k prompt — long prompts roughly halve prompt throughput)
- TTFT ≈ 200 s (prompt-bound; generation negligible by comparison)
- Generation: 192 tokens @ **45.8 tok/s** — long-context decode is slower than short-ctx ~60-72 (KV attention cost + unified pool)
- Draft acceptance at depth: **123/202 = 0.61** (vs 0.76-0.84 short-ctx; matches overnight 0.55 @ 36k — acceptance degrades with ctx depth, expected for MTP)
- Prompt was completely cached-cold (`cached_total 0`), `n_tokens_max = 92286`
- Answer truncated inside ` thinking` (max_tokens 192 too small — harness artifact, not a defect; pi sends 262144)

## Memory
- No OOM; RSS +0.7 GB during the soak (48→49 G used of 125 G; 75 G available). KV for 92k ≈ 7.5 GB F16, absorbed by the unified pool.
- Extrapolation to full 262,144: ~21.5 GB F16 KV → peak ~62-66 G RSS. **Comfortable — KV cache quantization NOT needed**; keep F16 for max long-context recall.

## Decisions
- **ubatch-size 2048 (lock-in)** — see sweep table below; peaked at 2048, regressed at 4096.
- KV quant skipped (no pressure).
- Acceptance-at-depth 0.61 is inherent to MTP at long ctx; n-max 3 remains the best setting.

## ubatch sweep (same 92,095-token prompt, restart per variant)

| ubatch | batch  | prompt tok/s | gen tok/s | draft acc |
|--------|--------|--------------|-----------|-----------|
| 512 (default) | 2048 (default) | 460.1 | 45.8 | 0.61 |
| 1024   | 2048   | 519.7 (+13%) | 47.9 | 0.65 |
| **2048** | 2048 | **555.5 (+21%)** | 59.7 | 0.93 |
| 4096   | 4096   | 524.8 (−6% vs 2048) | 60.3 | 0.95 |

- Optimal at 2048; 4096 regresses (larger physical batches overshoot GPU efficiency on this APU).
- `batch-size` left at default 2048 (physical cap is ubatch).
- Final child args verified: `--spec-draft-n-max 3 --flash-attn on --n-gpu-layers 99 --ubatch-size 2048`.
- Post-lock sanity: 72.4 tok/s short chat, 11/11 accepted.