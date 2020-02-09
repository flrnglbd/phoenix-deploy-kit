#!/bin/env bash

# Add user to deploy the app
adduser deploy

# Create home directory of the user `deploy` to store ssh informations
# And add the proper ACL
sudo mkdir -p /home/deploy/.ssh
sudo touch /home/deploy/.ssh/authorized_keys
sudo chmod 700 /home/deploy/.ssh
sudo chmod 644 /home/deploy/.ssh/authorized_keys
sudo chown -R deploy:deploy /home/deploy

# need to check manually if the PasswordAuthentication is commented or with the value 'no at'
# TODO script it
vim /etc/ssh/ssh_config

# add the proper sudo right to the user `deploy`
export EDITOR=vim
# TODO script it 
visudo # add after root in `User privilege spec`: deploy  ALL=(ALL) NOPASSWD: ALL

# Add in the /home/deploy/.ssh/authorized_keys the generated key during the creation of the computer cloud instance.
# OSX copy it with cat /path/to/key/<name>.pub |pbcopy
# Linux copy it with cat /path/to/key/<name>.pub | xclip -selection clipboard

# TODO script it
vim /home/deploy/.ssh/authorized_keys # paste the content in it



su deploy

# AS user `deploy`
cd

# Install asdf to manage runtime version of erlang, elixir, nodejs
git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.7.6
echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc
echo -e '\n. $HOME/.asdf/completions/asdf.bash' >> ~/.bashrc
. ~/.bashrc

# Update package manager
sudo apt update
sudo apt -y upgrade

# Install common dependencies of asdf plugins
sudo apt -y install automake autoconf libreadline-dev libncurses-dev libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev unzip curl

#########################################################
# Add Erlang plugin
asdf plugin-add erlang https://github.com/asdf-vm/asdf-erlang.git
# Install dependencies of Erlang plugin
sudo apt install -y automake autoconf libreadline-dev libncurses-dev \
    libssl-dev libyaml-dev libxslt-dev libffi-dev libtool unixodbc-dev \
    libwxgtk3.0-dev libgl1-mesa-dev  libglu1-mesa-dev libssh-dev xsltproc fop \
erlang_latest=$(asdf list-all erlang | tail -1)

# Skip java dependencies
export KERL_CONFIGURE_OPTIONS="--disable-debug --without-javac"

# Install plugin
asdf install erlang $erlang_latest
# In case of a crash during the installation of erlang 
# Add swap for the current session
sudo fallocate -l 1G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Set globally the runtime version
asdf global erlang $erlang_latest

#########################################################
# Add Elixir plugin
asdf plugin-add elixir https://github.com/asdf-vm/asdf-elixir.git

# Plugin dependencies
sudo apt -y install unzip

# Install plugin
asdf install elixir 1.10.0

# Set globally the runtime version
asdf global elixir 1.10.0

#########################################################
# Add Nodejs plugin
asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git

# Plugin dependencies
sudo apt install -y dirmngr gpg

# Import the Node.js release team's OpenPGP keys to main keyring
bash ~/.asdf/plugins/nodejs/bin/import-release-team-keyring

# Install plugin
asdf install nodejs 12.14.1

# Set globally the runtime version
asdf global nodejs 12.14.1

#########################################################
#########################################################
# Use mix to install hex
mix local.hex

#########################################################
# Setup environment variable
echo "export MIX_ENV=prod" >> ~/.profile
echo "export PORT=4000" >> ~/.profile

# TODO nginx, Secure Shared Memory, Install fail2ban, Activating the firewall, remove root access, manage to have the CD make hot update of the server, may *remove ssh access


