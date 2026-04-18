#!/bin/bash -xe
# Run as bash
# -x = print commands as they execute
# -e = stop immediately if a command fails


# -----------------------------
# Get configuration from AWS SSM Parameter Store
# -----------------------------

EFSFSID=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/EFSFSID --query Parameters[0].Value)
EFSFSID=`echo $EFSFSID | sed -e 's/^"//' -e 's/"$//'`
# Gets the EFS File System ID and removes surrounding quotes
# NOTE: Retrieved but never used later in the script

DBPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBPassword --with-decryption --query Parameters[0].Value)
DBPassword=`echo $DBPassword | sed -e 's/^"//' -e 's/"$//'`
# Gets the WordPress DB user password from SSM (decrypted)

DBRootPassword=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBRootPassword --with-decryption --query Parameters[0].Value)
DBRootPassword=`echo $DBRootPassword | sed -e 's/^"//' -e 's/"$//'`
# Gets the MariaDB root password from SSM (decrypted)

DBUser=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBUser --query Parameters[0].Value)
DBUser=`echo $DBUser | sed -e 's/^"//' -e 's/"$//'`
# Gets the DB username

DBName=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBName --query Parameters[0].Value)
DBName=`echo $DBName | sed -e 's/^"//' -e 's/"$//'`
# Gets the DB name

DBEndpoint=$(aws ssm get-parameters --region us-east-1 --names /A4L/Wordpress/DBEndpoint --query Parameters[0].Value)
DBEndpoint=`echo $DBEndpoint | sed -e 's/^"//' -e 's/"$//'`
# Gets the database endpoint/host


# -----------------------------
# Update the server
# -----------------------------

dnf -y update
# Updates all installed packages


# -----------------------------
# Install required software
# -----------------------------

dnf install wget php-mysqlnd httpd php-fpm php-mysqli mariadb105-server php-json php php-devel stress amazon-efs-utils -y
# Installs:
# - Apache web server
# - PHP and MySQL/MariaDB PHP modules
# - MariaDB server
# - wget
# - stress tool
# - EFS utilities


# -----------------------------
# Enable and start services
# -----------------------------

systemctl enable httpd
systemctl enable mariadb
# Enable Apache and MariaDB to start on boot

systemctl start httpd
systemctl start mariadb
# Start Apache and MariaDB now


# -----------------------------
# Secure local MariaDB root account
# -----------------------------

mysqladmin -u root password $DBRootPassword
# Sets the local MariaDB root password


# -----------------------------
# Download and install WordPress
# -----------------------------

wget http://wordpress.org/latest.tar.gz -P /var/www/html
# Download latest WordPress tarball into web root

cd /var/www/html
tar -zxvf latest.tar.gz
# Extract WordPress

cp -rvf wordpress/* .
# Copy extracted WordPress files into /var/www/html

rm -R wordpress
rm latest.tar.gz
# Clean up extracted folder and archive


# -----------------------------
# Configure WordPress database settings
# -----------------------------

sudo cp ./wp-config-sample.php ./wp-config.php
# Create WordPress config from sample

sed -i "s/'database_name_here'/'$DBName'/g" wp-config.php
sed -i "s/'username_here'/'$DBUser'/g" wp-config.php
sed -i "s/'password_here'/'$DBPassword'/g" wp-config.php
sed -i "s/'localhost'/'$DBEndpoint'/g" wp-config.php
# Replace default DB settings with values from SSM


# -----------------------------
# Set permissions for Apache/EC2 user access
# -----------------------------

usermod -a -G apache ec2-user
# Add ec2-user to apache group

chown -R ec2-user:apache /var/www
# Set ownership of web files

chmod 2775 /var/www
# Set permissions on /var/www and preserve group ownership on new files/dirs

find /var/www -type d -exec chmod 2775 {} \;
# Set directory permissions

find /var/www -type f -exec chmod 0664 {} \;
# Set file permissions


# -----------------------------
# Create local MariaDB database and user
# -----------------------------

echo "CREATE DATABASE $DBName;" >> /tmp/db.setup
echo "CREATE USER '$DBUser'@'localhost' IDENTIFIED BY '$DBPassword';" >> /tmp/db.setup
echo "GRANT ALL ON $DBName.* TO '$DBUser'@'localhost';" >> /tmp/db.setup
echo "FLUSH PRIVILEGES;" >> /tmp/db.setup
# Build SQL commands in a temp file

mysql -u root --password=$DBRootPassword < /tmp/db.setup
# Run SQL commands against local MariaDB

rm /tmp/db.setup
# Delete temp SQL file