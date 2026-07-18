# Reverse priority order: the LAST call lands frontmost. Nonexistent dirs are
# skipped, so the Apple Silicon and Linux Homebrew paths are both safe to list.
# mise activate re-prepends its tool dirs every prompt, so mise always wins.
fish_add_path --path --move /usr/local/bin /usr/local/sbin
fish_add_path --path --move /opt/homebrew/bin /opt/homebrew/sbin
fish_add_path --path --move /home/linuxbrew/.linuxbrew/bin /home/linuxbrew/.linuxbrew/sbin
fish_add_path --path --move ~/.local/bin
