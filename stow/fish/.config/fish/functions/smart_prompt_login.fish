function smart_prompt_login --description 'Display ccontextual tags when not in normal environment'
    set -l tags

    # SSH session
    if set -q SSH_TTY
        set -a tags (set_color yellow)"[ssh]"(set_color normal)
    end

    # Toolbox container
    if test -f /run/.toolboxenv
        set -a tags (set_color blue)"[toolbox]"(set_color normal)
    end

    # Root user
    if test (id -u) -eq 0
        set -a tags (set_color red)"[root]"(set_color normal)

    # Sudo session (shows as different user while preserving SUDO_USER)
    else if set -q SUDO_USER
        set -a tags (set_color red)"[sudo:$USER]"(set_color normal)
    end

    # Print all tags with space after if any exist
    if test (count $tags) -gt 0
        echo -n -s $tags " "
    end
end
