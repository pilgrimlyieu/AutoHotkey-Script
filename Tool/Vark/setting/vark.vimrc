" Set {{{1
set nocompatible
set fileformat=unix
set fileencodings=utf-8,gbk2312,gbk,gb18030,cp936
set encoding=utf-8
set nobomb
set mouse=
set magic
set smartcase
set laststatus=2
set showtabline=2
set history=256
set autochdir
set whichwrap=b,s,<,>,[,]
set backspace=indent,eol,start
set clipboard+=unnamed
set winaltkeys=no
set langmenu=zh_CN
set cursorline
set number
set relativenumber
set splitbelow
set splitright
set guioptions-=e
set guioptions-=m
set guioptions-=b
set guioptions-=l
set guioptions-=L
set guioptions-=r
set guioptions-=R
set guioptions-=t
set guioptions-=T
set nolist
set autoindent
set smartindent
set foldmethod=marker
set guifont=JetBrains_Mono:h15
set guifontwide=Microsoft_Yahei_Mono:h15
set conceallevel=2
set wildmenu
set scrolloff=9
set noshowmode
set tabstop=4
set expandtab
set softtabstop=4
set shiftwidth=4
set viewoptions-=options
set undofile
set undodir=D:\.vim\.undo\
set directory=D:\.vim\.swap\
set shortmess+=FWA
set noruler
set noshowmode
set noshowcmd
set showtabline=0
set filetype=markdown
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

let g:python3_host_skip_check = 1
let g:python3_host_prog       = '/usr/local/bin/python3'
let $LANG                     = 'en_US.UTF-8'

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
Plug 'yianwillis/vimcdoc'
Plug 'itchyny/lightline.vim'
Plug 'maximbaz/lightline-ale',        { 'for': g:language_types }
Plug 'junegunn/vim-easy-align'
Plug 'neoclide/coc.nvim',             { 'branch': 'release' }
Plug 'dense-analysis/ale',            { 'for': g:language_types }
Plug 'SirVer/ultisnips'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'easymotion/vim-easymotion'
Plug 'mg979/vim-visual-multi'
Plug 'Yggdroot/indentLine',           { 'for': g:language_types }
Plug 'luochen1990/rainbow',           { 'for': g:language_types }
Plug 'lervag/vimtex',                 { 'for': ['tex', 'markdown'] }
" Plug 'python-mode/python-mode',   { 'for': 'python', 'branch': 'develop' }
" }}}1
call plug#end()

colorscheme gruvbox

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                         Key Mappings                                         "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Key Mappings {{{1
let g:mapleader = ","

noremap  <Up>    <Nop>
noremap  <Down>  <Nop>
noremap  <Left>  <Nop>
noremap  <Right> <Nop>
inoremap <Up>    <Nop>
inoremap <Down>  <Nop>
inoremap <Left>  <Nop>
inoremap <Right> <Nop>
nnoremap <Esc>   <Nop>
inoremap <Esc>   <Nop>

inoremap jk                <Esc>
inoremap kj                <Esc>
nmap     H                 0
nnoremap L                 $
nnoremap U                 <C-r>
nnoremap ;                 :
nnoremap :                 ;
nnoremap k                 gk
nnoremap gk                k
nnoremap j                 gj
nnoremap gj                j
inoremap <silent><C-q>     <C-o>:x<Cr>
inoremap <silent><C-S-q>   <C-o>:q!<Cr>
nnoremap <silent><C-q>     :x<Cr>
nnoremap <silent><C-S-q>   :q!<Cr>
nnoremap <expr>0           col('.') == 1 ? '^': '0'
noremap  <silent><leader>/ :noh<Cr>
noremap  <ScrollWheelUp>   <nop>
noremap  <ScrollWheelDown> <nop>
inoremap <ScrollWheelUp>   <nop>
inoremap <ScrollWheelDown> <nop>
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                                                                              "
"                                           Markdown                                           "
"                                                                                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Markdown {{{1
autocmd FileType markdown let b:coc_pairs_disabled = ["'"]
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

" This is necessary for VimTeX to load properly. The "indent" is optional.
" Note that most plugin managers will do this automatically.
filetype plugin indent on

" This enables Vim's and neovim's syntax-related features. Without this, some
" VimTeX features will not work (see ":help vimtex-requirements" for more
" info).
syntax enable

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

augroup vimtex_config
  autocmd!
  autocmd User VimtexEventQuit call vimtex#compiler#clean(0)
augroup end
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
let g:UltiSnipsExpandTrigger       = 'ô'
let g:UltiSnipsListSnippets        = '<C-Tab>'
let g:UltiSnipsJumpForwardTrigger  = '<Tab>'
let g:UltiSnipsJumpBackwardTrigger = '<S-Tab>'
let g:UltiSnipsEditSplit           = "vertical"
let g:UltiSnipsSnippetDirectories  = ['Snips']
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
nnoremap <leader>S         <Plug>(easymotion-s2)
nnoremap /                 <Plug>(easymotion-sn)
onoremap /                 <Plug>(easymotion-tn)
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
let g:VM_maps                    = {}
let g:VM_maps["Exit"]            = '<C-c>'
let g:VM_maps["Add Cursor Down"] = '<A-s>'
let g:VM_maps["Add Cursor Up"]   = '<A-w>'
let g:VM_maps["Select l"]        = '<A-d>'
let g:VM_maps["Select h"]        = '<A-a>'
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
xnoremap ga <Plug>(EasyAlign)
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
let g:ale_linters      = {
\   'python': ['pylint'],
\}
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
" TextEdit might fail if hidden is not set.
set hidden

