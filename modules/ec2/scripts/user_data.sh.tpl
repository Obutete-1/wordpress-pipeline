#!/bin/bash

# Set required variables
AWS_REGION="eu-west-2"
DB_INSTANCE_IDENTIFIER="wordpress-db"

# Fetch the Secrets Manager secret ARN associated with the RDS instance
DB_SECRET_ARN=$(aws rds describe-db-instances \
  --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
  --region "$AWS_REGION" \
  --query 'DBInstances[0].MasterUserSecret.SecretArn' \
  --output text)

# Check if the secret ARN was found
if [ -z "$DB_SECRET_ARN" ]; then
  echo "Error: Could not find the secret ARN for the RDS instance. Exiting."
  exit 1
fi

# Fetch the RDS password from Secrets Manager
DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id "$DB_SECRET_ARN" \
  --region "$AWS_REGION" \
  --query 'SecretString' \
  --output text | jq -r '.password')

# Validate if the password was retrieved
if [ -z "$DB_PASSWORD" ]; then
  echo "Error: Could not retrieve the RDS password from Secrets Manager. Exiting."
  exit 1
fi

# Fetch RDS instance metadata
RDS_METADATA=$(aws rds describe-db-instances \
  --db-instance-identifier "$DB_INSTANCE_IDENTIFIER" \
  --region "$AWS_REGION" \
  --query 'DBInstances[0]' \
  --output json)

# Parse metadata for required values
DB_NAME=$(echo "$RDS_METADATA" | jq -r '.DBName')
DB_USER=$(echo "$RDS_METADATA" | jq -r '.MasterUsername')
DB_HOST=$(echo "$RDS_METADATA" | jq -r '.Endpoint.Address')

# Validate if metadata values were retrieved
if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ] || [ -z "$DB_HOST" ]; then
  echo "Error: Could not retrieve all required RDS metadata. Exiting."
  exit 1
fi

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

# Update the package repository
sudo yum update -y

# Create /var/www/html directory
sudo mkdir -p /var/www/html

# Mount EFS
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport "$EFS_DNS_NAME":/ /var/www/html

# Install Apache
sudo yum install git httpd -y

# Install PHP and dependencies
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
php-soap \
php-tokenizer

# Install MySQL Client
sudo wget https://dev.mysql.com/get/mysql80-community-release-el9-1.noarch.rpm 
sudo dnf install mysql80-community-release-el9-1.noarch.rpm -y
sudo rpm --import https://repo.mysql.com/RPM-GPG-KEY-mysql-2023
sudo dnf repolist enabled | grep "mysql.*-community.*"
sudo dnf install -y mysql-community-server 

# Start and enable services
sudo systemctl start httpd
sudo systemctl enable httpd
sudo systemctl start mysqld
sudo systemctl enable mysqld

# Set permissions
sudo usermod -aG apache ec2-user
sudo chown -R ec2-user:apache /var/www
sudo chmod 2775 /var/www && find /var/www -type d -exec sudo chmod 2775 {} \;
sudo find /var/www -type f -exec sudo chmod 0664 {} \;
sudo chown apache:apache -R /var/www/html 

# Download and configure WordPress
cd /tmp
wget https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
sudo cp -r wordpress/* /var/www/html/

# Configure wp-config.php
sudo cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php

# Define an associative array with configuration key-value pairs
sudo sed -i "s/define( 'DB_NAME', '.*' );/define( 'DB_NAME', '$DB_NAME' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_USER', '.*' );/define( 'DB_USER', '$DB_USER' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_PASSWORD', '.*' );/define( 'DB_PASSWORD', '$DB_PASSWORD' );/" /var/www/html/wp-config.php
sudo sed -i "s/define( 'DB_HOST', '.*' );/define( 'DB_HOST', '$DB_HOST' );/" /var/www/html/wp-config.php

# Restart PHP-FPM and HTTPD
sudo systemctl restart php-fpm
sudo systemctl restart httpd
