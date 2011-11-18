_ezp()
{
    local cur prev opts

    # Exit directly if not in an ezpublish instance
    if [ ! -f lib/version.php ]; then
        return 0
    fi

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in

        # completion for ezp command: script names
        ezp)
            scripts=`echo "" | php ezp.php _scripts`
            _ezp_complete "${scripts}" "${cur}"
            return 0
            ;;

        # other: arguments for the executed script
        *)
            script="${COMP_WORDS[1]}"
            options=`echo "" | php ezp.php _args ${script}`
            _ezp_complete "${options}" "${cur}"
            return 0
            ;;
    esac
}
complete -o default -o nospace -F _ezp ezp 2>>/dev/null || -o default -o nospace -F _ezp ezp 2>>/dev/null

# Parameters:
# @param $1 Options string, \n separated
# @param $2 Current word
_ezp_complete()
{
    _ezp_p_debug "CUR='${2}', W='${1}'"
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "${1}" -- ${2}) )
    _ezp_p_debug "COMPREPLY=${COMPREPLY}"
}

# Debug method. Prints to completion.log
# @param $1 String to print
_ezp_p_debug()
{
    echo "* ${1}" >> completion.log
}
