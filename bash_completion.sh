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

    if [ "${cur}" = "=" ]; then
        #todo split on = to get a valid $cur
        prev="${prev}="
        cur=""
    fi

    _ezp_p_debug "PREV: ${prev}"

    case "${prev}" in

        # completion for ezp command: script names
        ezp)
            _ezp_exec "_scripts"
	    scripts=$exec_result
            _ezp_complete "${scripts}" "${cur}"
            return 0
            ;;

        # siteaccess completion
	--siteaccess | -s)
	    _ezp_exec "_siteaccess_list"
	    _ezp_complete "${exec_result}" "${cur}"
            return 0
	    ;;

        # ezcache.php --clear-tag=
        --clear-tag=)
            _ezp_exec "_ezcache_tags"
            _ezp_complete "${exec_result}" "${cur}"     
            return 0
            ;;

        # ezcache.php --clear-id=
        --clear-id=)
            _ezp_exec "_ezcache_ids"
            _ezp_complete "${exec_result}" "${cur}"     
            return 0
            ;;

        # other: arguments for the executed script
        *)
            script="${COMP_WORDS[1]}"
            _ezp_exec "_args" "${script}"
	    options=$exec_result
	    _ezp_complete "${options}" "${cur}"
            return 0
            ;;
    esac
}
complete -o default -o nospace -F _ezp ezp 2>>/dev/null || -o default -o nospace -F _ezp ezp 2>>/dev/null

# COMPREPLY generator, based on a \n separated list of words
#
# @param $1 Options string, \n separated
# @param $2 Current word
_ezp_complete()
{
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "$1" -- $2 ) )
}

# Executes ezp.php with the given arguments
#
# @param $1 Command to execute
# @param $2...n Extra arguments
_ezp_exec()
{
    local command="php ezp.php ${1} ${2}"
    _ezp_p_debug "Exec command: ${command}"
    exec_result=`echo "" | ${command}`
}

# Debug method. Prints to completion.log
# @param $1 String to print
_ezp_p_debug()
{
    echo "* ${1}" >> completion.log
}
