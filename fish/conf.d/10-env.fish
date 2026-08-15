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

if not set -q SSH_CONNECTION
	set -gx KAGI_API_KEY "$(op read op://Private/Pi/kagi)"
end
