# Short-term Prometheus for llama-server (rootless podman)

- Container: `prometheus-short`, host networking, web UI on 127.0.0.1:9090
- Config: `prometheus.yml` (this dir), bind-mounted read-only +SELinux :z
- TSDB data: `~/.local/share/prometheus-data` (7d retention)
- Scrapes router `127.0.0.1:9931/metrics?model=qwen3.6-35b-a3b` every 10s
- Router requires `?model=` per job (400 without it)

Manage:
    podman start prometheus-short | podman stop prometheus-short | podman logs -f prometheus-short
    # config edits: podman exec prometheus-short kill -HUP 1   (or restart)

Useful queries (qwen3.6 job):
    increase(llamacpp:prompt_tokens_seconds[...])   # prompt tok/s windowed
    llmacpp:predicted_tokens_seconds                 # gen tok/s gauge
    sum(increase(llamacpp:spec_decode_num_accepted_tokens_total[5m]))
      / sum(increase(llamacpp:spec_decode_num_draft_tokens_total[5m]))   # acceptance
    sum(llamacpp:spec_decode_num_accepted_tokens_per_pos_total{position="1"})
      / sum(llamacpp:spec_decode_num_accepted_tokens_per_pos_total{position="0"})  # pos1 conditional

NOTE: rootless container does NOT auto-restart on machine reboot; restart manually with `podman start prometheus-short` (or promote to a quadlet user service if it outlives the short-term window).
