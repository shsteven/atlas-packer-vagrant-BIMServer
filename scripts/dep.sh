#!/bin/bash
#
# Setup the the box. This runs as root

apt-get -y update

apt-get -y install curl

# You can install anything you need here.

#	Install java jre and some helpers
apt-get -y install openjdk-7-jre-headless adduser ntpdate tzdata wget

#Set timezone and time
rm -rf /etc/timezone
echo "America/Los_Angeles" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata
ntpdate 0.nl.pool.ntp.org

# Create directories / users
#
# Command	Description
mkdir /var/www	#Create a /var/www directory if it’s not already there
mkdir /var/www/BIM	#Create a directory for you domain
useradd -s /sbin/nologin tomcat8	#Create a tomcat8 user
chown -R tomcat8 /var/www/BIM #Give rights to tomcat8 user to write
mkdir /var/bimserver	#Create a directory for you BIMserver home directory (this has nothing to do with /home on unix systems
chown -R tomcat8 /var/bimserver	#Give the appropriate rights to the tomcat8 user

## Install tomcat8 from apache (no .deb package for it yet)
# INSTALL TOMCAT8
#
cd /opt
wget -nv http://www.eu.apache.org/dist/tomcat/tomcat-8/v8.0.30/bin/apache-tomcat-8.0.30.zip -O tomcat8.zip
# * you can install and config tomcat8 using deployer
unzip tomcat8.zip
rm tomcat8.zip
chmod +x /opt/tomcat8/bin/*.sh
mkdir /opt/tomcat8/conf/policy.d
# paste the following code
echo """grant {
    permission java.security.AllPermission;
  };""" > /opt/tomcat8/conf/policy.d/default.policy

chown -R tomcat8 /opt/tomcat8

# Also add a new host, see below.
#
# Change the port attribute in the Connector tag to the desired port (also see: “Running op ports below 1024”.

echo '''<Host name="BIM" appBase="/var/www/BIM" unpackWARs="true" autoDeploy="true" xmlValidation="false" xmlNamespaceAware="false">
     <Context path="" docBase="/var/www/BIM/ROOT.war">
         <Parameter name="homedir" value="/var/bimserver/home"/>
     </Context>
</Host>''' >> /opt/tomcat8/conf/server.xml

# Tomcat startup script
# To be able to starts/stop/restart tomcat8 u need an init.d script. You can find one [https://gist.github.com/baylisscg/942150 here].
# Copy this file to /etc/init.d/tomcat8 and give it execute permissions (chmod +x /etc/init.d/tomcat8).
#
# vim /etc/init.d/tomcat8
# change them acc. to you config
#
# CATALINA_HOME=/opt/$NAME
# CATALINA_BASE=/opt/$NAME
# TOMCAT8_SECURITY=no // You can change this to yes later on
# JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/jre
# * check your JAVA_HOME before that.
#  $Javac
# if JAVA_HOME is not set then
#
# You can set your JAVA_HOME in /etc/profile But the preferred location for JAVA_HOME or any system variable is /etc/environment.
#
# Open vim /etc/environment
#
# JAVA_HOME="/usr/lib/jvm/open-jdk" (java path could be different)
#
# Use source to load the variables, by running this command:
#
#source /etc/environment
# Then check the variable, by running this command:
#
# echo $JAVA_HOME

# Get modified tomcat8 init.d script from GitHub gist
wget -nv https://gist.githubusercontent.com/dspeckhard/d0359929841ca7d20356/raw/8bd9ad14e1e3768f6872b678ce7c28a1f713a187/tomcat8 -O /etc/init.d/tomcat8
chmod +x /etc/init.d/tomcat8

# Restart Tomcat:
service tomcat8 restart


cd /var/www/BIM

# Download the latest BIMserver (Make sure you replace this with the latest version!)
wget -nv https://github.com/opensourceBIM/BIMserver/releases/download/1.4.0-FINAL-2015-11-04/bimserver-1.4.0-FINAL-2015-11-04.war -O ROOT.war
chown tomcat8 ROOT.war

# start tomcat7
service tomcat8 restart
