" Vim syntax file
" Language: Todo List
" Author: Jacob Niehus

if exists("b:current_syntax")
    finish
endif

syn match todoStringIncomplete '.*$' contained
syn match todoStringcomplete '.*$' contained
syn match todoCheckboxIncomplete '(O)' nextgroup=todoStringIncomplete
syn match todoCheckboxComplete '([X\\])' nextgroup=todoStringComplete
syn match todoIndent '\s*' nextgroup=todoCheckboxIncomplete,todoCheckboxComplete
syn match todoComment '\([\*#@%]\).*$' contained
syn match todoSectionTitle '^\s*\u\{2,}\S*$' contained
syn region todoLine start="^" end="$" fold transparent contains=ALL

let b:current_syntax = "todo"

hi def link todoCheckboxComplete Identifier
hi def link todoCheckboxIncomplete PreProc
hi def link todoStringIncomplete Special
hi def link todoStringComplete Identifier
hi def link todoSectionTitle Statement
hi def link todoComment Comment
