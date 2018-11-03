let g:consolidated_directory = $HOME . '/.config/vimfiles/persistence/'

let g:UltiSnipsMinePath = $HOME . '/.config/vimfiles/PluginConf/'

let plugin_manager_path = $HOME . '/.config/vimfiles/plugins/'
if has('nvim')
    let g:python_host_prog = $HOME . '/.config/nvim/env2/bin/python'
    let g:python3_host_prog = $HOME . '/.config/nvim/env3/bin/python'
endif

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
    function LoadVirtualEnv(path)
        let activate_this = a:path . '/bin/activate_this.py'
        if getftype(a:path) == "dir" && filereadable(activate_this)
        python << EOF
import vim
activate_this = vim.eval('l:activate_this')
execfile(activate_this, dict(__file__=activate_this))
EOF
        endif
    endfunction
    " Load up a 'stable' virtualenv if one exists in ~/.virtualenv
    " let defaultvirtualenv = $HOME . "/.virtualenvs/stable"
    let defaultvirtualenv = $HOME . "/bin/activitywatch/env"

    " Only attempt to load this virtualenv if the defaultvirtualenv
    " actually exists, and we aren't running with a virtualenv active.
    if has("python")
        if empty($VIRTUAL_ENV) && getftype(defaultvirtualenv) == "dir"
            call LoadVirtualEnv(defaultvirtualenv)
        endif
    endif
" }}}
" General {{{
    let mapleader = ','

    set background=dark         " Assume a dark background

    " Allow to trigger background
    function! ToggleBG()
        let s:tbg = &background
        " Inversion
        if s:tbg == "dark"
            set background=light
        else
            set background=dark
        endif
    endfunction
    noremap <leader>bg :call ToggleBG()<CR>

    set foldmethod=marker
    set nospell
    " if !has('gui')
        "set term=$TERM          " Make arrow and other keys work
    " endif
    filetype plugin indent on   " Automatically detect file types.
    syntax on                   " Syntax highlighting
    set mouse=a                 " Automatically enable mouse usage
    set mousehide               " Hide the mouse cursor while typing
    scriptencoding utf-8
    set fileencodings=utf-8,chinese,GB18030,latin-1
    "set fileencodings=chinese,utf-8,latin-1
    set fileformats=unix,dos,mac "Default file types

    " Most prefer to automatically switch to the current file directory when
    " a new buffer is opened; to prevent this behavior
    autocmd BufEnter * if bufname("") !~ "^\[A-Za-z0-9\]*://" | lcd %:p:h | endif

    " set shortmess+=filmnrxoOtT          " Abbrev. of messages (avoids 'hit enter')
    set viewoptions=folds,options,cursor,unix,slash " Better Unix / Windows compatibility
    " set virtualedit=onemore             " Allow for cursor beyond last character
    set history=1000                    " Store a ton of history (default is 20)
    exec "set viminfo+=n" . g:consolidated_directory . "viminfo"
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

    set cursorline                  " Highlight current line
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
" }}}
" GUI Settings {{{

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
" }}}
" Plugins {{{
    call plug#begin(plugin_manager_path)

    Plug 'https://github.com/junegunn/vim-plug'

    " self system
    " Plug 'https://github.com/ActivityWatch/aw-watcher-vim'

    " GUI
    if has('nvim')
        Plug 'https://github.com/equalsraf/neovim-gui-shim.git'
        Plug 'https://github.com/freeo/vim-kalisi'
    endif
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
    " Plug 'bling/vim-bufferline'
    Plug 'altercation/vim-colors-solarized'
    Plug 'Konfekt/FastFold'

    " " Edit
    Plug 'https://github.com/wsdjeg/vim-mundo.git', { 'on':  'MundoToggle' }
    Plug 'scrooloose/nerdtree'
    Plug 'https://github.com/lilydjwg/fcitx.vim'
    Plug 'https://github.com/kshenoy/vim-signature'
    Plug 'https://github.com/junegunn/rainbow_parentheses.vim'
    Plug 'https://github.com/Shougo/unite.vim'
    " Plug 'https://github.com/Shougo/denite.nvim.git'
    Plug 'https://github.com/Shougo/neomru.vim'
    " Plug 'https://github.com/dhruvasagar/vim-table-mode.git'
    Plug 'https://github.com/mhinz/vim-grepper.git'
    " Plug 'https://github.com/airodactyl/neovim-ranger.git'
    Plug 'https://github.com/Yggdroot/indentLine'
    Plug 'terryma/vim-multiple-cursors'
    Plug 'easymotion/vim-easymotion'
    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'mhinz/vim-signify'
    Plug 'osyo-manga/vim-over'
    Plug 'https://github.com/reedes/vim-litecorrect.git'

    " Developement
    if has('nvim')
        Plug 'https://github.com/benekastah/neomake.git'
        Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
        function! DoRemote(arg)
          UpdateRemotePlugins
        endfunction
        Plug 'zchee/deoplete-jedi'
        Plug 'https://github.com/python-rope/ropevim'
    else
        Plug 'https://github.com/Valloric/YouCompleteMe'
        Plug 'https://github.com/scrooloose/syntastic'
        " Plug 'https://github.com/fatih/vim-go'
    endif
    Plug 'KabbAmine/zeavim.vim'
    Plug 'gorodinskiy/vim-coloresque'
    Plug 'hail2u/vim-css3-syntax'
    Plug 'tpope/vim-commentary'
    Plug 'https://github.com/tpope/vim-fugitive.git'
    Plug 'https://github.com/majutsushi/tagbar'
    Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'
    Plug 'https://github.com/heracek/HTML-AutoCloseTag'

    " file type
    Plug 'https://github.com/dag/vim-fish.git'
    " Plug 'tpope/vim-markdown'

    "Plug 'klen/python-mode'
    " NeoBundle 'https://github.com/Chiel92/vim-autoformat'
    
    " Add plugins to &runtimepath
    call plug#end()
