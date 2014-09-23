if !exists('g:matlab_dict')
  if has("mac") || has("win16") || has("win32") || has("win64")
    let g:matlab_dict = expand('~/Documents/MATLAB/dict.m')
  elseif has('win32unix') || has('win64unix')
    let g:matlab_dict = substitute($USERPROFILE, '\', '/', 'g')
        \ ."/Documents/MATLAB/dict.m"
    let g:matlab_dict = '/cygdrive/'.tolower(g:matlab_dict[0])
        \ .g:matlab_dict[2:-1]
  else
    let g:matlab_dict = expand('~/MATLAB/dict.m')
  endif
endif

if !exists('*<SID>ShowDictionary')
    func s:ShowDictionary()
        execute "silent keepalt botright vertical split ".g:matlab_dict
        vertical resize 50
        setlocal winfixwidth readonly nomodifiable nobuflisted
        setlocal buftype=nofile bufhidden=hide noswapfile
        nnoremap <buffer> q :bd<CR>
        nnoremap <buffer> Q :bd<CR>
        nnoremap <buffer> <silent> <F5> :call <SID>UpdateDictionary()<CR>
        wincmd p
    endfunc
endif

if !exists('*<SID>ToggleDictionary')
    func! s:ToggleDictionary()
        let win = bufwinnr(g:matlab_dict)
        if win != -1
            execute win."wincmd w"
            bdelete
            wincmd p
        else
            call <SID>ShowDictionary()
        endif
    endfunc
endif

func! s:UpdateDictionary()
  call <SID>ToggleDictionary()
  call <SID>ToggleDictionary()
  wincmd p
  execute "normal \<Plug>(matlab_update_dictionary)"
endfunc

nnoremap <silent> <Leader>m :call <SID>ToggleDictionary()<CR>

set errorformat+=Error:\ File:\ %f\ Line:\ %l\ Column:\ %c\ -\ %m