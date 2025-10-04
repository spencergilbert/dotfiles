# Dotfiles

Personal workstation setup for DNF-based systems (Fedora, RHEL, etc.) using bash scripts and GNU Stow.

## Quick Start

**Fresh system:**
```bash
curl -fsSL https://raw.githubusercontent.com/spencergilbert/dotfiles/main/bootstrap.sh | bash
```

**Update existing:**
```bash
git pull && ./install.sh
```

## What's Included

- Modern CLI tools (ripgrep, eza, bat, zoxide, git-delta, btop, helix)
- Fish shell with minimal prompt and git integration
- SSH config with 1Password agent integration
- Git config with delta diff viewer
- Container tools (podman, toolbox)
- Development tools (gh, just, ansible)

## Post-Bootstrap

1. Launch 1Password and enable SSH agent in settings
2. Restart terminal: `exec fish`

## Structure

```
.
├── bootstrap.sh
├── install.sh
├── packages.txt
├── gnome/
│   └── ptyxis.conf
└── stow/
    ├── bash/
    ├── fish/
    ├── git/
    ├── helix/
    └── ssh/
```

## Usage

**Add packages:** Add to `packages.txt`, run `./install.sh`

**Add dotfiles:** Create `stow/<name>/`, run `./install.sh`

**Remove dotfiles:**
```bash
stow --delete --dir=stow --target="$HOME" <name>
```

## Development

**Validate:**
```bash
shellcheck *.sh && shfmt --diff *.sh
```

**Test in isolation:**
```bash
toolbox create test && toolbox enter test
./install.sh
```

## Key Features

**Fish shell:** Custom prompt with git status, exit codes, and aliases (`ls`→`eza`, `cat`→`bat`, `z` for smart cd)

**SSH:** 1Password agent integration with modular `config.d` structure

**Git:** Delta diff viewer with syntax highlighting and side-by-side view

## Why These Choices?

**Bash scripts:** Simple, fast, idempotent, no runtime dependencies

**GNU Stow:** Simple symlink management, easy to inspect and modify

**1Password:** SSH key management, no secrets in git, GUI access

## License

MIT