" }}}
" Plugin settings {{{
    " => scheme {{{
        if has('nvim')
            colorscheme kalisi
        else
            colorscheme solarized
        endif

    " }}}
    " => unite {{{
        let g:unite_source_history_yank_enable=1
        let g:unite_source_file_mru_long_limit = 100
        nnoremap <leader>s :Unite -start-insert buffer file_mru<CR>
    " }}}
    if has('nvim')
    " => deoplete {{{
        let g:deoplete#enable_at_startup = 1
        let g:deoplete#disable_auto_complete = 1
		" inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
		" inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
        " inoremap <silent><expr><C-l> deoplete#mappings#manual_complete()
        " inoremap <silent><expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
        inoremap <silent><expr> <C-n> pumvisible() ? "\<C-n>" : deoplete#mappings#manual_complete()
        autocmd CompleteDone * pclose!
    " }}}
    " => neomake {{{
        let g:neomake_python_enable_makers = ['flake8']
        let g:neomake_python_flake8_exe = substitute(g:python_host_prog, 'python$', '', '') . 'flake8'
        autocmd QuickFixCmdPost l* nested lwindow
        autocmd! BufWritePost *.py Neomake flake8
        " autocmd! BufWritePost *.py lwindow

        " let g:neomake_python_flake8_maker = {
        "         \ 'exe': '/home/dersu/.config/nvim/env2/bin/flake8',
        "         \ 'errorformat': '%A%f: line %l\, col %v\, %m \ (%t%*\d\)',
        "         \ }
        " }}}
    endif
    " => UltiSnip {{{
        let g:UltiSnipsExpandTrigger="<c-j>"

        if exists('g:UltiSnipsMinePath')
            let &runtimepath.= ','.g:UltiSnipsMinePath
        endif
        " autocmd! BufEnter *.md UltiSnipsAddFiletypes md.markdown
        
        " " Trigger configuration. Do not use <tab> if you use https://github.com/Valloric/YouCompleteMe.
        " let g:UltiSnipsExpandTrigger="<tab>"
        " let g:UltiSnipsJumpForwardTrigger="<tab>"
        " let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
    " }}}
    " => RainbowParentheses {{{
        autocmd VimEnter *.py RainbowParentheses
    " }}}
    " => TagBar {{{
        nnoremap <silent> <leader>tt :TagbarToggle<CR>
    " }}}
    " => Fugitive {{{
        " Instead of reverting the cursor to the last position in the buffer, we
        " set it to the first line when editing a git commit message
        au FileType gitcommit au! BufEnter COMMIT_EDITMSG call setpos('.', [0, 1, 1, 0])

        nnoremap <silent> <leader>gs :Gstatus<CR>
        nnoremap <silent> <leader>gd :Gdiff<CR>
        nnoremap <silent> <leader>gc :Gcommit<CR>
        nnoremap <silent> <leader>gb :Gblame<CR>
        nnoremap <silent> <leader>gl :Glog<CR>
        nnoremap <silent> <leader>gp :Git push<CR>
        nnoremap <silent> <leader>gr :Gread<CR>
        nnoremap <silent> <leader>gw :Gwrite<CR>
        nnoremap <silent> <leader>ge :Gedit<CR>
        " Mnemonic _i_nteractive
        nnoremap <silent> <leader>gi :Git add -p %<CR>
        nnoremap <silent> <leader>gg :SignifyToggle<CR>
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
    " => NERDTree plugin {{{
        map <C-e> :NERDTreeToggle<CR>
        map <leader>e :NERDTreeFind<CR>
        nmap <leader>nt :NERDTreeFind<CR>

        " let g:NERDShutUp=1
        let NERDTreeShowBookmarks=1
        let NERDTreeIgnore=['\.py[cd]$', '\~$', '\.swo$', '\.swp$', '^\.git$', '^\.hg$', '^\.svn$', '\.bzr$']
        let NERDTreeChDirMode=0
        let NERDTreeQuitOnOpen=1
        let NERDTreeMouseMode=2
        let NERDTreeShowHidden=1
        let NERDTreeKeepTreeInNewTab=1
        let g:nerdtree_tabs_open_on_gui_startup=0
    " }}}
    " => YouCompleteMe {{{
        if has('gui_running')
            " let g:ycm_server_python_interpreter = '/usr/bin/python'
            nnoremap <leader>jd :YcmCompleter GoTo<CR>

            let g:acp_enableAtStartup = 0

            " enable completion from tags
            let g:ycm_collect_identifiers_from_tags_files = 1

            " remap Ultisnips for compatibility for YCM
            let g:UltiSnipsExpandTrigger = '<C-j>'
            let g:UltiSnipsJumpForwardTrigger = '<C-j>'
            let g:UltiSnipsJumpBackwardTrigger = '<C-k>'

            " Enable omni completion.
            autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
            autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
            autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
            autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
            autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
            autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
            autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

            " Haskell post write lint and check with ghcmod
            " $ `cabal install ghcmod` if missing and ensure
            " ~/.cabal/bin is in your $PATH.
            if !executable("ghcmod")
                autocmd BufWritePost *.hs GhcModCheckAndLintAsync
            endif

            " For snippet_complete marker.
            if has('conceal')
                set conceallevel=2 concealcursor=i
            endif

            " Disable the neosnippet preview candidate window
            " When enabled, there can be too much visual noise
            " especially when splits are used.
            set completeopt-=preview
        endif
    " }}}
    " => syntastic {{{
        " autocmd QuickFixCmdPost l* nested lwindow
        " autocmd! BufWritePost *.py SyntasticCheck
        " let g:syntastic_quiet_messages={'level':'warnings'}
        let g:syntastic_python_checkers=['flake8']
        let g:syntastic_python_flake8_exec="/usr/local/bin/flake8"
        " let g:syntastic_python_flack8_quiet_messages = {
        "     \ "type":  "error",
        "     \ "regex": 'E202' }
        let g:syntastic_shell = "/bin/sh"
        let g:syntastic_always_populate_loc_list = 0
        " let g:syntastic_auto_loc_list = 1
        let g:syntastic_check_on_open = 1
        let g:syntastic_check_on_wq = 1
    "}}}
    " => vim-go {{{
    " let g:go_bin_path = "~/bin/go/bin"
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
    " if OSX()
    "     command! DlogFrame :r !~/Data/scripts/Self-productive/timecamp/env/bin/python ~/Data/scripts/Self-productive/timecamp/timecamp.py -e --startdate `date -v-1d "+\%Y-\%m-\%d"`
    " else
    "     command! DlogFrame :r !~/Data/scripts/Self-productive/timecamp/env/bin/python ~/Data/scripts/Self-productive/timecamp/timecamp.py -e --startdate `date -d yesterday +\%Y-\%m-\%d`
    " endif
    command! DlogFrame :r !~/Data/Personal-project/Self-productive/env/bin/python ~/Data/Personal-project/Self-productive/timecamp/timecamp.py -e --startdate `date -d yesterday +\%Y-\%m-\%d`
    command! -nargs=1 DlogFrameDate :r !~/Data/Personal-project/Self-productive/env/bin/python ~/Data/Personal-project/Self-productive/timecamp/timecamp.py -e --startdate "<args>"

    " command! DlogFrame :r !~/Data/My_Scripts/Self-productive/timecamp/env/bin/python ~/Data/My_Scripts/Self-productive/timecamp/timecamp.py -e --startdate "strftime("%Y%m%d")"
