hook global WinSetOption filetype=rust %{
    set-option window formatcmd 'rustfmt'
    set-option window makecmd 'cargo build'
    racer-enable-autocomplete

    map window user f ':nop %sh{cargo fmt}<ret>'
}

hook global WinSetOption filetype=(?!rust).* %{
    unmap window user f
    racer-disable-autocomplete
}
