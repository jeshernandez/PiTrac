#/bin/bash

download_opencv_script() {
echo "Download the script..."

wget https://github.com/Qengineering/Install-OpenCV-Raspberry-Pi-64-bits/raw/main/OpenCV-4-11-0.sh

chmod +x OpenCV-4-11-0.sh

mv OpenCV-4-11-0.sh work_dir

}

modify_opencv() {

echo "Editing Opencv script..."

OPENCV_SCRIPT="./work_dir/OpenCV-4-11-0.sh"

echo "Enable INSTALL_C_EXAMPLES..."
sed -i 's/-D INSTALL_C_EXAMPLES=OFF/-D INSTALL_C_EXAMPLES=ON/' "$OPENCV_SCRIPT"

echo "Enable INSTALL_PYTHON_EXAMPLES..."
sed -i 's/-D INSTALL_PYTHON_EXAMPLES=OFF/-D INSTALL_PYTHON_EXAMPLES=ON/' "$OPENCV_SCRIPT"

}

run_opencv_script() {
echo "Installing OpenCV-4-11-0.sh..."
./work_dir/OpenCV-4-11-0.sh
}


download_opencv_script

modify_opencv

run_opencv_script
