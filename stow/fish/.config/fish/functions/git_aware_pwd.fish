function git_aware_pwd --description 'Show repo-relative path with caching'
    # Check if we have a cached value for current directory
    if set -q __git_aware_pwd_cache_value; and test "$__git_aware_cache_key" = "$PWD"
        echo $__git_aware_pwd_cache_value
        return
    end

    # Calculate value
    set -l result
    set -l git_root (git rev-parse --show-toplevel 2>/dev/null)

    if test -n "$git_root"
        set -l repo_name (basename $git_root)
        set -l git_prefix (git rev-parse --show-prefix 2>/dev/null | string trim -r -c /)

        if test -n "$git_prefix"
            set result "$repo_name/$git_prefix"
        else
            set result "$repo_name"
        end
    else
        set result (prompt_pwd)
    end

    # Cache for this directory
    set -g __git_aware_pwd_cache_key $PWD
    set -g __git_aware_pwd_cache_value $result

    echo $result
end

# Clear cache when directory changes
function __git_aware_pwd_clear_cache --on-variable PWD
    set -e __git_aware_pwd_cache_key
    set -e __git_aware_pwd_cache_value
end
