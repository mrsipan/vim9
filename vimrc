vim9script
silent! source $VIMRUNTIME/defaults.vim
set nocompatible
set autoindent
set background=dark
set backspace=indent,eol,start
set cinoptions=:0,l1,g0,t0,+.5s,(.5s,u0,U1,j1
set encoding=utf-8
set history=999
set incsearch
set listchars=tab:>-,trail:-
set modelines=5
set printoptions=paper:letter
set ruler
set showcmd
set showmatch
set showmode
set spelllang=en_us
set nonumber
set wildmenu wildmode=list:longest,full
set laststatus=2
set tabpagemax=20
set splitright
set splitbelow
set hidden
set autoread
set wildignore=*.so,*.swp,*.zip
# Get rid of screen flash and beep
set noerrorbells
set visualbell t_vb=
# Ignore case in a pattern
set ignorecase
set smartcase
set clipboard+=unnamed
set nofoldenable
set listchars=eol:⏎,tab:␉·,trail:␠,nbsp:⎵
set winminheight=0
set winminwidth=0
&shell = executable("dash") ? "dash" : "sh"
# set hlsearch


var _backupdir = $HOME .. '/.vim/tmp/bkp'

def ReverseString(str: string): string
    var _reversed = ""
    for idx in range(len(str), 0, -1)
        _reversed ..= str[idx]
    endfor
    return _reversed
enddef

if !isdirectory(_backupdir)
    try
        mkdir(_backupdir, "p")
    catch
        var tmpdir = "/tmp"
        if !empty(getenv("TMPDIR"))
            tmpdir = $TMPDIR
        endif
        echo "Using" .. " " .. tmpdir
        _backupdir = tmpdir .. ReverseString($USER)
        mkdir(_backupdir)
    endtry
endif
&backupdir = _backupdir
set backup

var _undodir = $HOME .. '/.vim/tmp/undo'
if !isdirectory(_undodir)
    try
        mkdir(_undodir, "p")
    catch
        var tmpdir = "/tmp"
        if !empty(getenv("TMPDIR"))
            tmpdir = $TMPDIR
        endif
        echo Using .. " " .. tmpdir
        _undodir = tmpdir .. ReverseString($USER)
        mkdir(_undodir, "p")
    endtry
endif
&undodir = _undodir
set undofile

g:git_present = executable("git")

def g:BranchName(): string
    var parent_dir = expand("%:p:h")
    if g:git_present
        var cmd = join(
            [
            "git -C",
            parent_dir,
            "rev-parse 2>/dev/null",
            ],
            " ",
        )
        system(cmd)
    endif

    if v:shell_error == 0
        return split(system($"git rev-parse --abbrev-ref HEAD {parent_dir}"), "\n")[0]
    else
        return ""
    endif
enddef

set statusline=%<\%n:%F\ %m%r%y%=%-10.(%{"nogit"}\ L:\%l/%L\ C:\%c%V\ %P%)
# set statusline=%<\%n:%F\ %m%r%y%=%-10.(%{g:BranchName()}\ L:\%l/%L\ C:\%c%V\ %P%)
nnoremap <silent> gI :set invlist<CR>

# Use syntax highlighting when terminal allows it
if str2nr(&t_Co) > 2
    syntax on
endif

var _scheme = "sipan"
try
    execute "silent!" "colorscheme" _scheme
finally
endtry

g:mapleader = "\<Space>"
g:maplocalleader = "9"

# Mapping for spell checker
nnoremap <Leader>cs :up<CR>:!ispell -x %<CR>:edit!<CR>

# Mapping to switch off search highlighting
nnoremap <silent> <Leader>/ :nohlsearch<CR>/<BS>

# Switch between windows
# nmap <C-j> <C-w>j<C-w>_
# nmap <C-k> <C-w>k<C-w>_
# nmap <C-l> <C-w>l
# nmap <C-h> <C-w>h

nmap <Leader>fw :write<CR>
# sudo
# cmap w!! w !sudo tee % >/dev/null
nnoremap <Leader>fW :sudo tee % >/dev/null<CR>

nmap <silent> <Leader>fx :Vexplore!<CR>

# Just quit
nmap Q :q<CR>

# Make <Enter> in normal mode go down half a page
nnoremap <Enter> <C-d>
nnoremap <BS> <C-u>
# nnoremap <C-h> <C-u>

# ultisnips is overriden this:
vnoremap <Enter> <C-d>
# autocmd VimEnter * vmap <Tab> <C-d>
vnoremap <BS> <C-u>

# CtrlP to open buffers and files
nnoremap <Leader>bb :CtrlPBuffer<CR>
# nnoremap <Leader>bF :PrettyFormat<CR>
nnoremap <Leader>bk :bdel<CR>
nnoremap <Leader>fh :CtrlP ~<CR>
nnoremap <Leader>fd :CtrlP

nnoremap <Leader>fR :CtrlPClearCache<CR>

nnoremap <Leader>lp :lprevious<CR>
nnoremap <Leader>ln :lnext<CR>
nnoremap <Leader>lP :lfirst<CR>
nnoremap <Leader>lN :llast<CR>

g:ctrlp_map = '<Leader>ff'
g:ctrlp_cmd = 'CtrlP'
g:ctrlp_working_path_mode = 'ra'
g:ctrlp_show_hidden = 1


g:ctrlp_custom_ignore = {
    'dir': '\v[\/]\.(git|hg|svn)$|develop-eggs$|eggs$|Library$',
    'file': '\v\.(exe|so|dll|iso|tar\.gz|pdf|ps|jpeg|jpg|png|rpm|mp3|epub|chm|tmp|pyo|pyc|elc|old|dmg|xcf)$',
  }

# Help other people with your file if layout is not default
iabbrev MODELINE vi:set sw=4 ts=4 sts=0 noet:<Esc>

def g:Yapf()
    const lnr = line('.')
    const tmpfile = tempname()
    writefile(getline(1, "$"), tmpfile)
    const rv_string = system(
        'yapf -i --style="{based_on_style: facebook, indent_closing_brackets: true, arithmetic_precedence_indication: true, no_spaces_around_selected_binary_operators: true}"'
        ..
        ' '
        ..
        tmpfile
    )

    if v:shell_error == 0
        execute "silent!" ":%!cat" tmpfile
        cursor(lnr, 1)
    else
        throw rv_string
    endif
enddef

command! Yapf g:Yapf()
nnoremap <Leader>bf :Yapf<CR>

# Replace this with zprint
def g:Cljfmt()
    execute "silent!" ":!cljfmt fix %"
    # edit!
enddef
command! Cljfmt g:Cljfmt()
# nnoremap <Leader>bf :Cljfmt<CR>

def g:Zprint()

enddef

if has("autocmd")
    filetype plugin indent on

    # In text files, always limit the width of text to 72 characters.
    autocmd FileType org,text,nroff setlocal tw=72
    autocmd FileType tex,docbk,html,sgml,xhtml,xml setlocal sw=2 sts=2 et tw=72
    autocmd FileType html,xhtml hi htmlItalic term=underline cterm=underline
    # Java, JavaScript, Perl, Python and Tcl indent.
    autocmd FileType java,javascript,perl,python,tcl,vim,groovy,julia,xonsh
       \ setlocal sw=4 sts=4 et
    autocmd FileType python b:dispatch = 'pytest %'
    autocmd FileType go setlocal tabstop=3
    # Expand tab in Scheme and Lisp to preserve alignment.
    autocmd FileType lisp,scheme setlocal et
    # Python doctest indent.
    autocmd FileType rst,cfg,org setlocal sw=4 sts=4 et tw=72
    # Yaml
    autocmd FileType yml,yaml,json setlocal tabstop=2 sw=2 sts=2 et
    # Shell scripts
    autocmd FileType cpp,sh,spec,clj,lua,pp,rs,Dockerfile setlocal tabstop=2 sw=2 et

    # Remove trailing whitespaces on save
    autocmd BufWritePre * :%s/\s\+$//e
    # autocmd BufWritePre
    #    \ *.vim,*.py,*.org,*.rst,*.txt,*.clj,*.cljs,*.js,*.sh,*.rb,*.scala,*.groovy,Dockerfile :%s/\s\+$//e

    # # Replace this with zprint and use a tmpfile
    # if executable("cljfmt")
    #     autocmd BufWritePost *.cljs g:Cljfmt()
    # endif

    if executable("yapf")
        # autocmd BufWritePost *.py silent! !yapf -i --style='{based_on_style: facebook, indent_closing_brackets: true}' %
        # autocmd BufWritePre *.py silent :%!yapf --style='{based_on_style: facebook, indent_closing_brackets: true}'
        autocmd BufWritePre *.py Yapf
    endif
    autocmd BufNewFile,BufRead Jenkinsfile setlocal filetype=groovy

endif

# ctrl-u in insert mode deletes a lot. use ctrl-g u to first break undo
# so that you can undo ctrl-u after inserting a new line
inoremap <c-u> <c-g>u<c-u>
inoremap <c-w> <c-g>u<c-w>

&mouse = has("mouse") ? "a" : ""

# Convenient command to see the diff between the current buffer and
# the file it has loaded from, thus the change you made. Only define it
# when not defined already.
if !exists(":DiffDiskFile")
    command DiffDiskFile vert new | set bt=nofile | r # | 0d_ | diffthis
                \ | wincmd p | diffthis
endif

# do not set cursor line in netrw
g:netrw_cursor = 0

# Settings for clojure
g:clojure_align_multiline_strings = 1

autocmd Syntax clojure RainbowParenthesesLoadRound
autocmd Syntax clojure RainbowParenthesesLoadSquare
autocmd Syntax clojure RainbowParenthesesLoadBraces
# autocmd Syntax clojure RainbowParenthesesLoadChevrons
autocmd BufEnter *.clj,*.cljs RainbowParenthesesToggle
autocmd BufLeave *.clj,*.cljs RainbowParenthesesToggle

g:rbpt_colorpairs = [
    ['102', '#8c8c8c'],
    ['110', '#93a8c6'],
    ['143', '#b0b1a3'],
    ['108', '#97b098'],
    ['146', '#aebed8'],
    ['145', '#b0b0b3'],
    ['110', '#90a890'],
    ['148', '#a2b6da'],
    ['145', '#9cb6ad']
]

g:rbpt_types = [['(', ')'], ['\[', '\]'], ['{', '}']]

g:rbpt_max = 16
# let g:rbpt_loadcmd_toggle = 0

# toggle paste
set pastetoggle=<F9>

# completion in ex mode
if exists("&wildignorecase")
    set wildignorecase
endif
if exists("&fileignorecase")
    set fileignorecase
endif


# store yankring history file in tmp
g:yankring_history_dir = '$HOME/.vim/tmp'

# Reload file
nnoremap gR :edit! \| :redraw! \| :echo 'File reloaded'<CR>

# Paste and go to end
vnoremap <silent> y y`]
vnoremap <silent> p p`]
nnoremap <silent> p p`]

# Highlight last insert
nnoremap gV `[v`]

highlight ExtraWhitespace ctermbg=188 guibg=#d2d2d2
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

if executable('rg')
    set grepprg=rg\ --no-heading\ --color=never
    g:ctrlp_user_command = 'rg --no-heading --color=never --files'
    g:gitgutter_grep_command = 'rg --no-heading --color=never'
elseif executable('pss')
    grepprg=pss\ --noheading\ --nocolor
    g:ctrlp_user_command = 'pss --ignore-dir="eggs,site-packages,_tmp,.cache" --noheading --nocolor -f'
    g:gitgutter_grep_command = 'pss --noheading --nocolor'
endif

g:gitgutter_sign_modified = '≠'
g:gitgutter_sign_modified_removed = '±'
g:gitgutter_enabled = 0

nnoremap gGg :GitGutterToggle<CR>
nnoremap gGb :Gblame<CR>

nnoremap <Leader>q @q

g:terraform_fmt_on_save = 1

nnoremap <silent> <Leader>cp :cprev<CR>
nnoremap <silent> <Leader>cn :cnext<CR>
nnoremap <silent> <Leader>cN :clast<CR>
nnoremap <silent> <Leader>cP :cfirst<CR>
nnoremap <silent> <Leader>cc :cclose<CR>
nnoremap <silent> <Leader>co :copen<CR>

nnoremap <silent> <Leader>lp :lprev<CR>
nnoremap <silent> <Leader>ln :lnext<CR>
nnoremap <silent> <Leader>lP :lfirst<CR>
nnoremap <silent> <Leader>lN :llast<CR>
nnoremap <silent> <Leader>lc :lclose<CR>
nnoremap <silent> <Leader>lo :lopen<CR>

g:sexp_mappings = {
    'sexp_emit_head_element': '<LocalLeader>w',
    'sexp_emit_tail_element': '<LocalLeader>e',
    'sexp_capture_prev_element': '<LocalLeader>a',
    'sexp_capture_next_element': '<LocalLeader>f',
    }

nnoremap <Leader>Y "+y
vnoremap <Leader>Y "+y

autocmd BufRead,BufNewFile *.confluencewiki set filetype=confluencewiki

nnoremap <Leader>So :set filetype=org<CR>
nnoremap <Leader>Sy :set filetype=python<CR>
nnoremap <Leader>Sc :set filetype=clojure<CR>

g:yankring_map_dot = 0

# Go home
nnoremap <Leader>dc :cd %:p:h<CR>:pwd<CR>

# To work with kitty
if !has('gui_running')
    # Set the terminal default background and foreground colors, thereby
    # improving performance by not needing to set these colors on empty cells.
    hi Normal guifg=NONE guibg=NONE ctermfg=NONE ctermbg=NONE
    &t_ti = &t_ti .. "\033]10;##dddddd\007\033]11;##303030\007"
    &t_te = &t_te .. "\033]253\007\033]236\007"
endif

# command! InsertToday call Insert_today()
# nnoremap <Leader>it :InsertToday<CR>

# highlight DoneCheck ctermfg=194

g:iced_enable_default_key_mappings = true

g:org_target = "cat"

def OrgBlogger()
    if !(&filetype == "org")
        return
    endif

    var [p1, p2] = [
        search("^* ", "bnc"),
        search("^* ", "nc", line("$")),
    ]
    p2 = (p2 == 0 ? line("$") : (p2 - 1))

    var buf = join(getline(p1, p2), "\n")
    echo system($"printf '{buf}' | {g:org_target}")
enddef

command! OrgBlogger OrgBlogger()
nnoremap <Leader>bB :OrgBlogger<CR>

nnoremap <Leader>fer :source ~/.vimrc<CR> \| :echo "Vimrc reloaded"<CR>
nnoremap <Leader>fed :edit ~/.vimrc<CR>

g:table_of_plugins = {
    "ctrlp": "https://github.com/ctrlpvim/ctrlp.vim.git",
    "sipan-theme": "https://github.com/mrsipan/vim-sipan-theme.git",
    "emmet-vim": "https://github.com/mattn/emmet-vim.git",
    "vim-commentary": "https://github.com/tpope/vim-commentary.git",
    "vim-cutless": "https://github.com/svermeule/vim-cutlass.git",
    "vim-endwise": "https://github.com/tpope/vim-endwise.git",
    "vim-iced": "https://github.com/liquidz/vim-iced.git",
    "vim-lsp": "https://github.com/yegappan/lsp",
    "vim-matchup": "https://github.com/andymass/vim-matchup.git",
    "vim-org": "https://github.com/mrsipan/org.vim.git",
    "vim-rainbow": "https://github.com/mrsipan/rainbow_parentheses.vim.git",
    "vim-repeat": "https://github.com/tpope/vim-repeat.git",
    "vim-sexp": "https://github.com/guns/vim-sexp.git",
    "vim-subversive": "https://github.com/svermeulen/vim-subversive.git",
    "vim-surround": "https://github.com/tpope/vim-surround.git",
    "vim-terraform": "https://github.com/hashivim/vim-terraform.git",
    "vim-xonsh": "https://github.com/mrsipan/vim-xonsh.git",
    "vim-yoink": "https://github.com/svermeulen/vim-yoink.git",
}

def InstallPlugins()
    if !g:git_present
        echoerr "Git not present on system"
    endif
    var start_dir = expand("~/.vim/pack/plugins/start")

    if !isdirectory(start_dir)
        mkdir(start_dir, "p")
    else
        echo "Start dir already a directory"
    endif

    for [plugin_name, gitloc] in items(g:table_of_plugins)
        var plugin_dir = start_dir .. "/" .. plugin_name
        if !isdirectory(plugin_dir)
            echo $"Pulling plugin {plugin_name}"
            echo system($"git clone {gitloc} {plugin_dir}")
        else
            echo $"Plugin directory {plugin_name} present"
        endif
    endfor
enddef

command! InstallPlugins InstallPlugins()

def g:HandleQuit()
    # Make it if functional
    for nr in range(1, bufnr("$"))
        if bufexists(nr)
            var filetype = getbufvar(nr, '&filetype')
            if filetype == "help"
                helpclose
                return
            endif
        endif
    endfor
enddef

command! HandleQuit g:HandleQuit()
nnoremap q :HandleQuit<CR>

def PullBusybox()
enddef

g:yoinkIncludeDeleteOperations = 1

nnoremap m d
xnoremap m d

nnoremap mm dd
nnoremap M D

g:matchup_matchparen_enabled = 0
g:matchup_surround_enabled = 1

def g:ExecBuffer()
    if index(["xsh", "xonsh"], &filetype) >= 0
        write !xonsh
    elseif &filetype == 'python'
        # Send to pytest
        write !pytest
    endif
enddef

command! ExecBuffer g:ExecBuffer()
nnoremap gx :ExecBuffer<CR>

set hlsearch

# g:user_emmet_install_global = 0
# autocmd FileType html,css EmmetInstall

