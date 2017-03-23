colorscheme tomorrow-night

set global autoreload yes
set global grepcmd 'rg --follow --vimgrep'
set global ui_options ncurses_status_on_top=true:ncurses_assistant=none

def cd-toplevel %{
    # test $(git rev-parse 2> /dev/null)
    cd %sh{git rev-parse --show-toplevel}
}
def new-tool %{
    rename-client main
    set global jumpclient main

    new rename-client tools
    set global toolsclient tools
}
def open -params 1 -shell-candidates %{ rg --files } %{ edit %arg{1} }
def strip-trailing-whitespaces %{ exec -draft '%s\h+$<ret>d' }
alias global o open

hook global InsertChar j %{ try %{
  exec -draft hH <a-k>jj<ret> d
  exec <esc>
} }

# TODO handle multiline (if /\n/ comment-selection)
map global normal '#' ':comment-line<ret>'
map global normal <a-#> ':comment-selection<ret>'
map global insert <c-k> '<a-;>!ufind digraph -c '
map global insert <tab> '<a-;><a-gt>'
map global insert <backtab> '<a-;><lt>'
map global user b ':make<ret>'
map global user f ':format<ret>'
map global user l ':lint<ret>'
map global user n ':lint-next<ret>'

%sh{
    if which xsel 1>/dev/null; then
        echo '
            map global user y %{<a-|>xsel<ret>: echo -color Information %{yanked to X clipboard}<ret>}
            map global user p %{<a-!>xsel<ret>: echo -color Information %{pasted from X clipboard}<ret>}
            map global user P %{!xsel<ret>: echo -color Information %{pasted from X clipboard}<ret>}
            map global user R %{:reg w "%sh{xsel}"<ret>"wR: echo -color Information %{replaced from X clipboard }<ret>}
        '
    else
        echo '
            map global user y %{<a-|>pbcopy<ret>: echo -color Information %{yanked to OS clipboard}<ret>}
            map global user p %{<a-!>pbpaste<ret>: echo -color Information %{pasted from OS clipboard}<ret>}
            map global user P %{!pbpaste<ret>: echo -color Information %{pasted from OS clipboard}<ret>}
            map global user R %{:reg w "%sh{pbpaste}"<ret>"wR: echo -color Information %{replaced from OS clipboard }<ret>}
        '
    fi
}

hook global BufOpenFifo '\*grep\*' %{ map -- global normal - ':grep-next<ret>' }
hook global BufOpenFifo '\*lint\*' %{ map -- global normal - ':lint-next<ret>' }
hook global BufOpenFifo '\*make\*' %{ map -- global normal - ':make-next<ret>' }

hook global BufCreate /.+ %{ editorconfig-load }
hook global BufCreate .+ %{ modeline-parse }
hook global BufCreate \.git/(COMMIT_EDITMSG|MERGE_MSG) %{
    set buffer filetype git-commit
}
hook global WinCreate ^[^*]+$ %{
    add-highlighter number_lines -hlcursor
    add-highlighter show_matching
    lint-enable
}
hook global BufCreate .+\.ad(oc)? %{ set buffer filetype asciidoc }
hook global BufCreate .+\.vue %{ set buffer filetype html }

hook global WinSetOption filetype=asciidoc %{ autowrap-enable }
hook global WinSetOption filetype=git-commit %{
    # configure 50/72 rule
    set window autowrap_column 72
    autowrap-enable
    remove-highlighter number_lines
}
hook global WinSetOption filetype=sh %{
    set window formatcmd 'shfmt -i 4'
    set window lintcmd 'shellcheck -fgcc -Cnever'
}
hook global WinSetOption filetype=taskpaper %{ set window tabstop 4 }

face search +r
hook global NormalKey [/?*nN]|<a-[/?*nN]> %{ try %{ addhl dynregex '%reg{/}' 0:search } }
hook global NormalKey <esc> %{ try %{ rmhl dynregex_%reg{<slash>} } }

hook global InsertCompletionShow .* %{ map window insert <tab> <c-n>; map window insert <backtab> <c-p> }
hook global InsertCompletionHide .* %{ unmap window insert <tab> <c-n>; unmap window insert <backtab> <c-p> }

# testing

decl -hidden regex curword
face CurWord default,rgb:4a4a4a

hook global WinCreate .* %{
    addhl dynregex '%opt{curword}' 0:CurWord
}

hook global NormalIdle .* %{
    eval -draft %{ try %{
        exec <space><a-i>w <a-k>\`\w+\'<ret>
        set buffer curword "\b\Q%val{selection}\E\b"
    } catch %{
        set buffer curword ''
    } }
}

def -params ..1 dpaste -docstring "dpaste [*|<filetype>]: upload the current selection to dpaste.com" %{
    echo %sh{
        # http://dpaste.com/api/v2/syntax-choices/
        if [ "$1" = "*" ]; then
            ft_arg="-F syntax=${kak_opt_filetype}"
        elif [ -n "$1" ]; then
            ft_arg="-F syntax=$1"
        fi
        printf %s\\n "${kak_selection}" | curl -s ${ft_arg} -F "content=<-" http://dpaste.com/api/v2/
    }
}
