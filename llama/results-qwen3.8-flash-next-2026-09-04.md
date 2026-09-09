# qwen3.8-flash-next — 2026-09-04 (bonus model)

177B-class MoE (Qwen4 arch: Gated DeltaNet + QSA + N-gram embedding table + 512-expert MoE),
ctx 262k. MTP head exists but is NOT in mainline llama.cpp yet.

## Flavor / disk-serving
- N-gram embedding table ≈ 39-54 GB is designed to be **SSD-served** (2.7 KB/token,
  ~3 MB/s random reads; deterministic hash → page-cache friendly). Experts (6B/token) must be resident.
- **AtomicChat** `AD-4.27bpw-Q4_K_M-M64` isolates the table in its own shard → ~54G resident
  + ~38G on SSD. Downloads via `bin/dlmodel.mjs` (88 GiB, 33 shards). Works on the MAIN build (b210)
  with `--tensor-read-lazy on`.
- **unsloth** `UD-Q4_K_XL` (already on disk, interleaved table) needs the fork for disk-serving; loads on the fork at 96G.

## Results (all on Strix Halo)
| Config | gen tok/s | prompt pps | draft acc | notes |
|--------|-----------|------------|-----------|-------|
| AtomicChat + ngram-mod (n-max 64/4), main build | ~21 | ~238 @14k | 0.09 | usable baseline; clean on code case |
| unsloth UD + **MTP** (shared-Q4_K_M head, draft-mtp n-max 5), fork build | **~27.5 (+31%)** | ~230 @14k | **0.78** | effective chain ~1/step on APU (bandwidth-bound) |

## MTP support map (as of today)
- Upstream PR **ggml-org/llama.cpp#27836** (draft): qwen4exp `draft-mtp`, but its loader rejects
  head-only MTP GGUFs (`output_hc_norm.weight not found`) — main model loads, draft head doesn't.
  Build at `build-mtp/`.
- **unsloth fork** `danielhanchen/llama.cpp` branch **`qwen4exp/mtp`** (docs:
  unsloth.ai/docs/models/qwen3.8-next#mtp-guide): full qwen4exp MTP; loads unsloth's own main + shared
  head. Build at `build-fork/`. This is the documented, working path.
  - flags: `-m <UD-Q4_K_XL shard1> -md <shared-Q4_K_M head> --spec-type draft-mtp --spec-draft-n-max 5`
  - note: no `--tensor-read-lazy` in fork (SSD table via mmap default)
- Fork's MTP commit also covers qwen35/qwen35moe → qwen3.6/27b MTP would work on it too (untested here).

## Downloads added
- `mtp-Qwen3.8-Flash-Next-Q4_K_M.gguf` (2.6G) + `-shared-Q4_K_M.gguf` (1.8G) from unsloth (MTP head)

## Adopted (2026-09-04) — flash-next in rotation with MTP
- Service moved to the **unsloth fork binary** (`build-fork/bin/llama-server`, branch qwen4exp/mtp)
  so all three models benefit (fork also carries qwen35/qwen35moe MTP graphs).
- flash-next preset: unsloth `UD-Q4_K_XL` + `spec-draft-model mtp-...-shared-Q4_K_M.gguf`
  + `spec-type draft-mtp` n-max 5. n-gram table lazy-from-disk by the fork loader (no flag).
- Verified on the service: qwen3.6 67.6 t/s (22/27), 27B 21.4 t/s, flash-next 27.6 t/s (11/13) — MTP draft ctx confirmed in journal.
- Deep soak (160,784 tokens): **no OOM**, KV growth +1G only; prompt 132 pps, gen 9.5 t/s at depth
  → flash-next is the slow, careful, hard-task slot: expect ~20 min TTFT on 150k-token ingests.
- Old main build (build/bin b210) retained as fallback; AtomicChat AD-4.27bpw flavor (88 GiB) now unused on disk.

## MTP depth-1 bug — flash-next (found 2026-09-06 via Grafana, patched locally)
- Symptom: new Speculative Decoding dashboard section showed Pos1|Pos0 = 0% on flash-next.
  Counters: drafts == draft_tokens (depth exactly 1.0), accepts pos1+ hard zero; journal full of
  `spec draft: llama_decode[1] returned -1` (~1/round) + `init: ... X = 4958, Y = 4958 ... M-RoPE X < Y`.
  (qwen3.6 control on same build: 529 drafts -> 1587 tokens = 3.0 depth, ~70% acc, pos 0/1/2 — healthy.)
- Root cause (fork `common/speculative.cpp`): external MTP head borrows target tensors via `ctx_other`,
  and the ctor equated that with Gemma4-style shared KV (`is_mem_shared`). Shared path re-submits every
  draft token at the same position -> 2nd draft decode violates M-RoPE strict X<Y -> break -> len-1 drafts.
  `mean len = 1 + acceptance` (1.68 = 1 + 0.68) was the fingerprint.
- Local patch (uncommitted, on fork 2c967293c): gate `is_mem_shared` on draft arch == `gemma4-assistant`
  (via `general.architecture` meta); external MTP heads now get catch-up decode + advancing positions.
  Catch-up/prefix-check skips preserved for `chain_heads` so qwen3.6 behavior is byte-identical.
  Reapply after every fork pull; upstream candidate for the qwen4exp/mtp branch.
- Verified after rebuild + restart: 45 drafts -> 224 tokens (**~5.0/draft, full n-max 5**),
  accepts pos 0-4 = 37/30/19/10/8, **zero** decode errors. Acceptance still reads sane (~46% short sample).
