let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#history_ipython#define()
  return s:source
endfunction

let s:source = {
    \ 'name' : 'history/ipython',
    \ 'description' : 'candidates from IPython history',
    \ 'action_table' : {},
    \ 'hooks' : {},
    \ 'default_action' : 'send',
    \ 'default_kind' : 'word',
    \ 'syntax' : 'uniteSource__Python',
    \}

function! s:source.hooks.on_syntax(args, context)
  let save_current_syntax = get(b:, 'current_syntax', '')
  unlet! b:current_syntax

  try
    silent! syntax include @Python syntax/python.vim
    syntax region uniteSource__IPythonPython
        \ start=' ' end='$' contains=@Python containedin=uniteSource__IPython
  finally
    let b:current_syntax = save_current_syntax
  endtry
endfunction

function! s:source.hooks.on_init(args, context)
  let args = unite#helper#parse_source_args(a:args)
  let a:context.source__session = get(a:context, 'source__session', -1)
  if a:context.source__session == -1
    let a:context.source__session = get(args, 0, -1)
  endif
  let a:context.source__input = a:context.input
  if a:context.source__input == '' || a:context.unite__is_restart
    try
      let a:context.source__input = unite#util#input('Pattern: ',
          \ a:context.source__input)
    catch /^Vim:Interrupt$/
    endtry
  endif

  call unite#print_source_message('Pattern: '
      \ . a:context.source__input, s:source.name)
endfunction

function! s:source.gather_candidates(args, context)
  if !exists('*IPythonHistory')
    echohl WarningMsg
    echomsg 'IPythonHistory() does not exist'
    echohl None
    return []
  endif

  return map(IPythonHistory(a:context.source__input,
      \                     a:context.source__session), '{
      \ "word" : v:val.code,
      \ "abbr" : printf("'''''' %d/%d '''''' %s", v:val.session, v:val.line,
      \                 v:val.code =~ "\n" ? "\n" . v:val.code : v:val.code),
      \ "is_multiline" : 1,
      \ "source__session" : v:val.session,
      \ "source__line" : v:val.line,
      \ "source__context" : a:context,
      \ "action__regtype" : "V",
      \ }')
endfunction

let s:source.action_table.send = {
    \ 'description' : 'run in IPython',
    \ 'is_selectable' : 1,
    \ }
function! s:source.action_table.send.func(candidates)
  for candidate in a:candidates
    let g:ipy_input = candidate.word
    call IPyRunIPyInput()
  endfor
endfunction

let s:source.action_table.session = {
    \ 'description' : "get history for candidate's session",
    \ 'is_quit' : 0,
    \ 'is_invalidate_cache' : 1,
    \ }
function! s:source.action_table.session.func(candidate)
  let context = a:candidate.source__context
  let context.source__input = unite#util#input('Pattern: ',
      \ context.source__input)
  let context.source__session = a:candidate.source__session
endfunction

let s:source.action_table.macro = {
    \ 'description' : 'create IPython macro',
    \ 'is_selectable' : 1,
    \ }
function! s:source.action_table.macro.func(candidates)
  let g:ipy_input = printf('%%macro %s %s',
      \ unite#util#input('Macro name: '),
      \ join(map(a:candidates,
      \ 'printf("%s/%s", v:val.source__session, v:val.source__line)'))
      \ )
  call IPyRunIPyInput()
endfunction

let &cpo = s:save_cpo
unlet s:save_cpo

" vim:set et ts=2 sts=2 sw=2:
