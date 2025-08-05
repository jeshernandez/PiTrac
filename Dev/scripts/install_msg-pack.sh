#!/bin/bash
echo "Cloning msgpack..."
wget https://github.com/msgpack/msgpack-c/archive/refs/heads/cpp_master.zip
unzip cpp_master.zip -d work_dir

echo "Build and Install..."
cd work_dir/msgpack-c-cpp_master
cmake -DMSGPACK_CXX20=ON .
sudo cmake --build . --target install
sudo /sbin/ldconfig


echo "Verifying Installation..."
cd test-install
g++ -o simple simple.cpp

verify_msgpack_installation() {

expected_output="[1,true,\"example\"]"
actual_output=$(./simple)

echo "Output from msgpack simple test-install $actual_output"

if [[ "$actual_output" == "$expected_output" ]]; then
	echo "Msgpack Successfully Installed!"
	return 0
else
	echo "Error installing MSGPack"
	return 1
fi

}


verify_msgpack_installation
