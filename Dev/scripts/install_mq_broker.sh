#!/bin/bash


check_if_exists() {
if [ -d "/opt/apache-activemq" ]; then 
	echo "Active MQ Already installed. Delete /opt/apache-activemq if you want to re-install."
	exit 0
fi
}


install_activemq_broker() {
echo "Installing dependencies..."

sudo apt -y install libapr1-dev
sudo apt -y install libcppunit-dev
sudo apt -y install doxygen
sudo apt -y install e2fsprogs
sudo apt -y install maven

ACTIVEMQ_VERSION="6.1.7"
FILENAME="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz"
URL="https://www.apache.org/dyn/closer.cgi?filename=/activemq/${ACTIVEMQ_VERSION}/${FILENAME}&action=download"



if [ -f "$FILENAME" ]; then
  echo "File '$FILENAME' already exists. Skipping download."
else
  echo "Downloading $FILENAME..."
  cd work_dir
  wget -O "$FILENAME" "$URL"
  
  echo "Extracting Activemq Broker..."

  tar -zxvf "apache-activemq-$ACTIVEMQ_VERSION-bin.tar.gz"

  mv "apache-activemq-$ACTIVEMQ_VERSION" apache-activemq

  sudo mv apache-activemq /opt

  cd ..
  echo "Successfully Installed Active MQ! in /opt"
  echo "Configuration of ActiveMQ coming soon...."

  if [ $? -ne 0 ]; then
    echo "Download failed!"
    exit 1
  fi
fi

}


check_if_exists
install_activemq_broker