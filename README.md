# dotfiles

Personal dotfiles, kept as an auth-free public base that any machine can clone
and apply. Machine- and OS-specific pieces are layered on top instead of being
templated in: Linux lives in `mise.linux.toml` / `mise.desktop.toml` here, while
the macOS work setup lives in a private overlay repo that layers on this base
(Homebrew packages, work git identity, 1Password signing, Pi's vault keys).
Nothing in this repo needs a credential to read or clone.

## Install

```sh
./install.sh
```

`install.sh` installs `mise`, bootstraps from the public Tangled URL, and trusts
the checkout so later bare `mise` runs don't prompt. Pulls stay on HTTPS;
`mise run configure-forge-remotes` ([bootstrap.hooks.final]) points pushes at
the Tangled, GitLab, and GitHub mirrors.

## Layout

| path | contents |
| --- | --- |
| `mise.toml` | base layer: shared dotfiles, tools, bootstrap hooks |
| `mise.linux.toml` | Fedora packages, Linux-only tools (`glab`, `tg`), 1Password agent, Pi keys |
| `mise.desktop.toml` | AMD ROCm host notes (packages come from the amferd runbook) |
| `bashrc.d/`, `fish/` | shell startup, wired up via `~/.bashrc.d/` and `~/.config/fish/` |
| `bin/` | helper scripts on `~/.local/bin` |
| `git/` | `config`, `ignore`, `allowed_signers` |
| `ghostty/`, `bat/`, `nvim/` | terminal and editor config |
| `pi/` | Pi settings, models, MCP servers, and per-OS keys |
| `ssh/conf.d/` | ssh config fragments included from `~/.ssh/config` |
| `shared/AGENTS.md` | single copy of the agent instructions |
| `.mise/tasks/` | repo tasks (`configure-forge-remotes`, `setup-dnf-repos`) |

Two conventions worth knowing before editing:

- **Absolute sources.** `mise.toml` is also read through the
  `~/.config/mise/config.toml` symlink, so relative dotfile sources break
  whenever the cwd is outside this repo. Always write `~/.dotfiles/...`.
- **Blocks, not line edits.** `~/.ssh/config` gets an `Include conf.d/*.conf`
  block, because `mise dot unapply` refuses an entry it can't prove it owns and
  then takes every other entry down with it.

## Machine-local overrides

OS differences are no longer rendered from templates. Each tool includes an
untracked file when it exists, which is also where the private overlay drops its
identity:

- `~/.config/git/config.local` — included last by `~/.config/git/config`
  (identity, signing key, the 1Password `op-ssh-sign` path).
- `~/.config/ghostty/config.local` — optional `config-file` include.

`git/allowed_signers` ships the personal key only; work keys arrive with the
overlay. Pi is managed with merges rather than copies: `pi/settings.json` and
`pi/mcp.json` are merged as `base`, the per-OS `pi/settings.*.json` as `shared`,
and the `pi/auth.*.json` keys are merged into `auth.json` so `/login` and
`/logout` can still write it. The MCP base carries only the shared `grafana`
server, so the overlay can merge its private servers alongside it. A
`[bootstrap.hooks.pre-dotfiles]` hook seeds `auth.json` at 0600 before the
merge touches it.

## License

MIT-0