" }}}

" offlines {{{



" " Plugins {
    " if !exists('g:override_spf13_bundles') && filereadable(expand("~/.vim/bundle/vim-colors-solarized/colors/solarized.vim"))
    "     let g:solarized_termcolors=256
    "     let g:solarized_termtrans=1
    "     let g:solarized_contrast="normal"
    "     let g:solarized_visibility="normal"
    "     color solarized             " Load a colorscheme
    " endif


    " " TextObj Sentence {
    "     if count(g:spf13_bundle_groups, 'writing')
    "         augroup textobj_sentence
    "           autocmd!
    "           autocmd FileType markdown call textobj#sentence#init()
    "           autocmd FileType textile call textobj#sentence#init()
    "           autocmd FileType text call textobj#sentence#init()
    "         augroup END
    "     endif
    " " }

    " " TextObj Quote {
    "     if count(g:spf13_bundle_groups, 'writing')
    "         augroup textobj_quote
    "             autocmd!
    "             autocmd FileType markdown call textobj#quote#init()
    "             autocmd FileType textile call textobj#quote#init()
    "             autocmd FileType text call textobj#quote#init({'educate': 0})
    "         augroup END
    "     endif
    " " }

    " " Misc {
    "     if isdirectory(expand("~/.vim/bundle/matchit.zip"))
    "         let b:match_ignorecase = 1
    "     endif
    " " }

    " " OmniComplete {
    "     " To disable omni complete, add the following to your .vimrc.before.local file:
    "     "   let g:spf13_no_omni_complete = 1
    "     if !exists('g:spf13_no_omni_complete')
    "         if has("autocmd") && exists("+omnifunc")
    "             autocmd Filetype *
    "                 \if &omnifunc == "" |
    "                 \setlocal omnifunc=syntaxcomplete#Complete |
    "                 \endif
    "         endif

    "         hi Pmenu  guifg=#000000 guibg=#F8F8F8 ctermfg=black ctermbg=Lightgray
    "         hi PmenuSbar  guifg=#8A95A7 guibg=#F8F8F8 gui=NONE ctermfg=darkcyan ctermbg=lightgray cterm=NONE
    "         hi PmenuThumb  guifg=#F8F8F8 guibg=#8A95A7 gui=NONE ctermfg=lightgray ctermbg=darkcyan cterm=NONE

    "         " Some convenient mappings
    "         "inoremap <expr> <Esc>      pumvisible() ? "\<C-e>" : "\<Esc>"
    "         if exists('g:spf13_map_cr_omni_complete')
    "             inoremap <expr> <CR>     pumvisible() ? "\<C-y>" : "\<CR>"
    "         endif
    "         inoremap <expr> <Down>     pumvisible() ? "\<C-n>" : "\<Down>"
    "         inoremap <expr> <Up>       pumvisible() ? "\<C-p>" : "\<Up>"
    "         inoremap <expr> <C-d>      pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    "         inoremap <expr> <C-u>      pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"

    "         " Automatically open and close the popup menu / preview window
    "         au CursorMovedI,InsertLeave * if pumvisible() == 0|silent! pclose|endif
    "         set completeopt=menu,preview,longest
    "     endif
    " " }

    " " Ctags {
    "     set tags=./tags;/,~/.vimtags

    "     " Make tags placed in .git/tags file available in all levels of a repository
    "     let gitroot = substitute(system('git rev-parse --show-toplevel'), '[\n\r]', '', 'g')
    "     if gitroot != ''
    "         let &tags = &tags . ',' . gitroot . '/.git/tags'
    "     endif
    " " }

    " " AutoCloseTag {
    "     " Make it so AutoCloseTag works for xml and xhtml files as well
    "     au FileType xhtml,xml ru ftplugin/html/autoclosetag.vim
    "     nmap <Leader>ac <Plug>ToggleAutoCloseMappings
    " " }

    " " SnipMate {
    "     " Setting the author var
    "     " If forking, please overwrite in your .vimrc.local file
    "     let g:snips_author = 'Steve Francia <steve.francia@gmail.com>'
    " " }


    " " Tabularize {
    "     if isdirectory(expand("~/.vim/bundle/tabular"))
    "         nmap <Leader>a& :Tabularize /&<CR>
    "         vmap <Leader>a& :Tabularize /&<CR>
    "         nmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
    "         vmap <Leader>a= :Tabularize /^[^=]*\zs=<CR>
    "         nmap <Leader>a=> :Tabularize /=><CR>
    "         vmap <Leader>a=> :Tabularize /=><CR>
    "         nmap <Leader>a: :Tabularize /:<CR>
    "         vmap <Leader>a: :Tabularize /:<CR>
    "         nmap <Leader>a:: :Tabularize /:\zs<CR>
    "         vmap <Leader>a:: :Tabularize /:\zs<CR>
    "         nmap <Leader>a, :Tabularize /,<CR>
    "         vmap <Leader>a, :Tabularize /,<CR>
    "         nmap <Leader>a,, :Tabularize /,\zs<CR>
    "         vmap <Leader>a,, :Tabularize /,\zs<CR>
    "         nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "         vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
    "     endif
    " " }

    " " Session List {
    "     set sessionoptions=blank,buffers,curdir,folds,tabpages,winsize
    "     if isdirectory(expand("~/.vim/bundle/sessionman.vim/"))
    "         nmap <leader>sl :SessionList<CR>
    "         nmap <leader>ss :SessionSave<CR>
    "         nmap <leader>sc :SessionClose<CR>
    "     endif
    " " }

    " " JSON {
    "     nmap <leader>jt <Esc>:%!python -m json.tool<CR><Esc>:set filetype=json<CR>
    "     let g:vim_json_syntax_conceal = 0
    " " }

    " " PyMode {
    "     " Disable if python support not present
    "     if !has('python') && !has('python3')
    "         let g:pymode = 0
    "     endif

    "     if isdirectory(expand("~/.vim/bundle/python-mode"))
    "         let g:pymode_lint_checkers = ['pyflakes']
    "         let g:pymode_trim_whitespaces = 0
    "         let g:pymode_options = 0
    "         let g:pymode_rope = 0
    "     endif
    " " }


    " " neocomplete {
    "     if count(g:spf13_bundle_groups, 'neocomplete')
    "         let g:acp_enableAtStartup = 0
    "         let g:neocomplete#enable_at_startup = 1
    "         let g:neocomplete#enable_smart_case = 1
    "         let g:neocomplete#enable_auto_delimiter = 1
    "         let g:neocomplete#max_list = 15
    "         let g:neocomplete#force_overwrite_completefunc = 1


    "         " Define dictionary.
    "         let g:neocomplete#sources#dictionary#dictionaries = {
    "                     \ 'default' : '',
    "                     \ 'vimshell' : $HOME.'/.vimshell_hist',
    "                     \ 'scheme' : $HOME.'/.gosh_completions'
    "                     \ }

    "         " Define keyword.
    "         if !exists('g:neocomplete#keyword_patterns')
    "             let g:neocomplete#keyword_patterns = {}
    "         endif
    "         let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    "         " Plugin key-mappings {
    "             " These two lines conflict with the default digraph mapping of <C-K>
    "             if !exists('g:spf13_no_neosnippet_expand')
    "                 imap <C-k> <Plug>(neosnippet_expand_or_jump)
    "                 smap <C-k> <Plug>(neosnippet_expand_or_jump)
    "             endif
    "             if exists('g:spf13_noninvasive_completion')
    "                 inoremap <CR> <CR>
    "                 " <ESC> takes you out of insert mode
    "                 inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    "                 " <CR> accepts first, then sends the <CR>
    "                 inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    "                 " <Down> and <Up> cycle like <Tab> and <S-Tab>
    "                 inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    "                 inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    "                 " Jump up and down the list
    "                 inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    "                 inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
    "             else
    "                 " <C-k> Complete Snippet
    "                 " <C-k> Jump to next snippet point
    "                 imap <silent><expr><C-k> neosnippet#expandable() ?
    "                             \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
    "                             \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    "                 smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    "                 inoremap <expr><C-g> neocomplete#undo_completion()
    "                 inoremap <expr><C-l> neocomplete#complete_common_string()
    "                 "inoremap <expr><CR> neocomplete#complete_common_string()

    "                 " <CR>: close popup
    "                 " <s-CR>: close popup and save indent.
    "                 inoremap <expr><s-CR> pumvisible() ? neocomplete#smart_close_popup()."\<CR>" : "\<CR>"

    "                 function! CleverCr()
    "                     if pumvisible()
    "                         if neosnippet#expandable()
    "                             let exp = "\<Plug>(neosnippet_expand)"
    "                             return exp . neocomplete#smart_close_popup()
    "                         else
    "                             return neocomplete#smart_close_popup()
    "                         endif
    "                     else
    "                         return "\<CR>"
    "                     endif
    "                 endfunction

    "                 " <CR> close popup and save indent or expand snippet
    "                 imap <expr> <CR> CleverCr()
    "                 " <C-h>, <BS>: close popup and delete backword char.
    "                 inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    "                 inoremap <expr><C-y> neocomplete#smart_close_popup()
    "             endif
    "             " <TAB>: completion.
    "             inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    "             inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"

    "             " Courtesy of Matteo Cavalleri

    "             function! CleverTab()
    "                 if pumvisible()
    "                     return "\<C-n>"
    "                 endif
    "                 let substr = strpart(getline('.'), 0, col('.') - 1)
    "                 let substr = matchstr(substr, '[^ \t]*$')
    "                 if strlen(substr) == 0
    "                     " nothing to match on empty string
    "                     return "\<Tab>"
    "                 else
    "                     " existing text matching
    "                     if neosnippet#expandable_or_jumpable()
    "                         return "\<Plug>(neosnippet_expand_or_jump)"
    "                     else
    "                         return neocomplete#start_manual_complete()
    "                     endif
    "                 endif
    "             endfunction

    "             imap <expr> <Tab> CleverTab()
    "         " }

    "         " Enable heavy omni completion.
    "         if !exists('g:neocomplete#sources#omni#input_patterns')
    "             let g:neocomplete#sources#omni#input_patterns = {}
    "         endif
    "         let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "         let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
    "         let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "         let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
    "         let g:neocomplete#sources#omni#input_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    " " }
    " " neocomplcache {
    "     elseif count(g:spf13_bundle_groups, 'neocomplcache')
    "         let g:acp_enableAtStartup = 0
    "         let g:neocomplcache_enable_at_startup = 1
    "         let g:neocomplcache_enable_camel_case_completion = 1
    "         let g:neocomplcache_enable_smart_case = 1
    "         let g:neocomplcache_enable_underbar_completion = 1
    "         let g:neocomplcache_enable_auto_delimiter = 1
    "         let g:neocomplcache_max_list = 15
    "         let g:neocomplcache_force_overwrite_completefunc = 1

    "         " Define dictionary.
    "         let g:neocomplcache_dictionary_filetype_lists = {
    "                     \ 'default' : '',
    "                     \ 'vimshell' : $HOME.'/.vimshell_hist',
    "                     \ 'scheme' : $HOME.'/.gosh_completions'
    "                     \ }

    "         " Define keyword.
    "         if !exists('g:neocomplcache_keyword_patterns')
    "             let g:neocomplcache_keyword_patterns = {}
    "         endif
    "         let g:neocomplcache_keyword_patterns._ = '\h\w*'

    "         " Plugin key-mappings {
    "             " These two lines conflict with the default digraph mapping of <C-K>
    "             imap <C-k> <Plug>(neosnippet_expand_or_jump)
    "             smap <C-k> <Plug>(neosnippet_expand_or_jump)
    "             if exists('g:spf13_noninvasive_completion')
    "                 inoremap <CR> <CR>
    "                 " <ESC> takes you out of insert mode
    "                 inoremap <expr> <Esc>   pumvisible() ? "\<C-y>\<Esc>" : "\<Esc>"
    "                 " <CR> accepts first, then sends the <CR>
    "                 inoremap <expr> <CR>    pumvisible() ? "\<C-y>\<CR>" : "\<CR>"
    "                 " <Down> and <Up> cycle like <Tab> and <S-Tab>
    "                 inoremap <expr> <Down>  pumvisible() ? "\<C-n>" : "\<Down>"
    "                 inoremap <expr> <Up>    pumvisible() ? "\<C-p>" : "\<Up>"
    "                 " Jump up and down the list
    "                 inoremap <expr> <C-d>   pumvisible() ? "\<PageDown>\<C-p>\<C-n>" : "\<C-d>"
    "                 inoremap <expr> <C-u>   pumvisible() ? "\<PageUp>\<C-p>\<C-n>" : "\<C-u>"
    "             else
    "                 imap <silent><expr><C-k> neosnippet#expandable() ?
    "                             \ "\<Plug>(neosnippet_expand_or_jump)" : (pumvisible() ?
    "                             \ "\<C-e>" : "\<Plug>(neosnippet_expand_or_jump)")
    "                 smap <TAB> <Right><Plug>(neosnippet_jump_or_expand)

    "                 inoremap <expr><C-g> neocomplcache#undo_completion()
    "                 inoremap <expr><C-l> neocomplcache#complete_common_string()
    "                 "inoremap <expr><CR> neocomplcache#complete_common_string()

    "                 function! CleverCr()
    "                     if pumvisible()
    "                         if neosnippet#expandable()
    "                             let exp = "\<Plug>(neosnippet_expand)"
    "                             return exp . neocomplcache#close_popup()
    "                         else
    "                             return neocomplcache#close_popup()
    "                         endif
    "                     else
    "                         return "\<CR>"
    "                     endif
    "                 endfunction

    "                 " <CR> close popup and save indent or expand snippet
    "                 imap <expr> <CR> CleverCr()

    "                 " <CR>: close popup
    "                 " <s-CR>: close popup and save indent.
    "                 inoremap <expr><s-CR> pumvisible() ? neocomplcache#close_popup()."\<CR>" : "\<CR>"
    "                 "inoremap <expr><CR> pumvisible() ? neocomplcache#close_popup() : "\<CR>"

    "                 " <C-h>, <BS>: close popup and delete backword char.
    "                 inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
    "                 inoremap <expr><C-y> neocomplcache#close_popup()
    "             endif
    "             " <TAB>: completion.
    "             inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    "             inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<TAB>"
    "         " }

    "         " Enable omni completion.
    "         autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    "         autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    "         autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    "         autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    "         autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    "         autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    "         autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

    "         " Enable heavy omni completion.
    "         if !exists('g:neocomplcache_omni_patterns')
    "             let g:neocomplcache_omni_patterns = {}
    "         endif
    "         let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
    "         let g:neocomplcache_omni_patterns.perl = '\h\w*->\h\w*\|\h\w*::'
    "         let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
    "         let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'
    "         let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
    "         let g:neocomplcache_omni_patterns.go = '\h\w*\.\?'
    " " }
    " " Normal Vim omni-completion {
    " " To disable omni complete, add the following to your .vimrc.before.local file:
    " "   let g:spf13_no_omni_complete = 1
    "     elseif !exists('g:spf13_no_omni_complete')
    "         " Enable omni-completion.
    "         autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    "         autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    "         autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    "         autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    "         autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    "         autocmd FileType ruby setlocal omnifunc=rubycomplete#Complete
    "         autocmd FileType haskell setlocal omnifunc=necoghc#omnifunc

    "     endif
    " " }

    " " FIXME: Isn't this for Syntastic to handle?
    " " Haskell post write lint and check with ghcmod
    " " $ `cabal install ghcmod` if missing and ensure
    " " ~/.cabal/bin is in your $PATH.
    " if !executable("ghcmod")
    "     autocmd BufWritePost *.hs GhcModCheckAndLintAsync
    " endif

    " " indent_guides {
    "     if isdirectory(expand("~/.vim/bundle/vim-indent-guides/"))
    "         let g:indent_guides_start_level = 2
    "         let g:indent_guides_guide_size = 1
    "         let g:indent_guides_enable_on_vim_startup = 1
    "     endif
    " " }

    " " Wildfire {
    " let g:wildfire_objects = {
    "             \ "*" : ["i'", 'i"', "i)", "i]", "i}", "ip"],
    "             \ "html,xml" : ["at"],
    "             \ }
    " " }
" }}}
