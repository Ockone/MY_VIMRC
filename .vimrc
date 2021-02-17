" ********** 基础设置 **********
set nocompatible            " 不与vi兼容
set enc=utf-8               " 虽然Unix-like系统缺省utf-8，但移植到其他地方可能出错
set fileencodings=ucs-bom,utf-8,gb18030,latin1 " 为了适应中文编码

set number                  " 显示行号
set expandtab               " 将制表符Tab展开为空格，这对Python尤其有用
set tabstop=4               " 输入Tab时转化为4空格；打开文件时Tab显示为4空格
set backspace=2             " 在多数终端上修正退格键Backspace的行为
filetype plugin indent on   " 启用根据文件类型自动缩进
set autoindent              " 开始新行时处理缩进
set shiftwidth=4            " 用于自动缩进的空格数

set cursorline              " 高亮光标所在行
set hidden                  " 允许不保存当前文件，转而编辑其他文件（默认必须写入再换文件）

set foldmethod=indent       " 设置代码折叠方式：基于缩进；但它默认打开的所有文件处于缩进状态
autocmd BufRead * normal zR " 针对上一行代码，使打开的文件默认代码展开


" ********** 交换文件与历史记录 **********
if !isdirectory($HOME."/.vim/swap")
    call mkdir($HOME."/.vim/swap", 'p')
endif
set directory=$HOME/.vim/swap//     " 将交换文件集中放置，防止污染文件系统
set nobackup                    " set backup使每一次编辑文件都会保存上一次的备份文件；设置了撤销文件，就不需要保存文件备份了
set undofile                    " 为所有文件设置持久性撤销              
if !isdirectory($HOME."/.vim/undodir")
    call mkdir($HOME."/.vim/undodir", 'p')
endif
set undodir=$HOME/.vim/undodir//


" ********** Vim快捷键映射 **********
" 使用<Ctrl> + hjkl快速窗口间跳动
noremap <c-h> <c-w><c-h>
noremap <c-j> <c-w><c-j>
noremap <c-k> <c-w><c-k>
noremap <c-l> <c-w><c-l>
" 关闭缓冲区而不关闭窗口；这一段不理解(2021/1/23)
command! Bd :bp | :sp | :bn | :bd


" ********** 插件管理器vim-plug **********
" 如果没有安装过vim-plug，则立刻安装；但是如今(2021/1/22)raw.github.com域名被污染，无法访问
if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
                \https://raw.github.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
" ********** vim-plug添加新插件 **********
call plug#begin('~/.vim/plugged')   " Plugins will be downloaded under the specified directory.
Plug 'yianwillis/vimcdoc'           " 中文文档
Plug 'vim-airline/vim-airline'      " 花哨的状态栏工具
Plug 'Yggdroot/indentLine'          " 缩进线插件
Plug 'luochen1990/rainbow'          " 分层次括号彩色插件
Plug 'scrooloose/nerdtree'          " 提供类似于IDE的文件目录视图
Plug 'tpope/vim-unimpaired'         " 将一些常用Vim命令映射为简单的快捷键
Plug 'tpope/vim-fugitive'           " Git与Vim整合插件
Plug 'jiangmiao/auto-pairs'         " 括号、引号匹配工具
Plug 'preservim/nerdcommenter'      " 注释插件
Plug 'morhetz/gruvbox'              " 一款广受好评的配色方案
Plug 'neoclide/coc.nvim',{'branch':'release'}   " 实现类似于VScode的插件管理
call plug#end()                     " List ends here. Plugins become visible to Vim after this call.
" 对于插件的调用和配置最好放在这之后，不然可能出现Bug


" ********** 主题与字体 **********
syntax on                   " 支持语法高亮显示
colorscheme gruvbox         " 修正配色方案，默认有很多种主题可选
set background=dark         " 暗色主题
" 终端真彩设置;默认Vim认为终端模拟器只支持8色，会导致配色达不到预期效果
if has('termguicolors') &&
      \($COLORTERM == 'truecolor' || $COLORTERM == '24bit')
  set termguicolors
endif


" ********** 状态栏插件vim-airline配置 **********
set laststatus=2                                       " 总是显示状态栏；默认情况下，有时会隐藏
let g:airline_powerline_fonts = 1                      " 启用powerline字体，以显示特殊符号
let g:airline#extensions#tabline#enabled = 1           " 启用tabline扩展，在顶部显示缓冲区列表
let g:airline#extensions#tabline#buffer_nr_show = 1    " 令tabline显示缓冲区号 
let g:airline#extensions#tabline#overflow_maker = '…'  " 用中文字符“…”作为tabline中省略符
let g:airline#extensions#tabline#show_tab_nr = 0       " 不在tabline显示标签页编号，以免与缓冲区编号混乱


" ********** 目录插件NERDTree设置 **********
autocmd VimEnter * NERDTree         " Vim启动时打开NERDTree
let NERDTreeShowBookmarks = 1       " 启动NERDTree时显示书签
" 当NERDTree窗口是最后一个窗口时自动关闭；默认时NERDTree也是一个窗口需要手动关闭
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") &&
            \b:NERDTree.isTabTree()) | q | endif


" ********** 自动补全插件coc.nvim+clangd设置 **********
" 迁移vim后自动导入Coc插件
let g:coc_global_extensions = [
            \ 'coc-clangd',
            \ 'coc-json',
            \ 'coc-java',
            \ 'coc-python']
" 91-101行，设置Coc使用<Tab>健补全;否则,你按<Tab>它真的会输入一个'\t'
inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"
" 方法check_back_space()
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction


" ********** 括号自动补全插件auto-pairs **********
let g:AutoPairs = {'(':')', '[':']', '{':'}',"'":"'",'"':'"'}    " 设置要自动匹配的符号
let g:AutoPairsShortcutToggle = '<M-p>'                          " 设置打开/关闭插件快捷键默认Alt+P
let g:AutoPairsFlyMode = 1                                       " 启用Fly模式，默认为0
let g:AutoPairsShortcutBackInsert = '<M-b>'                      " 设置撤销飞行模式的快捷键，默认为Alt+b
let g:AutoPairsMultilineClose = 1                                " 启用跳出多行括号对;默认为1，为0则只能跳出同一行的括号
let g:AutoPairsMapCR = 1                                         " 把ENTER键映射为换行并缩进，默认为1
let g:AutoPairsCenterLine = 1                                    " 当g:AutoPairsMapCR为1时，且文本位于窗口底部时，自动移到窗口中间


" ********** 缩进线插件indentLine**********
let g:indentLine_enabled = 1                   " 默认启用indentLine
let g:indentLine_char='¦'                      " 设置缩进线字符


" ********** 彩色括号插件rainbow **********
 let g:rainbow_active = 1                      " 启用rainbow，默认0（不启用）
