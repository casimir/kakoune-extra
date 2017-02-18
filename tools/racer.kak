decl -hidden str racer_tmp_dir
decl -hidden completions racer_completions

def racer-complete -docstring "Complete the current selection with racer" %{
    %sh{
        dir=$(mktemp -d -t kak-racer.XXXXXXXX)
        printf %s\\n "set buffer racer_tmp_dir ${dir}"
        printf %s\\n "eval -no-hooks %{ write ${dir}/buf }"
    }
    %sh{
        dir=${kak_opt_racer_tmp_dir}
        (
            cursor="${kak_cursor_line} $((${kak_cursor_column} - 1))"
            racer_data=$(racer -i tab-text complete-with-snippet ${cursor} ${kak_buffile} ${dir}/buf)
            prefix_1=$(echo "${racer_data}" | head -n1 | awk '{print $2}')
            prefix_2=$(echo "${racer_data}" | head -n1 | awk '{print $3}')
            compl_column=$((${kak_cursor_column} + ${prefix_1} - ${prefix_2}))

            header="${kak_cursor_line}.${compl_column}\\@${kak_timestamp}"
            compl=$(echo "${racer_data}" | grep '^MATCH' | cut -f2,8,9 --output-delimiter='|' | sed -e 's/:/\\:/g' | awk -F "|" '{print $1 "|" $3 "|" $2}' | paste -s -d: -)
            printf %s\\n "racer -i tab-text complete-with-snippet ${cursor} ${kak_buffile} ${dir}/buf" > /tmp/kak-racer-out
            printf %s\\n "${racer_data}" >> /tmp/kak-racer-out
            printf %s\\n "%@${header}:${compl}@" >> /tmp/kak-racer-out
            printf %s\\n "eval -client '${kak_client}' %{
                set buffer=${kak_bufname} racer_completions %@${header}:${compl}@
            }" | kak -p ${kak_session}
            rm -r ${dir}
        ) > /dev/null 2>&1 < /dev/null &
    }
}

def racer-enable-autocomplete -docstring "Add racer completion candidates to the completer" %{
    set window completers "option=racer_completions:%opt{completers}"
    hook window -group racer-autocomplete InsertIdle .* %{ try %{
        exec -draft <a-h><a-k>([\w\.]|::).\z<ret>
        racer-complete
    } }
    alias window complete racer-complete
}

def racer-disable-autocomplete -docstring "Disable racer completion" %{
    set window completers %sh{ printf %s\\n "'${kak_opt_completers}'" | sed 's/option=racer_completions://g' }
    rmhooks window racer-autocomplete
    unalias window complete racer-complete
}
