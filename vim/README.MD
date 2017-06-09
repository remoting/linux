# vim 配置
## 安装插件管理器

```
mkdir -p ~/.vim/autoload ~/.vim/bundle
curl -LSso ~/.vim/autoload/pathogen.vim https://github.com/tpope/vim-pathogen/raw/master/autoload/pathogen.vim
```
 
## 配置VIM
```
curl -LSso ~/.vimrc https://github.com/remoting/linux/raw/master/vim/.vimrc
```

## 安装插件
```
git clone --depth=1 git://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
git clone --depth=1 git://github.com/scrooloose/syntastic.git ~/.vim/bundle/syntastic
```