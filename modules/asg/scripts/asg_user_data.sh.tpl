#!/bin/bash

# Set required variables
AWS_REGION="eu-west-2"

# Fetch the first EFS File System ID
EFS_FILE_SYSTEM_ID=$(aws efs describe-file-systems \
  --region "$AWS_REGION" \
  --query 'FileSystems[0].FileSystemId' \
  --output text)

# Validate if the EFS File System ID was retrieved
if [ -z "$EFS_FILE_SYSTEM_ID" ]; then
  echo "Error: Could not retrieve the EFS File System ID. Exiting."
  exit 1
fi

# Fetch the EFS DNS name
EFS_DNS_NAME="$EFS_FILE_SYSTEM_ID.efs.$AWS_REGION.amazonaws.com"

# update the software packages on the ec2 instance 
sudo yum update -y

# install the apache web server, enable it to start on boot, and then start the server immediately
sudo yum install -y git httpd
sudo systemctl enable httpd 
sudo systemctl start httpd

# install php 8 along with several necessary extensions for wordpress to run
sudo yum install -y \
php \
php-cli \
php-cgi \
php-curl \
php-mbstring \
php-gd \
php-mysqlnd \
php-gettext \
php-json \
php-xml \
php-fpm \
php-intl \
php-zip \
php-bcmath \
php-ctype \
php-fileinfo \
php-openssl \
php-pdo \
php-tokenizer

# Install Mysql-Client 
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server 

# start and enable the mysql server
sudo systemctl start mysqld
sudo systemctl enable mysqld

# mount the efs to the html directory 
echo "$EFS_DNS_NAME:/ /var/www/html nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 0 0" | sudo tee -a /etc/fstab
sudo mount -a

# set permissions
sudo chown apache:apache -R /var/www/html
sudo chmod 755 -R /var/www/html

# restart the webserver
sudo systemctl restart httpd
sudo systemctl restart php-fpm
