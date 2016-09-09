source /usr/share/fish/config.fish

set -x EDITOR vim
set -x LC_TIME 'en_US.UTF-8'

fish_vi_key_bindings

function tree
    find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'
end

function j
    set new_path (autojump $argv)

    if test -d "$new_path"
        echo $new_path
        cd "$new_path"
    else
        echo "autojump: directory '$argv' not found"
        echo "Try \`autojump --help\` for more information."
        false
    end
end

function v
    source (string trim -r -c / $argv[1])/bin/activate.fish
    # if set -q argv[2] 
    #     echo $argv[2]
    # end
end

function ve
    source env/bin/activate.fish
end

function vetimecamp
    cd ~/Data/scripts/Self-productive/timecamp/
    ve
end

function vescrpits
    cd ~/Data/My_Scripts/scripts/
    ve
    cd scripts
end

function vespider 
    cd ~/Data/Projects/20150422.SpiderStack/
    ve
    cd spiders/scrapyframe/scrapyframe
end

function vefabric
    cd ~/Data/Projects/20150825.fabric
    ve
end

function vezetta
    cd ~/Data/Projects/20151110.zettayun
    ve
    cd inside/Development
end

function vewebfront
    cd ~/Data/Projects/20131225.MicroawarenessWebsite/Website_v4_wagtail
    ve
    cd source
end

function veemulator
    cd ~/Data/scripts/webemulator
    ve
end

function anaconda
    set -gx PATH /opt/anaconda2/bin $PATH 
end

function calculator
    anaconda
    cd ~/Data/scripts/notebooks
    jupyter-notebook calculator.ipynb
end

function notebook
    anaconda
    cd ~/Data/scripts/notebooks
    jupyter-notebook
end

function mosht
    mosh --no-init -- $argv tmux a -d
end

set --local manpath_list ~/bin $PATH /usr/local/heroku/bin
# remove duplicates from the list
set --local manpath_sorted
for i in $manpath_list
    if not contains $i $manpath_sorted
        set manpath_sorted $manpath_sorted $i
    end
end

set -gx PATH $manpath_sorted
# set -gx PATH ~/bin $PATH /usr/local/heroku/bin
# set -gx NVIM_LISTEN_ADDRESS /tmp/nvimsocket
# set -gx SPARK_HOME /opt/spark

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
 
function fish_prompt
        set last_status $status
        set_color $fish_color_cwd
        printf '%s' (prompt_pwd)
        set_color normal
        printf '%s ' (__fish_git_prompt)
       set_color normal
end
