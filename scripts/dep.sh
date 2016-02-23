#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y update

apt-get -y install curl

# You can install anything you need here.

#	Install some helpers
apt-get -y install adduser ntpdate tzdata wget

#Set timezone and time
rm -rf /etc/timezone
echo "America/Los_Angeles" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
ntpdate 0.nl.pool.ntp.org

#install java JRE from PPA
sudo add-apt-repository ppa:openjdk-r/ppa -y
sudo apt-get update
sudo apt-get install openjdk-8-jre-headless -y

# Create directories / users
useradd -s /sbin/nologin tomcat8	#Create a tomcat8 user
mkdir /var/bimserver	#Create a directory for you BIMserver home directory (this has nothing to do with /home on unix systems
chown -R tomcat8 /var/bimserver	#Give the appropriate rights to the tomcat8 user

## Install tomcat8 from apache (no .deb package for it yet)
# INSTALL TOMCAT8
#
cd /opt
wget -nv http://www.eu.apache.org/dist/tomcat/tomcat-8/v8.0.32/bin/apache-tomcat-8.0.32.zip -O tomcat8.zip
# * you can install and config tomcat8 using deployer
unzip -q tomcat8.zip
rm tomcat8.zip
mv apache-tomcat-8.0.32 tomcat8
chmod +x /opt/tomcat8/bin/*.sh
mkdir /opt/tomcat8/conf/policy.d
# paste the following code
echo """grant {
    permission java.security.AllPermission;
  };""" > /opt/tomcat8/conf/policy.d/default.policy

chown -R tomcat8 /opt/tomcat8

# Tomcat startup script
# Get modified tomcat8 init.d script from GitHub gist
wget -nv https://gist.githubusercontent.com/dspeckhard/d0359929841ca7d20356/raw/8bd9ad14e1e3768f6872b678ce7c28a1f713a187/tomcat8 -O /etc/init.d/tomcat8
chmod +x /etc/init.d/tomcat8

# Restart Tomcat:
service tomcat8 restart

cd /opt/tomcat8/webapps

# Download the latest BIMserver (Make sure you replace this with the latest version!)
wget -nv https://github.com/opensourceBIM/BIMserver/releases/download/1.4.0-FINAL-2015-11-04/bimserver-1.4.0-FINAL-2015-11-04.war -O BIM.war
chown tomcat8 BIM.war

# start tomcat7
service tomcat8 restart
