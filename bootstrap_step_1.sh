#!/usr/bin/env bash

############################  SETUP PARAMETERS
app_name='dotfiles'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.dot_files"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/awayme/dot_files.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='master'
debug_mode='0'
#[ -z "$VUNDLE_URI" ] && VUNDLE_URI="https://github.com/VundleVim/Vundle.vim.git"
[ -z "$RANGER_URI" ] && RANGER_URI="https://github.com/ranger/ranger.git"

apps="neovim universal-ctags fish fasd ripgrep lazygit highlight atool bsdtar mediainfo odt2txt cmake"

############################  BASIC SETUP TOOLS
msg() {
    printf '%b\n' "$1" >&2
}

success() {
    if [ "$ret" -eq '0' ]; then
        msg "\33[32m[✔]\33[0m ${1}${2}"
    fi
}

error() {
    msg "\33[31m[✘]\33[0m ${1}${2}"
    exit 1
}

debug() {
    if [ "$debug_mode" -eq '1' ] && [ "$ret" -gt '1' ]; then
        msg "An error occurred in function \"${FUNCNAME[$i+1]}\" on line ${BASH_LINENO[$i+1]}, we're sorry for that."
    fi
}

program_exists() {
    local ret='0'
    command -v $1 >/dev/null 2>&1 || { local ret='1'; }

    # fail on non-zero return value
    if [ "$ret" -ne 0 ]; then
        return 1
    fi

    return 0
}

program_must_exist() {
    program_exists $1

    # throw error on non-zero return value
    if [ "$?" -ne 0 ]; then
        error "You must have '$1' installed to continue."
    fi
}

variable_set() {
    if [ -z "$1" ]; then
        error "You must have your HOME environmental variable set to continue."
    fi
}

lnif() {
    if [ -e "$1" ]; then
        ln -sf "$1" "$2"
    fi
    ret="$?"
    debug
}

############################ SETUP FUNCTIONS

do_backup() {
    if [ -e "$1" ] || [ -e "$2" ] || [ -e "$3" ] || [ -e "$4" ]; then
        msg "Attempting to back up your original configuration."
        today=`date +%Y%m%d_%s`
        for i in "$1" "$2" "$3" "$4"; do
            [ -e "$i" ] && [ ! -L "$i" ] && mv -v "$i" "$i.$today";
        done
        ret="$?"
        success "Your original configuration has been backed up."
        debug
   fi
}

sync_repo() {
    local repo_path="$1"
    local repo_uri="$2"
    local repo_branch="$3"
    local repo_name="$4"

    msg "Trying to update $repo_name"

    if [ ! -e "$repo_path" ]; then
        mkdir -p "$repo_path"
        git clone -b "$repo_branch" "$repo_uri" "$repo_path"
        ret="$?"
        success "Successfully cloned $repo_name."
    else
        cd "$repo_path" && git pull origin "$repo_branch"
        ret="$?"
        success "Successfully updated $repo_name"
    fi

    debug
}

install_widgets() {
    read -p "Install $apps?[y/n] " answer
    while true
    do
      case $answer in
       [yY]* ) echo "================================"

	       #sudo add-apt-repository ppa:hnakamur/universal-ctags -y
               sudo add-apt-repository ppa:lazygit-team/release -y
               #sudo apt-add-repository ppa:fish-shell/release-2 -y
               #sudo add-apt-repository ppa:x4121/ripgrep -y
               #sudo apt-add-repository ppa:neovim-ppa/stable -y

               sudo apt-get update

               sudo apt-get install $apps -y

	       #fd_deb=fd_7.3.0_amd64.deb
               #wget "https://github.com/sharkdp/fd/releases/download/v7.3.0/$fd_deb"
               #sudo dpkg -i $fd_deb
               #rm $fd_deb

               break;;

       [nN]* ) break;;
               # exit;;

       * )     echo "Dude, just enter Y or N, please."; break ;;
      esac
    done

    read -p "Install ranger?[y/n] " answer
    while true
    do
      case $answer in
       [yY]* ) echo "================================"
	       sync_repo        "$HOME/bin/ranger" \
	           		"$RANGER_URI" \
	           		"master" \
	           		"ranger"

	       mkdir -p ~/.config/ranger/
	       mv ~/.config/ranger ~/.config/ranger.org

           break;;

       [nN]* ) break;;
       * )     echo "Dude, just enter Y or N, please."; break ;;
      esac
    done

    read -p "Install fzf?[y/n] " answer
    while true
    do
      case $answer in
       [yY]* ) echo "================================"
                        #"--depth 1 https://github.com/junegunn/fzf.git" \
	       sync_repo           "$HOME/.fzf" \
	           		"https://github.com/junegunn/fzf.git" \
	           		"master" \
	           		"fzf"
	       ~/.fzf/install
               break;;

       [nN]* ) break;;
       * )     echo "Dude, just enter Y or N, please."; break ;;
      esac
    done

    read -p "Install vim/nvim-plug?[y/n] " answer
    while true
    do
      case $answer in
       [yY]* ) echo "================================"
	       mkdir -p ~/.config/vimfiles/persistence
           mkdir -p ~/.config/nvim/autoload
	       curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
	   	   https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

           cd ~/.config/nvim/autoload 
           ln -s ~/.vim/autoload/plug.vim

           cd ~/.config/nvim/
           virtualenv env2
           python3 -m venv env3
           env2/bin/pip install -U pip
           env2/bin/pip install pynvim neovim
           env3/bin/pip install -U pip
           env3/bin/pip install pynvim neovim jedi

           sudo gem install neovim
           # sudo npm install -g neovim
           # curl --compressed -o- -L https://yarnpkg.com/install.sh | bash

           break;;

       [nN]* ) break;;
       * )     echo "Dude, just enter Y or N, please."; break ;;
      esac
    done
}

############################ MAIN()
variable_set "$HOME"
#program_must_exist "vim"
program_must_exist "git"

#do_backup           "$HOME/.vim" \
#                    "$HOME/.vimrc" \
#                    "$HOME/.tmux.conf"\
#                    "$HOME/.zshrc"

echo "$app_name:"
read -p "Clone $REPO_URI into $APP_PATH? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]] 
then 
	sync_repo           "$APP_PATH" \
			    "$REPO_URI" \
			    "$REPO_BRANCH" \
			    "$app_name"
fi

read -p "Install personal tools?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]] 
then 
	install_widgets
fi

msg "DO THIS MANUALLY, THEN RUN BOOTSTRAP 2"
msg "curl -L https://get.oh-my.fish | fish"
msg "omf install fasd"
