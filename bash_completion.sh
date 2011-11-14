_ezp()
{
    local cur prev opts

    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    p_debug "PREV: ${prev}"


    case "${prev}" in

        # completion for ezp command: script names
        ezp)
            scripts=`echo "" | php ezp.php _scripts`
            COMPREPLY=( $(compgen -W "${scripts}" -- ${cur}) )
            return 0
            ;;

        # other: arguments for the executed script
        *)
            script="${COMP_WORDS[1]}"
            options=`echo "" | php ezp.php _args ${script}`
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