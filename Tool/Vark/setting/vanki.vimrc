" Settings {{{1
set nocompatible
set fileformat=unix
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
set encoding=utf-8
set nobomb
set magic
set smartcase
set laststatus=0
set showtabline=0
set history=256
set autochdir
set whichwrap=b,<,>,[,]
set backspace=indent,eol,start
set clipboard+=unnamed
set winaltkeys=no
set langmenu=zh_CN
set cursorline
set hlsearch
set incsearch
set number
set relativenumber
set splitbelow
set splitright
set guioptions-=e
set guioptions-=g
set guioptions-=m
set guioptions-=r
set guioptions-=L
set guioptions-=t
set guioptions-=T
set autoindent
set smartindent
set foldmethod=marker
set guifont=JetBrains_Mono:h15
set guifontwide=Sarasa_Mono_SC:h15
set conceallevel=2
set wildmenu
set scrolloff=10
set noshowmode
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set viewoptions-=options
set undofile
set undodir=D:\Temp\.vim\.undo\
set directory=D:\Temp\.vim\.swap\
set viewdir=D:\Temp\.vim\.view\
set shortmess+=F
set background=dark
set listchars=tab:!>,trail:·,lead:·
set list
set gdefault
set noruler
set noshowmode
set noshowcmd
set background=dark
set filetype=markdown
set titlestring=%{mode()}\&Vanki

let $LANG = 'en_US.UTF-8'
let &pythonthreedll = 'D:\Program Files\Python\Python310\python310.dll'
" }}}1

augroup auto_view
" auto_view {{{1
    autocmd!
    autocmd BufWinLeave Temp_* silent mkview
    autocmd BufWinEnter Temp_* silent loadview
    autocmd BufWinLeave Temp silent mkview
    autocmd BufWinEnter Temp silent loadview
" }}}1
augroup end

