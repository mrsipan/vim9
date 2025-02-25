vim9script
silent! source $VIMRUNTIME/defaults.vim
set nocompatible
set autoindent
set smartindent
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
set matchtime=3
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
set shm+=I
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
set undolevels=9999


g:git_is_available = executable("git")

def g:BranchName(): string
    var parent_dir = expand("%:p:h")
    if g:git_is_available
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
# nnoremap <silent> <Leader>/ :nohlsearch<CR>/<BS>
nnoremap <silent> <Leader>/ :nohlsearch<CR>

# Switch between windows
# nmap <C-j> <C-w>j<C-w>_
# nmap <C-k> <C-w>k<C-w>_
# nmap <C-l> <C-w>l
# nmap <C-h> <C-w>h

nmap <Leader>fw :write<CR>
# sudo
# cmap w!! w !sudo tee % >/dev/null
nnoremap <Leader>fW :sudo tee % >/dev/null<CR>

nmap <silent> <Leader>fX :Vexplore!<CR>

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

g:yapf_enabled = true
g:YapfToggle = () => {
    g:yapf_enabled = !g:yapf_enabled
}
command! YapfToggle g:YapfToggle()
nnoremap <Leader>ty :YapfToggle<CR>

def g:Yapf()
    if !g:yapf_enabled
        return
    endif
    const line_nr = line('.')
    const tmpfile = tempname()
    const tmpfile_of_buffer = tempname()
    writefile(getline(1, "$"), tmpfile)
    writefile(getline(1, "$"), tmpfile_of_buffer)

    const rv_string = system(
        'isort --om'
        ..
        ' '
        ..
        tmpfile
        ..
        ' && '
        ..
        'yapf -i --style="{based_on_style: facebook, indent_closing_brackets: true, arithmetic_precedence_indication: true, no_spaces_around_selected_binary_operators: true}"'
        ..
        ' '
        ..
        tmpfile
    )

    if v:shell_error == 0
        # const target_file = expand('%')
        const _cmp = system($'cmp {tmpfile_of_buffer} {tmpfile}')
        if v:shell_error != 0
            execute "silent!" ":%!cat" tmpfile
            cursor(line_nr, 1)
        endif
    else
        throw rv_string
    endif
enddef

command! Yapf g:Yapf()
nnoremap <Leader>bf :Yapf<CR>


# Replace this with zprint
# def g:Cljfmt()
#     execute "silent!" ":!cljfmt fix %"
#     # edit!
# enddef
# command! Cljfmt g:Cljfmt()
# nnoremap <Leader>bf :Cljfmt<CR>

# def g:Zprint()
# enddef


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

# Toggle paste
# set pastetoggle='<F10>'

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

def g:DisablePaste()
    if &paste
        set nopaste
        set mouse=a
        echo 'Setting nopaste'
    endif
    # if &l:diff
    #     diffupdate
    # endif
enddef

nnoremap go :set paste!<CR>o
nnoremap gO :set paste!<CR>O

autocmd InsertLeave * call DisablePaste()

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
nnoremap g= :!git diff<CR>

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

# Go to current file dir
nnoremap <Leader>df :cd %:p:h<CR>:pwd<CR>

# Move to home dir
def g:MoveToHomeDir()
    if g:git_is_available
        system("git rev-parse --is-inside-work-tree > /dev/null")
        if v:shell_error == 0
            execute "cd" system("git rev-parse --show-toplevel")
        endif
        return
    endif

    execute "cd" "~/"
enddef

command! -bar MoveToHomeDir g:MoveToHomeDir()
nnoremap <Leader>dr :MoveToHomeDir<CR>

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

nnoremap <Leader>feR :source ~/.vimrc<CR> \| :echo "Vimrc reloaded"<CR>
nnoremap <Leader>fed :edit ~/.vimrc<CR>
nnoremap <Leader>fex :edit ~/.xonshrc<CR>

g:table_of_plugins = {
    "ctrlp": "https://github.com/ctrlpvim/ctrlp.vim.git",
    "emmet-vim": "https://github.com/mattn/emmet-vim.git",
    "sipan-theme": "https://github.com/mrsipan/vim-sipan-theme.git",
    "vim-commentary": "https://github.com/tpope/vim-commentary.git",
    "vim-cutless": "https://github.com/mrsipan/vim-cutlass.git",
    "vim-endwise": "https://github.com/tpope/vim-endwise.git",
    "vim-lsp": "https://github.com/yegappan/lsp",
    "vim-matchup": "https://github.com/andymass/vim-matchup.git",
    "vim-org": "https://github.com/mrsipan/org.vim.git",
    "vim-puppet": "https://github.com/rodjek/vim-puppet.git",
    "vim-rainbow": "https://github.com/mrsipan/rainbow_parentheses.vim.git",
    "vim-repeat": "https://github.com/tpope/vim-repeat.git",
    "vim-sexp": "https://github.com/guns/vim-sexp.git",
    "vim-surround": "https://github.com/tpope/vim-surround.git",
    "vim-elin": "https://github.com/liquidz/elin.git",
    "vim-terraform": "https://github.com/hashivim/vim-terraform.git",
    "vim-vindent": "https://github.com/jessekelighine/vindent.vim.git",
    "vim-xonsh": "https://github.com/mrsipan/vim-xonsh.git",
    "vim-yoink": "https://github.com/svermeulen/vim-yoink.git",
    # "vim-subversive": "https://github.com/svermeulen/vim-subversive.git",
}

def InstallPlugins()
    if !g:git_is_available
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
    # what?
    redraw!
enddef

command! HandleQuit g:HandleQuit()
nnoremap q :HandleQuit<CR>

