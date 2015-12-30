#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y update

apt-get -y install curl

# You can install anything you need here.

#	Install JRE 7 and Tomcat7, plus ntpdate
apt-get -y install openjdk-8-jre-headless tomcat8 ntpdate tzdata wget

#Set timezone and time
rm -rf /etc/timezone
echo "America/Los_Angeles" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
ntpdate 0.nl.pool.ntp.org

#Create a directory for you BIMserver home directory (this has nothing to do with /home on unix systems
mkdir /var/bimserver
#Give the appropriate rights to the tomcat7 user
chown -R tomcat8 /var/bimserver

#	Go to tomcat folder
cd /var/lib/tomcat8/webapps

# Get rid of "default" webapp
rm -rf ROOT/

# Download the latest BIMserver (Make sure you replace this with the latest version!)
wget https://github.com/opensourceBIM/BIMserver/releases/download/1.4.0-FINAL-2015-11-04/bimserver-1.4.0-FINAL-2015-11-04.war -O ROOT.war
chown tomcat8 ROOT.war

# start tomcat7
service tomcat8 restart
