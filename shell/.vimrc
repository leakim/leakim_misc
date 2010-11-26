set nocompatible
syntax on
set et!
set shiftwidth=3
set softtabstop=3

set ai!
set cin!
set nu!
set ffs=unix,dos
set nowrap
"set spell spelllang=en_us
set hls!

map <F7> :call MakeC()<CR>
func! MakeC()
  exec "wa"
  exec "make"
endfunc

map gr :Ack <cword><CR>

map <F10> I/*A*/
map <F11> :s/\/\*//
:s/\*\//


filetype plugin indent on

set cindent

nnoremap <silent> <F8> :Tlist<CR>
nnoremap <silent> <F9> :w<CR>:TlistUpdate<CR>
let Tlist_Inc_Winwidth = 0

