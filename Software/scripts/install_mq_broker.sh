#!/bin/bash

if [ -d "/opt/apache-activemq" ]; then 
	echo "Active MQ Already installed. Delete /opt/apache-activemq if you want to re-install."
	exit 0
fi



echo "Installing dependencies..."

sudo apt -y install libapr1-dev
sudo apt -y install libcppunit-dev
sudo apt -y install doxygen
sudo apt -y install e2fsprogs
sudo apt -y install maven

echo "Download and save actiemq broker to this location. https://activemq.apache.org/components/classic/download/"
echo "Extracting Activemq Broker..."

tar -zxvf apache-activemq-6.1.4-bin.tar.gz

mv apache-activemq-6.1.4 apache-activemq

sudo mv apache-activemq /opt

echo "Successfully Installed Active MQ! in /opt"
