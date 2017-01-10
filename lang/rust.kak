hook global WinSetOption filetype=rust %{
    set window formatcmd 'cargo fmt'
    set window makecmd 'cargo build'
    racer-enable-autocomplete
}
