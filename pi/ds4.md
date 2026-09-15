# ds4 provider — Pi config and rationale (2026-09-15)

Notes for the `ds4` provider in `pi/models.json`, running DwarfStar (ds4) on the
Strix Halo desktop (`gfx1151`, ROCm). Covers *why* each field is set, because
most of it is non-obvious and easy to "fix" back into being wrong.

## Server

```sh
./ds4-server --rocm -m gguf/GLM-5.3-Flash-Q2.gguf \
  --ctx 131072 --host 0.0.0.0 --port 8000 \
  --kv-disk-dir ~/.ds4/server-kv --kv-disk-space-mb 16384
```

Resident (no `--ssd-streaming`). Measured on this box (GLM Q2 = 89.87 GiB,
Flash IQ2 = 80.76 GiB):

| Model | Mode | ctx | prefill | decode |
|---|---|---:|---:|---:|
| GLM 5.3 Flash Q2 | resident | 2,048 | 82.5 | 12.19 |
| GLM 5.3 Flash Q2 | resident | 16,384 | 57.8 | 11.35 |
| GLM 5.3 Flash Q2 | SSD streaming | 4,096 | 37.4 | 7.18 |
| Flash IQ2XXS | resident | 2,048 | 194.7 | 14.34 |
| Flash IQ2XXS | resident | 16,384 | 250.5 | 14.05 |
| Flash IQ2XXS | SSD streaming | 4,096 | 90.5 | 8.11 (steady 9.47) |

Resident lands on the documented Strix Halo figures (GLM 47–80 prefill / 14.25
gen; Flash IQ2 14.82 gen). Streaming costs ~1.7× decode / ~2.2× prefill.

Memory at `--ctx 131072` resident: `KV 1.46 + buffers 3.16 + model 89.87 =
94.49 GiB`, leaving ~8 GiB for the OS. GLM (90) and Flash (81) can't both be
resident at once on 125 GiB.

- **Do not use `--ctx 1000000`.** It forces streaming, reserves ~14.6 GiB of
  context buffers, and shrinks the expert cache (52 GiB / 6,852 experts vs
  63.6 GiB / 8,596 at ctx 4k).
- `SSD_STREAMING.md` recommends `--ctx 4096` for the reference Q2 setup only
  because some 128 GB boards expose ~62 GB to the GPU; this box reports a
  124 GiB working set, so resident fits.
- `--kv-disk-dir` checkpoints cold prefixes (≤30k) and aligned continued
  frontiers (every 10k), and persists the exact DSML tool-replay map, so a
  server restart no longer forces a cold 30k-token prefill. The dir contains
  prompt text and model state — keep it private (`0700`).
  Add `--kv-cache-reject-different-quant` if swapping quants.

## Thinking levels — the important part

ds4 has exactly **three** reasoning states, not seven:

```
none  -> no thinking (renders the non-thinking prompt)
high  -> normal thinking
max   -> Think Max (gated, see below)
```

`parse_reasoning_effort_name()` maps **`low` / `medium` / `high` / `xhigh` /
`minimal` all to `THINK_HIGH`**, and `think_mode_from_enabled()` funnels every
non-`none`/non-`max` effort to `THINK_HIGH`. So `low`, `medium`, `high`,
`xhigh`, and `minimal` are byte-for-byte identical at the server.

`max` is gated by context:

```c
#define DS4_THINK_MAX_MIN_CONTEXT 393216u
// ds4_think_mode_for_context(): MAX -> HIGH when ctx < 393216
// exception: DS4_MODEL_FAMILY_DEEPSEEK41 (V4.1) keeps max at any ctx
```

At `--ctx 131072`, `max` silently becomes `high`, so exposing it would be a lie.

Therefore the map exposes only the real states:

```json
"thinkingLevelMap": {
  "off": "none",
  "minimal": null,
  "low": null,
  "medium": null,
  "high": "high",
  "xhigh": null,
  "max": null
}
```

- `off` kept — genuinely distinct.
- `high` kept — the single "thinking on" level.
- `low`/`medium`/`minimal`/`xhigh` dropped — all aliases of `high` at the
  server, so exposing them would only add identical choices.
- `max` dropped — alias of `high` below ctx 393216. Re-add `"max": "max"` only
  when running `--ctx 393216+` or a V4.1 GGUF.

Gotcha: `defaultThinkingLevel` is `medium`, which is now `null`, so Pi clamps
it up to `high` (observed in ds4 server traces). If the "medium" label matters,
set `"medium": "high"` instead of `null` — same request, familiar UI.

## models.json fields

Provider `compat` matches `docs/CLIENTS.md` verbatim:

| Field | Why |
|---|---|
| `supportsStore: false` | ds4 has no `store` |
| `supportsDeveloperRole: false` | send `system`, not `developer` |
| `supportsReasoningEffort: true` | ds4 reads `reasoning_effort` |
| `supportsUsageInStreaming: true` | real cache/usage details in SSE |
| `maxTokensField: "max_tokens"` | ds4 advertises `max_tokens` |
| `supportsStrictMode: false` | no strict JSON-schema tools |
| `thinkingFormat: "deepseek"` | toggle via `thinking`/`reasoning_effort` |
| `requiresReasoningContentOnAssistantMessages: true` | Pi must replay `reasoning_content`; ds4 re-renders it in GLM tool turns, and mismatched replay is what breaks the KV prefix |

GLM overrides `thinkingFormat: "reasoning_effort"` (top-level
`reasoning_effort`, no `thinking` object) — that's what the server expects for
GLM. Verified in a raw request trace.

Sizing: `contextWindow` must never exceed the server's `--ctx`, and
`maxTokens` is carved out of it. Currently `contextWindow: 131072`,
`maxTokens: 32768`. The old `1000000` / `384000` values were sized for a server
that shouldn't be run.

### `-chat` / `-reasoner` aliases

`model_alias_disables_thinking()` (`*-chat`, `*-no-think`) and
`model_alias_enables_thinking()` (`*-reasoner`) force thinking off/on via the
model id. They only apply when the request did **not** set an explicit thinking
control (`!got_thinking`), and `reasoning_effort` does **not** set
`got_thinking`. Pointing Pi at `glm-5.3-flash-chat` would therefore force
thinking off and quietly ignore Pi's `reasoning_effort`. Use the base id.

## Related

- `ds4_server.c` `send_models()` advertised `glm-5.2*` for every GLM DSA
  engine. Fixed upstream in PR antirez/ds4#1055; the desktop build carries the
  patch.
- Reference docs: `docs/CLIENTS.md`, `docs/SSD_STREAMING.md`,
  `docs/PERFORMANCE.md`, `docs/STRIX_HALO.md`, `QA_BEFORE_RELEASES.md`.
