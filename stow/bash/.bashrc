# Auto-launch fish shell for interactive sessions
# Reference: https://tim.siosm.fr/blog/2023/12/22/dont-change-defaut-login-shell/
#
# This approach is safer than changing the default login shell because:
# - System scripts and SSH non-interactive commands still use bash
# - Graceful fallback to bash if fish is unavailable
# - No risk of being locked out during system upgrades (esp. Fedora Atomic/Silverblue)
# - Compatible with ostree updates where layered packages may be temporarily unavailable

# Get fish path dynamically (respects PATH, works with custom installs)
FISH_BIN=$(command -v fish)

# Only trigger if:
# - 'fish' is not the parent process of this shell (prevents exec loops)
# - We did not call: bash -c '...' (preserves SSH non-interactive commands)
# - The fish binary exists and is executable
if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ${BASH_EXECUTION_STRING} && -n "$FISH_BIN" && -x "$FISH_BIN" ]]; then
  # Preserve login shell semantics (important for TTY and SSH login sessions)
  shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=''
  exec "$FISH_BIN" $LOGIN_OPTION
fi