def PullBusybox()
enddef

def g:RunTests()
    # save buffers
    #
    if &filetype == 'python'
        # Send to pytest
        # system('pytest -s')
        execute ":!pytest -s"
    endif
enddef
command! RunTests g:RunTests()
nnoremap <Leader>tt :RunTests<CR>

g:yoinkIncludeDeleteOperations = 1

nnoremap gm d
xnoremap gm d

nnoremap gmm dd
nnoremap gM D

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


# def NohlPre(_)
#     execute "nohlsearch"
#     redraw
# enddef

# var NohlWithDelay = () =>  timer_start(13000,  "NohlPre")
# command! Nohl NohlWithDelay()

# cnoremap <expr> <Enter> getcmdtype() =~# '[?/]' ? '<CR>:Nohl<CR>' : '<CR>'

hi MatchParen ctermbg=222 ctermfg=130 guibg=yellow
# autocmd Syntax clojure DoMatchParen
# autocmd Syntax python DoMatchParen
autocmd BufEnter *.clj,*.cljs,*.py DoMatchParen
autocmd BufLeave *.clj,*.cljs.*.py DoMatchParen

# inoremap ( ()<Left>
# inoremap [ []<Left>
# inoremap { {}<Left>
# inoremap ' ''<Left>
# inoremap " ""<Left>


g:vindent_object_XX_ii     = 'ii'
g:vindent_object_XX_ai     = 'ai'
g:vindent_object_XX_aI     = 'aI'
g:vindent_jumps            = 1

# Taken from ranger-fm examples
def g:RangerChooser()

    var is_project = false

    if g:git_is_available
        system("git rev-parse --is-inside-work-tree > /dev/null")
        if v:shell_error == 0
            execute "silent! cd" system("git rev-parse --show-toplevel")
            is_project = true
        endif
    endif

    var tmpfile = tempname()
    execute "silent! !ranger" (is_project ? "--cmd='flat -1'" : "") "--choosefiles=" .. shellescape(tmpfile)

    if !filereadable(tmpfile)
        redraw!
        return
    endif

    var _files = readfile(tmpfile)

    if empty(_files)
        redraw!
        return
    endif

    execute "edit" fnameescape(_files[0])

    # Add the others to the buff list
    for _file in slice(_files, 1)
        execute "argadd" fnameescape(_file)
    endfor
    redraw!
enddef

command! -bar RangerChooser g:RangerChooser()
nnoremap <Leader>fx :RangerChooser<CR>


var _targetfile = "/Users/e140583/tmp/arel/example/pages/page5.html"
# var _targetfile = "/tmp/page1.html"
if !empty(getenv("ORG_TO_HTML_PATH"))
    _targetfile = $ORG_TO_HTML_PATH
endif

var cmd = [
    "pandoc",
    "-f",
    "org",
    "-t",
    "html5",
    "-o",
    _targetfile,
]

# Implement this as a server
# var cmd = [
#     "org2html.sh",
#     _targetfile,
# ]

var _changedtick = -1
def OnBufferModified()
    var buf_content = join(getline(1, '$'), "\n")

    if _changedtick != b:changedtick
        # execute "silent write!" _targetfile
        var _job = job_start(cmd)
        if job_status(_job) == "fail"
            echoerr "Failed to start" join(cmd, " ")
            return
        endif

        var ch = job_getchannel(_job)
        ch_sendraw(ch, buf_content)
        # ch_close_in(ch)
        ch_close(ch)
        _changedtick = b:changedtick
    endif
    # var bufname = expand('%:p')
enddef


augroup BufferModified
    autocmd!
    autocmd TextChanged,TextChangedI *.org OnBufferModified()
augroup END

if argc() == 0
    execute "silent! RangerChooser"
    redraw!
endif

g:elin_enable_default_key_mappings = true


g:cljstyle_enabled = true
g:CljstyleToggle = () => {
    g:cljstyle_enabled = !g:cljstyle_enabled
    if g:cljstyle_enabled
        echo "Cljstyle enabled"
    else
        echo "Cljstyle disabled"
    endif
}

command! CljstyleToggle g:CljstyleToggle()
nnoremap <Leader>tj :CljstyleToggle<CR>

def g:Cljstyle()
    if !g:cljstyle_enabled
        return
    endif
    const line_n = line('.')
    const tmpfile = tempname() .. '.cljs'
    const tmpfile_of_buffer = tempname() .. 'cljs'
    writefile(getline(1, "$"), tmpfile)
    writefile(getline(1, "$"), tmpfile_of_buffer)

    const rv_string = system(
        'cljstyle fix'
        ..
        ' '
        ..
        tmpfile
    )

    if v:shell_error == 0
        # const target_file = expand('%')
        const _cmp = system($'cmp {tmpfile_of_buffer} {tmpfile}')
        if v:shell_error != 0
            execute "silent!" ":%!cat" tmpfile
            cursor(line_n, 1)
        endif
    else
        throw rv_string
    endif
enddef

command! Cljstyle g:Cljstyle()
# nnoremap <Leader>bf :Cljstyle<CR>

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

    if executable("yapf") && executable("isort")
        # autocmd BufWritePost *.py silent! !yapf -i --style='{based_on_style: facebook, indent_closing_brackets: true}' %
        # autocmd BufWritePre *.py silent :%!yapf --style='{based_on_style: facebook, indent_closing_brackets: true}'
        autocmd BufWritePre *.py Yapf
    endif

    if executable("cljstyle")
        autocmd BufWritePre *.cljs Cljstyle
    endif

    autocmd BufNewFile,BufRead Jenkinsfile setlocal filetype=groovy

endif
