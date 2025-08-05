#/bin/bash


install_libraries() {
echo "Installing prerequisite libraries..."

sudo apt -y install libevent-dev pybind11-dev doxygen python3-graphviz \
	python3-sphinx python3-yaml python3-ply python3-pip python3-jinja2 \
	libavdevice-dev qtbase5-dev libqt5core5a libqt5gui5 libqt5widgets5 \
        meson cmake libglib2.0-dev libgstreamer-plugins-base1.0-dev	

}


install_libcamera() {

LIBCAMERA_DIRECTORY="libcamera"


echo "Download libcamera source code..."
cd work_dir 
git clone https://github.com/raspberrypi/libcamera.git

if [ -d "$LIBCAMERA_DIRECTORY" ]; then
	# could be needed due to meson failing issue. 
	export PKEXEC_UID=99999
	cd libcamera
	echo "Meson setup build..."
	meson setup build --buildtype=release -Dpipelines=rpi/vc4,rpi/pisp -Dipas=rpi/vc4,rpi/pisp -Dv4l2=enabled -Dgstreamer=enabled -Dtest=false -Dlc-compliance=disabled -Dcam=disabled -Dqcam=disabled -Ddocumentation=disabled -Dpycamera=enabled
    echo "Building libcamera..."
    ninja -C build
    echo "Compiling and installing..."
    sudo ninja -C build install
    # return to libcamera dir
    cd ..
    # return to work_dir 
    cd ..
else 
	echo "Error cloning libcamera. Check github settings, etc."
	exit 0
fi

}

install_rpicam_apps() {
	
RPICAM_APPS_DIR=rpicam-apps

	echo "Install rpicam pre-required libraries..."
	sudo apt -y install libboost-program-options-dev libdrm-dev libexif-dev
	cd work_dir
	echo "Cloning rpicam-apps..."
    git clone https://github.com/raspberrypi/rpicam-apps.git
    
	if [ -d "$RPICAM_APPS_DIR" ]; then
		cd rpicam-apps
		echo "Compiling and installing rpicam-apps"
		meson setup build -Denable_libav=enabled -Denable_drm=enabled -Denable_egl=enabled -Denable_qt=enabled -Denable_opencv=enabled -Denable_tflite=disabled -Denable_hailo=disabled
		meson compile -C build
		sudo meson install -C build
		sudo ldconfig
		
		echo "Libcamera is installed!!"

	else
		echo "Error: Could not clone or find $RPICAM_APPS_DIR"
		exit 0
	fi

}


verify_installation() {
			
	# Extract version number (strip 'v')
	INSTALLED_VERSION=$(rpicam-still --version | grep "rpicam-apps build" | awk '{print $3}' | sed 's/^v//')
	REQUIRED_VERSION="1.5.3"

	# Compare using sort -V (version sort)
	if printf "%s\n%s\n" "$REQUIRED_VERSION" "$INSTALLED_VERSION" | sort -V -C; then
	  echo "Congrats! Version $INSTALLED_VERSION is >= $REQUIRED_VERSION"
	  exit 1
	else
	  echo "Error: Version $INSTALLED_VERSION is less than required $REQUIRED_VERSION"
	  exit 0
	fi

}

install_libraries

install_libcamera

install_rpicam_apps

verify_installation