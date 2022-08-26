#!/bin/bash

echo "Installing some crap"

apt-get update 1>/dev/null

apt-get install chromium 1>/dev/null

wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add - 1>/dev/null
echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list 1>/dev/null
sudo apt-get update 1>/dev/null
sudo apt-get install sublime-text 1>/dev/null

apt-get install python3 python3-pip python3-dev git libssl-dev libffi-dev build-essential 1>/dev/null
python3 -m pip install --upgrade pip 1>/dev/null
python3 -m pip install --upgrade pwntools 1>/dev/null

python3 -m pip install --user xortool 1>/dev/null

apt-get install steghide 1>/dev/null
apt-get install stegsolve 1>/dev/null
apt-get install torbrowser-launcher 1>/dev/null
apt-get install exiftool 1>/dev/null
apt-get install foremost 1>/dev/null
apt-get install binwalk 1>/dev/null
