let g:consolidated_directory = $HOME . '/.config/vimfiles/persistence/'

" let g:UltiSnipsMinePath = $HOME . '/.config/vimfiles/PluginConf/'

let plugin_manager_path = $HOME . '/.config/vimfiles/plugins/'
if has('nvim')
    let g:python_host_prog = $HOME . '/.config/nvim/env2/bin/python'
    let g:python3_host_prog = $HOME . '/.config/nvim/env3/bin/python'
endif

" let python_virtualenv = $HOME . "/bin/env/"
let python_virtualenv = $HOME . '/.config/nvim/env3/'

" Environment {{{
    " Identify platform {
        silent function! OSX()
            return has('macunix')
        endfunction
        silent function! LINUX()
            return has('unix') && !has('macunix') && !has('win32unix')
        endfunction
        silent function! WINDOWS()
            return  (has('win32') || has('win64'))
        endfunction
    " }

    " Basics {
        set nocompatible        " Must be first line
        if !WINDOWS()
            set shell=/bin/bash
        endif
    " }

    " Windows Compatible {
        " On Windows, also use '.vim' instead of 'vimfiles'; this makes synchronization
        " across (heterogeneous) systems easier.
        if WINDOWS()
          set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
        endif
    " }
    
    " Arrow Key Fix {
        " https://github.com/spf13/spf13-vim/issues/780
        if &term[:4] == "xterm" || &term[:5] == 'screen' || &term[:3] == 'rxvt'
            inoremap <silent> <C-[>OC <RIGHT>
        endif
    " }
    
    " Function to activate a virtualenv in the embedded interpreter for
    " omnicomplete and other things like that.
    function LoadVirtualEnv2(path)
        let activate_this = a:path . '/bin/activate_this.py'
        if getftype(a:path) == "dir" && filereadable(activate_this)
        python << EOF
import vim
activate_this = vim.eval('l:activate_this')
execfile(activate_this, dict(__file__=activate_this))
EOF
        endif
    endfunction

    function LoadVirtualEnv3(path)
        let activate_this = a:path . '/bin/activate_this.py'
        if getftype(a:path) == "dir" && filereadable(activate_this)
        py3 << EOF
import vim
activate_this = vim.eval('l:activate_this')
exec(compile(open(activate_this, "rb").read(), activate_this, 'exec'), {'__file__': activate_this})
EOF
        endif
    endfunction

    " if has("python3")
    "     if empty($VIRTUAL_ENV) && getftype(python_virtualenv) == "dir"
    "         call LoadVirtualEnv3(python_virtualenv)
    "     endif
    " elseif has("python")
    "     if empty($VIRTUAL_ENV) && getftype(python_virtualenv) == "dir"
    "         call LoadVirtualEnv2(python_virtualenv)
    "     endif
    " endif
" }}}

" General {{{
    let mapleader = ','

    set background=dark         " Assume a dark background

    " " Allow to trigger background
    " function! ToggleBG()
    "     let s:tbg = &background
    "     " Inversion
    "     if s:tbg == "dark"
    "         set background=light
    "     else
    "         set background=dark
    "     endif
    " endfunction
    " noremap <leader>bg :call ToggleBG()<CR>

    set foldmethod=marker
    set nospell
    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    " set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8
    set fileencodings=utf-8,chinese,GB18030,latin-1
    "set fileencodings=chinese,utf-8,latin-1
    set fileformats=unix,dos,mac "Default file types

    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior
    autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

    " set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    " don't give |ins-completion-menu| messages.
    set shortmess+=c
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    " set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    if has('nvim')
        exec "set shada+=n" . g:consolidated_directory . "main.shada"
    else
        exec "set viminfo+=n" . g:consolidated_directory . "viminfo"
    endif

    " set spell                           " Spell checking on
    set hidden                          " Allow buffer switching without saving
    " set iskeyword-=.                    " '.' is an end of word designator
    " set iskeyword-=#                    " '#' is an end of word designator
    " set iskeyword-=-                    " '-' is an end of word designator

    " http://vim.wikia.com/wiki/Restore_cursor_to_file_position_in_previous_editing_session
    " Restore cursor to file position in previous editing session
    function! ResCur()
        if line("'\"") <= line("$")
            silent! normal! g`"
            return 1
        endif
    endfunction

    augroup resCur
        autocmd!
        autocmd BufWinEnter * call ResCur()
    augroup END

    " Setting up the directories 
    set backup                  " Backups are nice ...
    if has('persistent_undo')
        set undofile                " So is persistent undo ...
        set undolevels=1000         " Maximum number of changes that can be undone
        set undoreload=10000        " Maximum number lines to save for undo on a buffer reload
    endif

    " Initialize directories {
    function! InitializeDirectories()
        let parent = $HOME
        let prefix = 'vim'
        let dir_list = {
                    \ 'backup': 'backupdir',
                    \ 'views': 'viewdir',
                    \ 'swap': 'directory' }

        if has('persistent_undo')
            let dir_list['undo'] = 'undodir'
        endif

        " To specify a different directory in which to place the vimbackup,
        " vimviews, vimundo, and vimswap files/directories
        if exists('g:consolidated_directory')
            let common_dir = g:consolidated_directory . prefix
        else
            let common_dir = parent . '/.' . prefix
        endif

        for [dirname, settingname] in items(dir_list)
            let directory = common_dir . dirname . '/'
            if exists("*mkdir")
                if !isdirectory(directory)
                    call mkdir(directory)
                endif
            endif
            if !isdirectory(directory)
                echo "Warning: Unable to create backup directory: " . directory
                echo "Try: mkdir -p " . directory
            else
                let directory = substitute(directory, " ", "\\\\ ", "g")
                exec "set " . settingname . "=" . directory
            endif
        endfor
    endfunction
    call InitializeDirectories()

    " cm=zip
    " set cm=blowfish
    " cm=blowfish2

" }}}

" Vim UI {{{
    set title
    set tabpagemax=15               " Only show 15 tabs
    set showmode                    " Display the current mode
    set cmdheight=2

    set cursorline                  " Highlight current line
    set signcolumn=yes              " always show signcolumns
    highlight clear SignColumn      " SignColumn should match background
    highlight clear LineNr          " Current line number row will have same background color in relative mode
    "highlight clear CursorLineNr    " Remove highlight color from current line number

    if has('cmdline_info')
        set ruler                   " Show the ruler
        set rulerformat=%30(%=\:b%n%y%m%r%w\ %l,%c%V\ %P%) " A ruler on steroids
        set showcmd                 " Show partial commands in status line and
                                    " Selected characters/lines in visual mode
    endif

    if has('statusline')
        set laststatus=2

        " Broken down into easily includeable segments
        set statusline=%<%f\                     " Filename
        set statusline+=%w%h%m%r                 " Options
        " if !exists('g:override_spf13_bundles')
        "     set statusline+=%{fugitive#statusline()} " Git Hotness
        " endif
        set statusline+=\ [%{&ff}/%Y]            " Filetype
        set statusline+=\ [%{getcwd()}]          " Current dir
        set statusline+=%=%-14.(%l,%c%V%)\ %p%%  " Right aligned file nav info
    endif

    set backspace=indent,eol,start  " Backspace for dummies
    set linespace=0                 " No extra spaces between rows
    set number                      " Line numbers on
    set showmatch                   " Show matching brackets/parenthesis
    set incsearch                   " Find as you type search
    set magic "Set magic on, for regular expressions
    set hlsearch                    " Highlight search terms
    set winminheight=0              " Windows can be 0 line high
    set ignorecase                  " Case insensitive search
    set smartcase                   " Case sensitive when uc present
    set wildmenu                    " Show list instead of just completing
    set wildmode=list:longest,full  " Command <Tab> completion, list matches, then longest common part, then all.
    set whichwrap=b,s,h,l,<,>,[,]   " Backspace and cursor keys wrap too
    set scrolljump=5                " Lines to scroll when cursor leaves screen
    set scrolloff=3                 " Minimum lines to keep above and below cursor
    set foldenable                  " Auto fold code
    set list
    set listchars=tab:›\ ,trail:•,extends:#,nbsp:. " Highlight problematic whitespace

    " * selection
    " + copy-paste
    if has('clipboard')
        if has('nvim')
            set clipboard=unnamedplus
        elseif has('unnamedplus')  " When possible use + register for copy-paste
            set clipboard=unnamed,unnamedplus
        else         " On mac and Windows, use * register for copy-paste
            set clipboard=unnamed
        endif
    endif

    " Cut: control-X / shift-Delete
    " d
    vnoremap <S-Delete> "+x
    " Copy: control-C / control-Insert
    vnoremap <C-Insert> "+y
    " Paste: control-V / shift-Insert
    nnoremap <S-Insert> "+gP
    inoremap <S-Insert> <C-R><C-O>+
    cnoremap <S-Insert> <C-R>+

    if has('nvim')
        vmap <LeftRelease> "*ygv
    endif

    " autocmd VimLeave * call system("xsel -ib", getreg('+'))
    " autocmd VimLeave * call system("xsel -ip", getreg('*'))

    " GVIM- (here instead of .gvimrc)
    if has('gui_running')
        set guioptions-=T           " Remove the toolbar
        set lines=40                " 40 lines of text instead of 24
        if LINUX() && has("gui_running")
            set guifont=Andale\ Mono\ Regular\ 14,Menlo\ Regular\ 13,Consolas\ Regular\ 14,Courier\ New\ Regular\ 16
        elseif OSX() && has("gui_running")
            set guifont=Andale\ Mono\ Regular:h15,Menlo\ Regular:h15,Consolas\ Regular:h15,Courier\ New\ Regular:h15
        elseif WINDOWS() && has("gui_running")
            set guifont=Andale_Mono:h10,Menlo:h10,Consolas:h10,Courier_New:h10
        endif
    else
        if &term == 'xterm' || &term == 'screen'
            set t_Co=256            " Enable 256 colors to stop the CSApprox warning and make xterm vim shine
        endif
        "set term=builtin_ansi       " Make arrow and other keys work
    endif
" }}}

" Formatting {{{
    set linebreak
    " set nowrap                      " Do not wrap long lines
    set wrap
    set autoindent                  " Indent at the same level of the previous line
    set shiftwidth=4                " Use indents of 4 spaces
    set expandtab                   " Tabs are spaces, not tabs
    set tabstop=4                   " An indentation every four columns
    set smarttab
    set softtabstop=4               " Let backspace delete indent
    set nojoinspaces                " Prevents inserting two spaces after punctuation on a join (J)
    set splitright                  " Puts new vsplit windows to the right of the current
    set splitbelow                  " Puts new split windows to the bottom of the current
    "set matchpairs+=<:>             " Match, to be used with %
    set pastetoggle=<F12>           " pastetoggle (sane indentation on pastes)
    "set comments=sl:/*,mb:*,elx:*/  " auto format comment blocks
    autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl,sql autocmd BufWritePre <buffer> call StripTrailingWhitespace()
    " autocmd FileType go autocmd BufWritePre <buffer> Fmt
    " autocmd BufNewFile,BufRead *.html.twig set filetype=html.twig
    " autocmd FileType haskell,puppet,ruby,yml setlocal expandtab shiftwidth=2 softtabstop=2
    " autocmd BufNewFile,BufRead *.coffee set filetype=coffee
    " Workaround vim-commentary for Haskell
    " autocmd FileType haskell setlocal commentstring=--\ %s
    " Workaround broken colour highlighting in Haskell
    " autocmd FileType haskell,rust setlocal nospell

    set commentstring="# %s"
" }}}

" Key (re)Mappings {{{
    " Easier moving in tabs and windows
    " The lines conflict with the default digraph mapping of <C-K>
    " map <C-J> <C-W>j<C-W>_
    " map <C-K> <C-W>k<C-W>_
    " map <C-L> <C-W>l<C-W>_
    " map <C-H> <C-W>h<C-W>_

    map <C-j> <C-W>j
    map <C-k> <C-W>k
    map <C-h> <C-W>h
    map <C-l> <C-W>l

    " Wrapped lines goes down/up to next row, rather than next line in file.
    noremap j gj
    noremap k gk

    " End/Start of line motion keys act relative to row/wrap width in the
    " presence of `:set wrap`, and relative to line for `:set nowrap`.
    " Default vim behaviour is to act relative to text line in both cases
    " If you prefer the default behaviour, add the following to your
    " .vimrc.before.local file:
    " Same for 0, home, end, etc
    function! WrapRelativeMotion(key, ...)
        let vis_sel=""
        if a:0
            let vis_sel="gv"
        endif
        if &wrap
            execute "normal!" vis_sel . "g" . a:key
        else
            execute "normal!" vis_sel . a:key
        endif
    endfunction

    " Map g* keys in Normal, Operator-pending, and Visual+select
    noremap $ :call WrapRelativeMotion("$")<CR>
    noremap <End> :call WrapRelativeMotion("$")<CR>
    noremap 0 :call WrapRelativeMotion("0")<CR>
    noremap <Home> :call WrapRelativeMotion("0")<CR>
    noremap ^ :call WrapRelativeMotion("^")<CR>
    " Overwrite the operator pending $/<End> mappings from above
    " to force inclusive motion with :execute normal!
    onoremap $ v:call WrapRelativeMotion("$")<CR>
    onoremap <End> v:call WrapRelativeMotion("$")<CR>
    " Overwrite the Visual+select mode mappings from above
    " to ensure the correct vis_sel flag is passed to function
    vnoremap $ :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap <End> :<C-U>call WrapRelativeMotion("$", 1)<CR>
    vnoremap 0 :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap <Home> :<C-U>call WrapRelativeMotion("0", 1)<CR>
    vnoremap ^ :<C-U>call WrapRelativeMotion("^", 1)<CR>

    " Stupid shift key fixes
    if has("user_commands")
        command! -bang -nargs=* -complete=file E e<bang> <args>
        command! -bang -nargs=* -complete=file W w<bang> <args>
        command! -bang -nargs=* -complete=file Wq wq<bang> <args>
        command! -bang -nargs=* -complete=file WQ wq<bang> <args>
        command! -bang Wa wa<bang>
        command! -bang WA wa<bang>
        command! -bang Q q<bang>
        command! -bang QA qa<bang>
        command! -bang Qa qa<bang>
    endif

    cmap Tabe tabe

    " Yank from the cursor to the end of the line, to be consistent with C and D.
    nnoremap Y y$

    " Code folding options
    nmap <leader>f0 :set foldlevel=0<CR>
    nmap <leader>f1 :set foldlevel=1<CR>
    nmap <leader>f2 :set foldlevel=2<CR>
    nmap <leader>f3 :set foldlevel=3<CR>
    nmap <leader>f4 :set foldlevel=4<CR>
    nmap <leader>f5 :set foldlevel=5<CR>
    nmap <leader>f6 :set foldlevel=6<CR>
    nmap <leader>f7 :set foldlevel=7<CR>
    nmap <leader>f8 :set foldlevel=8<CR>
    nmap <leader>f9 :set foldlevel=9<CR>

    " Most prefer to toggle search highlighting rather than clear the current
    " search results
    " nmap <silent> <leader>/ :nohlsearch<CR>
    nmap <silent> <leader>/ :set invhlsearch<CR>

    " Find merge conflict markers
    map <leader>fc /\v^[<\|=>]{7}( .*\|$)<CR>

    " Shortcuts
    " Change Working Directory to that of the current file
    cmap cwd lcd %:p:h
    cmap cd. lcd %:p:h

    " Visual shifting (does not exit Visual mode)
    " vnoremap < <gv
    " vnoremap > >gv

    " Allow using the repeat operator with a visual selection (!)
    " http://stackoverflow.com/a/8064607/127816
    vnoremap . :normal .<CR>

    " For when you forget to sudo.. Really Write the file.
    " cmap w!! w !sudo tee % >/dev/null

    " Some helpers to edit mode
    " http://vimcasts.org/e/14
    cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<cr>
    map <leader>ew :e %%
    map <leader>es :sp %%
    map <leader>ev :vsp %%
    map <leader>et :tabe %%

    " Adjust viewports to the same size
    map <Leader>= <C-w>=

    " Map <Leader>ff to display all lines with keyword under cursor
    " and ask which one to jump to
    nmap <Leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>

    " Easier horizontal scrolling
    map zl zL
    map zh zH

    " Easier formatting
    nnoremap <silent> <leader>q gwip

    " FIXME: Revert this f70be548
    " fullscreen mode for GVIM and Terminal, need 'wmctrl' in you PATH
    map <silent> <F11> :call system("wmctrl -ir " . v:windowid . " -b toggle,fullscreen")<CR>

    function! CmdLine(str)
        exe "menu Foo.Bar :" . a:str
        emenu Foo.Bar
        unmenu Foo
    endfunction 
     
    " From an idea by Michael Naumann
    function! VisualSearch(direction) range
        let l:saved_reg = @"
        execute "normal! vgvy"
     
        let l:pattern = escape(@", '\\/.*$^~[]')
        let l:pattern = substitute(l:pattern, "\n$", "", "")
     
        if a:direction == 'b'
            execute "normal ?" . l:pattern . "^M"
        elseif a:direction == 'gv'
            call CmdLine("vimgrep " . '/'. l:pattern . '/' . ' **/*.')
        elseif a:direction == 'f'
            execute "normal /" . l:pattern . "^M"
        endif
     
        let @/ = l:pattern
        let @" = l:saved_reg
    endfunction

    "  In visual mode when you press * or # to search for the current selection
    vnoremap <silent> * :call VisualSearch('f')<CR>
    vnoremap <silent> # :call VisualSearch('b')<CR>
     
    " When you press gv you vimgrep after the selected text
    vnoremap <silent> gv :call VisualSearch('gv')<CR>

    " Close the current buffer
    map <leader>bd :Bclose<cr>
     
    command! Bclose call <SID>BufcloseCloseIt()
    function! <SID>BufcloseCloseIt()
       let l:currentBufNum = bufnr("%")
       let l:alternateBufNum = bufnr("#")
     
       if buflisted(l:alternateBufNum)
         buffer #
       else
         bnext
       endif
     
       if bufnr("%") == l:currentBufNum
         new
       endif
     
       if buflisted(l:currentBufNum)
         execute("bdelete! ".l:currentBufNum)
       endif
    endfunction

    "Move a line of text using ALT+[jk] or Comamnd+[jk] on mac
    nmap <M-j> mz:m+<cr>`z
    nmap <M-k> mz:m-2<cr>`z
    vmap <M-j> :m'>+<cr>`<my`>mzgv`yo`z
    vmap <M-k> :m'<-2<cr>`>my`<mzgv`yo`z

    "Pressing ,ss will toggle and untoggle spell checking
    map <leader>ss :setlocal spell!<cr>

    " map <leader>gp :vimgrep // **/*.<left><left><left><left><left><left><left>
    autocmd FileType python nnoremap <leader>y :0,$!yapf<Cr>

    nnoremap <Leader>b :ls<CR>:b<Space>
" }}}

" Plugins {{{
    call plug#begin(plugin_manager_path)

    Plug 'https://github.com/junegunn/vim-plug'

    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    Plug 'bling/vim-bufferline'
    Plug 'iCyMind/NeoSolarized'
    " Plug 'Konfekt/FastFold'
    "
    Plug 'Yggdroot/LeaderF'

    " " Edit
    Plug 'https://github.com/wsdjeg/vim-mundo.git', { 'on':  'MundoToggle' }
    " Plug 'scrooloose/nerdtree'
    if has('nvim')
      Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
    else
      Plug 'Shougo/defx.nvim'
      Plug 'roxma/nvim-yarp'
      Plug 'roxma/vim-hug-neovim-rpc'
    endif
    Plug 'https://github.com/kshenoy/vim-signature'  "Plugin to toggle, display and navigate marks
    Plug 'https://github.com/junegunn/rainbow_parentheses.vim'
    " Plug 'https://github.com/Shougo/unite.vim'
    " Plug 'https://github.com/Shougo/neomru.vim'
    Plug 'https://github.com/mhinz/vim-grepper.git'
    Plug 'https://github.com/Yggdroot/indentLine'
    " Plug 'terryma/vim-multiple-cursors'
    Plug 'mg979/vim-visual-multi'
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'mhinz/vim-signify' "Signify (or just Sy) uses the sign column to indicate added, modified and removed lines in a file that is managed by a version control system (VCS).
    Plug 'https://github.com/elzr/vim-json'

    " Developement
    Plug 'neoclide/coc.nvim', {'tag': '*', 'do': './install.sh'}
    " Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    " Plug 'deoplete-plugins/deoplete-jedi'
    Plug 'honza/vim-snippets'
    Plug 'gorodinskiy/vim-coloresque'  "color preview for vim.
    " Plug 'mattn/emmet-vim' "support for expanding abbreviations similar to emmet
    " Plug 'neomake/neomake'

    " Plug 'hail2u/vim-css3-syntax'
    Plug 'tpope/vim-commentary'
    " Plug 'https://github.com/majutsushi/tagbar'
    Plug 'liuchengxu/vista.vim'

    " file type
    Plug 'https://github.com/dag/vim-fish.git'

    " Add plugins to &runtimepath
    call plug#end()
" }}}

" Plugin settings {{{
    " => scheme {{{
      colorscheme NeoSolarized
    " }}}
    " => unite {{{
        " let g:unite_source_history_yank_enable=1
        " let g:unite_source_file_mru_long_limit = 100
        " nnoremap <leader>s :Unite -start-insert buffer file_mru<CR>
    " }}}
    " => coc {{{
        " Use tab for trigger completion with characters ahead and navigate.
        " Use command ':verbose imap <tab>' to make sure tab is not mapped by other plugin.
        inoremap <silent><expr> <TAB>
              \ pumvisible() ? "\<C-n>" :
              \ <SID>check_back_space() ? "\<TAB>" :
              \ coc#refresh()
        inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

        function! s:check_back_space() abort
          let col = col('.') - 1
          return !col || getline('.')[col - 1]  =~# '\s'
        endfunction

        " Use <c-space> to trigger completion.
        " inoremap <silent><expr> <c-space> coc#refresh()

        " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
        " Coc only does snippet and additional edit on confirm.
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

        " Use `[c` and `]c` to navigate diagnostics
        nmap <silent> [c <Plug>(coc-diagnostic-prev)
        nmap <silent> ]c <Plug>(coc-diagnostic-next)

        " Remap keys for gotos
        nmap <silent> gd <Plug>(coc-definition)
        nmap <silent> gy <Plug>(coc-type-definition)
        nmap <silent> gi <Plug>(coc-implementation)
        nmap <silent> gr <Plug>(coc-references)

        " Use K to show documentation in preview window
        nnoremap <silent> K :call <SID>show_documentation()<CR>

        function! s:show_documentation()
          if (index(['vim','help'], &filetype) >= 0)
            execute 'h '.expand('<cword>')
          else
            call CocAction('doHover')
          endif
        endfunction

        " Highlight symbol under cursor on CursorHold
        autocmd CursorHold * silent call CocActionAsync('highlight')

        " Remap for rename current word
        nmap <leader>rn <Plug>(coc-rename)

        " Remap for format selected region
        xmap <leader>f  <Plug>(coc-format-selected)
        nmap <leader>f  <Plug>(coc-format-selected)

        augroup mygroup
          autocmd!
          " Setup formatexpr specified filetype(s).
          autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
          " Update signature help on jump placeholder
          autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
        augroup end

        " Remap for do codeAction of selected region, ex: `<leader>aap` for current paragraph
        xmap <leader>a  <Plug>(coc-codeaction-selected)
        nmap <leader>a  <Plug>(coc-codeaction-selected)

        " Remap for do codeAction of current line
        nmap <leader>ac  <Plug>(coc-codeaction)
        " Fix autofix problem of current line
        nmap <leader>qf  <Plug>(coc-fix-current)

        " Use `:Format` to format current buffer
        command! -nargs=0 Format :call CocAction('format')

        " Use `:Fold` to fold current buffer
        command! -nargs=? Fold :call     CocAction('fold', <f-args>)


        " Add diagnostic info for https://github.com/itchyny/lightline.vim
        let g:lightline = {
              \ 'colorscheme': 'wombat',
              \ 'active': {
              \   'left': [ [ 'mode', 'paste' ],
              \             [ 'cocstatus', 'readonly', 'filename', 'modified' ] ]
              \ },
              \ 'component_function': {
              \   'cocstatus': 'coc#status'
              \ },
              \ }



        " Using CocList
        " Show all diagnostics
        nnoremap <silent> <space>a  :<C-u>CocList diagnostics<cr>
        " Manage extensions
        nnoremap <silent> <space>e  :<C-u>CocList extensions<cr>
        " Show commands
        nnoremap <silent> <space>c  :<C-u>CocList commands<cr>
        " Find symbol of current document
        nnoremap <silent> <space>o  :<C-u>CocList outline<cr>
        " Search workspace symbols
        nnoremap <silent> <space>s  :<C-u>CocList -I symbols<cr>
        " Do default action for next item.
        nnoremap <silent> <space>j  :<C-u>CocNext<CR>
        " Do default action for previous item.
        nnoremap <silent> <space>k  :<C-u>CocPrev<CR>
        " Resume latest coc list
        nnoremap <silent> <space>p  :<C-u>CocListResume<CR>


        imap <C-j> <Plug>(coc-snippets-expand)

        " nnoremap <leader>s :CocList mru<CR>
    " }}}
    " => LeaderF {{{
        nnoremap <leader>sm :Leaderf mru<CR>
        nnoremap <leader>sf :Leaderf file<CR>
        nnoremap <leader>sb :Leaderf buffer<CR>
    " }}}
    " => UltiSnip {{{
        " if exists('g:UltiSnipsMinePath')
        "     let &runtimepath.= ','.g:UltiSnipsMinePath
        " endif
        " " autocmd! BufEnter *.md UltiSnipsAddFiletypes md.markdown

        " " " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
        " " let g:UltiSnipsExpandTrigger="<tab>"
        " " let g:UltiSnipsJumpForwardTrigger="<tab>"
        " " let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

        " let g:UltiSnipsExpandTrigger = '<C-j>'
        " let g:UltiSnipsJumpForwardTrigger = '<C-j>'
        " let g:UltiSnipsJumpBackwardTrigger = '<C-k>'
    " }}}
    " => RainbowParentheses {{{
        autocmd VimEnter *.py RainbowParentheses
    " }}}
    " => TagBar {{{
        " nnoremap <silent> <leader>tt :TagbarToggle<CR>
    " }}}
    " => MUndo {{{
        nnoremap <Leader>u :MundoToggle<CR>
        " If undotree is opened, it is likely one wants to interact with it.
        " let g:undotree_SetFocusWhenToggle=1
    " }}}
    " => vim-airline {{{
        " Set configuration options for the statusline plugin vim-airline.
        " Use the powerline theme and optionally enable powerline symbols.
        " To use the symbols , , , , , , and .in the statusline
        " segments add the following to your .vimrc.before.local file:
        "   let g:airline_powerline_fonts=1
        " If the previous symbols do not render for you then install a
        " powerline enabled font.

        " See `:echo g:airline_theme_map` for some more choices
        " Default in terminal vim is 'dark'
        if !exists('g:airline_theme')
            let g:airline_theme = 'solarized'
        endif
        if !exists('g:airline_powerline_fonts')
            " Use the default set of separators with a few customizations
            let g:airline_left_sep='›'  " Slightly fancier than '>'
            let g:airline_right_sep='‹' " Slightly fancier than '<'
        endif
    " }}}
    " => vim bufferline{{{
    let g:bufferline_echo = 0
    " }}}
    " => NERDTree plugin {{{
        " map <C-e> :NERDTreeToggle<CR>
        " map <leader>e :NERDTreeFind<CR>
        " nmap <leader>nt :NERDTreeFind<CR>

        " " let g:NERDShutUp=1
        " let NERDTreeShowBookmarks=1
        " let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
        " let NERDTreeChDirMode=0
        " let NERDTreeQuitOnOpen=1
        " let NERDTreeMouseMode=2
        " let NERDTreeShowHidden=1
        " let NERDTreeKeepTreeInNewTab=1
        " let g:nerdtree_tabs_open_on_gui_startup=0
    " }}}
    
    " => Defx plugin {{{
        map <C-e> :Defx<CR>
        call defx#custom#option('_', {
              \ 'winwidth': 40,
              \ 'split': 'vertical',
              \ 'direction': 'topleft',
              \ 'show_ignored_files': 0,
              \ 'buffer_name': '',
              \ 'toggle': 1,
              \ 'resume': 1
              \ })

        autocmd FileType defx call s:defx_my_settings()
        function! s:defx_my_settings() abort
          setl nonumber
          setl norelativenumber
          setl listchars=

          " Define mappings
          nnoremap <silent><buffer><expr> <CR>
          \ defx#do_action('drop')
          nnoremap <silent><buffer><expr> C
          \ defx#do_action('toggle_columns',
          \                'mark:filename:type:size:time')
          nnoremap <silent><buffer><expr> yy
          \ defx#do_action('yank_path')
          nnoremap <silent><buffer><expr> .
          \ defx#do_action('toggle_ignored_files')
          nnoremap <silent><buffer><expr> q
          \ defx#do_action('quit')
        endfunction
    " }}}
    " => syntastic {{{
    "    " autocmd QuickFixCmdPost l* nested lwindow
    "    " autocmd! BufWritePost *.py SyntasticCheck
    "    " let g:syntastic_quiet_messages={'level':'warnings'}
    "    let g:syntastic_python_checkers=['flake8']
    "    let g:syntastic_python_flake8_exec="/usr/local/bin/flake8"
    "    " let g:syntastic_python_flack8_quiet_messages = {
    "    "     \ "type":  "error",
    "    "     \ "regex": 'E202' }
    "    let g:syntastic_shell = "/bin/sh"
    "    let g:syntastic_always_populate_loc_list = 0
    "    " let g:syntastic_auto_loc_list = 1
    "    let g:syntastic_check_on_open = 1
    "    let g:syntastic_check_on_wq = 1
    ""}}}
    " => vim-json {{{
    " Concealing issue
    let g:indentLine_concealcursor=""
    "}}}
"}}}

    " Functions {{{
    function SwitchBuffer()
      b#
    endfunction
    " nmap <leader>bn :call SwitchBuffer()<CR>
    nmap <C-_> :call SwitchBuffer()<CR>

    " Initialize NERDTree as needed {
    function! NERDTreeInitAsNeeded()
        redir => bufoutput
        buffers!
        redir END
        let idx = stridx(bufoutput, "NERD_tree")
        if idx > -1
            NERDTreeMirror
            NERDTreeFind
            wincmd l
        endif
    endfunction
    " }

    " Strip whitespace {
    function! StripTrailingWhitespace()
        " Preparation: save last search, and cursor position.
        let _s=@/
        let l = line(".")
        let c = col(".")
        " do the business:
        %s/\s\+$//e
        " clean up: restore previous search history, and cursor position
        let @/=_s
        call cursor(l, c)
    endfunction
    " }

    " Shell command {
    function! s:RunShellCommand(cmdline)
        botright new

        setlocal buftype=nofile
        setlocal bufhidden=delete
        setlocal nobuflisted
        setlocal noswapfile
        setlocal nowrap
        setlocal filetype=shell
        setlocal syntax=shell

        call setline(1, a:cmdline)
        call setline(2, substitute(a:cmdline, '.', '=', 'g'))
        execute 'silent $read !' . escape(a:cmdline, '%#')
        setlocal nomodifiable
    endfunction

    command! -complete=file -nargs=+ Shell call s:RunShellCommand(<q-args>)
    " e.g. Grep current file for <search_term>: Shell grep -Hn <search_term> %
" }}}

" my self-system {{{
    if OSX()
        command! DlogFrame :r !tt history --days 1
        command! -nargs=1 DlogFrameDate :r !tt history --days <args>
    "     command! DlogFrame :r !~/Data/scripts/Self-productive/timecamp/env/bin/python ~/Data/scripts/Self-productive/timecamp/timecamp.py -e --startdate `date -v-1d "+\%Y-\%m-\%d"`
    " else
    "     command! DlogFrame :r !~/Data/scripts/Self-productive/timecamp/env/bin/python ~/Data/scripts/Self-productive/timecamp/timecamp.py -e --startdate `date -d yesterday +\%Y-\%m-\%d`
    endif
    " command! DlogFrame :r !~/Data/Personal-project/Self-productive/env/bin/python ~/Data/Personal-project/Self-productive/timecamp/tc.py tc-query --start `date -d yesterday +\%Y-\%m-\%d` --end `date -d yesterday +\%Y-\%m-\%d`
    " command! DlogFrame :r !~/bin/env/bin/python ~/Data/Personal-project/Self-productive/timecamp/tc.py tc --days 1 --end 1
    " command! -nargs=1 DlogFrameDate :r !~/Data/Personal-project/Self-productive/env/bin/python ~/Data/Personal-project/Self-productive/timecamp/tc.py tc-query --start "<args>" --end "<args>"

    " command! DlogFrame :r !~/Data/My_Scripts/Self-productive/timecamp/env/bin/python ~/Data/My_Scripts/Self-productive/timecamp/timecamp.py -e --startdate "strftime("%Y%m%d")"
" }}}
