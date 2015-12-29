#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y update

apt-get -y install curl

# You can install anything you need here.

#	Install JRE 7 and some tools
apt-get -y install openjdk-7-jre-headless ntpdate adduser

ntpdate 0.nl.pool.ntp.org

MY_DOMAIN = BCJ.COM

##Install Tomcat7
apt-get install -y tomcat7

#Create a tomcat7 user
useradd -s /sbin/nologin tomcat7

## Setup tomcat7 directories
#Create a directory for you domain
mkdir /var/www/$MY_DOMAIN
#Give rights to tomcat7 user to write
chown -R tomcat7 /var/www/$MY_DOMAIN
#Create a directory for you BIMserver home directory (this has nothing to do with /home on unix systems
mkdir /var/bimserver
#Give the appropriate rights to the tomcat7 user
chown -R tomcat7 /var/bimserver

#	Go to your domain folder
cd /var/www/$MY_DOMAIN
# Download the latest BIMserver (Make sure you replace this with the latest version!)
curl https://github.com/opensourceBIM/BIMserver/releases/download/1.4.0-FINAL-2015-11-04/bimserver-1.4.0-FINAL-2015-11-04.war -o ROOT.war

echo """
<Host name="$MY_DOMAIN" appBase="/var/www/$MY_DOMAIN" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
    <Context path="" docBase="/var/www/$MY_DOMAIN/ROOT.war">
        <Parameter name="homedir" value="/var/bimserver/home"/>
    </Context>
</Host>
""" >> /etc/tomcat7/server.xml

# start tomcat7
service tomcat7 restart
