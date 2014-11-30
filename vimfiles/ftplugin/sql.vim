if exists("b:did_my_ftplugin")
  finish
endif

let b:did_my_ftplugin=1

if exists('$TMUX')
  nnoremap <silent> <buffer> <Leader>x :<C-u>set opfunc=<SID>ExecuteMotion<CR>g@
  nnoremap <silent> <buffer> <Leader>xx :<C-u>set opfunc=<SID>ExecuteMotion<Bar>exe 'norm! 'v:count1.'g@_'<CR>
  inoremap <silent> <buffer> <Leader>x  <Esc>:<C-u>set opfunc=<SID>ExecuteMotion<Bar>exe 'norm! 'v:count1.'g@_'<CR>
  vnoremap <silent> <buffer> <Leader>x :<C-u>call <SID>ExecuteMotion('visual')<CR>

  func! s:ExecuteMotion(type)
    let zoomed = system("tmux display-message -p '#F'") =~# 'Z'
    if zoomed | call system("tmux resize-pane -Z") | endif
    call VimuxOpenRunner()
    let input = vimtools#opfunc(a:type)
    call VimuxSendKeys("\<C-c>\<CR>")
    let lines = split(input, '\n')
    for line in lines[0:-2]
      call VimuxSendText(line)
      call VimuxSendKeys("C-j")
    endfor
    call VimuxSendText(lines[-1])
    call VimuxSendKeys("\<CR>")
    if zoomed | call system("tmux resize-pane -Z") | endif
  endfunc
endif

" vim:set et ts=2 sts=2 sw=2:
