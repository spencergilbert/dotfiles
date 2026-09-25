# Provide mise-managed tools (rg, zig, …) to non-interactive shells, including
# `ssh <host> cmd` and the pi ssh extension. --shims is mise's documented form
# for non-interactive shells; it just prepends the shims dir to PATH.
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash --shims)"
fi
