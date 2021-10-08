#source /usr/local/etc/fish/config.fish
#source /usr/share/fish/config.fish

set -x EDITOR vim
set -x LANG 'en_US.UTF-8'
set -x LC_TIME 'en_US.UTF-8'
set -x LC_CTYPE 'en_US.UTF-8'

fish_vi_key_bindings

# will cause title issue in iTerm2
function fish_title
    # echo $argv[1]
    # echo $_ ' '
    if [ $RANGER_LEVEL ]
        printf '[Ranger]'
    end

    echo $argv
    printf ' | %s' (prompt_pwd)
end

function tree
    find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
end

# function j
#     set new_path (autojump $argv)

#     if test -d "$new_path"
#         echo $new_path
#         cd "$new_path"
#     else
#         echo "autojump: directory '$argv' not found"
#         echo "Try \`autojump --help\` for more information."
#         false
#     end
# end
#
alias supervisorctl "supervisorctl -c /usr/local/etc/supervisor/supervisord.conf"

function v
    source (string trim -r -c / $argv[1])/bin/activate.fish
    # if set -q argv[2] 
    #     echo $argv[2]
    # end
end

function ve
    source env/bin/activate.fish
end

# function vetimecamp
#     cd ~/Projects/Self-productive
#     ve
#     cd timecamp
# end

# function vescrpits
#     cd ~/Data/My_Scripts/scripts/
#     ve
#     cd scripts
# end
function anaconda
    # set -gx PATH /opt/anaconda2/bin $PATH 
    # set -gx PATH /usr/local/opt/anaconda2/bin/ $PATH
    set -gx PATH ~/bin/anaconda3/bin/ $PATH
end

function calculator
    anaconda
    cd ~/Data/notebooks
    jupyter-notebook calculator.ipynb
end

function notebook
    anaconda
    cd ~/Data/notebooks
    jupyter-notebook
end

function mosht
    mosh --no-init -- $argv tmux a -d
    # /usr/local/bin/mosh --ssh="ssh -i ~/.ssh/id_rsa -p 7722" zibu@104.128.69.20
end

function ver
    #ve relocated
    source $VIRTUALENV_HOME/$argv/bin/activate.fish
end

function mkve
    python3 -m venv $VIRTUALENV_HOME/$argv
    ln -s $VIRTUALENV_HOME/$argv env
end

function svc
    sudo supervisorctl $argv
end

