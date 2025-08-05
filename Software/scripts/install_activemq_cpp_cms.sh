#!/bin/bash
echo "Installing dependency libraries for ActiveMQ C++ CMS..."
sudo apt -y install libtool
sudo apt-get -y install libssl-dev
sudo apt-get -y install libapr1-dev
sudo apt install -y libcppunit-dev
sudo apt-get install -y autoconf
sudo apt-get install -y uuid-dev
sudo apt-get install -y libcppunit-dev

git clone https://gitbox.apache.org/repos/asf/activemq-cpp.git

echo "Installing ActiveMQ c++..."
cd activemq-cpp/activemq-cpp
./autogen.sh
./configure
make
sudo make install

echo "Doxygen docs.."
make doxygen-run

echo "Unit tests (optional)..."
make check
