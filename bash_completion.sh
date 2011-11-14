_ezp()
{
    local cur prev opts

    # No other arguments: list commands
    # Commands are to be returned by the ezp.php script, that should list bin scripts available in the CURRENT instance
    # This also means that if no current instance is available (e.g. if we're not in an ezpublish root), no completion
    # must be offered.

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    p_debug "PREV: ${prev}"


    case "${prev}" in

        # completion for ezp command: script names
        ezp)
            scripts=`echo "" | php ezp.php scripts`
            COMPREPLY=( $(compgen -W "${scripts}" -- ${cur}) )
            return 0
            ;;

        # other: arguments for the executed script
        *)
            options=`echo "" | php ezp.php args ${prev}`
            p_debug "OPTIONS: ${options[@]}"
            COMPREPLY=( $(compgen -W "${options}" -- ${cur}) )
            return 0
            ;;
    esac
}
complete -F _ezp ezp

p_debug()
{
    echo "* ${1}" >> completion.log
}