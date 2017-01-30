hook global WinSetOption filetype=python %{
    %sh{
        values="self"
        functions="super"
        methods="__init__"

        printf %s "
            add-highlighter -group /python/code regex '\b${values}\b' 0:value
            add-highlighter -group /python/code regex '\b(${functions})\(' 1:builtin
            add-highlighter -group /python/code regex '(def\s+|\.)(${methods})' 2:builtin
        "
    }
    
    # integer formats
    add-highlighter -group /python/code regex '\b0[bB][01]+[lL]?\b' 0:value
    add-highlighter -group /python/code regex '\b0[xX][\da-fA-F]+[lL]?\b' 0:value
    add-highlighter -group /python/code regex '\b0[oO]?[0-7]+[lL]?\b' 0:value
    add-highlighter -group /python/code regex '\b([1-9]\d*|0)[lL]?\b' 0:value
    # float formats (still missing `1.` and `.1`
    add-highlighter -group /python/code regex '\b((\d+\.\d+)|(\d+\.)|(\.\d+))([eE][+-]?\d+)?\b' 0:value
    add-highlighter -group /python/code regex '\b\d+[eE][+-]?\d+\b' 0:value
    # imaginary format
    add-highlighter -group /python/code regex '\b\d+[jJ]\b' 0:value
    add-highlighter -group /python/code regex '\b((\d+\.\d+)|(\d+\.)|(\.\d+))([eE][+-]?\d+)?[jJ]\b' 0:value
    add-highlighter -group /python/code regex '\b\d+[eE][+-]?\d+[jJ]\b' 0:value
}
