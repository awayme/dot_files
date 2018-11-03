#!/usr/bin/env bash

############################  SETUP PARAMETERS
app_name='dotfiles'
[ -z "$APP_PATH" ] && APP_PATH="$HOME/.dot_files"
[ -z "$REPO_URI" ] && REPO_URI='https://github.com/awayme/dot_files.git'
[ -z "$REPO_BRANCH" ] && REPO_BRANCH='master'
debug_mode='0'
#[ -z "$VUNDLE_URI" ] && VUNDLE_URI="https://github.com/VundleVim/Vundle.vim.git"
[ -z "$RANGER_URI" ] && RANGER_URI="https://github.com/ranger/ranger.git"

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

create_symlinks() {
    local source_path="$1"
    local target_path="$2"

    lnif "$source_path/fish/config.fish" "$target_path/.config/omf/init.fish"
    lnif "$source_path/vim/init.vim"     "$target_path/.vimrc"
    lnif "$source_path/tmux/tmux.conf"   "$target_path/.tmux.conf"

    lnif "$source_path/ranger"   "$target_path/.config/ranger"
    lnif "$source_path/ranger/rc.conf.linux" "$source_path/ranger/rc.conf"
    lnif "$source_path/ranger/rifle.conf.linux" "$source_path/ranger/rifle.conf"

    #if program_exists "nvim"; then
    #    lnif "$source_path/.vim"       "$target_path/.config/nvim"
    #    lnif "$source_path/.vimrc"     "$target_path/.config/nvim/init.vim"
    #fi

    ret="$?"
    success "Setting up configurtion symlinks."
    debug
}

install_widgets() {
    sudo apt-add-repository ppa:fish-shell/release-2
    sudo add-apt-repository ppa:aacebedo/fasd
    sudo add-apt-repository ppa:x4121/ripgrep
    
    sudo apt-get update
    sudo apt-get install vim fish fasd ripgrep 

    wget https://github.com/sharkdp/fd/releases/download/v7.2.0/fd_7.2.0_amd64.deb
    sudo dpkg -i fd_7.2.0_amd64.deb
    rm fd_7.2.0_i386.deb
    
    sync_repo           "$HOME/bin/ranger" \
                        "$RANGER_URI" \
                        "master" \
                        "ranger"

    mv ~/.config/ranger ~/.config/ranger.org

                        #"--depth 1 https://github.com/junegunn/fzf.git" \
    sync_repo           "$HOME/.fzf" \
                        "https://github.com/junegunn/fzf.git" \
                        "master" \
                        "fzf"
    cd ~/.fzf
    ./install

    mkdir -p ~/.config/vimfiles/persistence
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
            https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    curl -L https://get.oh-my.fish > install
    fish install 
    rm install 
}

change_sh() {
    sh=`cat /etc/shells | grep /usr/bin/fish`
    if [ "/usr/bin/fish"x = "$sh"x ]; then
        if [ "/usr/bin/fish"x != "$SHELL"x ]; then
            chsh -s /usr/bin/fish
        fi
    else
        msg "You need to install fish."
    fi
}
############################ MAIN()
variable_set "$HOME"
program_must_exist "vim"
program_must_exist "git"

#do_backup           "$HOME/.vim" \
#                    "$HOME/.vimrc" \
#                    "$HOME/.tmux.conf"\
#                    "$HOME/.zshrc"

sync_repo           "$APP_PATH" \
                    "$REPO_URI" \
                    "$REPO_BRANCH" \
                    "$app_name"


install_widgets

change_sh

create_symlinks     "$APP_PATH" \
                    "$HOME"

msg "omf install fasd"
msg "vim: Plug install"
msg             "\nThanks for installing $app_name."