" Some servers have issues with backup files, see #649.
set nobackup
set nowritebackup

" Give more space for displaying messages.
" set cmdheight=1

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
" delays and poor user experience.
set updatetime=300

" Don't pass messages to |ins-completion-menu|.
set shortmess+=c

" Always show the signcolumn, otherwise it would shift the text each time
" diagnostics appear/become resolved.
" Recently vim can merge signcolumn and number column into one
set signcolumn=number

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <C-z>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<C-z>" :
      \ coc#refresh()
inoremap <expr><C-S-z> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <C-c> pumvisible() ? coc#_select_confirm()
                             \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" Remap <C-f> and <C-b> for scroll float windows/popups.
inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
" set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>
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
inoremap <silent><F5> <C-O>:call RunProgram()<CR>

autocmd FileType python,javascript nnoremap <silent><leader>Q :call CloseTerminal()<CR>

let g:support_f5_filetypes = ['python', 'javascript', 'autohotkey']
let g:terminal_settings = {'vertical': 1}

function! RunProgram()
    if index(g:support_f5_filetypes, &filetype) >= 0
        execute 'silent execute "w"'
        let l:filename = expand('%')
        let l:opts     = g:terminal_settings

        if &filetype == 'python'
            call OpenTerminal()
            let l:opts.term_name = 'python_terminal'
            call term_start('python ' . l:filename, l:opts)
        elseif &filetype == 'javascript'
            call OpenTerminal()
            let l:opts.term_name = 'javascript_terminal'
            call term_start('node '. l:filename, l:opts)
        elseif &filetype == 'autohotkey'
            execute 'silent execute "!start \"D:/Program Files/AutoHotkey/autohotkey.exe\" /restart /CP65001 %:p"'
        endif                                                                              

    endif
endfunction

function! OpenTerminal()
    let l:windowsWithTerminal = filter(range(1, winnr('$')), 'getwinvar(v:val, "&buftype") ==# "terminal" || term_getstatus(winbufnr(v:val))')
    if !empty(l:windowsWithTerminal)
        execute 'silent execute "' . l:windowsWithTerminal[0] . 'wincmd w"'
        call CloseTerminal()
    endif
endfunction

function! CloseTerminal()
    let l:winnumber = winnr()
    if getwinvar(l:winnumber, "&buftype") ==# "terminal" || term_getstatus(winbufnr(l:winnumber))
        execute 'silent execute "' . winbufnr(l:winnumber) . 'bw!"'
    else
        execute 'silent execute "q!"'
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
\             [ 'readonly' ] ],
\   'right': [ [ 'lineinfo' ],
\              [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_infos', 'linter_ok' ],
\              [ 'fileformat', 'fileencoding', 'filetype'] ]
\ },
\ 'component_expand': {
\   'linter_checking' : 'lightline#ale#checking',
\   'linter_infos'    : 'lightline#ale#infos',
\   'linter_warnings' : 'lightline#ale#warnings',
\   'linter_errors'   : 'lightline#ale#errors',
\   'linter_ok'       : 'lightline#ale#ok',
\ },
\ 'component_type': {
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

function! LightLineLineInfo()
  return printf(' %d/%d | %d/%d', line('.'), line('$'), col('.'), col('$'))
endfunction

let s:palette = g:lightline#colorscheme#gruvbox#palette
let s:palette.tabline.ale = [['#282C34', '#26A69A', 0, 21]]

let g:lightline#ale#indicator_checking     = '⏳'
let g:lightline#ale#indicator_infos        = '📜'
let g:lightline#ale#indicator_errors       = '💥'
let g:lightline#ale#indicator_warnings     = '⚡'
let g:lightline#ale#indicator_ok           = '✨'
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
let g:indent_guides_guide_size   = 1
let g:indent_guides_start_level  = 1
let g:indentLine_setConceal      = 0
let g:indentLine_enabled         = 1
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
inoremap <silent> <End>   <C-r>=IncreaseColNumber()<CR>
inoremap <silent> <S-End> <C-r>=DecreaseColNumber()<CR>

let s:delimiters_exp = '[\[\]{}()$&"' . "'" . '<>]'

function! IncreaseColNumber()
    let l:line = getline('.')
    if l:line[col('.') - 1] =~# s:delimiters_exp
        return "\<Right>"
    endif
endfunction

function! DecreaseColNumber()
    let l:line = getline('.')
    if l:line[col('.') - 2] =~# s:delimiters_exp
        return "\<Left>"
    endif
endfunction
" }}}1

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
