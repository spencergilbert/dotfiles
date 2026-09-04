# qwen3.8-27b tuning — 2026-09-04

Dense 27B (12B-param-scale dense, 64 layers), Q4_K_M 16G + mmproj-BF16, draft-mtp n-max 4, effort medium, ctx 262144.
All A/Bs on the live router (get /models?reload=1 + POST /models/load to swap).

## Verdict: no config changes needed — original preset kept.

| Test | Result | Decision |
|------|--------|----------|
| Quant Q4_K_M vs Q8_K_XL | Q8: −30–35% decode (13–21 vs 17–30 tok/s), prompt pps equal (~326), acceptance equal (~0.62) | **Keep Q4_K_M.** Dense model is bandwidth-bound; the 30G Q8 gguf stays on disk as a one-line swap for peak-quality sessions |
| reasoning-effort medium vs xhigh | xhigh did NOT deepen thinking: hard-case output shrank 753→492–597 tok, chat 197–256→112–119 (xhigh just injects a system instruction; `pn` 19→61 confirms live). Same correct answers | **Keep medium**. Card's xhigh default not vindicated on this stack |
| ubatch 512 vs 2048 | 2048 REGRESSED prompt pps: 300 vs 326 (3× consistent 326 at 512). Dense is compute-bound, unlike MoE | **Keep 512 for 27b.** ubatch 2048 stays qwen3.6-stanza-only |

## Baseline numbers (Q4_K_M final config)
- gen tok/s: chat ~18–21, reasoning ~26–28, tool ~22–27, code ~30 (avg ~24; dense 27B ≪ qwen3.6 MoE's 60–72)
- prompt pps: 326 @ 14.4k (vs qwen3.6's 813)
- draft acceptance 0.62–0.64, mean draft len 4.00 (full MTP chains)
- system memory: +17G total (16G weights + 0.9G mmproj) — negligible here
- sanity: 25 tok/s, 11/15 accepted

## Open watch item
Reproducible in the battery's codebase Q&A case: model emitted a hallucinated
`<tool_call><function=get_weather>...` **with no tools defined** in the request
(both medium and xhigh runs). 26-token generation, wrong behavior for a pure
code question. Worth confirming against real pi agentic traffic (tool-enabled
requests are the normal path, so exposure may be low).

**UPDATE (Q8 & Q6 follow-up): content-triggered, not a quant defect.**
Same code case on Q8_K_XL: correct 2/2. Then Q6_K_XL (downloaded via
`bin/dlmodel.mjs` from unsloth/Qwen3.8-27B-GGUF) also hallucinated a
`list_files` tool-call on the SAME dirty dump. Root cause: the test dump
embodies ./llama/qwen-fixed-chat_template.jinja, which contains the tool-call
format examples (get_weather etc.) — the model imitated prose found in
context. On a clean dump (llama.cpp C++ src): Q4 AND Q6 both correct, no
tool-call noise. Q8 resists the in-context imitation best; Q4/Q6 imitate it.
Practical exposure is narrow (no tools defined + tool-call prose in context);
when tools ARE defined, emitting a tool_call is correct behavior.

## Q6_K_XL middle-quant probe (downloaded 23.6 GiB, unsloth/Qwen3.8-27B-GGUF)
- gen tok/s: chat ~15-18, reasoning ~20-21, tool ~22-24, code ~22 (avg ~20;
  between Q4 ~24 and Q8 ~16.5 as expected for 23.6G weights)
- prompt pps: ~302 @ 14.4k (flat across all three quants)
- draft acceptance 0.594, mean len 4.00
- file retained on disk as a middle option (one-line swap + reload)
## Note
reasoning-effort per-request overrides work through the froggeric template
(`<|think_*|>` markers / system instruction injection); pi's thinkingLevelMap
for this model maps off/low/medium/xhigh.