switch (uname)
    case Linux
        set -gx VIRTUALENV_HOME ~/lib/virtualenv/
        # function ttf
        #     tc (t tasks-list | fzf)
        # end

        set --local manpath_list ~/bin $JAVA_HOME/bin /snap/bin/ $PATH 
        # set --local manpath_list ~/bin $JAVA_HOME/bin /snap/bin/ /home/dersu/.fzf/bin /usr/local/sbin /usr/local/bin /usr/sbin /usr/bin /sbin /bin 
        set --local manpath_sorted
        for i in $manpath_list
            if not contains $i $manpath_sorted
                set manpath_sorted $manpath_sorted $i
            end
        end
        set -gx PATH $manpath_sorted
        function ttstart
            svc start driller
        end
        function ttstop
            svc stop driller
        end
    case Darwin

        set -gx VIRTUALENV_HOME /Users/dersu/NoBackup/virtualenv/
        # tct (tc tc list --flat | fzf)
        # function ttf
        #     tc (t tasks-list | fzf)
        # end

        function ttstart
            launchctl load  /Users/dersu/Library/LaunchAgents/dersu.timecounter.plist
        end
        function ttstop
            launchctl unload  /Users/dersu/Library/LaunchAgents/dersu.timecounter.plist
        end
        function mipc
            # open 'smb://guest:guest@10.1.0.2/inbox'
            open 'smb://guest:guest@10.1.0.2/'
        end
        function bdso_bd
            cd /Users/dersu/Projects/201908.BDSO/repo
            ve
            python main.py ful_auto_baidu
        end

        function webdav
            ~/bin/webdav/webdav -c ~/bin/webdav/config.yaml
        end

        # set -gx GOPATH ~/Data/Personal-project/go/

        set -gx JAVA_HOME /Library/Java/JavaVirtualMachines/jdk/Contents/Home
        # set -gx JAVAFX_HOME /Library/Java/JavaVirtualMachines/javafx
        # set -gx JAVAFX_LIB $JAVAFX_HOME/lib
        set -gx CLASSPATH $JAVA_HOME/lib/tools.jar:$JAVA_HOME/lib/dt.jar:.
        set --local manpath_list ~/bin /usr/local/opt/coreutils/libexec/gnubin /usr/local/sbin /usr/local/bin /usr/local/opt/ruby/bin /usr/local/opt/sqlite/bin $JAVA_HOME/bin $PATH 
        # set --local manpath_list ~/bin /usr/local/sbin /usr/local/opt/coreutils/libexec/gnubin /usr/local/opt/openssl@1.1/bin /usr/local/opt/sqlite/bin /usr/local/opt/sphinx-doc/bin /usr/local/bin/ /usr/local/opt/mysql@5.7/bin $JAVA_HOME/bin $PATH 
        set --local manpath_sorted
        for i in $manpath_list
            if not contains $i $manpath_sorted
                set manpath_sorted $manpath_sorted $i
            end
        end
        set -gx PATH $manpath_sorted

        set -gx MANPATH /usr/local/opt/coreutils/libexec/gnuman $MANPATH

        test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

        # status --is-interactive; and source (pyenv init -|psub)
        #
    case FreeBSD NetBSD DragonFly
        echo Hi Beastie!
    case '*'
        echo Hi, stranger!
end
# remove duplicates from the list

#set -g fish_user_paths "/usr/local/opt/node@6/bin" $fish_user_paths
#set -x LDFLAGS  -L/usr/local/opt/node@6/lib
#set -x CPPFLAGS -I/usr/local/opt/node@6/include
#
# set -gx LDFLAGS "-L/usr/local/opt/sqlite/lib"
# set -gx CPPFLAGS "-I/usr/local/opt/sqlite/include"
# set -gx PKG_CONFIG_PATH "/usr/local/opt/sqlite/lib/pkgconfig"
#
# set -gx LDFLAGS "-L/usr/local/opt/openssl@1.1/lib"
# set -gx CPPFLAGS "-I/usr/local/opt/openssl@1.1/include"
# set -gx PKG_CONFIG_PATH "/usr/local/opt/openssl@1.1/lib/pkgconfig"

# eval (thefuck --alias | tr '\n' ';')

# fish git prompt
set __fish_git_prompt_showdirtystate 'yes'
set __fish_git_prompt_showstashstate 'yes'
set __fish_git_prompt_showupstream 'yes'
set __fish_git_prompt_color_branch yellow
# set __fish_git_prompt_showuntrackedfiles 'yes'

set -g __fish_git_prompt_color_branch yellow
set -g __fish_git_prompt_color_upstream_ahead green
set -g __fish_git_prompt_color_upstream_behind red

# Status Chars
set __fish_git_prompt_char_dirtystate '⚡'
set __fish_git_prompt_char_stagedstate '→'
set __fish_git_prompt_char_stashstate '↩'
set __fish_git_prompt_char_conflictedstate "✖"
set __fish_git_prompt_char_upstream_ahead '↑'
set __fish_git_prompt_char_upstream_behind '↓'
set __fish_git_prompt_char_cleanstate "✔"
# set __fish_git_prompt_char_untrackedfiles '☡'
#
# kitty + complete setup fish | source
 
function fish_prompt
        if [ $RANGER_LEVEL ]
            printf '[Ranger]'
        end

        set last_status $status
        set_color $fish_color_cwd
        printf '%s:' (hostname)
        printf '%s' (prompt_pwd)
        set_color normal
        printf '%s ' (__fish_git_prompt)
        set_color normal
end

