function! criticmarkup#Init()
    command! -buffer -nargs=1 -complete=custom,criticmarkup#CriticCompleteFunc 
                \Critic call criticmarkup#Critic("<args>")
endfunction

function! criticmarkup#InjectHighlighting()
    syn region criticAddition matchgroup=criticAdd start=/{++/ end=/++}/ containedin=pandocDefinitionBlock concealends
    syn region criticDeletion matchgroup=criticDel start=/{--/ end=/--}/ containedin=pandocDefinitionBlock concealends
    syn region criticSubstitutionDeletion start=/{\~\~/ end=/.\(\~>\)\@=/ containedin=pandocDefinitionBlock keepend
    syn region criticSubstitutionAddition start=/\~>/ end=/\~\~}/ containedin=pandocDefinitionBlock keepend
    syn match criticSubstitutionDeletionMark /{\~\~/ contained containedin=criticSubstitutionDeletion conceal
    syn match criticSubstitutionAdditionMark /\~\~}/ contained containedin=criticSubstitutionAddition conceal
    syn region criticComment matchgroup=criticMeta start=/{>>/ end=/<<}/ containedin=pandocDefinitionBlock concealends
    syn region criticHighlight matchgroup=criticHighlighter start=/{==/ end=/==}/ containedin=pandocDefinitionBlock concealends

    hi criticAdd guibg=#00ff00 guifg=#101010
    hi criticDel guibg=#ff0000 guifg=#ffffff
    hi link criticAddition criticAdd
    hi link criticDeletion criticDel
    hi link criticSubstitutionAddition criticAddition
    hi link criticSubstitutionDeletion criticDeletion
    hi link criticSubstitutionAdditionMark criticAddition
    hi link criticSubstitutionDeletionMark criticDeletion
    hi criticMeta guibg=#0099FF guifg=#101010
    hi criticHighlighter guibg=#ffff00 guifg=#101010
    hi link criticComment criticMeta
    hi link criticHighlight criticHighlighter
endfunction

function! criticmarkup#Accept()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind =~ "criticAdd"
        call search("{++", "cb")
        normal d3l
        call search("++}", "c")
        normal d3l
    elseif kind =~ "criticDel"
        call search("{--", "cb")
        exe "normal v/\\(--\\)\\@<=}\<cr>"
        normal x
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        exe "normal v/\\~\\@<=>\<cr>"
        normal x
        call search('\~\~}', "c")
        exe "normal d3l"
    endif
endfunction

function! criticmarkup#Reject()
    let kind = synIDattr(synID(line("."), col("."), 1), "name")
    if kind =~ "criticDel"
        call search("{--", "cb")
        exe "normal v/\\(--\\)\\@<=}\<cr>"
        exe "normal :s/{\\=--}\\=//g\<cr>"
    elseif kind =~ "criticAdd"
        call search("{++", "cb")
        exe "normal v/\\(++\\)\\@<=}\<cr>"
        normal x
    elseif kind =~ "criticSubstitution"
        call search('{\~\~', "cb")
        exe "normal v/.\\(\\~>\\)\\@=\<cr>"
        exe "normal :s/{\\~\\~//g\<cr>"
        call search('\~>', "c")
        exe "normal v/\\(\\~\\~\\)\\@<=}\<cr>"
        normal x
    endif
endfunction

function! criticmarkup#Critic(args)
    if a:args =~ "accept"
        call criticmarkup#Accept()
    elseif a:args =~ "reject"
        call criticmarkup#Reject()
    endif
endfunction

function! criticmarkup#CriticNext()
    exe "normal /{[-+\\~]\\{2}\<cr>"
    let op = input("What to do? ", "", "custom,criticmarkup#CriticCompleteFunc")
    if op =~ "accept"
        call criticmarkup#Accept()
    elseif op =~ "reject"
        call criticmarkup#Reject()
    endif
endfunction

function! criticmarkup#CriticCompleteFunc(a, c, p)
    if len(split(a:c, " ", 1)) < 3
        return "accept\nreject"
    else
        return ""
    endif
endfunction
