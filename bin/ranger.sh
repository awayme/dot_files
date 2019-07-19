#!/bin/bash

# EDITOR="vimr"
# export EDITOR

cd ~/bin/ranger/
echo -ne "\033]0;ranger.py\007"
python3 ranger.py ~
# /Users/dersu/bin/env/bin/python bin/ranger.py ~
