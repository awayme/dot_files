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

    echo "$source_path/fish/config.fish to $target_path/.config/omf/init.fish"
    lnif "$source_path/fish/config.fish" "$target_path/.config/omf/init.fish"

    echo "$source_path/vim/init.vim to $target_path/.vimrc"
    lnif "$source_path/vim/init.vim"     "$target_path/.vimrc"

    echo "$source_path/tmux/tmux.conf to $target_path/.tmux.conf"
    lnif "$source_path/tmux/tmux.conf"   "$target_path/.tmux.conf"

    echo "$source_path/ranger to $target_path/.config/ranger"
    lnif "$source_path/ranger"   "$target_path/.config/ranger"

    echo "$source_path/ranger/rc.conf.linux to $source_path/ranger/rc.conf"
    lnif "$source_path/ranger/rc.conf.linux" "$source_path/ranger/rc.conf"

    echo "$source_path/ranger/rifle.conf.linux to $source_path/ranger/rifle.conf"
    lnif "$source_path/ranger/rifle.conf.linux" "$source_path/ranger/rifle.conf"

    echo "$source_path/sh/ranger.sh to $source_path/bin/ranger.sh"
    lnif "$source_path/sh/ranger.sh" "$source_path/bin/ranger.sh"

    if program_exists "nvim"; then
        #lnif "$source_path/.vim"       "$target_path/.config/nvim"
        #lnif "$source_path/.vimrc"     "$target_path/.config/nvim/init.vim"
        mkdir -p ~/.config/nvim/
        echo "$source_path/vim/init.vim to $target_path/.config/nvim/init.vim"
        lnif "$source_path/vim/init.vim"     "$target_path/.config/nvim/init.vim"
    fi

    ret="$?"
    success "Setting up configurtion symlinks."
    debug
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

read -p "Change shell to fish?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	change_sh
fi

#mv ~/.config/ranger ~/.config/ranger.org

read -p "symlinks all file in .dot?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
	create_symlinks     "$APP_PATH" \
			    "$HOME"
fi

#应该在1里做过了
#read -p "plug.vim" -n 1 -r
#echo    # (optional) move to a new line
#if [[ $REPLY =~ ^[Yy]$ ]]
#then
#	curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
#	    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
#fi

msg "nvim +checkhealth"
msg "nvim: Plug install"
msg "nvim +checkhealth"
#msg "CocInstall coc-python coc-emmet coc-snippets"
#msg             "\nThanks for installing $app_name."


# pdftotext mutool
