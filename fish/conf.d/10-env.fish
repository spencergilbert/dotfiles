if type -q nvim
	set -gx EDITOR nvim
	set -gx VISUAL nvim
end

set -q XDG_CONFIG_HOME; or set -gx XDG_CONFIG_HOME $HOME/.config
set -q XDG_STATE_HOME; or set -gx XDG_STATE_HOME $HOME/.local/state

set -gx CLAUDE_CONFIG_DIR $XDG_CONFIG_HOME/claude
set -gx CODEX_HOME $XDG_CONFIG_HOME/codex
set -gx PI_CODING_AGENT_DIR $XDG_CONFIG_HOME/pi
set -gx PI_CODING_AGENT_SESSION_DIR $XDG_STATE_HOME/pi/sessions

# The desktop loads its extra mise env (ROCm toolchains, llama-server files)
# on top of the base + linux envs. Hostname-gated so other machines
# (including macOS) are unaffected.
if test (hostname) = desktop; and not set -q MISE_ENV
	set -gx MISE_ENV desktop
end

set -gx MCP_UI_VIEWER none
