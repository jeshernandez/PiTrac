#!/bin/bash


CONFIG_FILE="/boot/firmware/config.txt"
SPI_LINE_ON="dtparam=spi=on"
SPI_LINE_OFF="dtparam=spi=off"


install_lgpio() {

echo "Download LGPIO..."
	cd work_dir
	wget http://abyz.me.uk/lg/lg.zip
unzip lg.zip
cd lg

echo "Make LGPIO..."
make
sudo make install

# .. to work_dir
cd .. 
# .. to Dev
cd ..

}

copy_lgpio_pc() {

# Copy lgpio.pc from assets 

echo "Copy lgpio.pc to /usr/lib/pkgconfig"

sudo cp assets/lgpio.pc /usr/lib/pkgconfig/

if [ -f "/usr/lib/pkgconfig/lgpio.pc" ]; then
	echo "Successfully copied lgpio.pc to /usr/lib/pkgconfig"
else
	echo "Issue copying lgpio.pc to /usr/lib/pkgconfig"
	exit 0
fi

}

enable_spi() {

echo "Attemping to enable SPI pins.."

# 1. Replace 'off' with 'on' if it exists
if grep -q "^${SPI_LINE_OFF}" "$CONFIG_FILE"; then
  echo "Found SPI disabled in $CONFIG_FILE. Enabling it..."
  sudo sed -i "s/^${SPI_LINE_OFF}/${SPI_LINE_ON}/" "$CONFIG_FILE"
elif ! grep -q "^${SPI_LINE_ON}" "$CONFIG_FILE"; then
  # 2. Add 'on' line if not present at all
  echo "Adding SPI enable line to $CONFIG_FILE..."
  echo "$SPI_LINE_ON" | sudo tee -a "$CONFIG_FILE" > /dev/null
else
  echo "SPI already enabled in $CONFIG_FILE"
fi

# 3. Validate that SPI devices are available
if [ -e /dev/spidev0.0 ] && [ -e /dev/spidev0.1 ]; then
  echo "SPI devices found: /dev/spidev0.0 and /dev/spidev0.1"
  echo "Successfully installed and configured LGPIO!! DONE!"
else
  echo "SPI devices not found. You may need to reboot first."
  exit 1
fi
}



install_lgpio
copy_lgpio_pc
enable_spi