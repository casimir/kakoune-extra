hook global WinSetOption filetype=go %{
    set window formatcmd 'goimports'
    set window indentwith 0
    set window lintcmd 'golint-kak'

    go-enable-autocomplete
    hook buffer BufWritePre .+\.go %{ go-format -use-goimports }
    hook window BufWritePost .* lint

    map window user d ':go-doc-info<ret>'
}
