" Set {{{1
set nocompatible
set fileformat=unix
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
set encoding=utf-8
set nobomb
set magic
set smartcase
set laststatus=2
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
set filetype=markdown
set titlestring=%{mode()}\&Vark

let $LANG = 'en_US.UTF-8'
let &pythonthreedll = 'D:\Program Files\Python\Python310\python310.dll'
" }}}

augroup auto_view
" auto_view {{{1
    autocmd!
    autocmd BufWinLeave Temp silent mkview
    autocmd BufWinEnter Temp silent loadview
" }}}1
augroup end

augroup spell_check
" spell_check {{{1
    autocmd!
    autocmd FileType tex,markdown setlocal spell spelllang=en_us,cjk
    autocmd FileType tex,markdown inoremap <silent><C-n> <C-g>u<Esc>[s1z=`'a<C-g>u
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

let g:language_types = ['python', 'javascript', 'vim']
call plug#begin("~/vimfiles/plugged")
" Plug {{{1
Plug 'morhetz/gruvbox'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale',        { 'for': g:language_types }
Plug 'junegunn/vim-easy-align'
Plug 'neoclide/coc.nvim',             { 'branch': 'release' }
Plug 'dense-analysis/ale',            { 'for': g:language_types }
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'pilgrimlyieu/vim-surround'
Plug 'easymotion/vim-easymotion'
Plug 'ZSaberLv0/vim-easymotion-chs'
Plug 'mg979/vim-visual-multi'
Plug 'luochen1990/rainbow'
Plug 'Yggdroot/indentLine'
Plug 'lervag/vimtex',                 { 'for': ['tex', 'markdown'] }
Plug 'pilgrimlyieu/md-img-paste.vim', { 'for': 'markdown' }
Plug 'mzlogin/vim-markdown-toc',      { 'for': 'markdown'}
Plug 'rrethy/vim-hexokinase',         { 'do': 'make hexokinase' }
Plug 'vim-autoformat/vim-autoformat'
" Plug 'python-mode/python-mode',       { 'for': 'python', 'branch': 'develop' }
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

inoremap <silent><C-j> <C-r>=Execute('normal! <C-v><C-w>j<C-v><Esc>')<Cr>
inoremap <silent><C-k> <C-r>=Execute('normal! <C-v><C-w>k<C-v><Esc>')<Cr>
inoremap <silent><C-h> <C-r>=Execute('normal! <C-v><C-w>h<C-v><Esc>')<Cr>
inoremap <silent><C-l> <C-r>=Execute('normal! <C-v><C-w>l<C-v><Esc>')<Cr>
nnoremap <C-j>         <C-W>j
nnoremap <C-k>         <C-W>k
nnoremap <C-h>         <C-W>h
nnoremap <C-l>         <C-W>l
nnoremap <C-S-j>       <C-W>-
nnoremap <C-S-k>       <C-W>+
nnoremap <C-S-h>       <C-W><
nnoremap <C-S-l>       <C-W>>

nnoremap k  gk
nnoremap gk k
nnoremap j  gj
nnoremap gj j

nnoremap gA ga

inoremap <silent><C-s>     <C-r>=Execute('w')<Cr>
inoremap <silent><C-q>     <C-r>=Execute('x')<Cr>
inoremap <silent><C-S-q>   <C-r>=Execute('q!')<Cr>
inoremap <silent><C-S-c>   <C-r>=Execute('bw')<Cr>
vnoremap <C-q>             <Esc>ZZ
vnoremap <C-S-q>           <Esc>ZQ
vnoremap <silent><C-s>     <Esc>:w<Cr>
vnoremap <silent><C-S-c>   <Esc>:bw<Cr>
vnoremap <silent><S-Esc>   <Esc>:qa!<Cr>
nnoremap <C-q>             ZZ
nnoremap <C-S-q>           ZQ
nnoremap <silent><C-s>     :w<Cr>
nnoremap <silent><C-S-c>   :bw<Cr>
nnoremap <leader>q         ZZ
nnoremap <leader>Q         ZQ
nnoremap <silent><leader>w :w<Cr>
nnoremap <silent><leader>C :bw<Cr>
nnoremap <silent><S-Esc>   :qa!<Cr>

tnoremap <F1>           <C-\><C-N>
tnoremap <S-F1>         <C-W><C-C>
tnoremap <silent><S-F5> <C-W>N:bw!<Cr>
nnoremap <silent><S-F5> :call CloseTerminal()<CR>

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



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
let g:tex_conceal = ''

" Viewer options: One may configure the viewer either by specifying a built-in
" viewer method:
" let g:vimtex_view_method = 'SumatraPDF'

" Or with a generic interface:
let g:vimtex_view_general_viewer = 'SumatraPDF' 

" SumatraPDF Setting
" gvim --servername GVIM --remote-send "<C-\><C-n>:drop %f<CR>:%l<CR>:normal! zzzv<CR>:execute 'drop ' . fnameescape('%f')<CR>:%l<CR>:normal! zzzv<CR>:call remote_foreground('GVIM')<CR><CR>"

let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'

" VimTeX uses latexmk as the default compiler backend. If you use it, which is
" strongly recommended, you probably don't need to configure anything. If you
" want another compiler backend, you can change it as follows. The list of
" supported backends and further explanation is provided in the documentation,
" see ":help vimtex-compiler".
let g:vimtex_compiler_method = 'latexmk'

" Most VimTeX mappings rely on localleader and this can be changed with the
" following line. The default is usually fine and is the symbol "\".
let maplocalleader = ","

let g:tex_flavor = "latex"

let g:vimtex_texcount_custom_arg = " -ch -total"

autocmd FileType tex noremap <buffer> <silent> <leader>lw :VimtexCountWords! <CR><CR>

let g:Tex_ViewRule_pdf = 'D:\Program Files\SumatraPDF\SumatraPDF.exe -reuse-instance -inverse-search "gvim -c \":RemoteOpen +\%l \%f\""'

let g:vimtex_compiler_latexmk_engines = {
    \ '_'                : '-pdf',
    \ 'pdflatex'         : '-pdf',
    \ 'dvipdfex'         : '-pdfdvi',
    \ 'lualatex'         : '-lualatex',
    \ 'xelatex'          : '-xelatex',
    \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
    \ 'context (luatex)' : '-pdf -pdflatex=context',
    \ 'context (xetex)'  : '-pdf -pdflatex=''texexec --xtx''',
    \}

let g:vimtex_compiler_latexmk = {
    \ 'build_dir'  : {-> 'out'},
    \ 'callback'   : 1,
    \ 'continuous' : 1,
    \ 'executable' : 'latexmk',
    \ 'hooks'      : [],
    \ 'options'    : [
    \   '-verbose',
    \   '-file-line-error',
    \   '-shell-escape',
    \   '-synctex=1',
    \   '-interaction=nonstopmode',
    \ ],
    \}

let g:vimtex_syntax_conceal_disable   = 1
let g:vimtex_quickfix_open_on_warning = 0

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
"                                             ale                                              "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" ale {{{1
let g:ale_sign_error   = '>>'
let g:ale_sign_warning = '--'
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

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-@> coc#refresh()

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Use K to show documentation in preview window.
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Formatting selected code.
" xmap <leader>f  <Plug>(coc-format-selected)
" nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Applying code actions to the selected code block
" Example: `<leader>aap` for current paragraph
" xmap <leader>a  <Plug>(coc-codeaction-selected)
" nmap <leader>a  <Plug>(coc-codeaction-selected)

" Remap keys for applying code actions at the cursor position
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
" Remap keys for apply code actions affect whole buffer
nmap <leader>as  <Plug>(coc-codeaction-source)
" Apply the most preferred quickfix action to fix diagnostic on the current line
" nmap <leader>qf  <Plug>(coc-fix-current)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line.
" nmap <leader>cl  <Plug>(coc-codelens-action)

" Map function and class text objects
" NOTE: Requires 'textDocument.documentSymbol' support from the language server.
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Remap <C-f> and <C-b> for scroll float windows/popups.
" nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
" nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(1)\<Cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<C-r>=coc#float#scroll(0)\<Cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
" nmap <silent> <C-s> <Plug>(coc-range-select)
" xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
" nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
" nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
" nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
" nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
" nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
" nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
" nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
" nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
" nnoremap <silent><nowait> <space>l  :<C-u>CocList<CR>
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                            Python                                            "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Python {{{1
nnoremap <silent><F5> :call RunProgram()<CR>
inoremap <silent><F5> <C-r>=Execute('call RunProgram()')<Cr>

autocmd FileType python,javascript nnoremap <silent><leader>Q :call CloseTerminal()<CR>

let g:python3_host_skip_check = 1
let g:python3_host_prog       = '/usr/local/bin/python3'
let g:terminal_settings       = {'vertical': 1}

highlight default link Terminal Normal

function! RunProgram()
    if &filetype == ''
        return
    endif

    silent execute 'w'
    let l:filename = expand('%')
    let l:opts     = g:terminal_settings

    if &filetype == 'python'
        let l:term_col = OpenTerminal()
        let l:opts.term_name = 'python_terminal'
        if l:term_col
            let l:opts.term_cols = l:term_col
        endif
        call term_start('python "' . l:filename . '"', l:opts)
    elseif &filetype == 'javascript'
        let l:term_col = OpenTerminal()
        let l:opts.term_name = 'javascript_terminal'
        if l:term_col
            let l:opts.term_cols = l:term_col
        endif
        call term_start('node "'. l:filename . '"', l:opts)
    elseif &filetype == 'autohotkey'
        let l:autohotkey_ux_path = $ProgramFiles . '/AutoHotkey/UX/'
        silent execute '!start "' . l:autohotkey_ux_path . 'AutoHotkeyUX.exe" "' . l:autohotkey_ux_path . 'launcher.ahk" /restart "%:p"'
    elseif &filetype == 'markdown'
        silent execute 'CocCommand markdown-preview-enhanced.openPreview'
    elseif &filetype == 'dosbatch'
        silent !%
    else
        let l:term_col = OpenTerminal()
        let l:opts.term_name = 'Terminal'
        if l:term_col
            let l:opts.term_cols = l:term_col
        endif
        call term_start('cmd', l:opts)
    endif
endfunction

function! OpenTerminal()
    let l:windowsWithTerminal = filter(range(1, winnr('$')), 'getwinvar(v:val, "&buftype") ==# "terminal" || term_getstatus(winbufnr(v:val))')
    if !empty(l:windowsWithTerminal)
        silent execute l:windowsWithTerminal[0] . 'wincmd w'
        let l:current_col = winwidth(l:windowsWithTerminal[0])
        call CloseTerminal()
        return l:current_col
    endif
endfunction

function! CloseTerminal()
    let l:winnumber = winnr()
    if getwinvar(l:winnumber, "&buftype") ==# "terminal" || term_getstatus(winbufnr(l:winnumber))
        silent execute winbufnr(l:winnumber) . 'bw!'
    else
        silent execute 'q!'
    endif
endfunction
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""



""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                          lightLine                                           "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" lightLine {{{1
let g:lightline = {
\ 'colorscheme': 'gruvbox',
\ 'active': {
\   'left': [ [ 'mode', 'paste' ],
\             [ 'readonly', 'filename' ] ],
\   'right': [ [ 'lineinfo' ],
\              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
\              [ 'fileformat', 'fileencoding', 'filetype'] ]
\ },
\ 'tabline': {
\   'left'  : [ ['buffers'] ],
\   'right' : [ ['close'] ]
\ },
\ 'component_expand': {
\   'buffers'         : 'lightline#bufferline#buffers',
\   'linter_checking' : 'lightline#ale#checking',
\   'linter_infos'    : 'lightline#ale#infos',
\   'linter_warnings' : 'lightline#ale#warnings',
\   'linter_errors'   : 'lightline#ale#errors',
\   'linter_ok'       : 'lightline#ale#ok',
\ },
\ 'component_type': {
\   'buffers'         : 'tabsel',
\   'linter_warnings' : 'warning',
\   'linter_errors'   : 'error',
\   'linter_ok'       : 'ale',
\ },
\ 'component_function': {
\   'lineinfo'  : 'LightLineLineInfo',
\ },
\ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
\ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
\}

let g:viewplugins = 'NERD_tree\|\[Plugins\]\|\[coc-explorer\]'

function! LightLineLineInfo()
  return expand('%:t') =~# g:viewplugins ? '' : printf(' %d/%d | %d/%d', line('.'), line('$'), col('.'), col('$'))
endfunction

let s:palette = g:lightline#colorscheme#gruvbox#palette
let s:palette.tabline.ale = [['#282C34', '#92A4A4', 0, 21]]

let g:lightline#ale#indicator_checking     = '⏳'
let g:lightline#ale#indicator_infos        = '📜'
let g:lightline#ale#indicator_errors       = '💥'
let g:lightline#ale#indicator_warnings     = '⚡'
let g:lightline#ale#indicator_ok           = '✨'
let g:lightline#bufferline#show_number     = 2
let g:lightline#bufferline#unicode_symbols = 1
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
\        '*': {},
\      	 'markdown': {
\      	   	 'parentheses_options': 'containedin=markdownCode contained',
\      	 },
\        'tex': {
\            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
\        },
\        'lisp': {
\            'guifgs': ['royalblue3', 'darkorange3', 'seagreen3', 'firebrick', 'darkorchid3'],
\        },
\        'vim': {
\            'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/', 'start=/{/ end=/}/ fold', 'start=/(/ end=/)/ containedin=vimFuncBody', 'start=/\[/ end=/\]/ containedin=vimFuncBody', 'start=/{/ end=/}/ fold containedin=vimFuncBody'],
\        },
\        'html': {
\            'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
\        },
\        'css': 0,
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
"                                          autoformat                                          "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" autoformat {{{1
noremap <silent><F3> :Autoformat<Cr>
" npm install -g js-beautify
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