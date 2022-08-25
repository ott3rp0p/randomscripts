#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Run this as root"
    exit
fi

user="wordpress@localhost"
password="w0rdpr355I54ann0y1NG"
database="wordpress"

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
                 php-zip --yes
}

phpUpdate(){
	sudo sed -i 's/upload_max_filesize = 2M/upload_max_filesize = 20M/' /etc/php/8.1/apache2/php.ini
}
makeWWW(){
	sudo mkdir -p /srv/www
	sudo chown www-data: /srv/www
	curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www
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
	sudo mysql --user=root --execute="CREATE DATABASE $database;CREATE USER $user IDENTIFIED BY $password; GRANT ALL PRIVILEGES ON $database.* TO $user; FLUSH PRIVILEGES"
	sudo service mysql start.
}

wordPress(){
	sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/database_name_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i "s/password_here/$password/" /srv/www/wordpress/wp-config.php
	sudo -u www-data sed -i -e '$adefine('WP_MEMORY_LIMIT', '256M');' /srv/www/wordpress/wp-config.php 
	sudo a2ensite wordpress
	sudo a2enmod rewrite
	sudo a2dissite 000-default
	sudo service apache2 reload
}

thecartPress(){
	sudo wget https://www.exploit-db.com/apps/13ca191fd4ed373457b6f3c2cb48ba3e-thecartpress.zip
	sudo unzip *.zip
	rm *.zip
	cd /tmp;sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	sudo chmod +x wp-cli.phar
	sudo mv wp-cli.phar /usr/local/bin/wp
	cd /srv/www/wordpress; wp plugin activate thecartpress 

}

userStuff(){
	sudo useradd -s /bin/bash -p $(perl -e'print crypt("w0rdpr355I54ann0y1NG", "aa")') -m -N steve
	sudo echo -ne "steve ALL=(root) NOPASSWD: /usr/bin/vim" >> /etc/sudoers

}

updateUbuntu
makeWWW
mysqlStuff
wordPress
phpUpdate
thecartPress
userStuff

#last setup steps are manual
#create wordpress admin by browsing to the website 

###############

# Walkthrough
# nmap finds 22/80
# wordpress on 80
# wpscan finds thecartpress
# exploitdb for wordpress admin
# upload reverse shell
# get www-data
# user password in wp-config.php
# user can run vim with sudo 
# gtfobins to root