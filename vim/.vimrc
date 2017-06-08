execute pathogen#infect()

" plugin on就是允许执行 ftplugin 目录下的文件类型特定的脚本。
" indent on就是按 indent 目录下的脚本自动缩进，

filetype plugin indent on

syntax enable
syntax on


" http://ethanschoonover.com/solarized/vim-colors-solarized
" let g:solarized_termtrans=1
let g:solarized_termcolors=256
if has('gui_running')
    set background=light
else
    set background=dark
endif
colorscheme solarized

set ruler
set number
set hlsearch


set cursorline
set cursorcolumn