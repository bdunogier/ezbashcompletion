# Comment out to disable logging to ./completion.log
DEBUG=0

__ezp_reassemble_comp_words_by_ref()
{
    local exclude i j first
    # Which word separators to exclude?
    exclude="${1//[^$COMP_WORDBREAKS]}"
    cword_=$COMP_CWORD
    if [ -z "$exclude" ]; then
        words_=("${COMP_WORDS[@]}")
        return
    fi
    # List of word completion separators has shrunk;
    # re-assemble words to complete.
    for ((i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++)); do
        # Append each nonempty word consisting of just
        # word separator characters to the current word.
        first=t
        while
            [ $i -gt 0 ] &&
            [ -n "${COMP_WORDS[$i]}" ] &&
            # word consists of excluded word separators
            [ "${COMP_WORDS[$i]//[^$exclude]}" = "${COMP_WORDS[$i]}" ]
        do
            # Attach to the previous token,
            # unless the previous token is the command name.
            if [ $j -ge 2 ] && [ -n "$first" ]; then
                ((j--))
            fi
            first=
            words_[$j]=${words_[j]}${COMP_WORDS[i]}
            if [ $i = $COMP_CWORD ]; then
                cword_=$j
            fi
            if (($i < ${#COMP_WORDS[@]} - 1)); then
                ((i++))
            else
                # Done.
                return
            fi
        done
        words_[$j]=${words_[j]}${COMP_WORDS[i]}
        if [ $i = $COMP_CWORD ]; then
            cword_=$j
        fi
    done
}

if ! type _get_comp_words_by_ref >/dev/null 2>&1; then
_get_comp_words_by_ref()
{
    local exclude cur_ words_ cword_
    if [ "$1" = "-n" ]; then
        exclude=$2
        shift 2
    fi
    __ezp_reassemble_comp_words_by_ref "$exclude"
    cur_=${words_[cword_]}
    while [ $# -gt 0 ]; do
        case "$1" in
        cur)
            cur=$cur_
            ;;
        prev)
            prev=${words_[$cword_-1]}
            ;;
        words)
            words=("${words_[@]}")
            ;;
        cword)
            cword=$cword_
            ;;
        esac
        shift
    done
}
fi


_ezp()
{
    local cur prev opts

    if [ -n "$EZPCOMP_IS_EZ_DIR" ]; then EZPCOMP_IS_EZ_DIR=0; fi
    # Exit directly if not in an ezpublish instance
    CWD=$(pwd)
    EZPCOMP_PWD=$CWD

    # Reset the previous working directory if it doesn't match the current one
    if [ -n "$EZPCOMP_PWD" ] || [ "$EZPCOMP_PWD" -ne "$CWD" ]; then
        local cwd_array ifs_bak
        IFS_BAK=$IFS
        IFS="/"
	CWD_ARRAY=( $CWD )
        EZPCOMP_IS_EZ_DIR=0
	for(( index=${#CWD_ARRAY[*]} ; index > 0 ; index-- ))
        do
            local testdir    
            testdir="${CWD_ARRAY[*]:0:$index}"
            _ezp_p_debug "$index: $testdir/lib/version.php"
            if [ -f "$testdir/lib/version.php" ]; then
                _ezp_p_debug "$testdir did match"
                EZPCOMP_EZ_DIR="$testdir"
                EZPCOMP_IS_EZ_DIR=1
                EZPCOMP_PWD=$CWD
                export EZPCOMP_EZ_DIR
                export EZPCOMP_IS_EZ_DIR
                break
            fi
        done
        IFS=$IFS_BAK
    fi

    # Not an eZ Dir
    if [ -z "$EZPCOMP_IS_EZ_DIR" ] || [ "$EZPCOMP_IS_EZ_DIR" -eq 0 ]; then
        return 0
    fi

    COMPREPLY=()
    #cur=$(_get_cword "=")
    _get_comp_words_by_ref -n =: cur prev

    prev="${COMP_WORDS[COMP_CWORD-1]}"


    # Store the current command for further usage
    if [ $COMP_CWORD -gt 1 ]; then COMMAND=${COMP_WORDS[1]}; fi

    _ezp_p_debug "COMP_CWORD: ${COMP_CWORD} | COMP_WORDS: ${COMP_WORDS[*]} | PREV: ${prev} | CUR: ${cur} | COMMAND: ${COMMAND}"
    
    case "$cur" in

        # siteaccess completion
        --siteaccess=*)
            _ezp_exec "_siteaccess_list"
            _ezp_complete "${exec_result}" "${cur##--siteaccess=}"
            return 0
            ;;

        # ezcache.php --clear-tag=
        --clear-tag=*)
            _ezp_exec "_ezcache_tags"
            _ezp_complete "${exec_result}" "${cur##--clear-tag=}"
            return 0
            ;;

        # ezcache.php --clear-id=
        --clear-id=*)
            _ezp_exec "_ezcache_ids"
            _ezp_complete "${exec_result}" "${cur##--clear-id=}"
            return 0
    esac

    case "$prev" in

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
            _ezp_complete "${exec_result}" "${cur##--siteaccess=}"
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
    # _ezp_p_debug "_ezp_complete '$1' '$2'"
    local IFS=$'\n'
    COMPREPLY=( $(compgen -W "$1" -- "$2" ) )
}

# Executes ezp.php with the given arguments
#
# @param $1 Command to execute
# @param $2...n Extra arguments
_ezp_exec()
{
    if [ -n "$EZPCOMP_IS_EZ_DIR" ] || [ "$EZPCOMP_IS_EZ_DIR" -eq 1 ]; then
        _ezp_p_debug "cd $EZPCOMP_EZ_DIR"
	cd "$EZPCOMP_EZ_DIR" > /dev/null
    fi

    local command="ezp ${1} ${2}"
    _ezp_p_debug "Exec command: ${command} from wd $(pwd)"
    exec_result=`echo "" | ${command}`
    
    if [ -n "$EZPCOMP_IS_EZ_DIR" ] || [ "$EZPCOMP_IS_EZ_DIR" -eq 1 ]; then
        _ezp_p_debug "cd -"
	cd - > /dev/null
    fi
}

# Debug method. Prints to completion.log
# @param $1 String to print
_ezp_p_debug()
{
    local DEBUG
    
    if [ -n "$DEBUG" ]; then
        echo "* ${1}" >> /tmp/ezcompletion.log
    fi
}
