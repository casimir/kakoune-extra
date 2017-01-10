hook global WinSetOption filetype=go %{
    set window formatcmd 'goimports'
    set window indentwidth 0
    set window lintcmd 'golint-kak'
    set window makecmd 'go install'

    go-enable-autocomplete
    hook buffer BufWritePre .+\.go %{ go-format -use-goimports }
    hook window BufWritePost .* lint

    map window user d ':go-doc-info<ret>'
}
