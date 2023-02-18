# Create symlink of the file
# usage: link_file FILE [-ds] [-t TARGET_DIRECTORY]
# options:
# -d, --as-dotfile        link as dotfile
# -s, --silent, --quiet   don't print log messages
# -t                      directory to put the link in
link_file () {
    . $(dirname $BASH_SOURCE)/options.sh

    parse_opts dst: "$@"
    set -- ${OPTS[@]-}
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--as-dotfile)
                local dotfile=;;
            -s|--silent|--quiet)
                silent=;;
            -t) local target_dir="$2"
                shift
                ;;
            *)  echo lib/symlinks.sh: \'link_file\' function: bad usage >&2
                return 1
                ;;
        esac
        shift
    done

    if [[ -n ${ARGS[0]-} ]]; then
        local file="$(readlink -f "${ARGS[0]}")"
    else
        echo lib/symlinks.sh: \'link_file\' function: bad usage >&2
        return 1
    fi

    local actual_file="$file"
    local target_file="${target_dir:-$HOME}/${dotfile+.}$(basename "$file")"

    if [[ -L "$target_file" || -e "$target_file" ]]; then
        # Check permissions to overwrite the existing file
        while [[ -z "${ALLOW_OVERWRITE-}" || "$ALLOW_OVERWRITE" != [yYnN] ]]; do
            read -p 'WARNING: existing dotfiles found. Overwrite them? (y/N) ' ALLOW_OVERWRITE

            [[ -n "${ALLOW_OVERWRITE-}" ]] || ALLOW_OVERWRITE=N

            [[ "$ALLOW_OVERWRITE" = [yYnN] ]] || echo "You need to answer Y(es) or N(o) (default N)\n" >&2
        done

        case $ALLOW_OVERWRITE in
            [yY])
                [[ -n "${silent+set}" ]] || echo Replacing file: ${target_file/$HOME/\~}
                rm "$target_file"
                ln -s "$actual_file" "$target_file"
                ;;
            [nN])
                [[ -n "${silent+set}" ]] || echo Skipping file: ${target_file/$HOME/\~}
                ;;
            *)  echo lib/symlinks.sh: programming error >&2
                return 2
                ;;
        esac
    else
        [[ -n "${silent+set}" ]] || echo Creating link: ${target_file/$HOME/\~}
        ln -s "$actual_file" "$target_file"
    fi
}

# Create symlinks of files found in DIRECTORY
# usage: link_files_in DIRECTORY [-ds] [-e 'excluded|files|separated|with|pipes'] [-t TARGET_DIRECTORY]
# options:
# -d, --as-dotfile        link as dotfile
# -e                      exclude files
# -s, --silent, --quiet   don't print log messages
# -t                      directory to put links in
link_files_in () {
    . $(dirname $BASH_SOURCE)/options.sh

    parse_opts de:st: "$@"
    set -- ${OPTS[@]-}
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--as-dotfile)
                local dotfile=;;
            -e) local exclude="$2"
                shift
                ;;
            -s|--silent|--quiet)
                silent=;;
            -t) local target_dir="$2"
                shift
                ;;
            *)  echo lib/symlinks.sh: \'link_files_in\' function: bad usage >&2
                return 1
                ;;
        esac
        shift
    done

    if [[ -n ${ARGS[0]-} ]]; then
        local dir="$(readlink -f "${ARGS[0]}")"
    else
        echo lib/symlinks.sh: \'link_files_in\' function: bad usage >&2
        return 1
    fi

    # Exclude sub-directories, scripts and explicitly excluded files
    local exclude=".*/|.+\.sh${exclude+|$exclude}"
    local file

    # Loop on every file in DIRECTORY, except the excluded ones
    for file in $(ls -p "$dir" | grep -Ewv "$exclude"); do
        link_file "$dir/$file" ${dotfile+-d} ${target_dir+-t $target_dir} ${silent+-s}
    done
}
