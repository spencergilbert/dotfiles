function fish_prompt
    set -l last_command_status $status

    set -l normal_color (set_color normal)
    set -l success_color (set_color brgreen)
    set -l error_color (set_color $fish_color_error 2> /dev/null; or set_color --bold red )
    set -l directory_color (set_color $fish_color_quote 2> /dev/null; or set_color brown)

    # Color the prompt differently when we're root
    set -l prompt_string "❯"
    if functions -q fish_is_root_user; and fish_is_root_user
        if set -q fish_color_cwd_root
            set directory_color (set_color $fish_color_cwd_root)
        end
        set prompt_string "#"
    end

    echo -n -s (smart_prompt_login)
    echo -n -s $directory_color (git_aware_pwd) $normal_color

    # Git/VCS info if available
    echo -n (fish_vcs_prompt ' on %s')

    # Always newline before prompt character
    echo ""

    # Color the prompt in red on error
    if test $last_command_status -eq 0
        echo -n -s $success_color $prompt_string $normal_color
    else
        echo -n -s $error_color $prompt_string $normal_color
    end

    echo -n -s " "
end
