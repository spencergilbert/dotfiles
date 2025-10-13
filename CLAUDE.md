# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

Personal dotfiles repository for DNF-based Linux systems using bash scripts. Manages package installation, dotfile deployment via GNU Stow, and GNOME configuration. Designed for idempotent, repeatable workstation setup with minimal dependencies.

## Common Commands

### Installation

```bash
# Full installation (idempotent - safe to run multiple times)
./install.sh

# Fresh system bootstrap
curl -fsSL https://raw.githubusercontent.com/spencergilbert/dotfiles/main/bootstrap.sh | bash

# Or inspect first (recommended)
curl -fsSL https://raw.githubusercontent.com/spencergilbert/dotfiles/main/bootstrap.sh -o bootstrap.sh
less bootstrap.sh
bash bootstrap.sh
```

### Validation & Testing

```bash
shellcheck *.sh && shfmt --diff *.sh
```

### Update

```bash
# Update existing system
git pull
./install.sh
```

## Architecture

### Script Execution Flow

`install.sh` executes in this order:

1. **1Password repository setup** - Adds official RPM repo (only if 1Password not installed)
2. **Package installation** - Installs all packages from `packages.txt` via DNF
3. **Dotfile stowing** - Loops through `stow/*/` and creates symlinks
4. **GNOME configuration** - Loops through `gnome/*.conf` and loads via dconf

### Dotfiles Management

- **Tool**: GNU Stow for symlink management
- **Structure**: `stow/<package>/.config/...` maps to `~/.config/...`
- **Packages discovered dynamically**: `install.sh` loops through `stow/*/` to auto-discover all directories
- **Adding new packages**: Just create `stow/<new-package>/` directory - no code changes needed
- **Idempotency**: Stow is idempotent by default - re-stowing existing links is a no-op

### Key Directories

```
├── install.sh                # Main installation script (idempotent)
├── bootstrap.sh              # Fresh system bootstrap script
├── packages.txt              # Flat list of DNF packages

├── stow/                     # Dotfiles (each subdir = one stow package)
│   └── <package>/            # Auto-discovered by install.sh
│       └── .config/...       # Maps to ~/.config/...
└── gnome/                    # GNOME dconf configuration files
    └── <AppName>.conf        # Auto-discovered by install.sh
```

### Bootstrap Design

`bootstrap.sh` clones via HTTPS then auto-converts to SSH:
- HTTPS works immediately for public repos (no 1Password agent needed during bootstrap)
- Auto-converts remote to SSH after `install.sh` completes
- Repo is ready for pushing once user completes 1Password setup

### Package Management

- **Platform**: DNF-based systems (Fedora, RHEL 8+, CentOS Stream, etc.)
- **Third-party repos**: 1Password repo setup in `install.sh` (only if 1Password not installed)
- **Package list**: `packages.txt` (flat list, add new packages here)
- **Modern CLI tools**: ripgrep, bat, git-delta, zoxide, btop, etc.

### Shell Configuration

- **Interactive shell**: Fish (auto-launched from bash via `.bashrc`)
- **Login shell**: Bash (intentionally unchanged)
- **Rationale**: Keeps bash as the default login shell to maintain POSIX compliance for system scripts, SSH non-interactive commands, and to avoid lockout risks during system upgrades (especially on Fedora Atomic/Silverblue where layered packages may be temporarily unavailable)
- **Implementation**: See `stow/bash/.bashrc` for the auto-launch logic

### GNOME Configuration

- **Method**: `dconf load` for each `gnome/*.conf` file
- **Discovery**: Automatic loop through `gnome/*.conf`
- **Adding new apps**: Create `gnome/appname.conf`, run `install.sh` - no code changes needed

## Important Implementation Details

### Safe Re-execution

Scripts are designed to be safe to run multiple times without causing harm or duplicates:

- **DNF**: Skips already-installed packages
- **Stow**: Re-stowing existing links is a no-op
- **dconf**: Loads settings (always runs, but overwrites to desired state)

### Design Principles

**Prefer automatic discovery over hardcoded lists:**
- Loop through directories/files rather than maintaining manual lists
- Adding new packages/configs requires no code changes
- Examples: `stow/*/` loop, `gnome/*.conf` loop

**Use long flags for readability:**
- `--assumeyes` not `-y`
- `--invert-match` not `-v`
- Makes intent clear without consulting man pages

**Trust tool behavior:**
- Don't add unnecessary existence checks
- Let tools handle their own idempotency
- Keep scripts simple and maintainable

**Comments explain "why" not "what":**
- Only comment on non-obvious decisions
- Example: "1Password not available in Fedora repos - add official repo"

### Cleanup Tasks

**Broken symlinks:** If you remove a package from `stow/`, clean up manually:
```bash
find ~/.config ~/.ssh -xtype l -delete
```

## Development Workflow

### Adding New Dotfile Packages

1. Create `stow/<package>/.config/<app>/...` structure
2. Run `./install.sh`
3. No code changes needed - package auto-discovered

### Adding New System Packages

1. Add package name to `packages.txt`
2. Run `./install.sh`

### Adding New GNOME Configs

1. Export settings: `dconf dump /org/gnome/appname/ > gnome/appname.conf`
2. Run `./install.sh`
3. No code changes needed - config auto-discovered

### Testing in Isolated Environments

**Using toolbox (quick, isolated):**
```bash
toolbox create dotfiles-test
toolbox enter dotfiles-test
cd /path/to/dotfiles
./install.sh
```

**Using VM (full fidelity testing):**
```bash
vagrant init fedora/42-cloud-base
vagrant up
vagrant ssh
curl -fsSL https://raw.githubusercontent.com/USER/dotfiles/main/bootstrap.sh | bash
```

## Platform Notes

- **Target OS**: DNF-based Linux (Fedora, RHEL 8+, CentOS Stream, etc.)
- **Architecture**: x86_64
- **Desktop**: GNOME

## Architecture Decisions

### Why Bash Scripts Over Ansible?

- **Simplicity**: Minimal bash scripts vs hundreds of lines of YAML
- **Dependencies**: 1 tool (stow) vs 2 (ansible-core + stow)
- **Maintainability**: Standard bash + dnf + stow - easy to understand and modify
- **Performance**: Fast execution, no Python interpreter overhead
- **Use case**: 2 similar Framework machines - Ansible abstraction not needed

### Why GNU Stow?

- Simple, widely understood symlink management
- Language/tool agnostic (just creates symlinks)
- Easy to inspect what's linked where
- Safe re-stowing (no-op if links already exist)

### Why 1Password?

- Already using for SSH keys and git signing
- Better UX than encrypted files (GUI, mobile access)
- No secrets stored in git (even encrypted)
- Single source of truth for all secrets

### Why Not Change Default Shell to Fish?

- **POSIX compliance**: System scripts and SSH non-interactive commands require bash/POSIX semantics
- **Safety**: Prevents lockouts during system upgrades (especially Fedora Atomic/Silverblue)
- **Compatibility**: Works with ostree updates where layered packages may be temporarily unavailable
- **Solution**: Fish auto-launches from bash via `.bashrc` for interactive sessions only
- **Reference**: https://tim.siosm.fr/blog/2023/12/22/dont-change-defaut-login-shell/

## Related Documentation

- **README.md**: User-facing documentation, quick start guide, usage examples
