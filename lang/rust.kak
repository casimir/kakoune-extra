hook global WinSetOption filetype=rust %{
    set window formatcmd 'rustfmt' # still useful for standalone files
    set window makecmd 'cargo build'
    racer-enable-autocomplete

    map window user f ':nop %sh{cargo fmt}<ret>'
}

hook global WinSetOption filetype=(?!rust).* %{
    unmap window user f
}
