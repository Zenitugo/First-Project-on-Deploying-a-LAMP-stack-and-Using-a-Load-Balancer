#!/bin/bash

set -e


vagrant ssh slave <<EOF
    sudo apt -y install sshpass
    sudo apt update
    echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
    sudo apt update -y
    sudo apt install apache2 -y
    echo -e "\n\nAdding firewall rule to Apache\n"
    sudo ufw allow in "Apache"
    sudo ufw status
    echo -e "\n\nInstalling MySQL\n"
    sudo apt install mysql-server -y
    echo -e "\n\nPermissions for /var/www\n"
    sudo chown -R www-data:www-data /var/www
    echo -e "\n\n Permissions have been set\n"
    sudo apt install php libapache2-mod-php php-mysql -y
    echo -e "\n\nEnabling Modules\n"
    sudo a2enmod rewrite
    sudo phpenmod mcrypt
    sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
    echo -e "\n\nRestarting Apache\n"
    sudo systemctl reload apache2
    echo -e "\n\nLAMP Installation Completed"
    exit 0
EOF



vagrant ssh master <<EOF
    sudo useradd -m -G sudo altschool
    echo -e "ruby\nruby\n" | sudo passwd altschool
    sudo usermod -aG sudo altschool
    sudo -u altschool ssh-keygen -t rsa -b 4096 -f /home/altschool/.ssh/id_rsa -N "" 
    sudo mkdir /home/altschool/accesskeys/altschoolkey.txt
    sudo cp /home/altschool/.ssh/id_rsa.pub /home/altschool/accesskeys/keys.tex
    sudo ssh-keygen -t rsa -b 4096 -f /home/vagrant/.ssh/id_rsa -N ""
    sudo cat /home/vagrant/.ssh/id_rsa.pub | sshpass -p "vagrant" ssh -o StrictHostKeyChecking=no vagrant@192.168.56.107 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sudo cat /home/altschool/acceskeys/keys.txt | sshpass -p "vagrant" ssh vagrant@192.168.56.106 'mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys'
    sshpass -p "ruby" sudo -u altschool mkdir -p /mnt/altschool/slave
    sshpass -p "ruby" ssh -o StrictHostKeyChecking=no vagrant@192.168.56.107 "sudo -u altschool scp -r -o StrictHostKeyChecking=no -i /home/vagrant/.ssh/id_rsa -p /mnt/* /home/vagrant/mnt/"
    exit
EOF

vagrant ssh master <<EOF
    sudo apt -y install sshpass
    sudo apt update
    echo -e "\n\nUpdating Apt Packages and upgrading latest patches\n"
    sudo apt update -y
    sudo apt install apache2 -y
    echo -e "\n\nAdding firewall rule to Apache\n"
    sudo ufw allow in "Apache"
    sudo ufw status
    echo -e "\n\nInstalling MySQL\n"
    sudo apt install mysql-server -y
    echo -e "\n\nPermissions for /var/www\n"
    sudo chown -R www-data:www-data /var/www
    echo -e "\n\n Permissions have been set\n"
    sudo apt install php libapache2-mod-php php-mysql -y
    echo -e "\n\nEnabling Modules\n"
    sudo a2enmod rewrite
    sudo phpenmod mcrypt
    sudo sed -i 's/DirectoryIndex index.html index.cgi index.pl index.xhtml index.htm/DirectoryIndex index.php index.html index.cgi index.pl index.xhtml index.htm/' /etc/apache2/mods-enabled/dir.conf
    echo -e "\n\nRestarting Apache\n"
    sudo systemctl reload apache2
    echo -e "\n\nLAMP Installation Completed"
    exit 0
EOF