augroup spell_check
" spell_check {{{1
    autocmd!
    setlocal spell spelllang=en_us,cjk
    inoremap <silent><C-n> <C-g>u<Esc>[s1z=`'a<C-g>u
" }}}1
augroup end

" win-clipboard {{{1
let g:clipboard = {
    \ 'name': 'win32yank',
    \ 'copy': {
    \ '+': 'win32yank.exe -i --crlf',
    \ '*': 'win32yank.exe -i --crlf',
    \ },
    \ 'paste': {
    \ '+': 'win32yank.exe -o --lf',
    \ '*': 'win32yank.exe -o --lf',
    \ },
    \ 'cache_enabled': 0,
    \ }
" }}}1

start
filetype plugin indent on
syntax enable

call plug#begin("~/vimfiles/plugged")
" Plug {{{1
Plug 'morhetz/gruvbox'
Plug 'junegunn/vim-easy-align'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'pilgrimlyieu/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'ZSaberLv0/vim-easymotion-chs'
Plug 'mg979/vim-visual-multi'
Plug 'luochen1990/rainbow'
Plug 'Yggdroot/indentLine'
Plug 'lervag/vimtex'
Plug 'pilgrimlyieu/md-img-paste.vim'
Plug 'mzlogin/vim-markdown-toc'
Plug 'rrethy/vim-hexokinase', { 'do': 'make hexokinase' }
" }}}1
call plug#end()

colorscheme gruvbox
let g:Hexokinase_highlighters = ['backgroundfull']

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                         Key Mappings                                         "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Key Mappings {{{1
let g:mapleader = " "

function! Execute(cmd)
    execute a:cmd
    return ''
endfunction

inoremap jk      <Esc>
inoremap kj      <Esc>
inoremap jj      <Esc>
inoremap kk      <Esc>
nnoremap U       <C-r>
nnoremap ;       :
nnoremap :       ,
nnoremap ,       ;
nnoremap `       '
nnoremap '       `
nnoremap H       0
onoremap H       0
nnoremap L       $
onoremap L       $
nnoremap <expr>0 col('.') == 1 ? '^' : '0'
nnoremap <C-f> <C-d>
nnoremap <C-b> <C-u>

nnoremap <silent><leader>/ :noh<Cr>
vnoremap /                 /\v
nnoremap ?                 ?\v
vnoremap ?                 ?\v

nnoremap k  gk
nnoremap gk k
nnoremap j  gj
nnoremap gj j

nnoremap gA ga

inoremap <silent><C-q>     <C-r>=Execute('x')<Cr>
inoremap <silent><C-S-q>   <C-r>=Execute('q!')<Cr>
vnoremap <C-q>             <Esc>ZZ
vnoremap <C-S-q>           <Esc>ZQ
nnoremap <C-q>             ZZ
nnoremap <C-S-q>           ZQ

nnoremap Q  <Nop>
nnoremap gq Q

set mouse=
noremap  <ScrollWheelUp>   <nop>
noremap  <ScrollWheelDown> <nop>
inoremap <ScrollWheelUp>   <nop>
inoremap <ScrollWheelDown> <nop>
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                         vim-surround                                         "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Custom Surroundings {{{1
let g:surround_{char2nr('（')} = "（\r）"
let g:surround_{char2nr('）')} = "（\r）"
let g:surround_{char2nr('【')} = "【\r】"
let g:surround_{char2nr('】')} = "【\r】"
let g:surround_{char2nr('《')} = "《\r》"
let g:surround_{char2nr('》')} = "《\r》"
let g:surround_{char2nr('‘')}  = "「\r」"
let g:surround_{char2nr('’')}  = "「\r」"
let g:surround_{char2nr('“')}  = "『\r』"
let g:surround_{char2nr('”')}  = "『\r』"
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                           Markdown                                           "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Markdown {{{1
" autocmd FileType markdown inoremap <silent><C-x>      <Cr><Cr><hr class='section'><Cr><Cr>
autocmd FileType markdown inoremap <silent><C-p>      <C-r>=Execute('call mdip#MarkdownClipboardImage()')<Cr>
autocmd FileType markdown inoremap <silent><C-t>      <C-r>=Execute('UpdateToc')<Cr>
autocmd FileType markdown nnoremap <silent><leader>mt :UpdateToc<Cr>
autocmd FileType markdown vnoremap <silent><leader>vl <Plug>(EasyAlign)*<C-x>\\\@<!<Bar><Cr>
autocmd FileType markdown vnoremap <silent><leader>vr <Plug>(EasyAlign)*<C-a><Bs>r<Cr><C-x>\\\@<!<Bar><Cr>
autocmd FileType markdown vnoremap <silent><leader>vv <Plug>(EasyAlign)*<C-a><Bs>c<Cr><C-x>\\\@<!<Bar><Cr>
autocmd FileType markdown nnoremap <silent><leader>vl <Plug>(EasyAlign)ip*<C-x>\\\@<!<Bar><Cr>
autocmd FileType markdown nnoremap <silent><leader>vr <Plug>(EasyAlign)ip*<C-a><Bs>r<Cr><C-x>\\\@<!<Bar><Cr>
autocmd FileType markdown nnoremap <silent><leader>vv <Plug>(EasyAlign)ip*<C-a><Bs>c<Cr><C-x>\\\@<!<Bar><Cr>

autocmd FileType markdown inoreabbr <silent>toc <C-r>=Execute('GenTocGFM')<Cr>

autocmd FileType markdown let b:coc_pairs_disabled = ["'"]

let g:vmt_auto_update_on_save = 0
let g:vmt_fence_text          = 'TOC Start'
let g:vmt_fence_closing_text  = 'TOC End'
let g:vmt_list_item_char      = '-'
let g:mdip_imgdir             = 'images'
let g:mdip_imgname            = ''
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                            VimTeX                                            "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TeX {{{1
let g:tex_conceal                   = ''
let g:vimtex_syntax_conceal_disable = 1
let g:vimtex_toggle_fractions = {
        \ 'frac': 'dfrac',
        \ 'dfrac': 'frac',
    \}
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                           UltiSnip                                           "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" UltiSnips {{{1
let g:UltiSnipsListSnippets        = '<S-Tab>'
let g:UltiSnipsEditSplit           = "vertical"
let g:UltiSnipsSnippetDirectories  = ['Snips']

inoremap <silent><F2>      <C-R>=UltiSnips#ExpandSnippet()<Cr>
snoremap <silent><F2>      <Esc>:call UltiSnips#ExpandSnippet()<Cr>
inoremap <silent><M-F12>   <C-R>=UltiSnips#JumpForwards()<Cr>
snoremap <silent><M-F12>   <Esc>:call UltiSnips#JumpForwards()<Cr>
inoremap <silent><M-S-F12> <C-R>=UltiSnips#JumpBackwards()<Cr>
snoremap <silent><M-S-F12> <Esc>:call UltiSnips#JumpBackwards()<Cr>
nnoremap <silent><C-d>     <Esc>:call UltiSnips#RefreshSnippets()<Cr>
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                          easymotion                                          "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Easy Motion {{{1
let g:EasyMotion_enter_jump_first = 1

nnoremap <leader>j         <Plug>(easymotion-j)
nnoremap <leader>k         <Plug>(easymotion-k)
nnoremap <leader>h         <Plug>(easymotion-linebackward)
nnoremap <leader>l         <Plug>(easymotion-lineforward)
nnoremap <leader>.         <Plug>(easymotion-repeat)
nnoremap <leader>f         <Plug>(easymotion-f)
nnoremap <leader>F         <Plug>(easymotion-F)
nnoremap <leader>t         <Plug>(easymotion-t)
nnoremap <leader>T         <Plug>(easymotion-T)
nnoremap <leader><leader>f <Plug>(easymotion-f2)
nnoremap <leader><leader>F <Plug>(easymotion-F2)
nnoremap <leader><leader>t <Plug>(easymotion-t2)
nnoremap <leader><leader>T <Plug>(easymotion-T2)
nnoremap <leader>s         <Plug>(easymotion-s)
nnoremap s                 <Plug>(easymotion-s2)
nnoremap /                 <Plug>(easymotion-sn)\v
onoremap /                 <Plug>(easymotion-tn)\v
nnoremap n                 <Plug>(easymotion-next)
nnoremap N                 <Plug>(easymotion-prev)
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                       vim-visual-multi                                       "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim-visual-multi {{{1
let g:VM_theme = 'iceblue'

let g:VM_maps                    = {}
let g:VM_maps["Exit"]            = '<C-c>'
let g:VM_maps["Add Cursor Down"] = '<A-s>'
let g:VM_maps["Add Cursor Up"]   = '<A-w>'
let g:VM_maps["Select l"]        = '<A-d>'
let g:VM_maps["Select h"]        = '<A-a>'
let g:VM_maps["Move Left"]       = '<A-S-a>'
let g:VM_maps["Move Right"]      = '<A-S-d>'
let g:VM_maps["Undo"]            = 'u'
let g:VM_maps["Redo"]            = 'U'
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                        vim-easy-align                                        "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" vim-easy-align {{{1
nnoremap ga <Plug>(EasyAlign)
vnoremap ga <Plug>(EasyAlign)

nnoremap <silent>g:             <Plug>(EasyAlign)ip*<C-l>0<Cr><C-x>\\\@<!:\(=\)\@!<Cr>
vnoremap <silent>g:             <Plug>(EasyAlign)*<C-l>0<Cr><C-x>\\\@<!:\(=\)\@!<Cr>
nnoremap <silent>g=             <Plug>(EasyAlign)ip=<Cr>
vnoremap <silent>g=             <Plug>(EasyAlign)*=<Cr>
nnoremap <silent><expr>g<Space> '<C-u><Plug>(EasyAlign)ip' . v:count1 . ' \<Cr>'
vnoremap <silent><expr>g<Space> '<Plug>(EasyAlign)' . v:count1 . ' \<Cr>'
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                             coc                                              "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" coc {{{1
let g:coc_data_home = $USERPROFILE . '/vimfiles/extra/coc'

let g:coc_snippet_next = '<Tab>'
let g:coc_snippet_prev = '<S-Tab>'

" Git Config
" [coc-git]
"     issuesources = github/pilgrimlyieu/School-Note,github/pilgrimlyieu/vimrc,github/pilgrimlyieu/Snippets,github/pilgrimlyieu/Snippets-Dependencies,github/pilgrimlyieu/AutoHotkey-Script,github/pilgrimlyieu/Python-Script

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
" Recently vim can merge signcolumn and number column into one
set signcolumn=number

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <C-z>
      \ coc#pum#visible() ? coc#pum#next(1):
      \ CheckBackspace() ? "\<C-z>" :
      \ coc#refresh()
inoremap <silent><expr><C-S-z> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <C-c> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                           Rainbow                                            "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Rainbow {{{1
let g:rainbow_active = 1

let g:rainbow_conf = {
\    'guifgs': ['#858580', '#8FBCBB', '#D08770', '#A3BE8C', '#EBCB8B', '#B48EAD', '#80a880', '#887070'],
\    'ctermfgs': ['lightblue', 'lightyellow', 'lightcyan', 'lightmagenta'],
\    'operators': '_,_',
\    'parentheses': ['start=/(/ end=/)/ fold', 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold'],
\    'separately': {
\      	 'markdown': {
\      	   	 'parentheses_options': 'containedin=markdownCode contained',
\      	 },
\    }
\}
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                         Indent Line                                          "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Indent Line {{{1
let g:indentLine_fileTypeExclude = ['json', 'markdown']
let g:indentLine_conceallevel    = 2
let g:indentLine_concealcursor   = ''
let g:indentLine_setConceal      = 0
let g:indentLine_enabled         = 1
let g:indent_guides_guide_size   = 1
let g:indent_guides_start_level  = 1
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                            Tabout                                            "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" https://stackoverflow.com/questions/20038550/step-over-bracket-parenthesis-etc-with-tab-in-vim

" Tabout {{{1
inoremap <silent><M-F12>   <C-r>=IncreaseColNumber()<CR>
inoremap <silent><M-S-F12> <C-r>=DecreaseColNumber()<CR>

let s:delimiters_exp = '[\[\]{}()$&"' . "'" . '<>]'

function! IncreaseColNumber()
    let l:line = getline('.')
    if l:line[col('.') - 1] =~# s:delimiters_exp
        return "\<Right>"
    endif
    return ""
endfunction

function! DecreaseColNumber()
    let l:line = getline('.')
    if l:line[col('.') - 2] =~# s:delimiters_exp
        return "\<Left>"
    endif
    return ""
endfunction
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""