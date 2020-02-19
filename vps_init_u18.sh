#!/bin/bash

echo 'Run this script as ROOT'

read -p "Setup sshd?" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    sed -i 's/^Port [0-9]*$/Port 7722/g' /etc/ssh/sshd_config
    # sed -i 's/^#RSAAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config
    # sed -i 's/^#PubkeyAuthentication yes/RSAAuthentication yes/g' /etc/ssh/sshd_config
    # sed -i 's/^#AuthorizedKeysFile.*%h\/\.ssh\/authorized_keys/AuthorizedKeysFile %h\/\.ssh\/authorized_keys/g' /etc/ssh/sshd_config
    # sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    # sed -i 's/^#\?PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config
    # sed -i 's/^PermitEmptyPasswords yes/PermitEmptyPasswords no/g' /etc/ssh/sshd_config

    diff /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

    systemctl restart sshd
fi

read -p "Configure location?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    #echo 'en_US.UTF-8 UTF-8' >> /var/lib/locales/supported.d/local
    #echo 'en_US ISO-8859-1' >> /var/lib/locales/supported.d/local
    #echo 'en_US.ISO-8859-15 ISO-8859-15' >> /var/lib/locales/supported.d/local
    #echo 'zh_CN.GB18030 GB18030' >> /var/lib/locales/supported.d/local
    #echo 'zh_CN.GBK GBK' >> /var/lib/locales/supported.d/local
    #echo 'zh_CN.UTF-8 UTF-8' >> /var/lib/locales/supported.d/local
    #echo 'zh_CN GB2312' >> /var/lib/locales/supported.d/local
    #locale-gen --purge

    dpkg-reconfigure locales
    dpkg-reconfigure tzdata
fi


read -p "install softwares?" -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
    sudo apt-get update
    sudo apt-get install -y python-dev python-lxml supervisor git htop multitail tmux software-properties-common libffi-dev libssl-dev libmysqlclient-dev build-essential atool p7zip-full curl python3-venv virtualenv ruby ruby-dev trash-cli
    # vim-gtk3 nodejs-dev node-gyp 
    # sudo apt-get install -y npm 

    add-apt-repository -y ppa:keithw/mosh
    add-apt-repository -y ppa:nginx/stable
    #add-apt-repository -y ppa:chris-lea/redis-server
    apt-get -y update
    apt-get install -y mosh
    apt-get install -y nginx-full
    #apt-get install -y redis-server

    #cd /etc/redis/redis.conf /etc/redis/redis.conf.bak
    #mv redis.conf /etc/redis/
    #chown redis:redis /etc/redis/redis.conf
    #systemctl restart redis-server

    apt-get -y upgrade
    apt-get -y autoremove

    #systemctl restart cron
fi

echo 'edit hostname: /etc/hostname'
echo 'edit hostname: /etc/hosts'

