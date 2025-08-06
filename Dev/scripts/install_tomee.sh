#!bin/bash

install_tomee() {


TOMEE_VERSION="10.1.0"
FILE_NAME="apache-tomee-$TOMEE_VERSION-plume.zip"
URL="https://dlcdn.apache.org/tomee/tomee-$TOMEE_VERSION/$FILE_NAME"

echo "Download Tomee version $TOMEE_VERSION"

if [ -f "$FILE_NAME" ]; then
  echo "File '$FILE_NAME' already exists. Skipping download."
else
  echo "Downloading file $FILE_NAME..."
  cd work_dir
  wget -O "$FILE_NAME" "$URL"
  echo "Unzipping..."
  unzip "$FILE_NAME"
  
  echo "Installing..."
  mv "apache-tomee-plume-$TOMEE_VERSION" tomee
  sudo mv tomee /opt
fi

}


validate_installation() {
	
if [ -d "/opt/tomee" ]; then
	echo "Successfully installed Tomee!!"
else 
	echo "Error: Failure to install Tomee."
fi
	
}

install_tomee
validate_installation