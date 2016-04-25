set fisher_home ~/.local/share/fisherman
set fisher_config ~/.config/fisherman
source $fisher_home/config.fish

set -x EDITOR vim

fish_vi_mode

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

function ve
    source env/bin/activate.fish
end

function vetimecamp
    cd ~/Data/My_Scripts/Self-productive/timecamp
    ve
end

function vescrpits
    cd ~/Data/My_Scripts/scripts/
    ve
    cd scripts
end

function vespider 
    cd ~/NoSync/Projects/20150422.SpiderStack/
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
    cd ~/Data/My_Scripts/webemulator
    ve
end

function anaconda
    set -gx PATH /opt/anaconda/bin $PATH 
end

function calculator
    anaconda
    cd ~/Data/My_Scripts/notebooks
    jupyter-notebook calculator.ipynb
end

function notebook
    anaconda
    cd ~/Data/My_Scripts/notebooks
    jupyter-notebook
end

function mosht
    mosh --no-init -- $argv tmux a -d
end

set -gx PATH $PATH /usr/local/heroku/bin

# eval (thefuck --alias | tr '\n' ';')
