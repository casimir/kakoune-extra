def -hidden _insert-paren %{ try %{
    exec -draft hLs\([^)]<ret> \;i)
    exec <left>
} }

def -hidden _insert-brace %[ try %[
    exec -draft hLs{[^}]<ret> \;i}
    exec <left>
] ]

def -hidden _insert-bracket %{ try %{
    exec -draft hLs\[[^\]]<ret> \;i]
    exec <left>
} }

def -hidden _insert-chevron %{ try %{
    exec -draft hLs<lt>[^<gt>]<ret> \;i<gt>
    exec <left>
} }

def smartpairs-enable "
    hook window InsertChar \( -group smartpairs-hooks _insert-paren
    hook window InsertChar {  -group smartpairs-hooks _insert-brace
    hook window InsertChar \[ -group smartpairs-hooks _insert-bracket
    hook window InsertChar <  -group smartpairs-hooks _insert-chevron
"

def smartpairs-disable %{
    remove-hooks window smartpairs-hooks
}
